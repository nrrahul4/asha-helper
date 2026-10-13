import '../../../data/models/member_search_query.dart';
import '../../../data/repositories/member_repository.dart';
import '../../../domain/age_calculator.dart';
import 'member_search_filters.dart';
import 'member_search_result.dart';

class MemberSearchService {
  MemberSearchService(this._memberRepository);

  final MemberRepository _memberRepository;

  Future<List<MemberSearchResult>> search(
    MemberSearchFilters filters, {
    DateTime? referenceDate,
  }) async {
    final minimumAge = filters.minimumAge;
    final maximumAge = filters.maximumAge;
    if (minimumAge != null && minimumAge < 0) {
      throw ArgumentError.value(minimumAge, 'minimumAge');
    }
    if (maximumAge != null && maximumAge < 0) {
      throw ArgumentError.value(maximumAge, 'maximumAge');
    }
    if (minimumAge != null && maximumAge != null && minimumAge > maximumAge) {
      throw ArgumentError('Minimum age cannot exceed maximum age.');
    }

    final today = referenceDate ?? DateTime.now();
    final earliestDob = maximumAge == null
        ? null
        : AgeCalculator.earliestDateOfBirthForMaximumAge(maximumAge, today);
    final latestDob = minimumAge == null
        ? null
        : AgeCalculator.latestDateOfBirthForMinimumAge(minimumAge, today);
    final query = MemberSearchQuery(
      textPrefix: _trimToNull(filters.query),
      genderCodes: filters.genders.map((gender) => gender.code).toList(),
      rationCardTypeCodes: filters.rationCardTypes
          .map((type) => type.code)
          .toList(),
      householdId: _trimToNull(filters.householdId),
      earliestDateOfBirth: earliestDob == null ? null : _dateOnly(earliestDob),
      latestDateOfBirth: latestDob == null ? null : _dateOnly(latestDob),
      currentlyPregnantOnly: filters.currentlyPregnantOnly,
    );

    final records = await _memberRepository.search(query);
    return records
        .map(
          (record) => MemberSearchResult(
            member: record.member,
            householdName: record.householdName,
            houseNumber: record.houseNumber,
            rationCardType: record.rationCardType,
            age: AgeCalculator.completedYears(record.member.dateOfBirth, today),
          ),
        )
        .toList(growable: false);
  }
}

String _dateOnly(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';

String? _trimToNull(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}
