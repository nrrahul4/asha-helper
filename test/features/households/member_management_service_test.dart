import 'dart:io';

import 'package:family_tracker/data/database/app_database.dart';
import 'package:family_tracker/data/models/database_codes.dart';
import 'package:family_tracker/data/models/household.dart';
import 'package:family_tracker/data/models/member.dart';
import 'package:family_tracker/data/repositories/household_repository.dart';
import 'package:family_tracker/data/repositories/member_repository.dart';
import 'package:family_tracker/features/households/domain/member_form_input.dart';
import 'package:family_tracker/features/households/domain/member_management_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory temporaryDirectory;
  late AppDatabase appDatabase;
  late HouseholdRepository householdRepository;
  late MemberRepository memberRepository;
  late MemberManagementService service;
  late Household household;
  late Member head;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'member_management_test_',
    );
    appDatabase = AppDatabase(
      path: '${temporaryDirectory.path}/households.db',
      encryptionKey: 'test-key-only',
      opener: _openFfiDatabase,
    );
    householdRepository = HouseholdRepository(appDatabase);
    memberRepository = MemberRepository(appDatabase);
    service = MemberManagementService(memberRepository);
    household = _household();
    head = _head(household.id);
    await householdRepository.createWithHead(household, head);
  });

  tearDown(() async {
    await appDatabase.close();
    await temporaryDirectory.delete(recursive: true);
  });

  test('validates required data, future DOB, and malformed optional phone', () {
    final issues = service.validate(
      const MemberFormInput(
        fullName: ' ',
        dateOfBirth: null,
        gender: null,
        relationshipToHead: null,
        phone: 'call me',
      ),
      isHead: false,
      now: DateTime(2026, 1, 1),
    );

    expect(
      issues[MemberValidationField.fullName],
      MemberValidationIssue.required,
    );
    expect(
      issues[MemberValidationField.dateOfBirth],
      MemberValidationIssue.required,
    );
    expect(
      issues[MemberValidationField.gender],
      MemberValidationIssue.required,
    );
    expect(
      issues[MemberValidationField.relationship],
      MemberValidationIssue.required,
    );
    expect(
      issues[MemberValidationField.phone],
      MemberValidationIssue.invalidPhone,
    );

    final futureIssues = service.validate(
      _input(dateOfBirth: DateTime(2026, 1, 2)),
      isHead: false,
      now: DateTime(2026, 1, 1),
    );
    expect(
      futureIssues[MemberValidationField.dateOfBirth],
      MemberValidationIssue.futureDate,
    );
  });

  test('adds a non-head member with relationship and optional phone', () async {
    final added = await service.addMember(
      householdId: household.id,
      input: _input(phone: '+1 (212) 555-0100'),
      now: DateTime.utc(2026, 3, 4),
    );

    expect(added.isHead, isFalse);
    expect(added.relationshipToHead, RelationshipToHead.daughter);
    expect(added.personPhone, '+1 (212) 555-0100');
    final stored = await memberRepository.listForHousehold(household.id);
    expect(stored, hasLength(2));
    expect(stored.where((member) => member.isHead), hasLength(1));
  });

  test('edits name, DOB, gender, relationship, and phone', () async {
    final member = await service.addMember(
      householdId: household.id,
      input: _input(),
    );
    final updated = await service.updateMember(
      existing: member,
      input: _input(
        fullName: '  Maya Nair  ',
        dateOfBirth: DateTime(2010, 9, 8),
        gender: Gender.other,
        relationship: RelationshipToHead.sibling,
        phone: '0123456789',
      ),
    );

    expect(updated.id, member.id);
    expect(updated.householdId, household.id);
    expect(updated.fullName, 'Maya Nair');
    expect(updated.dateOfBirth, DateTime(2010, 9, 8));
    expect(updated.gender, Gender.other);
    expect(updated.relationshipToHead, RelationshipToHead.sibling);
    expect(updated.personPhone, '0123456789');
    expect(updated.isHead, isFalse);
  });

  test(
    'head can be edited but remains the only head with Head relationship',
    () async {
      final updated = await service.updateMember(
        existing: head,
        input: _input(
          fullName: 'Updated head',
          gender: Gender.male,
          relationship: null,
        ),
      );

      expect(updated.isHead, isTrue);
      expect(updated.relationshipToHead, RelationshipToHead.head);
      expect(
        (await memberRepository.listForHousehold(household.id))
            .where((member) => member.isHead),
        hasLength(1),
      );
    },
  );

  test('archives regular members, blocks head removal, and restores archived records', () async {
    final member = await service.addMember(
      householdId: household.id,
      input: _input(),
    );

    await expectLater(service.archiveMember(head), throwsStateError);
    await service.archiveMember(member);
    final activeMembers = await memberRepository.listForHousehold(household.id);
    expect(activeMembers, hasLength(1));
    expect(activeMembers.single.id, head.id);
    expect(activeMembers.single.isHead, isTrue);
    expect(
      await memberRepository.listForHousehold(
        household.id,
        includeArchived: true,
      ),
      hasLength(2),
    );

    await service.restoreMember(member);
    expect(await memberRepository.listForHousehold(household.id), hasLength(2));
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

Household _household() => Household.create(
  houseName: 'Family home',
  addressLine: 'Main Road',
  rationCardType: RationCardType.apl,
  hasOwnWell: false,
  houseType: HouseType.concreteTerrace,
  now: DateTime.utc(2026, 1, 1),
);

Member _head(String householdId) => Member.createHead(
  householdId: householdId,
  fullName: 'Family head',
  dateOfBirth: DateTime(1970, 1, 1),
  gender: Gender.female,
  now: DateTime.utc(2026, 1, 1),
);

MemberFormInput _input({
  String fullName = 'Maya Nair',
  DateTime? dateOfBirth,
  Gender? gender = Gender.female,
  RelationshipToHead? relationship = RelationshipToHead.daughter,
  String phone = '',
}) => MemberFormInput(
  fullName: fullName,
  dateOfBirth: dateOfBirth ?? DateTime(2012, 3, 4),
  gender: gender,
  relationshipToHead: relationship,
  phone: phone,
);
