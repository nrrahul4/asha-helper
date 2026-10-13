import 'database_codes.dart';

enum FamilyAgeBand {
  zeroToFive('0-5'),
  sixToSeventeen('6-17'),
  eighteenToFiftyNine('18-59'),
  sixtyPlus('60+');

  const FamilyAgeBand(this.code);

  final String code;
}

class FamilyReportSummary {
  const FamilyReportSummary({
    required this.householdCount,
    required this.memberCount,
    required this.genderCounts,
    required this.ageBandCounts,
    required this.rationCardCounts,
    required this.houseTypeCounts,
    required this.wellOwnershipCounts,
  });

  final int householdCount;
  final int memberCount;
  final Map<Gender, int> genderCounts;
  final Map<FamilyAgeBand, int> ageBandCounts;
  final Map<RationCardType, int> rationCardCounts;
  final Map<HouseType, int> houseTypeCounts;
  final Map<bool, int> wellOwnershipCounts;
}
