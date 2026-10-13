import '../../../data/models/member_health_details.dart';
import '../../../data/models/member_marriage_details.dart';
import '../../../data/repositories/member_repository.dart';
import 'member_health_marriage_input.dart';

enum MemberHealthMarriageField {
  otherIllnessText,
  marriageDate,
  specialCareRequired,
  specialCareDetails,
}

enum MemberHealthMarriageIssue {
  otherIllnessTextRequired,
  futureMarriageDate,
  specialCareAnswerRequired,
  specialCareDetailsRequired,
}

class MemberHealthMarriageValidationException implements Exception {
  const MemberHealthMarriageValidationException(this.issues);

  final Map<MemberHealthMarriageField, MemberHealthMarriageIssue> issues;
}

class MemberHealthMarriageService {
  MemberHealthMarriageService(this._memberRepository);

  final MemberRepository _memberRepository;

  Future<({MemberHealthDetails? health, MemberMarriageDetails? marriage})> get(
    String memberId,
  ) async => (
    health: await _memberRepository.getHealthDetails(memberId),
    marriage: await _memberRepository.getMarriageDetails(memberId),
  );

  Map<MemberHealthMarriageField, MemberHealthMarriageIssue> validate(
    MemberHealthMarriageInput input, {
    required DateTime today,
  }) {
    final issues = <MemberHealthMarriageField, MemberHealthMarriageIssue>{};
    if (input.illnesses.contains(IllnessCode.other) &&
        input.otherIllnessText.trim().isEmpty) {
      issues[MemberHealthMarriageField.otherIllnessText] =
          MemberHealthMarriageIssue.otherIllnessTextRequired;
    }
    if (input.maritalStatus == MaritalStatus.yes) {
      final marriageDate = input.marriageDate;
      if (marriageDate != null &&
          _dateOnly(marriageDate).isAfter(_dateOnly(today))) {
        issues[MemberHealthMarriageField.marriageDate] =
            MemberHealthMarriageIssue.futureMarriageDate;
      }
      if (input.specialCareRequired == null) {
        issues[MemberHealthMarriageField.specialCareRequired] =
            MemberHealthMarriageIssue.specialCareAnswerRequired;
      }
      if (input.specialCareRequired == true &&
          input.specialCareDetails.trim().isEmpty) {
        issues[MemberHealthMarriageField.specialCareDetails] =
            MemberHealthMarriageIssue.specialCareDetailsRequired;
      }
    }
    return issues;
  }

  Future<void> save({
    required String memberId,
    required MemberHealthMarriageInput input,
    required DateTime now,
  }) async {
    final issues = validate(input, today: now);
    if (issues.isNotEmpty) {
      throw MemberHealthMarriageValidationException(issues);
    }
    final married = input.maritalStatus == MaritalStatus.yes;
    await _memberRepository.saveHealthAndMarriageDetails(
      health: MemberHealthDetails(
        memberId: memberId,
        illnesses: input.illnesses,
        otherIllnessText: input.illnesses.contains(IllnessCode.other)
            ? _trimToNull(input.otherIllnessText)
            : null,
        hasCancer: input.hasCancer,
        hasAsthma: input.hasAsthma,
        hasHeartDisease: input.hasHeartDisease,
        updatedAt: now.toUtc(),
      ),
      marriage: MemberMarriageDetails(
        memberId: memberId,
        maritalStatus: input.maritalStatus,
        marriageDate: married ? input.marriageDate : null,
        specialCareRequired: married ? input.specialCareRequired : null,
        specialCareDetails: married && input.specialCareRequired == true
            ? _trimToNull(input.specialCareDetails)
            : null,
        premaritalCounsellingReceived: married
            ? input.premaritalCounsellingReceived
            : null,
        updatedAt: now.toUtc(),
      ),
    );
  }
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

String? _trimToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
