import 'package:uuid/uuid.dart';

class PregnancyRecord {
  const PregnancyRecord({
    required this.id,
    required this.motherMemberId,
    required this.isCurrent,
    required this.createdAt,
    required this.updatedAt,
    this.abaId,
    this.lastMensesDate,
    this.consultingHospital,
    this.previousPregnancyCount,
    this.lastLiveBirthDate,
  });

  factory PregnancyRecord.create({
    required String motherMemberId,
    required DateTime now,
    String? abaId,
    DateTime? lastMensesDate,
    String? consultingHospital,
    int? previousPregnancyCount,
    DateTime? lastLiveBirthDate,
  }) {
    final timestamp = now.toUtc();
    return PregnancyRecord(
      id: const Uuid().v4(),
      motherMemberId: motherMemberId,
      isCurrent: true,
      createdAt: timestamp,
      updatedAt: timestamp,
      abaId: _trimToNull(abaId),
      lastMensesDate: lastMensesDate,
      consultingHospital: _trimToNull(consultingHospital),
      previousPregnancyCount: previousPregnancyCount,
      lastLiveBirthDate: lastLiveBirthDate,
    );
  }

  final String id;
  final String motherMemberId;
  final String? abaId;
  final DateTime? lastMensesDate;
  final String? consultingHospital;
  final int? previousPregnancyCount;
  final DateTime? lastLiveBirthDate;
  final bool isCurrent;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, Object?> toMap() => {
    'pregnancy_id': id,
    'mother_member_id': motherMemberId,
    'aba_id': _trimToNull(abaId),
    'last_menses_date': _dateOnly(lastMensesDate),
    'consulting_hospital': _trimToNull(consultingHospital),
    'previous_pregnancy_count': previousPregnancyCount,
    'last_child_birth_date': _dateOnly(lastLiveBirthDate),
    'is_current': isCurrent ? 1 : 0,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
  };

  factory PregnancyRecord.fromMap(Map<String, Object?> map) => PregnancyRecord(
    id: _string(map, 'pregnancy_id'),
    motherMemberId: _string(map, 'mother_member_id'),
    abaId: map['aba_id'] as String?,
    lastMensesDate: _date(map['last_menses_date']),
    consultingHospital: map['consulting_hospital'] as String?,
    previousPregnancyCount: map['previous_pregnancy_count'] as int?,
    lastLiveBirthDate: _date(map['last_child_birth_date']),
    isCurrent: _integer(map, 'is_current') == 1,
    createdAt: DateTime.parse(_string(map, 'created_at')).toUtc(),
    updatedAt: DateTime.parse(_string(map, 'updated_at')).toUtc(),
  );
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
