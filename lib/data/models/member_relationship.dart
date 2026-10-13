enum MemberRelationshipType {
  motherOf('MOTHER_OF'),
  spouseOf('SPOUSE_OF');

  const MemberRelationshipType(this.code);

  final String code;

  static MemberRelationshipType fromCode(String code) =>
      values.firstWhere((value) => value.code == code);
}

class MemberRelationship {
  const MemberRelationship({
    required this.id,
    required this.fromMemberId,
    required this.toMemberId,
    required this.type,
    this.validFrom,
    this.validTo,
  });

  final String id;
  final String fromMemberId;
  final String toMemberId;
  final MemberRelationshipType type;
  final DateTime? validFrom;
  final DateTime? validTo;

  bool get isActive => validTo == null;

  factory MemberRelationship.fromMap(Map<String, Object?> map) {
    final validFrom = map['valid_from'];
    final validTo = map['valid_to'];
    return MemberRelationship(
      id: _string(map, 'relationship_id'),
      fromMemberId: _string(map, 'from_member_id'),
      toMemberId: _string(map, 'to_member_id'),
      type: MemberRelationshipType.fromCode(_string(map, 'relationship_type')),
      validFrom: validFrom is String ? DateTime.parse(validFrom) : null,
      validTo: validTo is String ? DateTime.parse(validTo) : null,
    );
  }
}

String _string(Map<String, Object?> map, String key) {
  final value = map[key];
  if (value is String) return value;
  throw FormatException('Missing or invalid database field: $key');
}
