import 'dart:io';

import 'package:family_tracker/data/database/app_database.dart';
import 'package:family_tracker/data/models/database_codes.dart';
import 'package:family_tracker/data/models/household.dart';
import 'package:family_tracker/data/models/member.dart';
import 'package:family_tracker/data/models/member_health_details.dart';
import 'package:family_tracker/data/models/member_marriage_details.dart';
import 'package:family_tracker/data/repositories/household_repository.dart';
import 'package:family_tracker/data/repositories/member_repository.dart';
import 'package:family_tracker/features/households/domain/member_health_marriage_input.dart';
import 'package:family_tracker/features/households/domain/member_health_marriage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory temporaryDirectory;
  late AppDatabase appDatabase;
  late MemberHealthMarriageService service;
  late Household household;
  late Member member;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'health_marriage_test_',
    );
    appDatabase = AppDatabase(
      path: '${temporaryDirectory.path}/households.db',
      encryptionKey: 'test-key-only',
      opener: _openFfiDatabase,
    );
    final householdRepository = HouseholdRepository(appDatabase);
    service = MemberHealthMarriageService(MemberRepository(appDatabase));
    household = Household.create(
      houseName: 'Family home',
      addressLine: 'Main Road',
      rationCardType: RationCardType.bpl,
      hasOwnWell: false,
      houseType: HouseType.concreteTerrace,
    );
    member = Member.createHead(
      householdId: household.id,
      fullName: 'Family head',
      dateOfBirth: DateTime(1990, 1, 1),
      gender: Gender.female,
    );
    await householdRepository.createWithHead(household, member);
  });

  tearDown(() async {
    await appDatabase.close();
    await temporaryDirectory.delete(recursive: true);
  });

  test('requires Other text and conditionally validates marriage fields', () {
    final errors = service.validate(
      const MemberHealthMarriageInput(
        illnesses: {IllnessCode.other},
        maritalStatus: MaritalStatus.yes,
        specialCareRequired: true,
      ),
      today: DateTime(2026, 10, 12),
    );
    expect(errors, {
      MemberHealthMarriageField.otherIllnessText:
          MemberHealthMarriageIssue.otherIllnessTextRequired,
      MemberHealthMarriageField.specialCareDetails:
          MemberHealthMarriageIssue.specialCareDetailsRequired,
    });
    expect(
      service.validate(
        const MemberHealthMarriageInput(
          maritalStatus: MaritalStatus.no,
          specialCareRequired: true,
        ),
        today: DateTime(2026, 10, 12),
      ),
      isEmpty,
    );
  });

  test(
    'saves health and marriage data transactionally and clears deselected data',
    () async {
      final now = DateTime(2026, 10, 12);
      await service.save(
        memberId: member.id,
        now: now,
        input: MemberHealthMarriageInput(
          illnesses: {IllnessCode.diabetic, IllnessCode.other},
          otherIllnessText: '  Other condition ',
          hasCancer: HealthAnswer.no,
          hasAsthma: HealthAnswer.unknown,
          hasHeartDisease: HealthAnswer.yes,
          maritalStatus: MaritalStatus.yes,
          marriageDate: DateTime(2020, 1, 2),
          specialCareRequired: true,
          specialCareDetails: '  Follow-up care ',
          premaritalCounsellingReceived: CounsellingAnswer.no,
        ),
      );
      var saved = await service.get(member.id);
      expect(saved.health?.illnesses, {
        IllnessCode.diabetic,
        IllnessCode.other,
      });
      expect(saved.health?.otherIllnessText, 'Other condition');
      expect(saved.health?.hasCancer, HealthAnswer.no);
      expect(saved.health?.hasHeartDisease, HealthAnswer.yes);
      expect(saved.marriage?.maritalStatus, MaritalStatus.yes);
      expect(saved.marriage?.specialCareDetails, 'Follow-up care');

      await service.save(
        memberId: member.id,
        now: now.add(const Duration(days: 1)),
        input: const MemberHealthMarriageInput(
          illnesses: {IllnessCode.diabetic},
          maritalStatus: MaritalStatus.no,
        ),
      );
      saved = await service.get(member.id);
      expect(saved.health?.illnesses, {IllnessCode.diabetic});
      expect(saved.health?.otherIllnessText, isNull);
      expect(saved.marriage?.marriageDate, isNull);
      expect(saved.marriage?.specialCareRequired, isNull);
      expect(saved.marriage?.specialCareDetails, isNull);
      expect(saved.marriage?.premaritalCounsellingReceived, isNull);
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
