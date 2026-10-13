import 'package:uuid/uuid.dart';

enum PregnancyAvoidanceIntention {
  yes('yes'),
  no('no'),
  notDecided('not_decided'),
  unknown('unknown');

  const PregnancyAvoidanceIntention(this.code);

  final String code;

  static PregnancyAvoidanceIntention fromCode(String code) =>
      values.firstWhere((value) => value.code == code);
}

enum CurrentMethodUseStatus {
  yes('yes'),
  no('no'),
  unknown('unknown');

  const CurrentMethodUseStatus(this.code);

  final String code;

  static CurrentMethodUseStatus fromCode(String code) =>
      values.firstWhere((value) => value.code == code);
}

enum FamilyPlanningType {
  temporary('TEMPORARY'),
  permanent('PERMANENT');

  const FamilyPlanningType(this.code);

  final String code;

  static FamilyPlanningType fromCode(String code) =>
      values.firstWhere((value) => value.code == code);
}

enum TemporaryFamilyPlanningMethod {
  cuT('CU-T'),
  ppiucd('PPIUCD'),
  paiucd('PAIUCD');

  const TemporaryFamilyPlanningMethod(this.code);

  final String code;

  static TemporaryFamilyPlanningMethod fromCode(String code) =>
      values.firstWhere((value) => value.code == code);
}

class FamilyPlanningRecord {
  const FamilyPlanningRecord({
    required this.id,
    required this.memberId,
    required this.intention,
    required this.methodUseStatus,
    required this.isCurrent,
    required this.createdAt,
    required this.updatedAt,
    this.type,
    this.temporaryMethod,
    this.actionDate,
    this.remarks,
  });

  factory FamilyPlanningRecord.create({
    required String memberId,
    required PregnancyAvoidanceIntention intention,
    required CurrentMethodUseStatus methodUseStatus,
    required bool isCurrent,
    required DateTime now,
    FamilyPlanningType? type,
    TemporaryFamilyPlanningMethod? temporaryMethod,
    DateTime? actionDate,
    String? remarks,
  }) {
    final timestamp = now.toUtc();
    return FamilyPlanningRecord(
      id: const Uuid().v4(),
      memberId: memberId,
      intention: intention,
      methodUseStatus: methodUseStatus,
      isCurrent: isCurrent,
      createdAt: timestamp,
      updatedAt: timestamp,
      type: type,
      temporaryMethod: temporaryMethod,
      actionDate: actionDate,
      remarks: _trimToNull(remarks),
    );
  }

  final String id;
  final String memberId;
  final PregnancyAvoidanceIntention intention;
  final CurrentMethodUseStatus methodUseStatus;
  final FamilyPlanningType? type;
  final TemporaryFamilyPlanningMethod? temporaryMethod;
  final DateTime? actionDate;
  final String? remarks;
  final bool isCurrent;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, Object?> toMap() => {
    'family_planning_id': id,
    'member_id': memberId,
    'plan_status': intention.code,
    'intention_status': intention.code,
    'method_use_status': methodUseStatus.code,
    'plan_type': type?.code,
    'method': temporaryMethod?.code,
    'action_date': _dateOnly(actionDate),
    'remarks': _trimToNull(remarks),
    'is_current': isCurrent ? 1 : 0,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
  };

  factory FamilyPlanningRecord.fromMap(Map<String, Object?> map) {
    final intentionCode =
        map['intention_status'] as String? ?? map['plan_status'] as String?;
    final methodStatusCode = map['method_use_status'] as String?;
    final typeCode = map['plan_type'] as String?;
    final methodCode = map['method'] as String?;
    return FamilyPlanningRecord(
      id: _string(map, 'family_planning_id'),
      memberId: _string(map, 'member_id'),
      intention: intentionCode == null
          ? PregnancyAvoidanceIntention.unknown
          : PregnancyAvoidanceIntention.fromCode(intentionCode),
      methodUseStatus: methodStatusCode == null
          ? CurrentMethodUseStatus.unknown
          : CurrentMethodUseStatus.fromCode(methodStatusCode),
      type: typeCode == null ? null : FamilyPlanningType.fromCode(typeCode),
      temporaryMethod: methodCode == null
          ? null
          : TemporaryFamilyPlanningMethod.fromCode(methodCode),
      actionDate: _date(map['action_date']),
      remarks: map['remarks'] as String?,
      isCurrent: _integer(map, 'is_current') == 1,
      createdAt: DateTime.parse(_string(map, 'created_at')).toUtc(),
      updatedAt: DateTime.parse(_string(map, 'updated_at')).toUtc(),
    );
  }
}

DateTime? _date(Object? value) =>
    value is String ? DateTime.parse(value) : null;

String? _dateOnly(DateTime? value) => value == null
    ? null
    : '${value.year.toString().padLeft(4, '0')}-'
          '${value.month.toString().padLeft(2, '0')}-'
          '${value.day.toString().padLeft(2, '0')}';

String _string(Map<String, Object?> map, String key) {
  final value = map[key];
  if (value is String) return value;
  throw FormatException('Missing or invalid database field: $key');
}

int _integer(Map<String, Object?> map, String key) {
  final value = map[key];
  if (value is int) return value;
  throw FormatException('Missing or invalid database field: $key');
}

String? _trimToNull(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}
