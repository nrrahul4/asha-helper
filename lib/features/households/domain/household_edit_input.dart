import '../../../data/models/database_codes.dart';

class HouseholdEditInput {
  const HouseholdEditInput({
    required this.houseName,
    required this.addressLine,
    required this.hasOwnWell,
    required this.houseType,
    required this.houseNumber,
    required this.locality,
    required this.postOffice,
    required this.pincode,
    required this.contactPhone,
    required this.notes,
  });

  final String houseName;
  final String addressLine;
  final bool? hasOwnWell;
  final HouseType? houseType;
  final String houseNumber;
  final String locality;
  final String postOffice;
  final String pincode;
  final String contactPhone;
  final String notes;
}
