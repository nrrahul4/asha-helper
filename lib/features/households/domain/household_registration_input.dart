import '../../../data/models/database_codes.dart';

class HouseholdRegistrationInput {
  const HouseholdRegistrationInput({
    required this.houseName,
    required this.addressLine,
    required this.rationCardType,
    required this.hasOwnWell,
    required this.houseType,
    required this.headFullName,
    required this.headDateOfBirth,
    required this.headGender,
    this.houseNumber = '',
    this.locality = '',
    this.postOffice = '',
    this.pincode = '',
    this.contactPhone = '',
    this.headPhone = '',
  });

  final String houseName;
  final String houseNumber;
  final String addressLine;
  final String locality;
  final String postOffice;
  final String pincode;
  final String contactPhone;
  final RationCardType? rationCardType;
  final bool? hasOwnWell;
  final HouseType? houseType;
  final String headFullName;
  final DateTime? headDateOfBirth;
  final Gender? headGender;
  final String headPhone;
}
