import '../../../data/models/member_general_details.dart';
import '../../../data/repositories/member_repository.dart';
import 'member_general_details_input.dart';

enum MemberGeneralDetailsField { aadhaarNumber }

enum MemberGeneralDetailsIssue { invalidAadhaar }

class MemberGeneralDetailsValidationException implements Exception {
  const MemberGeneralDetailsValidationException(this.issues);

  final Map<MemberGeneralDetailsField, MemberGeneralDetailsIssue> issues;
}

class MemberGeneralDetailsService {
  MemberGeneralDetailsService(this._memberRepository);

  final MemberRepository _memberRepository;

  Future<MemberGeneralDetails?> get(String memberId) =>
      _memberRepository.getGeneralDetails(memberId);

  Map<MemberGeneralDetailsField, MemberGeneralDetailsIssue> validate(
    MemberGeneralDetailsInput input,
  ) {
    final issues = <MemberGeneralDetailsField, MemberGeneralDetailsIssue>{};
    final aadhaarNumber = input.aadhaarNumber.trim();
    if (aadhaarNumber.isNotEmpty &&
        !RegExp(r'^[0-9]{12}$').hasMatch(aadhaarNumber)) {
      issues[MemberGeneralDetailsField.aadhaarNumber] =
          MemberGeneralDetailsIssue.invalidAadhaar;
    }
    return issues;
  }

  Future<void> save({
    required String memberId,
    required MemberGeneralDetailsInput input,
    DateTime? now,
  }) async {
    final issues = validate(input);
    if (issues.isNotEmpty) {
      throw MemberGeneralDetailsValidationException(issues);
    }
    await _memberRepository.saveGeneralDetails(
      MemberGeneralDetails(
        memberId: memberId,
        aadhaarNumber: _trimToNull(input.aadhaarNumber),
        educationLevel: _trimToNull(input.educationLevel),
        jobTitle: _trimToNull(input.jobTitle),
        isCurrentlyWorkingAbroad: input.isCurrentlyWorkingAbroad,
        bloodGroup: input.bloodGroup,
        updatedAt: (now ?? DateTime.now()).toUtc(),
      ),
    );
  }
}

String? _trimToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
