import 'household_registration_input.dart';

enum HouseholdRegistrationField {
  houseName,
  addressLine,
  rationCardType,
  hasOwnWell,
  houseType,
  headFullName,
  headDateOfBirth,
  headGender,
}

enum HouseholdRegistrationIssue { required, futureDate }

class HouseholdRegistrationValidator {
  const HouseholdRegistrationValidator();

  Map<HouseholdRegistrationField, HouseholdRegistrationIssue> validate(
    HouseholdRegistrationInput input, {
    DateTime? now,
  }) {
    final issues = <HouseholdRegistrationField, HouseholdRegistrationIssue>{};

    void requireText(String value, HouseholdRegistrationField field) {
      if (value.trim().isEmpty) {
        issues[field] = HouseholdRegistrationIssue.required;
      }
    }

    requireText(input.houseName, HouseholdRegistrationField.houseName);
    requireText(input.addressLine, HouseholdRegistrationField.addressLine);
    requireText(input.headFullName, HouseholdRegistrationField.headFullName);
    if (input.rationCardType == null || input.rationCardType!.requiresReview) {
      issues[HouseholdRegistrationField.rationCardType] =
          HouseholdRegistrationIssue.required;
    }
    if (input.hasOwnWell == null) {
      issues[HouseholdRegistrationField.hasOwnWell] =
          HouseholdRegistrationIssue.required;
    }
    if (input.houseType == null) {
      issues[HouseholdRegistrationField.houseType] =
          HouseholdRegistrationIssue.required;
    }
    if (input.headGender == null) {
      issues[HouseholdRegistrationField.headGender] =
          HouseholdRegistrationIssue.required;
    }

    final dateOfBirth = input.headDateOfBirth;
    if (dateOfBirth == null) {
      issues[HouseholdRegistrationField.headDateOfBirth] =
          HouseholdRegistrationIssue.required;
    } else {
      final referenceDate = now ?? DateTime.now();
      final birthDate = DateTime(
        dateOfBirth.year,
        dateOfBirth.month,
        dateOfBirth.day,
      );
      final today = DateTime(
        referenceDate.year,
        referenceDate.month,
        referenceDate.day,
      );
      if (birthDate.isAfter(today)) {
        issues[HouseholdRegistrationField.headDateOfBirth] =
            HouseholdRegistrationIssue.futureDate;
      }
    }
    return issues;
  }
}
