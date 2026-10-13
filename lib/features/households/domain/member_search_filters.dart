import '../../../data/models/database_codes.dart';

class MemberSearchFilters {
  const MemberSearchFilters({
    this.query = '',
    this.genders = const {},
    this.minimumAge,
    this.maximumAge,
    this.rationCardTypes = const {},
    this.householdId,
    this.currentlyPregnantOnly = false,
  });

  final String query;
  final Set<Gender> genders;
  final int? minimumAge;
  final int? maximumAge;
  final Set<RationCardType> rationCardTypes;
  final String? householdId;
  final bool currentlyPregnantOnly;
}
