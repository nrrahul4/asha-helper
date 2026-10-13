import '../../../data/models/child_birth_details.dart';
import '../../../data/repositories/member_repository.dart';
import 'child_birth_details_input.dart';

enum ChildBirthDetailsField {
  birthWeightKg,
  birthTime,
  specialCareRequired,
  specialCareDetails,
}

enum ChildBirthDetailsIssue {
  weightOutOfRange,
  invalidTime,
  careAnswerRequired,
  careDetailsRequired,
}

class ChildBirthDetailsValidationException implements Exception {
  const ChildBirthDetailsValidationException(this.issues);

  final Map<ChildBirthDetailsField, ChildBirthDetailsIssue> issues;
}

class ChildBirthDetailsService {
  ChildBirthDetailsService(this._memberRepository);

  final MemberRepository _memberRepository;

  Future<ChildBirthDetails?> get(String memberId) =>
      _memberRepository.getChildBirthDetails(memberId);

  Map<ChildBirthDetailsField, ChildBirthDetailsIssue> validate(
    ChildBirthDetailsInput input,
  ) {
    final issues = <ChildBirthDetailsField, ChildBirthDetailsIssue>{};
    final weight = input.birthWeightKg;
    if (weight != null && (weight < 0.3 || weight > 8.0)) {
      issues[ChildBirthDetailsField.birthWeightKg] =
          ChildBirthDetailsIssue.weightOutOfRange;
    }
    if (input.birthTime != null &&
        !RegExp(r'^(?:[01]\d|2[0-3]):[0-5]\d$').hasMatch(input.birthTime!)) {
      issues[ChildBirthDetailsField.birthTime] =
          ChildBirthDetailsIssue.invalidTime;
    }
    if (input.requiresSpecialCareAnswer && input.specialCareRequired == null) {
      issues[ChildBirthDetailsField.specialCareRequired] =
          ChildBirthDetailsIssue.careAnswerRequired;
    }
    if (input.specialCareRequired == true &&
        (input.specialCareDetails == null ||
            input.specialCareDetails!.trim().isEmpty)) {
      issues[ChildBirthDetailsField.specialCareDetails] =
          ChildBirthDetailsIssue.careDetailsRequired;
    }
    return issues;
  }

  Future<void> save({
    required String memberId,
    required ChildBirthDetailsInput input,
    required DateTime now,
  }) async {
    final issues = validate(input);
    if (issues.isNotEmpty) {
      throw ChildBirthDetailsValidationException(issues);
    }
    await _memberRepository.saveChildBirthDetails(
      ChildBirthDetails(
        memberId: memberId,
        birthWeightKg: input.birthWeightKg,
        birthTime: _trimToNull(input.birthTime),
        deliveryType: input.deliveryType,
        specialCareRequired: input.specialCareRequired,
        specialCareDetails: input.specialCareRequired == true
            ? _trimToNull(input.specialCareDetails)
            : null,
        updatedAt: now.toUtc(),
      ),
    );
  }
}

String? _trimToNull(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}
