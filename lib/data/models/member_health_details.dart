enum HealthAnswer {
  yes('yes'),
  no('no'),
  unknown('unknown');

  const HealthAnswer(this.code);

  final String code;

  static HealthAnswer fromCode(String code) =>
      values.firstWhere((answer) => answer.code == code);
}

enum IllnessCode {
  diabetic('DIABETIC'),
  bloodPressure('BLOOD_PRESSURE'),
  cholesterol('CHOLESTEROL'),
  other('OTHER');

  const IllnessCode(this.code);

  final String code;

  static IllnessCode fromCode(String code) =>
      values.firstWhere((illness) => illness.code == code);
}

class MemberHealthDetails {
  const MemberHealthDetails({
    required this.memberId,
    required this.illnesses,
    required this.updatedAt,
    this.otherIllnessText,
    this.hasCancer,
    this.hasAsthma,
    this.hasHeartDisease,
  });

  final String memberId;
  final Set<IllnessCode> illnesses;
  final String? otherIllnessText;
  final HealthAnswer? hasCancer;
  final HealthAnswer? hasAsthma;
  final HealthAnswer? hasHeartDisease;
  final DateTime updatedAt;
}
