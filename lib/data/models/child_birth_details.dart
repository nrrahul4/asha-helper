enum ChildDeliveryType {
  vaginal('vaginal'),
  caesarean('caesarean');

  const ChildDeliveryType(this.code);

  final String code;

  static ChildDeliveryType fromCode(String code) =>
      values.firstWhere((value) => value.code == code);
}

class ChildBirthDetails {
  const ChildBirthDetails({
    required this.memberId,
    required this.updatedAt,
    this.birthWeightKg,
    this.birthTime,
    this.deliveryType,
    this.specialCareRequired,
    this.specialCareDetails,
  });

  final String memberId;
  final double? birthWeightKg;
  final String? birthTime;
  final ChildDeliveryType? deliveryType;
  final bool? specialCareRequired;
  final String? specialCareDetails;
  final DateTime updatedAt;

  Map<String, Object?> toMap() => {
    'member_id': memberId,
    'birth_weight_kg': birthWeightKg,
    'birth_time': _trimToNull(birthTime),
    'delivery_type': deliveryType?.code,
    'special_care_required': specialCareRequired == null
        ? null
        : specialCareRequired!
        ? 'yes'
        : 'no',
    'special_care_details': specialCareRequired == true
        ? _trimToNull(specialCareDetails)
        : null,
    'updated_at': updatedAt.toUtc().toIso8601String(),
  };

  factory ChildBirthDetails.fromMap(Map<String, Object?> map) {
    final specialCareCode = map['special_care_required'] as String?;
    final deliveryCode = map['delivery_type'] as String?;
    final weight = map['birth_weight_kg'] as num?;
    return ChildBirthDetails(
      memberId: _string(map, 'member_id'),
      birthWeightKg: weight?.toDouble(),
      birthTime: map['birth_time'] as String?,
      deliveryType: deliveryCode == null
          ? null
          : ChildDeliveryType.fromCode(deliveryCode),
      specialCareRequired: switch (specialCareCode) {
        'yes' => true,
        'no' => false,
        _ => null,
      },
      specialCareDetails: map['special_care_details'] as String?,
      updatedAt: DateTime.parse(_string(map, 'updated_at')).toUtc(),
    );
  }
}

String _string(Map<String, Object?> map, String key) {
  final value = map[key];
  if (value is String) return value;
  throw FormatException('Missing or invalid database field: $key');
}

String? _trimToNull(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}
