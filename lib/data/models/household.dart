import 'package:uuid/uuid.dart';

import 'database_codes.dart';

class Household {
  const Household({
    required this.id,
    required this.houseName,
    required this.addressLine,
    required this.rationCardType,
    required this.hasOwnWell,
    required this.houseType,
    required this.createdAt,
    required this.updatedAt,
    this.houseNumber,
    this.locality,
    this.postOffice,
    this.pincode,
    this.contactPhone,
    this.notes,
    this.recordStatus = HouseholdRecordStatus.draft,
    this.isArchived = false,
    this.rationCardReviewRequired = false,
  });

  factory Household.create({
    required String houseName,
    required String addressLine,
    required RationCardType rationCardType,
    required bool hasOwnWell,
    required HouseType houseType,
    String? houseNumber,
    String? locality,
    String? postOffice,
    String? pincode,
    String? contactPhone,
    String? notes,
    DateTime? now,
  }) {
    final timestamp = (now ?? DateTime.now()).toUtc();
    return Household(
      id: const Uuid().v4(),
      houseName: houseName.trim(),
      houseNumber: _trimToNull(houseNumber),
      addressLine: addressLine.trim(),
      locality: _trimToNull(locality),
      postOffice: _trimToNull(postOffice),
      pincode: _trimToNull(pincode),
      contactPhone: _trimToNull(contactPhone),
      rationCardType: rationCardType,
      hasOwnWell: hasOwnWell,
      houseType: houseType,
      notes: _trimToNull(notes),
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  final String id;
  final String houseName;
  final String? houseNumber;
  final String addressLine;
  final String? locality;
  final String? postOffice;
  final String? pincode;
  final String? contactPhone;
  final RationCardType rationCardType;
  final bool hasOwnWell;
  final HouseType houseType;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final HouseholdRecordStatus recordStatus;
  final bool isArchived;
  final bool rationCardReviewRequired;

  Household copyWith({
    RationCardType? rationCardType,
    HouseholdRecordStatus? recordStatus,
    DateTime? updatedAt,
    bool? isArchived,
    bool? rationCardReviewRequired,
  }) => Household(
    id: id,
    houseName: houseName,
    houseNumber: houseNumber,
    addressLine: addressLine,
    locality: locality,
    postOffice: postOffice,
    pincode: pincode,
    contactPhone: contactPhone,
    rationCardType: rationCardType ?? this.rationCardType,
    hasOwnWell: hasOwnWell,
    houseType: houseType,
    notes: notes,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    recordStatus: recordStatus ?? this.recordStatus,
    isArchived: isArchived ?? this.isArchived,
    rationCardReviewRequired:
        rationCardReviewRequired ?? this.rationCardReviewRequired,
  );

  Map<String, Object?> toMap() => {
    'household_id': id,
    'house_name': houseName.trim(),
    'house_number': _trimToNull(houseNumber),
    'address_line': addressLine.trim(),
    'locality': _trimToNull(locality),
    'post_office': _trimToNull(postOffice),
    'pincode': _trimToNull(pincode),
    'contact_phone': _trimToNull(contactPhone),
    'ration_card_type': rationCardType.code,
    'ration_card_review_required':
        (rationCardReviewRequired || rationCardType.requiresReview) ? 1 : 0,
    'has_own_well': hasOwnWell ? 1 : 0,
    'house_type': houseType.code,
    'notes': _trimToNull(notes),
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'record_status': recordStatus.code,
    'is_archived': isArchived ? 1 : 0,
  };

  factory Household.fromMap(Map<String, Object?> map) => Household(
    id: _string(map, 'household_id'),
    houseName: _string(map, 'house_name'),
    houseNumber: map['house_number'] as String?,
    addressLine: _string(map, 'address_line'),
    locality: map['locality'] as String?,
    postOffice: map['post_office'] as String?,
    pincode: map['pincode'] as String?,
    contactPhone: map['contact_phone'] as String?,
    rationCardType: RationCardType.fromCode(_string(map, 'ration_card_type')),
    hasOwnWell: _integer(map, 'has_own_well') == 1,
    houseType: HouseType.fromCode(_string(map, 'house_type')),
    notes: map['notes'] as String?,
    createdAt: DateTime.parse(_string(map, 'created_at')).toUtc(),
    updatedAt: DateTime.parse(_string(map, 'updated_at')).toUtc(),
    recordStatus: HouseholdRecordStatus.fromCode(_string(map, 'record_status')),
    isArchived: _integer(map, 'is_archived') == 1,
    rationCardReviewRequired: map['ration_card_review_required'] == null
        ? RationCardType.fromCode(_string(map, 'ration_card_type'))
              .requiresReview
        : _integer(map, 'ration_card_review_required') == 1,
  );
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
