import 'dart:io';

import 'package:family_tracker/data/database/app_database.dart';
import 'package:family_tracker/data/models/database_codes.dart';
import 'package:family_tracker/data/models/household.dart';
import 'package:family_tracker/data/models/member.dart';
import 'package:family_tracker/data/repositories/household_repository.dart';
import 'package:family_tracker/data/repositories/member_repository.dart';
import 'package:family_tracker/features/households/domain/member_general_details_input.dart';
import 'package:family_tracker/features/households/domain/member_general_details_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory temporaryDirectory;
  late AppDatabase appDatabase;
  late HouseholdRepository householdRepository;
  late MemberRepository memberRepository;
  late MemberGeneralDetailsService service;
  late Household household;
  late Member head;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'member_general_details_test_',
    );
    appDatabase = AppDatabase(
      path: '${temporaryDirectory.path}/households.db',
      encryptionKey: 'test-key-only',
      opener: _openFfiDatabase,
    );
    householdRepository = HouseholdRepository(appDatabase);
    memberRepository = MemberRepository(appDatabase);
    service = MemberGeneralDetailsService(memberRepository);
    household = Household.create(
      houseName: 'Family home',
      addressLine: 'Main Road',
      rationCardType: RationCardType.bpl,
      hasOwnWell: false,
      houseType: HouseType.concreteTerrace,
    );
    head = Member.createHead(
      householdId: household.id,
      fullName: 'Family head',
      dateOfBirth: DateTime(1970, 1, 1),
      gender: Gender.female,
    );
    await householdRepository.createWithHead(household, head);
  });

  tearDown(() async {
    await appDatabase.close();
    await temporaryDirectory.delete(recursive: true);
  });

  test('accepts only 12 ASCII digits for optional Aadhaar', () {
    expect(service.validate(const MemberGeneralDetailsInput()), isEmpty);
    expect(
      service.validate(
        const MemberGeneralDetailsInput(aadhaarNumber: '12345678901'),
      )[MemberGeneralDetailsField.aadhaarNumber],
      MemberGeneralDetailsIssue.invalidAadhaar,
    );
    expect(
      service.validate(
        const MemberGeneralDetailsInput(aadhaarNumber: '12345678901x'),
      )[MemberGeneralDetailsField.aadhaarNumber],
      MemberGeneralDetailsIssue.invalidAadhaar,
    );
    expect(
      service.validate(
        const MemberGeneralDetailsInput(aadhaarNumber: '012345678901'),
      ),
      isEmpty,
    );
  });

  test(
    'saves and reloads member details without losing leading zeroes',
    () async {
      await service.save(
        memberId: head.id,
        input: const MemberGeneralDetailsInput(
          aadhaarNumber: '012345678901',
          educationLevel: '  Higher secondary  ',
          jobTitle: '  Nurse  ',
          isCurrentlyWorkingAbroad: true,
          bloodGroup: BloodGroup.oNegative,
        ),
        now: DateTime.utc(2026, 10, 12),
      );

      final stored = await service.get(head.id);
      expect(stored?.aadhaarNumber, '012345678901');
      expect(stored?.educationLevel, 'Higher secondary');
      expect(stored?.jobTitle, 'Nurse');
      expect(stored?.isCurrentlyWorkingAbroad, isTrue);
      expect(stored?.bloodGroup, BloodGroup.oNegative);
      expect(stored?.updatedAt, DateTime.utc(2026, 10, 12));
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
