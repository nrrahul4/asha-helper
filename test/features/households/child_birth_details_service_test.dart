import 'dart:io';

import 'package:family_tracker/data/database/app_database.dart';
import 'package:family_tracker/data/models/child_birth_details.dart';
import 'package:family_tracker/data/models/database_codes.dart';
import 'package:family_tracker/data/models/household.dart';
import 'package:family_tracker/data/models/member.dart';
import 'package:family_tracker/data/repositories/household_repository.dart';
import 'package:family_tracker/data/repositories/member_repository.dart';
import 'package:family_tracker/features/households/domain/child_birth_details_input.dart';
import 'package:family_tracker/features/households/domain/child_birth_details_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory temporaryDirectory;
  late AppDatabase appDatabase;
  late ChildBirthDetailsService service;
  late Household household;
  late Member member;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'child_birth_details_test_',
    );
    appDatabase = AppDatabase(
      path: '${temporaryDirectory.path}/households.db',
      encryptionKey: 'test-key-only',
      opener: _openFfiDatabase,
    );
    final householdRepository = HouseholdRepository(appDatabase);
    service = ChildBirthDetailsService(MemberRepository(appDatabase));
    household = Household.create(
      houseName: 'Family home',
      addressLine: 'Main Road',
      rationCardType: RationCardType.bpl,
      hasOwnWell: false,
      houseType: HouseType.concreteTerrace,
    );
    member = Member.createHead(
      householdId: household.id,
      fullName: 'Child',
      dateOfBirth: DateTime(2025, 1, 1),
      gender: Gender.other,
    );
    await householdRepository.createWithHead(household, member);
  });

  tearDown(() async {
    await appDatabase.close();
    await temporaryDirectory.delete(recursive: true);
  });

  test('validates weight range, time format, and under-one care details', () {
    expect(
      service.validate(
        const ChildBirthDetailsInput(
          birthWeightKg: 0.2,
          birthTime: '25:70',
          specialCareRequired: true,
          requiresSpecialCareAnswer: true,
        ),
      ),
      {
        ChildBirthDetailsField.birthWeightKg:
            ChildBirthDetailsIssue.weightOutOfRange,
        ChildBirthDetailsField.birthTime: ChildBirthDetailsIssue.invalidTime,
        ChildBirthDetailsField.specialCareDetails:
            ChildBirthDetailsIssue.careDetailsRequired,
      },
    );
    expect(
      service.validate(
        const ChildBirthDetailsInput(requiresSpecialCareAnswer: true),
      )[ChildBirthDetailsField.specialCareRequired],
      ChildBirthDetailsIssue.careAnswerRequired,
    );
    expect(
      service.validate(
        const ChildBirthDetailsInput(
          birthWeightKg: 8,
          birthTime: '23:59',
          specialCareRequired: false,
          requiresSpecialCareAnswer: true,
        ),
      ),
      isEmpty,
    );
  });

  test(
    'retains saved details when the child ages out of the form threshold',
    () async {
      await service.save(
        memberId: member.id,
        now: DateTime.utc(2026, 10, 12),
        input: const ChildBirthDetailsInput(
          birthWeightKg: 3.2,
          birthTime: '10:30',
          deliveryType: ChildDeliveryType.vaginal,
          specialCareRequired: true,
          specialCareDetails: 'Follow-up visits',
          requiresSpecialCareAnswer: true,
        ),
      );

      final db = await appDatabase.database;
      await db.update(
        'member',
        {'date_of_birth': '2020-01-01'},
        where: 'member_id = ?',
        whereArgs: [member.id],
      );

      final saved = await service.get(member.id);
      expect(saved?.birthWeightKg, 3.2);
      expect(saved?.birthTime, '10:30');
      expect(saved?.deliveryType, ChildDeliveryType.vaginal);
      expect(saved?.specialCareRequired, isTrue);
      expect(saved?.specialCareDetails, 'Follow-up visits');
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
