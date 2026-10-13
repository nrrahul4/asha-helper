import 'database_codes.dart';

class MemberGeneralDetails {
  const MemberGeneralDetails({
    required this.memberId,
    required this.isCurrentlyWorkingAbroad,
    required this.updatedAt,
    this.aadhaarNumber,
    this.educationLevel,
    this.jobTitle,
    this.bloodGroup,
  });

  final String memberId;
  final String? aadhaarNumber;
  final String? educationLevel;
  final String? jobTitle;
  final bool? isCurrentlyWorkingAbroad;
  final BloodGroup? bloodGroup;
  final DateTime updatedAt;

  Map<String, Object?> toMap() => {
    'member_id': memberId,
    'aadhaar_number': _trimToNull(aadhaarNumber),
    'education_level': _trimToNull(educationLevel),
    'job_title': _trimToNull(jobTitle),
    'is_abroad': isCurrentlyWorkingAbroad == null
        ? null
        : isCurrentlyWorkingAbroad!
        ? 1
        : 0,
    'blood_group': bloodGroup?.code,
    'updated_at': updatedAt.toUtc().toIso8601String(),
  };

  factory MemberGeneralDetails.fromMap(Map<String, Object?> map) {
    final abroadValue = map['is_abroad'];
    final bloodGroupCode = map['blood_group'];
    return MemberGeneralDetails(
      memberId: _string(map, 'member_id'),
      aadhaarNumber: map['aadhaar_number'] as String?,
      educationLevel: map['education_level'] as String?,
      jobTitle: map['job_title'] as String?,
      isCurrentlyWorkingAbroad: abroadValue == null
          ? null
          : _integer(map, 'is_abroad') == 1,
      bloodGroup: bloodGroupCode is String
          ? BloodGroup.fromCode(bloodGroupCode)
          : null,
      updatedAt: DateTime.parse(_string(map, 'updated_at')).toUtc(),
    );
  }
}

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
