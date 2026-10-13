import '../../../data/models/member_health_details.dart';
import '../../../data/models/member_marriage_details.dart';

class MemberHealthMarriageInput {
  const MemberHealthMarriageInput({
    this.illnesses = const {},
    this.otherIllnessText = '',
    this.hasCancer = HealthAnswer.unknown,
    this.hasAsthma = HealthAnswer.unknown,
    this.hasHeartDisease = HealthAnswer.unknown,
    this.maritalStatus = MaritalStatus.unknown,
    this.marriageDate,
    this.specialCareRequired,
    this.specialCareDetails = '',
    this.premaritalCounsellingReceived = CounsellingAnswer.unknown,
  });

  final Set<IllnessCode> illnesses;
  final String otherIllnessText;
  final HealthAnswer hasCancer;
  final HealthAnswer hasAsthma;
  final HealthAnswer hasHeartDisease;
  final MaritalStatus maritalStatus;
  final DateTime? marriageDate;
  final bool? specialCareRequired;
  final String specialCareDetails;
  final CounsellingAnswer premaritalCounsellingReceived;
}
