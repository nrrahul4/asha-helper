import '../../../data/models/family_planning_record.dart';

class FamilyPlanningInput {
  const FamilyPlanningInput({
    this.intention = PregnancyAvoidanceIntention.unknown,
    this.methodUseStatus = CurrentMethodUseStatus.unknown,
    this.type,
    this.temporaryMethod,
    this.actionDate,
    this.remarks = '',
  });

  final PregnancyAvoidanceIntention intention;
  final CurrentMethodUseStatus methodUseStatus;
  final FamilyPlanningType? type;
  final TemporaryFamilyPlanningMethod? temporaryMethod;
  final DateTime? actionDate;
  final String remarks;
}
