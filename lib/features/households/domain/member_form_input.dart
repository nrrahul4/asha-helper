import '../../../data/models/database_codes.dart';

class MemberFormInput {
  const MemberFormInput({
    required this.fullName,
    required this.dateOfBirth,
    required this.gender,
    required this.relationshipToHead,
    this.phone = '',
  });

  final String fullName;
  final DateTime? dateOfBirth;
  final Gender? gender;
  final RelationshipToHead? relationshipToHead;
  final String phone;
}
