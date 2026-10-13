import 'dart:io';

import 'package:family_tracker/data/database/app_database.dart';
import 'package:family_tracker/data/models/database_codes.dart';
import 'package:family_tracker/data/models/family_planning_record.dart';
import 'package:family_tracker/data/models/household.dart';
import 'package:family_tracker/data/models/member.dart';
import 'package:family_tracker/data/repositories/household_repository.dart';
import 'package:family_tracker/data/repositories/member_repository.dart';
import 'package:family_tracker/features/households/domain/family_planning_input.dart';
import 'package:family_tracker/features/households/domain/family_planning_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory temporaryDirectory;
  late AppDatabase appDatabase;
  late FamilyPlanningService service;
  late Household household;
  late Member member;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'family_planning_test_',
    );
    appDatabase = AppDatabase(
      path: '${temporaryDirectory.path}/households.db',
      encryptionKey: 'test-key-only',
      opener: _openFfiDatabase,
    );
    final householdRepository = HouseholdRepository(appDatabase);
    service = FamilyPlanningService(MemberRepository(appDatabase));
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

  test(
    'requires type, method and date for current use and rejects future date',
    () {
      final today = DateTime(2026, 10, 12);
      expect(
        service.validate(
          const FamilyPlanningInput(
            methodUseStatus: CurrentMethodUseStatus.yes,
            type: FamilyPlanningType.temporary,
          ),
          today: today,
        ),
        {
          FamilyPlanningField.method:
              FamilyPlanningIssue.temporaryMethodRequired,
          FamilyPlanningField.actionDate:
              FamilyPlanningIssue.actionDateRequired,
        },
      );
      expect(
        service.validate(
          FamilyPlanningInput(
            methodUseStatus: CurrentMethodUseStatus.yes,
            type: FamilyPlanningType.permanent,
            actionDate: today.add(const Duration(days: 1)),
          ),
          today: today,
        )[FamilyPlanningField.actionDate],
        FamilyPlanningIssue.futureActionDate,
      );
      expect(
        service.validate(
          const FamilyPlanningInput(
            intention: PregnancyAvoidanceIntention.yes,
            methodUseStatus: CurrentMethodUseStatus.no,
          ),
          today: today,
        ),
        isEmpty,
      );
    },
  );

  test('keeps previous entries and marks exactly one current', () async {
    final now = DateTime(2026, 10, 12);
    await service.save(
      memberId: member.id,
      now: now,
      input: FamilyPlanningInput(
        intention: PregnancyAvoidanceIntention.yes,
        methodUseStatus: CurrentMethodUseStatus.yes,
        type: FamilyPlanningType.temporary,
        temporaryMethod: TemporaryFamilyPlanningMethod.cuT,
        actionDate: DateTime(2026, 8, 1),
      ),
    );
    await service.save(
      memberId: member.id,
      now: now.add(const Duration(days: 3)),
      input: const FamilyPlanningInput(
        intention: PregnancyAvoidanceIntention.notDecided,
        methodUseStatus: CurrentMethodUseStatus.no,
      ),
    );

    final history = await service.history(member.id);
    expect(history, hasLength(2));
    expect(history.where((record) => record.isCurrent), hasLength(1));
    expect(history.first.intention, PregnancyAvoidanceIntention.notDecided);
    expect(history.last.temporaryMethod, TemporaryFamilyPlanningMethod.cuT);
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
