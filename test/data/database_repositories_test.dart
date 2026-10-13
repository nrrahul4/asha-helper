import 'dart:io';

import 'package:family_tracker/data/database/app_database.dart';
import 'package:family_tracker/data/database/database_migrations.dart';
import 'package:family_tracker/data/models/database_codes.dart';
import 'package:family_tracker/data/models/family_report_summary.dart';
import 'package:family_tracker/data/models/household.dart';
import 'package:family_tracker/data/models/member.dart';
import 'package:family_tracker/data/repositories/household_repository.dart';
import 'package:family_tracker/data/repositories/member_repository.dart';
import 'package:family_tracker/data/repositories/family_report_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory temporaryDirectory;
  late AppDatabase appDatabase;
  late HouseholdRepository householdRepository;
  late MemberRepository memberRepository;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'family_tracker_database_test_',
    );
    appDatabase = AppDatabase(
      path: '${temporaryDirectory.path}/family_tracker.db',
      encryptionKey: 'test-only-encryption-key',
      opener: _openFfiDatabase,
    );
    householdRepository = HouseholdRepository(appDatabase);
    memberRepository = MemberRepository(appDatabase);
  });

  tearDown(() async {
    await appDatabase.close();
    await temporaryDirectory.delete(recursive: true);
  });

  test(
    'creates latest schema, seeds lookups, and enables foreign keys',
    () async {
      final db = await appDatabase.database;

      expect(await db.getVersion(), DatabaseMigrations.latestVersion);
      expect(await db.query('household'), isEmpty);
      expect(await db.query('member'), isEmpty);
      expect(await db.query('lookup_value'), hasLength(28));
      expect(await db.query('member_general_detail'), isEmpty);
      expect(await db.query('pregnancy_record'), isEmpty);
      expect(RationCardType.selectableValues.map((type) => type.code), [
        'bpl',
        'apl',
        'aay',
      ]);
      expect(await db.rawQuery('PRAGMA foreign_keys'), [
        {'foreign_keys': 1},
      ]);

      final indexes = await db.rawQuery("PRAGMA index_list('member')");
      expect(
        indexes.any(
          (index) => index['name'] == 'ux_member_one_head_per_household',
        ),
        isTrue,
      );
      final pregnancyIndexes = await db.rawQuery(
        "PRAGMA index_list('pregnancy_record')",
      );
      expect(
        pregnancyIndexes.any(
          (index) =>
              index['name'] == 'ux_pregnancy_one_current_per_member' &&
              index['unique'] == 1,
        ),
        isTrue,
      );
    },
  );

  test('upgrades the v3 schema without remapping or losing records', () async {
    final legacyPath = '${temporaryDirectory.path}/legacy.db';
    final legacyDb = await databaseFactoryFfi.openDatabase(
      legacyPath,
      options: OpenDatabaseOptions(
        version: 3,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: DatabaseMigrations.onCreate,
        onUpgrade: DatabaseMigrations.onUpgrade,
      ),
    );
    final legacyHousehold = Household(
      id: 'legacy-household',
      houseName: 'Legacy house',
      houseNumber: '04/A',
      addressLine: 'Old Road',
      locality: 'Old Ward',
      postOffice: 'Old Post',
      pincode: '001234',
      contactPhone: '0100200300',
      rationCardType: RationCardType.yellow,
      hasOwnWell: true,
      houseType: HouseType.tiledRoof,
      createdAt: DateTime.utc(2024, 3, 1),
      updatedAt: DateTime.utc(2024, 3, 2),
      recordStatus: HouseholdRecordStatus.complete,
    );
    final legacyHouseholdRow = legacyHousehold.toMap()
      ..remove('ration_card_review_required');
    await legacyDb.insert('household', legacyHouseholdRow);
    final legacyMember = _head(legacyHousehold.id, id: 'legacy-head');
    await legacyDb.insert('member', legacyMember.toMap());
    await legacyDb.delete(
      'lookup_value',
      where: "category = 'ration_card_type' AND code IN ('bpl', 'apl', 'aay')",
    );
    await legacyDb.close();

    final upgraded = AppDatabase(
      path: legacyPath,
      encryptionKey: 'test-only-encryption-key',
      opener: _openFfiDatabase,
    );
    final db = await upgraded.database;

    expect(await db.getVersion(), DatabaseMigrations.latestVersion);
    final restoredHousehold = Household.fromMap(
      (await db.query('household')).single,
    );
    final restoredMember = Member.fromMap((await db.query('member')).single);
    expect(restoredHousehold.id, legacyHousehold.id);
    expect(restoredHousehold.houseName, legacyHousehold.houseName);
    expect(restoredHousehold.houseNumber, legacyHousehold.houseNumber);
    expect(restoredHousehold.addressLine, legacyHousehold.addressLine);
    expect(restoredHousehold.locality, legacyHousehold.locality);
    expect(restoredHousehold.postOffice, legacyHousehold.postOffice);
    expect(restoredHousehold.pincode, legacyHousehold.pincode);
    expect(restoredHousehold.contactPhone, legacyHousehold.contactPhone);
    expect(restoredHousehold.rationCardType, RationCardType.yellow);
    expect(restoredHousehold.rationCardReviewRequired, isTrue);
    expect(restoredHousehold.recordStatus, HouseholdRecordStatus.complete);
    expect(restoredMember.id, legacyMember.id);
    expect(restoredMember.householdId, legacyMember.householdId);
    expect(await db.query('lookup_value'), hasLength(28));
    final currentCards = await db.query(
      'lookup_value',
      columns: ['code', 'is_active'],
      where: "category = 'ration_card_type'",
    );
    expect(
      currentCards
          .where((row) => row['is_active'] == 1)
          .map((row) => row['code'])
          .toSet(),
      {'bpl', 'apl', 'aay'},
    );
    await upgraded.close();
  });

  test(
    'clears legacy card review only after explicit category selection',
    () async {
      final household = _household(id: 'review-household');
      await householdRepository.createWithHead(
        household,
        _head(household.id, id: 'review-head'),
      );
      final db = await appDatabase.database;
      await db.update(
        'household',
        {'ration_card_type': 'yellow', 'ration_card_review_required': 1},
        where: 'household_id = ?',
        whereArgs: [household.id],
      );

      final legacy = await householdRepository.getById(household.id);
      expect(legacy?.rationCardType, RationCardType.yellow);
      expect(legacy?.rationCardReviewRequired, isTrue);

      expect(
        await householdRepository.updateRationCardType(
          household.id,
          RationCardType.aay,
        ),
        isTrue,
      );
      final reviewed = await householdRepository.getById(household.id);
      expect(reviewed?.rationCardType, RationCardType.aay);
      expect(reviewed?.rationCardReviewRequired, isFalse);
    },
  );

  test('creates household and head as one completed record', () async {
    final household = _household(id: 'household-1');
    final head = _head(household.id, id: 'head-1', name: 'അനു നായർ');

    await householdRepository.createWithHead(household, head);

    final storedHousehold = await householdRepository.getById(household.id);
    final storedMembers = await memberRepository.listForHousehold(household.id);
    expect(storedHousehold?.recordStatus, HouseholdRecordStatus.complete);
    expect(storedMembers, hasLength(1));
    expect(storedMembers.single.fullName, 'അനു നായർ');
    expect(storedMembers.single.isHead, isTrue);
    expect(storedMembers.single.dateOfBirth, DateTime(1988, 2, 29));
  });

  test('rolls back household insert when head insert fails', () async {
    final existingHousehold = _household(id: 'existing-household');
    final existingHead = _head(existingHousehold.id, id: 'duplicate-member-id');
    await householdRepository.createWithHead(existingHousehold, existingHead);

    final attemptedHousehold = _household(id: 'rolled-back-household');
    final duplicateHead = Member(
      id: existingHead.id,
      householdId: attemptedHousehold.id,
      fullName: 'Another person',
      dateOfBirth: DateTime(1980, 1, 1),
      gender: Gender.other,
      relationshipToHead: RelationshipToHead.head,
      isHead: true,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );

    await expectLater(
      householdRepository.createWithHead(attemptedHousehold, duplicateHead),
      throwsA(isA<DatabaseException>()),
    );
    expect(await householdRepository.getById(attemptedHousehold.id), isNull);
  });

  test('database rejects a second head for one household', () async {
    final household = _household(id: 'household-1');
    await householdRepository.createWithHead(
      household,
      _head(household.id, id: 'head-1'),
    );

    final db = await appDatabase.database;
    await expectLater(
      db.insert('member', _head(household.id, id: 'head-2').toMap()),
      throwsA(isA<DatabaseException>()),
    );
  });

  test(
    'adds and edits members without allowing household or head changes',
    () async {
      final household = _household(id: 'household-1');
      await householdRepository.createWithHead(
        household,
        _head(household.id, id: 'head-1'),
      );
      final member = _member(household.id, id: 'member-1');
      await memberRepository.createAdditionalMember(member);

      final edited = Member(
        id: member.id,
        householdId: member.householdId,
        fullName: '  Maya Nair  ',
        dateOfBirth: member.dateOfBirth,
        gender: Gender.female,
        relationshipToHead: RelationshipToHead.daughter,
        isHead: false,
        personPhone: '  0123456789 ',
        createdAt: member.createdAt,
        updatedAt: member.updatedAt,
      );
      expect(await memberRepository.update(edited), isTrue);
      expect(
        (await memberRepository.getById(member.id))?.fullName,
        'Maya Nair',
      );
      expect(
        (await memberRepository.getById(member.id))?.personPhone,
        '0123456789',
      );
      expect(
        () => Member.create(
          householdId: household.id,
          fullName: 'Invalid head',
          dateOfBirth: DateTime(1980),
          gender: Gender.other,
          relationshipToHead: RelationshipToHead.head,
        ),
        throwsArgumentError,
      );

      final changedRole = Member(
        id: member.id,
        householdId: member.householdId,
        fullName: member.fullName,
        dateOfBirth: member.dateOfBirth,
        gender: member.gender,
        relationshipToHead: RelationshipToHead.head,
        isHead: true,
        createdAt: member.createdAt,
        updatedAt: member.updatedAt,
      );
      await expectLater(memberRepository.update(changedRole), throwsStateError);
    },
  );

  test(
    'archives households and restores the household without restoring members',
    () async {
      final household = _household(id: 'household-1');
      final head = _head(household.id, id: 'head-1');
      await householdRepository.createWithHead(household, head);
      await memberRepository.createAdditionalMember(
        _member(household.id, id: 'member-1'),
      );

      await expectLater(memberRepository.archive(head.id), throwsStateError);
      expect(await householdRepository.archive(household.id), isTrue);
      expect(await householdRepository.getById(household.id), isNull);
      expect(
        await householdRepository.getById(household.id, includeArchived: true),
        isNotNull,
      );
      expect(await memberRepository.listForHousehold(household.id), isEmpty);
      expect(
        await memberRepository.listForHousehold(
          household.id,
          includeArchived: true,
        ),
        hasLength(2),
      );
      expect(await householdRepository.restore(household.id), isTrue);
      expect(await householdRepository.getById(household.id), isNotNull);
      expect(await memberRepository.listForHousehold(household.id), isEmpty);
      expect(await memberRepository.restore(head.id), isTrue);
      expect(
        (await memberRepository.listForHousehold(household.id)).single.id,
        head.id,
      );
    },
  );

  test('member requires an active completed household', () async {
    final draft = _household(id: 'draft-household');
    await householdRepository.createDraft(draft);

    await expectLater(
      memberRepository.createAdditionalMember(
        _member(draft.id, id: 'member-1'),
      ),
      throwsStateError,
    );
    await expectLater(
      memberRepository.createAdditionalMember(
        _member('missing-household', id: 'member-2'),
      ),
      throwsStateError,
    );
  });

  test('household edits preserve creation time and completion state', () async {
    final household = _household(id: 'household-1');
    await householdRepository.createWithHead(
      household,
      _head(household.id, id: 'head-1'),
    );

    final loaded = (await householdRepository.getById(household.id))!;
    final changed = Household(
      id: loaded.id,
      houseName: 'Updated house',
      houseNumber: '001/A',
      addressLine: 'New road',
      rationCardType: loaded.rationCardType,
      hasOwnWell: loaded.hasOwnWell,
      houseType: loaded.houseType,
      createdAt: loaded.createdAt,
      updatedAt: loaded.updatedAt,
      recordStatus: loaded.recordStatus,
    );

    expect(await householdRepository.update(changed), isTrue);
    final result = (await householdRepository.getById(household.id))!;
    expect(result.houseName, 'Updated house');
    expect(result.houseNumber, '001/A');
    expect(result.createdAt, household.createdAt);
    expect(result.recordStatus, HouseholdRecordStatus.complete);
  });

  test('reports count active members from complete households only', () async {
    final activeHousehold = _household(id: 'active-household');
    await householdRepository.createWithHead(
      activeHousehold,
      _head(activeHousehold.id, id: 'active-head'),
    );
    await memberRepository.createAdditionalMember(
      Member(
        id: 'young-member',
        householdId: activeHousehold.id,
        fullName: 'Young member',
        dateOfBirth: DateTime(2022, 10, 13),
        gender: Gender.male,
        relationshipToHead: RelationshipToHead.son,
        isHead: false,
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      ),
    );

    final archivedHousehold = _household(id: 'archived-household');
    await householdRepository.createWithHead(
      archivedHousehold,
      _head(archivedHousehold.id, id: 'archived-head'),
    );
    await householdRepository.archive(archivedHousehold.id);
    await householdRepository.createDraft(_household(id: 'draft-household'));

    final summary = await FamilyReportRepository(appDatabase)
        .load(referenceDate: DateTime(2026, 10, 12));

    expect(summary.householdCount, 1);
    expect(summary.memberCount, 2);
    expect(summary.genderCounts[Gender.female], 1);
    expect(summary.genderCounts[Gender.male], 1);
    expect(summary.ageBandCounts[FamilyAgeBand.zeroToFive], 1);
    expect(summary.ageBandCounts[FamilyAgeBand.eighteenToFiftyNine], 1);
    expect(summary.rationCardCounts[RationCardType.bpl], 1);
    expect(summary.wellOwnershipCounts[true], 1);
  });
}

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

Household _household({required String id}) {
  final timestamp = DateTime.utc(2026, 1, 2, 3, 4, 5);
  return Household(
    id: id,
    houseName: 'Kavungal house',
    houseNumber: '012/A',
    addressLine: 'Market Road',
    locality: 'North Ward',
    postOffice: 'Town',
    pincode: '001234',
    contactPhone: '0123456789',
    rationCardType: RationCardType.bpl,
    hasOwnWell: true,
    houseType: HouseType.tiledRoof,
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}

Member _head(String householdId, {required String id, String name = 'Head'}) =>
    Member(
      id: id,
      householdId: householdId,
      fullName: name,
      dateOfBirth: DateTime(1988, 2, 29),
      gender: Gender.female,
      relationshipToHead: RelationshipToHead.head,
      isHead: true,
      createdAt: DateTime.utc(2026, 1, 2),
      updatedAt: DateTime.utc(2026, 1, 2),
    );

Member _member(String householdId, {required String id}) => Member(
  id: id,
  householdId: householdId,
  fullName: 'Maya Nair',
  dateOfBirth: DateTime(2012, 3, 4),
  gender: Gender.female,
  relationshipToHead: RelationshipToHead.daughter,
  isHead: false,
  personPhone: null,
  createdAt: DateTime.utc(2026, 1, 2),
  updatedAt: DateTime.utc(2026, 1, 2),
);
