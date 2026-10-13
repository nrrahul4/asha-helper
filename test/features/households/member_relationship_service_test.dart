import 'dart:io';

import 'package:family_tracker/data/database/app_database.dart';
import 'package:family_tracker/data/models/database_codes.dart';
import 'package:family_tracker/data/models/household.dart';
import 'package:family_tracker/data/models/member.dart';
import 'package:family_tracker/data/models/member_relationship.dart';
import 'package:family_tracker/data/repositories/household_repository.dart';
import 'package:family_tracker/data/repositories/member_repository.dart';
import 'package:family_tracker/features/households/domain/member_relationship_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory temporaryDirectory;
  late AppDatabase appDatabase;
  late MemberRelationshipService service;
  late Household household;
  late Member mother;
  late Member child;
  late Member spouse;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'member_relationship_test_',
    );
    appDatabase = AppDatabase(
      path: '${temporaryDirectory.path}/households.db',
      encryptionKey: 'test-key-only',
      opener: _openFfiDatabase,
    );
    final householdRepository = HouseholdRepository(appDatabase);
    final repository = MemberRepository(appDatabase);
    service = MemberRelationshipService(repository);
    household = Household.create(
      houseName: 'Family home',
      addressLine: 'Main Road',
      rationCardType: RationCardType.bpl,
      hasOwnWell: false,
      houseType: HouseType.concreteTerrace,
    );
    mother = Member.createHead(
      householdId: household.id,
      fullName: 'Mother',
      dateOfBirth: DateTime(1990, 1, 1),
      gender: Gender.female,
    );
    child = Member.create(
      householdId: household.id,
      fullName: 'Child',
      dateOfBirth: DateTime(2015, 1, 1),
      gender: Gender.other,
      relationshipToHead: RelationshipToHead.other,
    );
    spouse = Member.create(
      householdId: household.id,
      fullName: 'Spouse',
      dateOfBirth: DateTime(1990, 1, 1),
      gender: Gender.male,
      relationshipToHead: RelationshipToHead.other,
    );
    await householdRepository.createWithHead(household, mother);
    await repository.createAdditionalMember(child);
    await repository.createAdditionalMember(spouse);
  });

  tearDown(() async {
    await appDatabase.close();
    await temporaryDirectory.delete(recursive: true);
  });

  test(
    'stores mother-child direction and prevents a second active mother',
    () async {
      await service.add(
        memberId: mother.id,
        otherMemberId: child.id,
        type: MemberRelationshipType.motherOf,
        memberIsMother: true,
        now: DateTime(2026, 10, 12),
      );
      final saved = await service.forMember(child.id);
      expect(saved, hasLength(1));
      expect(saved.single.fromMemberId, mother.id);
      expect(saved.single.toMemberId, child.id);
      await expectLater(
        service.add(
          memberId: mother.id,
          otherMemberId: child.id,
          type: MemberRelationshipType.motherOf,
          memberIsMother: true,
          now: DateTime(2026, 10, 13),
        ),
        throwsA(isA<StateError>()),
      );
    },
  );

  test(
    'stores canonical spouse pair, rejects duplicates, and ends by archive',
    () async {
      await service.add(
        memberId: spouse.id,
        otherMemberId: mother.id,
        type: MemberRelationshipType.spouseOf,
        memberIsMother: true,
        now: DateTime(2026, 10, 12),
      );
      final relationships = await service.forMember(mother.id);
      expect(relationships, hasLength(1));
      expect(
        relationships.single.fromMemberId.compareTo(
              relationships.single.toMemberId,
            ) <
            0,
        isTrue,
      );
      await expectLater(
        service.add(
          memberId: mother.id,
          otherMemberId: spouse.id,
          type: MemberRelationshipType.spouseOf,
          memberIsMother: true,
          now: DateTime(2026, 10, 13),
        ),
        throwsA(isA<StateError>()),
      );
      await service.end(relationships.single.id, DateTime(2026, 10, 14));
      expect((await service.forMember(mother.id)).single.isActive, isFalse);
    },
  );
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
