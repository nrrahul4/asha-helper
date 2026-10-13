import 'package:uuid/uuid.dart';

import 'database_codes.dart';

class Member {
  const Member({
    required this.id,
    required this.householdId,
    required this.fullName,
    required this.dateOfBirth,
    required this.gender,
    required this.relationshipToHead,
    required this.isHead,
    required this.createdAt,
    required this.updatedAt,
    this.personPhone,
    this.isArchived = false,
  });

  factory Member.create({
    required String householdId,
    required String fullName,
    required DateTime dateOfBirth,
    required Gender gender,
    required RelationshipToHead relationshipToHead,
    String? personPhone,
    DateTime? now,
  }) {
    if (relationshipToHead == RelationshipToHead.head) {
      throw ArgumentError.value(
        relationshipToHead,
        'relationshipToHead',
        'Use createHead for the household head.',
      );
    }
    return _create(
      householdId: householdId,
      fullName: fullName,
      dateOfBirth: dateOfBirth,
      gender: gender,
      relationshipToHead: relationshipToHead,
      isHead: false,
      personPhone: personPhone,
      now: now,
    );
  }

  factory Member.createHead({
    required String householdId,
    required String fullName,
    required DateTime dateOfBirth,
    required Gender gender,
    String? personPhone,
    DateTime? now,
  }) => _create(
    householdId: householdId,
    fullName: fullName,
    dateOfBirth: dateOfBirth,
    gender: gender,
    relationshipToHead: RelationshipToHead.head,
    isHead: true,
    personPhone: personPhone,
    now: now,
  );

  static Member _create({
    required String householdId,
    required String fullName,
    required DateTime dateOfBirth,
    required Gender gender,
    required RelationshipToHead relationshipToHead,
    required bool isHead,
    required String? personPhone,
    required DateTime? now,
  }) {
    final timestamp = (now ?? DateTime.now()).toUtc();
    return Member(
      id: const Uuid().v4(),
      householdId: householdId,
      fullName: fullName.trim(),
      dateOfBirth: DateTime(
        dateOfBirth.year,
        dateOfBirth.month,
        dateOfBirth.day,
      ),
      gender: gender,
      relationshipToHead: relationshipToHead,
      isHead: isHead,
      personPhone: _trimToNull(personPhone),
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  final String id;
  final String householdId;
  final String fullName;
  final DateTime dateOfBirth;
  final Gender gender;
  final RelationshipToHead relationshipToHead;
  final bool isHead;
  final String? personPhone;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;

  Map<String, Object?> toMap() => {
    'member_id': id,
    'household_id': householdId,
    'full_name': fullName.trim(),
    'date_of_birth': _dateOnly(dateOfBirth),
    'gender': gender.code,
    'relationship_to_head': relationshipToHead.code,
    'is_head': isHead ? 1 : 0,
    'person_phone': _trimToNull(personPhone),
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'is_archived': isArchived ? 1 : 0,
  };

  factory Member.fromMap(Map<String, Object?> map) => Member(
    id: _string(map, 'member_id'),
    householdId: _string(map, 'household_id'),
    fullName: _string(map, 'full_name'),
    dateOfBirth: DateTime.parse(_string(map, 'date_of_birth')),
    gender: Gender.fromCode(_string(map, 'gender')),
    relationshipToHead: RelationshipToHead.fromCode(
      _string(map, 'relationship_to_head'),
    ),
    isHead: _integer(map, 'is_head') == 1,
    personPhone: map['person_phone'] as String?,
    createdAt: DateTime.parse(_string(map, 'created_at')).toUtc(),
    updatedAt: DateTime.parse(_string(map, 'updated_at')).toUtc(),
    isArchived: _integer(map, 'is_archived') == 1,
  );
}

String _dateOnly(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-'
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
