import '../../../data/models/family_planning_record.dart';
import '../../../data/repositories/member_repository.dart';
import 'family_planning_input.dart';

enum FamilyPlanningField { type, method, actionDate }

enum FamilyPlanningIssue {
  typeRequired,
  temporaryMethodRequired,
  actionDateRequired,
  futureActionDate,
}

class FamilyPlanningValidationException implements Exception {
  const FamilyPlanningValidationException(this.issues);

  final Map<FamilyPlanningField, FamilyPlanningIssue> issues;
}

class FamilyPlanningService {
  FamilyPlanningService(this._memberRepository);

  final MemberRepository _memberRepository;

  Future<List<FamilyPlanningRecord>> history(String memberId) =>
      _memberRepository.listFamilyPlanningRecords(memberId);

  Map<FamilyPlanningField, FamilyPlanningIssue> validate(
    FamilyPlanningInput input, {
    required DateTime today,
  }) {
    final issues = <FamilyPlanningField, FamilyPlanningIssue>{};
    if (input.methodUseStatus == CurrentMethodUseStatus.yes) {
      if (input.type == null) {
        issues[FamilyPlanningField.type] = FamilyPlanningIssue.typeRequired;
      } else if (input.type == FamilyPlanningType.temporary &&
          input.temporaryMethod == null) {
        issues[FamilyPlanningField.method] =
            FamilyPlanningIssue.temporaryMethodRequired;
      }
      if (input.actionDate == null) {
        issues[FamilyPlanningField.actionDate] =
            FamilyPlanningIssue.actionDateRequired;
      } else if (_dateOnly(input.actionDate!).isAfter(_dateOnly(today))) {
        issues[FamilyPlanningField.actionDate] =
            FamilyPlanningIssue.futureActionDate;
      }
    }
    return issues;
  }

  Future<void> save({
    required String memberId,
    required FamilyPlanningInput input,
    required DateTime now,
  }) async {
    final issues = validate(input, today: now);
    if (issues.isNotEmpty) {
      throw FamilyPlanningValidationException(issues);
    }
    final usingMethod = input.methodUseStatus == CurrentMethodUseStatus.yes;
    await _memberRepository.addFamilyPlanningRecord(
      FamilyPlanningRecord.create(
        memberId: memberId,
        intention: input.intention,
        methodUseStatus: input.methodUseStatus,
        isCurrent: true,
        type: usingMethod ? input.type : null,
        temporaryMethod:
            usingMethod && input.type == FamilyPlanningType.temporary
            ? input.temporaryMethod
            : null,
        actionDate: usingMethod ? input.actionDate : null,
        remarks: input.remarks,
        now: now,
      ),
    );
  }
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);
