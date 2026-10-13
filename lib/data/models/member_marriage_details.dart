enum MaritalStatus {
  yes('yes'),
  no('no'),
  unknown('unknown');

  const MaritalStatus(this.code);

  final String code;

  static MaritalStatus fromCode(String code) =>
      values.firstWhere((status) => status.code == code);
}

enum CounsellingAnswer {
  yes('yes'),
  no('no'),
  notApplicable('not_applicable'),
  unknown('unknown');

  const CounsellingAnswer(this.code);

  final String code;

  static CounsellingAnswer fromCode(String code) =>
      values.firstWhere((answer) => answer.code == code);
}

class MemberMarriageDetails {
  const MemberMarriageDetails({
    required this.memberId,
    required this.maritalStatus,
    required this.updatedAt,
    this.marriageDate,
    this.specialCareRequired,
    this.specialCareDetails,
    this.premaritalCounsellingReceived,
  });

  final String memberId;
  final MaritalStatus maritalStatus;
  final DateTime? marriageDate;
  final bool? specialCareRequired;
  final String? specialCareDetails;
  final CounsellingAnswer? premaritalCounsellingReceived;
  final DateTime updatedAt;
}
