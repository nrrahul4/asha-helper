import 'dart:io';

import 'package:family_tracker/data/database/app_database.dart';
import 'package:family_tracker/data/models/database_codes.dart';
import 'package:family_tracker/data/repositories/household_repository.dart';
import 'package:family_tracker/data/repositories/member_repository.dart';
import 'package:family_tracker/features/households/domain/household_registration_input.dart';
import 'package:family_tracker/features/households/domain/household_registration_service.dart';
import 'package:family_tracker/features/households/domain/household_registration_validator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory temporaryDirectory;
  late AppDatabase appDatabase;
  late HouseholdRepository householdRepository;
  late MemberRepository memberRepository;
  late HouseholdRegistrationService service;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'household_registration_service_test_',
    );
    appDatabase = AppDatabase(
      path: '${temporaryDirectory.path}/households.db',
      encryptionKey: 'test-key-only',
      opener: _openFfiDatabase,
    );
    householdRepository = HouseholdRepository(appDatabase);
    memberRepository = MemberRepository(appDatabase);
    service = HouseholdRegistrationService(householdRepository);
  });

  tearDown(() async {
    await appDatabase.close();
    await temporaryDirectory.delete(recursive: true);
  });

  test(
    'reports required fields and future dates without writing data',
    () async {
      final input = HouseholdRegistrationInput(
        houseName: ' ',
        addressLine: '',
        rationCardType: null,
        hasOwnWell: null,
        houseType: null,
        headFullName: '',
        headDateOfBirth: DateTime(2026, 1, 2),
        headGender: null,
      );
      final validator = const HouseholdRegistrationValidator();

      final issues = validator.validate(input, now: DateTime(2026, 1, 1));

      expect(issues[HouseholdRegistrationField.houseName], isNotNull);
      expect(issues[HouseholdRegistrationField.addressLine], isNotNull);
      expect(issues[HouseholdRegistrationField.rationCardType], isNotNull);
      expect(issues[HouseholdRegistrationField.hasOwnWell], isNotNull);
      expect(issues[HouseholdRegistrationField.houseType], isNotNull);
      expect(issues[HouseholdRegistrationField.headFullName], isNotNull);
      expect(
        issues[HouseholdRegistrationField.headDateOfBirth],
        HouseholdRegistrationIssue.futureDate,
      );
      expect(issues[HouseholdRegistrationField.headGender], isNotNull);
      await expectLater(
        service.register(input, now: DateTime(2026, 1, 1)),
        throwsA(isA<HouseholdRegistrationValidationException>()),
      );
      expect(await householdRepository.list(), isEmpty);
    },
  );

  test(
    'registers a complete household and its head with normalized data',
    () async {
      final household = await service.register(
        _validInput(
          houseName: '  Kavungal house  ',
          houseNumber: ' 001/A ',
          pincode: '001234',
          phone: ' 0123456789 ',
        ),
        now: DateTime(2026, 1, 2, 3),
      );

      final storedHousehold = await householdRepository.getById(household.id);
      final members = await memberRepository.listForHousehold(household.id);
      expect(storedHousehold?.recordStatus, HouseholdRecordStatus.complete);
      expect(storedHousehold?.houseName, 'Kavungal house');
      expect(storedHousehold?.houseNumber, '001/A');
      expect(storedHousehold?.pincode, '001234');
      expect(storedHousehold?.contactPhone, '0123456789');
      expect(members, hasLength(1));
      expect(members.single.isHead, isTrue);
      expect(members.single.relationshipToHead, RelationshipToHead.head);
      expect(members.single.fullName, 'Anu Nair');
    },
  );

  test(
    'warns about duplicates and permits registration after confirmation',
    () async {
      await service.register(
        _validInput(houseName: 'Same house', houseNumber: '17/A'),
      );

      await expectLater(
        service.register(
          _validInput(houseName: 'same house', houseNumber: '17/A'),
        ),
        throwsA(
          isA<PossibleHouseholdDuplicatesException>().having(
            (exception) => exception.households,
            'matching households',
            hasLength(1),
          ),
        ),
      );

      final second = await service.register(
        _validInput(houseName: 'same house', houseNumber: '17/A'),
        confirmPossibleDuplicates: true,
      );
      expect(await householdRepository.list(), hasLength(2));
      expect(await householdRepository.getById(second.id), isNotNull);
    },
  );

  test('does not treat a shared house name alone as a duplicate', () async {
    await service.register(_validInput(houseName: 'Shared name'));
    await service.register(_validInput(houseName: 'Shared name'));

    expect(await householdRepository.list(), hasLength(2));
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

HouseholdRegistrationInput _validInput({
  String houseName = 'Nair house',
  String houseNumber = '',
  String pincode = '',
  String phone = '',
}) => HouseholdRegistrationInput(
  houseName: houseName,
  houseNumber: houseNumber,
  addressLine: 'Canal Road',
  locality: 'East Ward',
  postOffice: 'Town',
  pincode: pincode,
  contactPhone: phone,
  rationCardType: RationCardType.bpl,
  hasOwnWell: false,
  houseType: HouseType.tiledRoof,
  headFullName: 'Anu Nair',
  headDateOfBirth: DateTime(1988, 2, 29),
  headGender: Gender.female,
  headPhone: '',
);
