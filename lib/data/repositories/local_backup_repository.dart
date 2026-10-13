import 'package:sqflite_common/sqlite_api.dart'
    show ConflictAlgorithm, DatabaseExecutor;

import '../database/app_database.dart';
import '../database/database_migrations.dart';
import '../models/backup_snapshot.dart';

enum BackupRestoreMode { merge, replace }

enum CsvExportField {
  householdName('house_name'),
  houseNumber('house_number'),
  address('address_line'),
  locality('locality'),
  postOffice('post_office'),
  pincode('pincode'),
  householdPhone('contact_phone'),
  rationCardType('ration_card_type'),
  wellOwnership('has_own_well'),
  houseType('house_type'),
  memberName('full_name'),
  dateOfBirth('date_of_birth'),
  gender('gender'),
  relationshipToHead('relationship_to_head'),
  memberPhone('person_phone'),
  aadhaar('aadhaar_number', isSensitive: true),
  cancerStatus('has_cancer', isSensitive: true),
  asthmaStatus('has_asthma', isSensitive: true),
  heartDiseaseStatus('has_heart_disease', isSensitive: true),
  otherIllnesses('illnesses', isSensitive: true),
  marriageStatus('is_married', isSensitive: true),
  marriageDate('marriage_date', isSensitive: true),
  premaritalCounselling('premarital_counselling_received', isSensitive: true),
  pregnancyLastMenses('last_menses_date', isSensitive: true),
  pregnancyAbaId('aba_id', isSensitive: true),
  pregnancyHospital('consulting_hospital', isSensitive: true),
  previousPregnancies('previous_pregnancy_count', isSensitive: true),
  childBirthWeight('birth_weight_kg', isSensitive: true),
  childDeliveryType('delivery_type', isSensitive: true),
  familyPlanningIntention('plan_status', isSensitive: true),
  familyPlanningMethod('method', isSensitive: true),
  familyPlanningActionDate('action_date', isSensitive: true),
  specialCareDetails('special_care_details', isSensitive: true);

  const CsvExportField(this.column, {this.isSensitive = false});

  final String column;
  final bool isSensitive;
}

class BackupExportHousehold {
  const BackupExportHousehold({required this.id, required this.displayName});

  final String id;
  final String displayName;
}

class BackupRestorePreview {
  const BackupRestorePreview({
    required this.householdsInBackup,
    required this.membersInBackup,
    required this.householdIdConflicts,
    required this.memberIdConflicts,
  });

  final int householdsInBackup;
  final int membersInBackup;
  final int householdIdConflicts;
  final int memberIdConflicts;

  int get householdAdds => householdsInBackup - householdIdConflicts;
  int get memberAdds => membersInBackup - memberIdConflicts;
}

class BackupRestoreResult {
  const BackupRestoreResult({
    required this.importedRows,
    required this.skippedRows,
  });

  final int importedRows;
  final int skippedRows;
}

class LocalBackupRepository {
  LocalBackupRepository(this._appDatabase);

  final AppDatabase _appDatabase;

  Future<BackupSnapshot> capture() async {
    final db = await _appDatabase.database;
    return db.transaction((transaction) async {
      final tables = <String, List<Map<String, Object?>>>{};
      for (final table in BackupTables.ordered) {
        final rows = await transaction.query(table);
        tables[table] = rows;
      }
      return BackupSnapshot(
        schemaVersion: DatabaseMigrations.latestVersion,
        tables: Map.unmodifiable(tables),
      );
    });
  }

  Future<List<BackupExportHousehold>> listActiveHouseholdsForExport() async {
    final db = await _appDatabase.database;
    final rows = await db.query(
      'household',
      columns: ['household_id', 'house_name', 'house_number'],
      where: 'is_archived = 0',
      orderBy: 'house_name COLLATE NOCASE, house_number COLLATE NOCASE',
    );
    return rows
        .map(
          (row) => BackupExportHousehold(
            id: row['household_id']! as String,
            displayName: [
              row['house_name']! as String,
              if (row['house_number'] != null &&
                  (row['house_number']! as String).isNotEmpty)
                row['house_number']! as String,
            ].join(' · '),
          ),
        )
        .toList(growable: false);
  }

  Future<String> exportCsv(
    Set<CsvExportField> fields, {
    required Map<CsvExportField, String> headers,
    required Set<String> householdIds,
    Set<String>? memberIds,
  }) async {
    if (fields.isEmpty) {
      throw ArgumentError.value(fields, 'fields', 'Select at least one field.');
    }
    final db = await _appDatabase.database;
    final selected = CsvExportField.values
        .where(fields.contains)
        .toList(growable: false);
    final header = selected
        .map((field) => _csvValue(headers[field] ?? field.column))
        .join(',');
    final recordIds = memberIds ?? householdIds;
    if (recordIds.isEmpty) {
      return '\uFEFF$header\r\n';
    }
    final recordFilter = memberIds == null ? 'h.household_id' : 'm.member_id';
    final rows = await db.transaction((transaction) async {
      final rows = <Map<String, Object?>>[];
      for (var offset = 0; offset < recordIds.length; offset += 500) {
        final chunk = recordIds.skip(offset).take(500).toList(growable: false);
        final placeholders = List.filled(chunk.length, '?').join(', ');
        rows.addAll(
          await transaction.rawQuery('''
      SELECT h.house_name, h.house_number, h.address_line, h.locality,
             h.post_office, h.pincode, h.contact_phone, h.ration_card_type,
             h.has_own_well, h.house_type, m.full_name, m.date_of_birth,
             m.gender, m.relationship_to_head, m.person_phone,
             gd.aadhaar_number, hd.has_cancer, hd.has_asthma,
             hd.has_heart_disease,
             (SELECT group_concat(
                       illness_code || COALESCE(': ' || other_illness_text, ''),
                       '; '
                     )
              FROM member_illness AS mi
              WHERE mi.member_id = m.member_id) AS illnesses,
             md.is_married, md.marriage_date,
             md.premarital_counselling_received,
             COALESCE(md.special_care_details, cb.special_care_details)
               AS special_care_details,
             pr.last_menses_date, pr.aba_id, pr.consulting_hospital,
             pr.previous_pregnancy_count, cb.birth_weight_kg, cb.delivery_type,
             fp.plan_status, fp.method, fp.action_date
      FROM household AS h
      LEFT JOIN member AS m
        ON m.household_id = h.household_id AND m.is_archived = 0
      LEFT JOIN member_general_detail AS gd ON gd.member_id = m.member_id
      LEFT JOIN member_health_detail AS hd ON hd.member_id = m.member_id
      LEFT JOIN member_marriage_detail AS md ON md.member_id = m.member_id
      LEFT JOIN pregnancy_record AS pr
        ON pr.mother_member_id = m.member_id AND pr.is_current = 1
      LEFT JOIN child_birth_detail AS cb ON cb.member_id = m.member_id
      LEFT JOIN family_planning_record AS fp
        ON fp.member_id = m.member_id AND fp.is_current = 1
      WHERE h.is_archived = 0
        AND $recordFilter IN ($placeholders)
      ORDER BY h.house_name, h.household_id, m.full_name, m.member_id
    ''', chunk),
        );
      }
      return rows;
    });
    rows.sort((left, right) {
      for (final column in [
        'house_name',
        'household_id',
        'full_name',
        'member_id',
      ]) {
        final comparison = (left[column]?.toString() ?? '')
            .toLowerCase()
            .compareTo((right[column]?.toString() ?? '').toLowerCase());
        if (comparison != 0) return comparison;
      }
      return 0;
    });
    final csvRows = <List<String>>[
      [header],
      for (final row in rows)
        selected
            .map((field) => _csvValue(row[field.column]))
            .toList(growable: false),
    ];
    return '\uFEFF${csvRows.map((row) => row.join(',')).join('\r\n')}\r\n';
  }

  Future<void> validate(BackupSnapshot snapshot) async {
    if (snapshot.schemaVersion != DatabaseMigrations.latestVersion) {
      throw const BackupFormatException(
        'This backup uses an unsupported database version.',
      );
    }
    final db = await _appDatabase.database;
    for (final table in BackupTables.ordered) {
      final columns = await db.rawQuery('PRAGMA table_info($table)');
      final allowedColumns = columns
          .map((column) => column['name']! as String)
          .toSet();
      for (final row in snapshot.tables[table]!) {
        if (row.keys.any((key) => !allowedColumns.contains(key))) {
          throw const BackupFormatException(
            'Backup record contains unsupported fields.',
          );
        }
      }
    }
  }

  String _csvValue(Object? value) {
    if (value == null) return '';
    final text = value.toString();
    return '"${text.replaceAll('"', '""')}"';
  }

  Future<BackupRestorePreview> preview(BackupSnapshot snapshot) async {
    await validate(snapshot);
    final db = await _appDatabase.database;
    final householdIds = snapshot.tables['household']!
        .map((row) => row['household_id'])
        .whereType<String>()
        .toList(growable: false);
    final memberIds = snapshot.tables['member']!
        .map((row) => row['member_id'])
        .whereType<String>()
        .toList(growable: false);
    final householdConflicts = await _countExistingIds(
      db,
      'household',
      'household_id',
      householdIds,
    );
    final memberConflicts = await _countExistingIds(
      db,
      'member',
      'member_id',
      memberIds,
    );
    return BackupRestorePreview(
      householdsInBackup: householdIds.length,
      membersInBackup: memberIds.length,
      householdIdConflicts: householdConflicts,
      memberIdConflicts: memberConflicts,
    );
  }

  Future<BackupRestoreResult> restore(
    BackupSnapshot snapshot,
    BackupRestoreMode mode,
  ) async {
    await validate(snapshot);
    final db = await _appDatabase.database;
    return db.transaction((transaction) async {
      if (mode == BackupRestoreMode.replace) {
        for (final table in BackupTables.reverseOrder) {
          await transaction.delete(table);
        }
      }
      var imported = 0;
      var skipped = 0;
      final presentMemberIds = (await transaction.query(
        'member',
        columns: ['member_id'],
      )).map((row) => row['member_id']! as String).toSet();
      final localMemberIdConflicts = mode == BackupRestoreMode.merge
          ? presentMemberIds.intersection(
              snapshot.tables['member']!
                  .map((row) => row['member_id'])
                  .whereType<String>()
                  .toSet(),
            )
          : <String>{};
      final presentHouseholdIds = (await transaction.query(
        'household',
        columns: ['household_id'],
      )).map((row) => row['household_id']! as String).toSet();
      final currentPregnancyMembers = (await transaction.query(
        'pregnancy_record',
        columns: ['mother_member_id'],
        where: 'is_current = 1',
      )).map((row) => row['mother_member_id']! as String).toSet();
      final currentPlanningMembers = (await transaction.query(
        'family_planning_record',
        columns: ['member_id'],
        where: 'is_current = 1',
      )).map((row) => row['member_id']! as String).toSet();

      for (final table in BackupTables.ordered) {
        for (final backupRow in snapshot.tables[table]!) {
          final row = Map<String, Object?>.from(backupRow);
          if (mode == BackupRestoreMode.merge &&
              !_hasRequiredParent(
                table,
                row,
                presentHouseholdIds,
                presentMemberIds,
              )) {
            skipped++;
            continue;
          }
          if (mode == BackupRestoreMode.merge &&
              _referencesConflictingMember(
                table,
                row,
                localMemberIdConflicts,
              )) {
            skipped++;
            continue;
          }
          if (mode == BackupRestoreMode.merge &&
              table == 'pregnancy_record' &&
              row['is_current'] == 1 &&
              currentPregnancyMembers.contains(row['mother_member_id'])) {
            row['is_current'] = 0;
          }
          if (mode == BackupRestoreMode.merge &&
              table == 'family_planning_record' &&
              row['is_current'] == 1 &&
              currentPlanningMembers.contains(row['member_id'])) {
            row['is_current'] = 0;
          }
          await transaction.insert(
            table,
            row,
            conflictAlgorithm: mode == BackupRestoreMode.merge
                ? ConflictAlgorithm.ignore
                : ConflictAlgorithm.abort,
          );
          final changes = mode == BackupRestoreMode.merge
              ? (await transaction.rawQuery('SELECT changes() AS count'))
                        .single['count']!
                    as int
              : 1;
          if (changes == 0) {
            skipped++;
          } else {
            imported++;
            if (table == 'household') {
              presentHouseholdIds.add(row['household_id']! as String);
            } else if (table == 'member') {
              presentMemberIds.add(row['member_id']! as String);
            } else if (table == 'pregnancy_record' && row['is_current'] == 1) {
              currentPregnancyMembers.add(row['mother_member_id']! as String);
            } else if (table == 'family_planning_record' &&
                row['is_current'] == 1) {
              currentPlanningMembers.add(row['member_id']! as String);
            }
          }
        }
      }
      return BackupRestoreResult(importedRows: imported, skippedRows: skipped);
    });
  }
}

Future<int> _countExistingIds(
  DatabaseExecutor db,
  String table,
  String column,
  List<String> ids,
) async {
  var count = 0;
  for (final id in ids) {
    final rows = await db.query(
      table,
      columns: [column],
      where: '$column = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isNotEmpty) count++;
  }
  return count;
}

bool _referencesConflictingMember(
  String table,
  Map<String, Object?> row,
  Set<String> conflicts,
) {
  if (table == 'member_relationship') {
    return conflicts.contains(row['from_member_id']) ||
        conflicts.contains(row['to_member_id']);
  }
  final memberId = switch (table) {
    'member_general_detail' ||
    'member_health_detail' ||
    'member_illness' ||
    'member_marriage_detail' ||
    'child_birth_detail' ||
    'family_planning_record' => row['member_id'],
    'pregnancy_record' => row['mother_member_id'],
    _ => null,
  };
  return memberId != null && conflicts.contains(memberId);
}

bool _hasRequiredParent(
  String table,
  Map<String, Object?> row,
  Set<String> households,
  Set<String> members,
) {
  if (table == 'member') return households.contains(row['household_id']);
  if (table == 'household') return true;
  if (table == 'lookup_value') return true;
  if (table == 'member_relationship') {
    return members.contains(row['from_member_id']) &&
        members.contains(row['to_member_id']);
  }
  final memberId = switch (table) {
    'member_general_detail' ||
    'member_health_detail' ||
    'member_illness' ||
    'member_marriage_detail' ||
    'child_birth_detail' => row['member_id'],
    'pregnancy_record' => row['mother_member_id'],
    'family_planning_record' => row['member_id'],
    _ => null,
  };
  return memberId == null || members.contains(memberId);
}
