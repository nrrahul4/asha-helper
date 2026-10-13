import 'dart:io';
import 'dart:math';

import 'package:family_tracker/data/database/app_database.dart';
import 'package:family_tracker/data/models/backup_snapshot.dart';
import 'package:family_tracker/data/repositories/local_backup_repository.dart';
import 'package:family_tracker/features/backup/domain/encrypted_backup_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory temporaryDirectory;
  late AppDatabase appDatabase;
  late LocalBackupRepository repository;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'family_tracker_backup_test_',
    );
    appDatabase = AppDatabase(
      path: '${temporaryDirectory.path}/family_tracker.db',
      encryptionKey: 'test-only-encryption-key',
      opener: _openFfiDatabase,
    );
    repository = LocalBackupRepository(appDatabase);
    final db = await appDatabase.database;
    await db.insert('household', _household('home-one'));
    await db.insert('member', _member('member-one', 'home-one'));
    await db.insert('member_general_detail', {
      'member_id': 'member-one',
      'aadhaar_number': '123456789012',
      'education_level': 'Graduate',
      'updated_at': '2025-01-01T00:00:00.000Z',
    });
  });

  tearDown(() async {
    await appDatabase.close();
    await temporaryDirectory.delete(recursive: true);
  });

  test('encrypted backup round trips the full snapshot', () async {
    final service = EncryptedBackupService(random: Random(1));
    final snapshot = await repository.capture();
    final bytes = await service.encrypt(snapshot, 'long-test-passphrase');

    expect(utf8Decode(bytes), contains(EncryptedBackupService.magic));
    final restored = await service.decrypt(bytes, 'long-test-passphrase');
    expect(restored.householdCount, 1);
    expect(restored.memberCount, 1);
    expect(
      restored.tables['member_general_detail']!.single['aadhaar_number'],
      '123456789012',
    );
  });

  test('wrong passphrase and modified ciphertext are rejected', () async {
    final service = EncryptedBackupService(random: Random(2));
    final bytes = await service.encrypt(
      await repository.capture(),
      'long-test-passphrase',
    );

    await expectLater(
      service.decrypt(bytes, 'another-long-passphrase'),
      throwsA(isA<BackupAuthenticationException>()),
    );
    final modified = List<int>.from(bytes)..[bytes.length - 1] ^= 1;
    await expectLater(
      service.decrypt(modified, 'long-test-passphrase'),
      throwsA(isA<BackupAuthenticationException>()),
    );
  });

  test('merge preserves local ID conflicts and adds new records', () async {
    final snapshot = await repository.capture();
    final db = await appDatabase.database;
    await db.update('household', {
      'house_name': 'Kept local value',
    }, where: "household_id = 'home-one'");
    final secondHousehold = _household('home-two');
    final secondMember = _member('member-two', 'home-two');
    final tables = {
      for (final entry in snapshot.tables.entries)
        entry.key: List<Map<String, Object?>>.from(entry.value),
    };
    tables['household']!.add(secondHousehold);
    tables['member']!.add(secondMember);
    final backup = snapshotWith(tables);
    final preview = await repository.preview(backup);
    expect(preview.householdIdConflicts, 1);
    expect(preview.memberIdConflicts, 1);

    final result = await repository.restore(backup, BackupRestoreMode.merge);
    expect(result.skippedRows, greaterThanOrEqualTo(2));
    expect(await db.query('household'), hasLength(2));
    expect(await db.query('member'), hasLength(2));
    expect(
      (await db.query(
        'household',
        where: "household_id = 'home-one'",
      )).single['house_name'],
      'Kept local value',
    );
  });

  test('replace restores all data transactionally', () async {
    final snapshot = await repository.capture();
    final db = await appDatabase.database;
    await db.insert('household', _household('local-only'));

    await repository.restore(snapshot, BackupRestoreMode.replace);
    expect(await db.query('household'), hasLength(1));
    expect((await db.query('household')).single['household_id'], 'home-one');
    expect(await db.query('member'), hasLength(1));
    expect(await db.query('member_general_detail'), hasLength(1));
  });

  test('CSV export contains only selected non-health fields', () async {
    final db = await appDatabase.database;
    await db.insert(
      'member',
      _member('member-two', 'home-one', isHead: false, relationship: 'son'),
    );
    await db.update('member', {
      'full_name': 'Person, "One"',
    }, where: "member_id = 'member-one'");
    final csv = await repository.exportCsv(
      {CsvExportField.householdName, CsvExportField.memberName},
      householdIds: {'home-one'},
      headers: {
        CsvExportField.householdName: 'Household',
        CsvExportField.memberName: 'Member',
      },
    );

    expect(csv, contains('"Household","Member"'));
    expect(csv, contains('"Original home","Person, ""One"""'));
    expect(csv, isNot(contains('123456789012')));
    expect(csv, isNot(contains('Aadhaar')));
    expect(csv, isNot(contains('pregnancy')));

    final explicitlySelectedSensitiveCsv = await repository.exportCsv(
      {CsvExportField.aadhaar, CsvExportField.pregnancyLastMenses},
      householdIds: {'home-one'},
      headers: {
        CsvExportField.aadhaar: 'Aadhaar',
        CsvExportField.pregnancyLastMenses: 'LMP',
      },
    );
    expect(explicitlySelectedSensitiveCsv, contains('"Aadhaar","LMP"'));
    expect(explicitlySelectedSensitiveCsv, contains('123456789012'));

    final matchingPeopleCsv = await repository.exportCsv(
      {CsvExportField.memberName},
      householdIds: const {},
      memberIds: {'member-one'},
      headers: {CsvExportField.memberName: 'Member'},
    );
    expect(matchingPeopleCsv, contains('Person, ""One""'));
    expect(matchingPeopleCsv, isNot(contains('member-two')));
  });

  test('failed replace rolls back and preserves current data', () async {
    final snapshot = await repository.capture();
    final tables = {
      for (final entry in snapshot.tables.entries)
        entry.key: List<Map<String, Object?>>.from(entry.value),
    };
    tables['household']![0] = {
      ...tables['household']!.single,
      'house_name': '',
    };
    final invalidBackup = snapshotWith(tables);
    final db = await appDatabase.database;
    await db.insert('household', _household('local-only'));

    await expectLater(
      repository.restore(invalidBackup, BackupRestoreMode.replace),
      throwsA(anything),
    );
    expect(
      (await db.query(
        'household',
        orderBy: 'household_id',
      )).map((row) => row['household_id']),
      ['home-one', 'local-only'],
    );
  });
}

BackupSnapshot snapshotWith(Map<String, List<Map<String, Object?>>> tables) =>
    BackupSnapshot.fromMap({
      'formatVersion': 1,
      'schemaVersion': 6,
      'tables': tables,
    });

Map<String, Object?> _household(String id) => {
  'household_id': id,
  'house_name': id == 'home-one' ? 'Original home' : 'Second home',
  'house_number': '1',
  'address_line': 'Road',
  'locality': 'Ward',
  'post_office': 'Post',
  'pincode': '123456',
  'contact_phone': null,
  'ration_card_type': 'bpl',
  'has_own_well': 1,
  'house_type': 'tiled_roof',
  'notes': null,
  'created_at': '2025-01-01T00:00:00.000Z',
  'updated_at': '2025-01-01T00:00:00.000Z',
  'record_status': 'complete',
  'is_archived': 0,
};

Map<String, Object?> _member(
  String id,
  String householdId, {
  bool isHead = true,
  String relationship = 'head',
}) => {
  'member_id': id,
  'household_id': householdId,
  'full_name': id,
  'date_of_birth': '1990-01-01',
  'gender': 'female',
  'relationship_to_head': relationship,
  'is_head': isHead ? 1 : 0,
  'person_phone': null,
  'created_at': '2025-01-01T00:00:00.000Z',
  'updated_at': '2025-01-01T00:00:00.000Z',
  'is_archived': 0,
};

Future<Database> _openFfiDatabase(
  String path, {
  required String password,
  required int version,
  OnDatabaseConfigureFn? onConfigure,
  OnDatabaseCreateFn? onCreate,
  OnDatabaseVersionChangeFn? onUpgrade,
}) => databaseFactoryFfi.openDatabase(
  path,
  options: OpenDatabaseOptions(
    version: version,
    onConfigure: onConfigure,
    onCreate: onCreate,
    onUpgrade: onUpgrade,
  ),
);

String utf8Decode(List<int> bytes) => String.fromCharCodes(bytes);
