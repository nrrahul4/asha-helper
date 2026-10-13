import 'dart:io';

import 'package:family_tracker/data/database/app_database.dart';
import 'package:family_tracker/data/models/database_codes.dart';
import 'package:family_tracker/data/models/household.dart';
import 'package:family_tracker/data/models/member.dart';
import 'package:family_tracker/data/repositories/household_repository.dart';
import 'package:family_tracker/data/repositories/member_repository.dart';
import 'package:family_tracker/features/households/domain/pregnancy_details_input.dart';
import 'package:family_tracker/features/households/domain/pregnancy_details_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory temporaryDirectory;
  late AppDatabase appDatabase;
  late MemberRepository memberRepository;
  late PregnancyDetailsService service;
  late Household household;
  late Member member;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'pregnancy_details_test_',
    );
    appDatabase = AppDatabase(
      path: '${temporaryDirectory.path}/households.db',
      encryptionKey: 'test-key-only',
      opener: _openFfiDatabase,
    );
    final householdRepository = HouseholdRepository(appDatabase);
    memberRepository = MemberRepository(appDatabase);
    service = PregnancyDetailsService(memberRepository);
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

  test('estimates trimester at the approved week boundaries', () {
    final today = DateTime(2026, 10, 12);
    expect(
      estimatePregnancy(
        today.subtract(const Duration(days: 13 * 7 + 6)),
        today,
      )?.trimester,
      EstimatedTrimester.first,
    );
    expect(
      estimatePregnancy(
        today.subtract(const Duration(days: 14 * 7)),
        today,
      )?.trimester,
      EstimatedTrimester.second,
    );
    expect(
      estimatePregnancy(
        today.subtract(const Duration(days: 27 * 7 + 6)),
        today,
      )?.trimester,
      EstimatedTrimester.second,
    );
    expect(
      estimatePregnancy(
        today.subtract(const Duration(days: 28 * 7)),
        today,
      )?.trimester,
      EstimatedTrimester.third,
    );
  });

  test('does not estimate missing, future, or over-42-week LMP dates', () {
    final today = DateTime(2026, 10, 12);
    expect(estimatePregnancy(null, today), isNull);
    expect(
      estimatePregnancy(today.add(const Duration(days: 1)), today),
      isNull,
    );
    expect(
      estimatePregnancy(
        today.subtract(const Duration(days: 42 * 7 + 1)),
        today,
      ),
      isNull,
    );
    expect(
      estimatePregnancy(today.subtract(const Duration(days: 42 * 7)), today),
      isNotNull,
    );
  });

  test('validates pregnancy dates and non-negative previous count', () {
    final today = DateTime(2026, 10, 12);
    expect(
      service.validate(
        PregnancyDetailsInput(
          lastMensesDate: today.add(const Duration(days: 1)),
          previousPregnancyCount: -1,
          lastLiveBirthDate: today.add(const Duration(days: 1)),
        ),
        today: today,
      ),
      {
        PregnancyDetailsField.lastMensesDate: PregnancyDetailsIssue.futureDate,
        PregnancyDetailsField.previousPregnancyCount:
            PregnancyDetailsIssue.invalidCount,
        PregnancyDetailsField.lastLiveBirthDate:
            PregnancyDetailsIssue.futureDate,
      },
    );
  });

  test(
    'saves, reloads, and updates current pregnancy details offline',
    () async {
      final now = DateTime(2026, 10, 12, 10);
      await service.save(
        memberId: member.id,
        now: now,
        input: PregnancyDetailsInput(
          abaId: 'AB-123',
          lastMensesDate: DateTime(2026, 8, 3),
          consultingHospital: 'Community Hospital',
          previousPregnancyCount: 2,
          lastLiveBirthDate: DateTime(2023, 4, 5),
        ),
      );
      final initial = await service.getCurrent(member.id);
      expect(initial?.abaId, 'AB-123');
      expect(initial?.previousPregnancyCount, 2);
      expect(initial?.lastLiveBirthDate, DateTime(2023, 4, 5));

      await service.save(
        memberId: member.id,
        now: now.add(const Duration(days: 1)),
        input: const PregnancyDetailsInput(previousPregnancyCount: 3),
      );
      final updated = await service.getCurrent(member.id);
      expect(updated?.id, initial?.id);
      expect(updated?.createdAt, initial?.createdAt);
      expect(updated?.previousPregnancyCount, 3);
      expect(updated?.abaId, isNull);
      expect(
        (await memberRepository.getCurrentPregnancy(member.id))?.id,
        updated?.id,
      );
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
