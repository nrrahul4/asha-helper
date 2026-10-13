class MemberSearchQuery {
  const MemberSearchQuery({
    this.textPrefix,
    this.genderCodes = const [],
    this.rationCardTypeCodes = const [],
    this.householdId,
    this.earliestDateOfBirth,
    this.latestDateOfBirth,
    this.currentlyPregnantOnly = false,
  });

  final String? textPrefix;
  final List<String> genderCodes;
  final List<String> rationCardTypeCodes;
  final String? householdId;
  final String? earliestDateOfBirth;
  final String? latestDateOfBirth;
  final bool currentlyPregnantOnly;
}
