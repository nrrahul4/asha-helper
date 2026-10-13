import 'dart:io';

import 'package:family_tracker/data/database/app_database.dart';
import 'package:family_tracker/data/database/database_migrations.dart';
import 'package:family_tracker/data/models/database_codes.dart';
import 'package:family_tracker/data/models/household.dart';
import 'package:family_tracker/data/models/member.dart';
import 'package:family_tracker/data/repositories/household_repository.dart';
import 'package:family_tracker/data/repositories/member_repository.dart';
import 'package:family_tracker/features/households/domain/member_search_filters.dart';
import 'package:family_tracker/features/households/domain/member_search_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory temporaryDirectory;
  late AppDatabase appDatabase;
  late HouseholdRepository householdRepository;
  late MemberRepository memberRepository;
  late MemberSearchService searchService;
  late Household yellowHousehold;
  late Household blueHousehold;
  late Member yellowTeen;
  late Member blueAdult;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'family_tracker_member_search_test_',
    );
    appDatabase = AppDatabase(
      path: '${temporaryDirectory.path}/search.db',
      encryptionKey: 'test-only-key',
      opener: _openFfiDatabase,
    );
    householdRepository = HouseholdRepository(appDatabase);
    memberRepository = MemberRepository(appDatabase);
    searchService = MemberSearchService(memberRepository);

    yellowHousehold = await _createHousehold(
      householdRepository,
      name: 'Cedar Family',
      number: '011/A',
      card: RationCardType.bpl,
      contactPhone: '001122',
      head: _person(
        name: 'Anu Nair',
        dob: DateTime(1980, 1, 1),
        gender: Gender.female,
        relation: RelationshipToHead.head,
        isHead: true,
      ),
    );
    yellowTeen = _person(
      name: 'Ravi Menon',
      dob: DateTime(2008, 10, 12),
      gender: Gender.male,
      relation: RelationshipToHead.son,
      householdId: yellowHousehold.id,
      phone: '0098765',
    );
    await memberRepository.createAdditionalMember(yellowTeen);
    await memberRepository.createAdditionalMember(
      _person(
        name: 'Nila Das',
        dob: DateTime(2008, 10, 13),
        gender: Gender.female,
        relation: RelationshipToHead.daughter,
        householdId: yellowHousehold.id,
      ),
    );

    blueHousehold = await _createHousehold(
      householdRepository,
      name: 'Lakeside Home',
      number: '022/B',
      card: RationCardType.aay,
      contactPhone: '778899',
      head: _person(
        name: 'Maya Ravi',
        dob: DateTime(1990, 2, 3),
        gender: Gender.female,
        relation: RelationshipToHead.head,
        isHead: true,
      ),
    );
    blueAdult = _person(
      name: 'Ravi Kumar',
      dob: DateTime(2007, 4, 4),
      gender: Gender.male,
      relation: RelationshipToHead.spouse,
      householdId: blueHousehold.id,
    );
    await memberRepository.createAdditionalMember(blueAdult);
  });

  tearDown(() async {
    await appDatabase.close();
    await temporaryDirectory.delete(recursive: true);
  });

  final referenceDate = DateTime(2026, 10, 12);

  test(
    'searches member name, household name, house number, and phone prefixes',
    () async {
      final byPerson = await searchService.search(
        const MemberSearchFilters(query: 'ravi'),
        referenceDate: referenceDate,
      );
      expect(byPerson.map((result) => result.member.fullName), [
        'Ravi Kumar',
        'Ravi Menon',
      ]);

      final byHousehold = await searchService.search(
        const MemberSearchFilters(query: 'Cedar'),
        referenceDate: referenceDate,
      );
      expect(byHousehold, hasLength(3));
      expect(
        byHousehold.every((result) => result.householdName == 'Cedar Family'),
        isTrue,
      );

      final byHouseNumber = await searchService.search(
        const MemberSearchFilters(query: '011/'),
        referenceDate: referenceDate,
      );
      expect(byHouseNumber, hasLength(3));

      final byPhone = await searchService.search(
        const MemberSearchFilters(query: '009'),
        referenceDate: referenceDate,
      );
      expect(byPhone.map((result) => result.member.id), [yellowTeen.id]);

      final byHouseholdPhone = await searchService.search(
        const MemberSearchFilters(query: '001'),
        referenceDate: referenceDate,
      );
      expect(byHouseholdPhone, hasLength(3));
    },
  );

  test('filters by gender, card type, and household', () async {
    final males = await searchService.search(
      const MemberSearchFilters(genders: {Gender.male}),
      referenceDate: referenceDate,
    );
    expect(males.map((result) => result.member.fullName), [
      'Ravi Kumar',
      'Ravi Menon',
    ]);

    final eitherCard = await searchService.search(
      const MemberSearchFilters(
        rationCardTypes: {RationCardType.bpl, RationCardType.aay},
      ),
      referenceDate: referenceDate,
    );
    expect(eitherCard, hasLength(5));

    final householdOnly = await searchService.search(
      MemberSearchFilters(householdId: yellowHousehold.id),
      referenceDate: referenceDate,
    );
    expect(householdOnly, hasLength(3));
    expect(
      householdOnly.every(
        (result) => result.member.householdId == yellowHousehold.id,
      ),
      isTrue,
    );
  });

  test('filters only members with an active current pregnancy', () async {
    final db = await appDatabase.database;
    final currentPregnantMemberId = (await memberRepository.listForHousehold(
      yellowHousehold.id,
    )).first.id;
    final endedPregnancyMemberId = (await memberRepository.listForHousehold(
      blueHousehold.id,
    )).first.id;
    await db.insert('pregnancy_record', {
      'pregnancy_id': 'current-pregnancy',
      'mother_member_id': currentPregnantMemberId,
      'last_menses_date': '2026-05-01',
      'is_current': 1,
      'created_at': '2026-05-01T00:00:00.000Z',
      'updated_at': '2026-05-01T00:00:00.000Z',
    });
    await db.insert('pregnancy_record', {
      'pregnancy_id': 'ended-pregnancy',
      'mother_member_id': endedPregnancyMemberId,
      'last_menses_date': '2025-01-01',
      'is_current': 0,
      'created_at': '2025-01-01T00:00:00.000Z',
      'updated_at': '2025-02-01T00:00:00.000Z',
    });

    final pregnantMembers = await searchService.search(
      const MemberSearchFilters(currentlyPregnantOnly: true),
      referenceDate: referenceDate,
    );
    expect(pregnantMembers.map((result) => result.member.id), [
      currentPregnantMemberId,
    ]);

    final combinedFilters = await searchService.search(
      const MemberSearchFilters(
        currentlyPregnantOnly: true,
        rationCardTypes: {RationCardType.bpl},
      ),
      referenceDate: referenceDate,
    );
    expect(combinedFilters.map((result) => result.member.id), [
      currentPregnantMemberId,
    ]);
  });

  test('age range is inclusive and age is derived for each result', () async {
    final exactly18 = await searchService.search(
      const MemberSearchFilters(minimumAge: 18, maximumAge: 18),
      referenceDate: referenceDate,
    );
    expect(exactly18.map((result) => result.member.id), [yellowTeen.id]);
    expect(exactly18.single.age, 18);
    expect(exactly18.single.member.dateOfBirth, DateTime(2008, 10, 12));

    final atMost17 = await searchService.search(
      const MemberSearchFilters(maximumAge: 17),
      referenceDate: referenceDate,
    );
    expect(atMost17.map((result) => result.member.fullName), ['Nila Das']);

    final atLeast19 = await searchService.search(
      const MemberSearchFilters(minimumAge: 19),
      referenceDate: referenceDate,
    );
    expect(
      atLeast19.any((result) => result.member.id == yellowTeen.id),
      isFalse,
    );
    expect(
      atLeast19.singleWhere((result) => result.member.id == blueAdult.id).age,
      19,
    );
  });

  test(
    'combines dimensions with AND and values within a dimension with OR',
    () async {
      final results = await searchService.search(
        const MemberSearchFilters(
          query: 'Ravi',
          genders: {Gender.male, Gender.female},
          minimumAge: 18,
          maximumAge: 18,
          rationCardTypes: {RationCardType.bpl, RationCardType.aay},
        ),
        referenceDate: referenceDate,
      );

      expect(results.map((result) => result.member.id), [yellowTeen.id]);
      expect(results.single.rationCardType, RationCardType.bpl);
      expect(results.single.houseNumber, '011/A');
    },
  );

  test(
    'excludes archived members, archived households, and incomplete drafts',
    () async {
      final db = await appDatabase.database;
      final draft = Household.create(
        houseName: 'Draft Family',
        addressLine: 'Draft Road',
        rationCardType: RationCardType.bpl,
        hasOwnWell: false,
        houseType: HouseType.other,
      );
      await householdRepository.createDraft(draft);
      await db.insert(
        'member',
        _person(
          name: 'Draft Person',
          dob: DateTime(1990),
          gender: Gender.female,
          relation: RelationshipToHead.head,
          isHead: true,
          householdId: draft.id,
        ).toMap(),
      );
      await memberRepository.archive(yellowTeen.id);
      await householdRepository.archive(blueHousehold.id);

      final results = await searchService.search(
        const MemberSearchFilters(),
        referenceDate: referenceDate,
      );

      expect(results.map((result) => result.member.fullName), [
        'Anu Nair',
        'Nila Das',
      ]);
    },
  );

  test('escapes SQL LIKE metacharacters in search text', () async {
    final results = await searchService.search(
      const MemberSearchFilters(query: '%'),
      referenceDate: referenceDate,
    );

    expect(results, isEmpty);
  });

  test('rejects invalid age filters', () async {
    await expectLater(
      searchService.search(
        const MemberSearchFilters(minimumAge: 19, maximumAge: 18),
        referenceDate: referenceDate,
      ),
      throwsArgumentError,
    );
    await expectLater(
      searchService.search(
        const MemberSearchFilters(minimumAge: -1),
        referenceDate: referenceDate,
      ),
      throwsArgumentError,
    );
  });

  test(
    'migration adds indexes for member and household search fields',
    () async {
      final db = await appDatabase.database;
      final memberIndexes = await db.rawQuery("PRAGMA index_list('member')");
      final householdIndexes = await db.rawQuery(
        "PRAGMA index_list('household')",
      );
      final memberNames = memberIndexes.map((row) => row['name']).toSet();
      final householdNames = householdIndexes.map((row) => row['name']).toSet();

      expect(
        memberNames,
        containsAll(['ix_member_search_name', 'ix_member_search_phone']),
      );
      expect(
        householdNames,
        containsAll([
          'ix_household_search_name',
          'ix_household_search_number',
          'ix_household_search_phone',
        ]),
      );
      expect(await db.getVersion(), DatabaseMigrations.latestVersion);
    },
  );
}

Future<Household> _createHousehold(
  HouseholdRepository repository, {
  required String name,
  required String number,
  required RationCardType card,
  required String contactPhone,
  required Member head,
}) async {
  final household = Household.create(
    houseName: name,
    houseNumber: number,
    addressLine: 'Main Road',
    contactPhone: contactPhone,
    rationCardType: card,
    hasOwnWell: false,
    houseType: HouseType.tiledRoof,
    now: DateTime.utc(2026, 1, 1),
  );
  final householdHead = Member(
    id: head.id,
    householdId: household.id,
    fullName: head.fullName,
    dateOfBirth: head.dateOfBirth,
    gender: head.gender,
    relationshipToHead: RelationshipToHead.head,
    isHead: true,
    personPhone: head.personPhone,
    createdAt: head.createdAt,
    updatedAt: head.updatedAt,
  );
  return repository.createWithHead(household, householdHead);
}

Member _person({
  required String name,
  required DateTime dob,
  required Gender gender,
  required RelationshipToHead relation,
  String? householdId,
  String? phone,
  bool isHead = false,
}) => Member(
  id: '${householdId ?? 'new'}-${name.toLowerCase().replaceAll(' ', '-')}',
  householdId: householdId ?? '',
  fullName: name,
  dateOfBirth: dob,
  gender: gender,
  relationshipToHead: relation,
  isHead: isHead,
  personPhone: phone,
  createdAt: DateTime.utc(2026, 1, 1),
  updatedAt: DateTime.utc(2026, 1, 1),
);

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
