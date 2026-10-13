import '../../../data/models/household.dart';
import '../../../data/repositories/household_repository.dart';
import 'household_edit_input.dart';

enum HouseholdEditField { houseName, addressLine, hasOwnWell, houseType }

enum HouseholdEditIssue { required }

class HouseholdEditValidationException implements Exception {
  const HouseholdEditValidationException(this.issues);

  final Map<HouseholdEditField, HouseholdEditIssue> issues;
}

class HouseholdEditService {
  HouseholdEditService(this._householdRepository);

  final HouseholdRepository _householdRepository;

  Map<HouseholdEditField, HouseholdEditIssue> validate(
    HouseholdEditInput input,
  ) {
    final issues = <HouseholdEditField, HouseholdEditIssue>{};
    if (input.houseName.trim().isEmpty) {
      issues[HouseholdEditField.houseName] = HouseholdEditIssue.required;
    }
    if (input.addressLine.trim().isEmpty) {
      issues[HouseholdEditField.addressLine] = HouseholdEditIssue.required;
    }
    if (input.hasOwnWell == null) {
      issues[HouseholdEditField.hasOwnWell] = HouseholdEditIssue.required;
    }
    if (input.houseType == null) {
      issues[HouseholdEditField.houseType] = HouseholdEditIssue.required;
    }
    return issues;
  }

  Future<Household> update({
    required Household household,
    required HouseholdEditInput input,
  }) async {
    final issues = validate(input);
    if (issues.isNotEmpty) throw HouseholdEditValidationException(issues);
    final updated = Household(
      id: household.id,
      houseName: input.houseName.trim(),
      houseNumber: _trimToNull(input.houseNumber),
      addressLine: input.addressLine.trim(),
      locality: _trimToNull(input.locality),
      postOffice: _trimToNull(input.postOffice),
      pincode: _trimToNull(input.pincode),
      contactPhone: _trimToNull(input.contactPhone),
      rationCardType: household.rationCardType,
      hasOwnWell: input.hasOwnWell!,
      houseType: input.houseType!,
      notes: _trimToNull(input.notes),
      createdAt: household.createdAt,
      updatedAt: DateTime.now().toUtc(),
      recordStatus: household.recordStatus,
      isArchived: household.isArchived,
      rationCardReviewRequired: household.rationCardReviewRequired,
    );
    if (!await _householdRepository.update(updated)) {
      throw StateError('Household is no longer active.');
    }
    return updated;
  }
}

String? _trimToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
