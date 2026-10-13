import '../../../data/models/household.dart';
import '../../../data/models/member.dart';
import '../../../data/repositories/household_repository.dart';
import 'household_registration_input.dart';
import 'household_registration_validator.dart';

class HouseholdRegistrationValidationException implements Exception {
  const HouseholdRegistrationValidationException(this.issues);

  final Map<HouseholdRegistrationField, HouseholdRegistrationIssue> issues;
}

class PossibleHouseholdDuplicatesException implements Exception {
  const PossibleHouseholdDuplicatesException(this.households);

  final List<Household> households;
}

class HouseholdRegistrationService {
  HouseholdRegistrationService(
    this._householdRepository, {
    this._validator = const HouseholdRegistrationValidator(),
  });

  final HouseholdRepository _householdRepository;
  final HouseholdRegistrationValidator _validator;

  Future<Household> register(
    HouseholdRegistrationInput input, {
    bool confirmPossibleDuplicates = false,
    DateTime? now,
  }) async {
    final issues = _validator.validate(input, now: now);
    if (issues.isNotEmpty) {
      throw HouseholdRegistrationValidationException(issues);
    }

    final possibleDuplicates = await _householdRepository
        .findPossibleDuplicates(
          houseName: input.houseName,
          houseNumber: input.houseNumber,
          contactPhone: input.contactPhone,
        );
    if (possibleDuplicates.isNotEmpty && !confirmPossibleDuplicates) {
      throw PossibleHouseholdDuplicatesException(possibleDuplicates);
    }

    final timestamp = (now ?? DateTime.now()).toUtc();
    final household = Household.create(
      houseName: input.houseName,
      houseNumber: input.houseNumber,
      addressLine: input.addressLine,
      locality: input.locality,
      postOffice: input.postOffice,
      pincode: input.pincode,
      contactPhone: input.contactPhone,
      rationCardType: input.rationCardType!,
      hasOwnWell: input.hasOwnWell!,
      houseType: input.houseType!,
      now: timestamp,
    );
    final head = Member.createHead(
      householdId: household.id,
      fullName: input.headFullName,
      dateOfBirth: input.headDateOfBirth!,
      gender: input.headGender!,
      personPhone: input.headPhone,
      now: timestamp,
    );

    return _householdRepository.createWithHead(household, head);
  }
}
