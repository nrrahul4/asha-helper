import '../../../data/models/database_codes.dart';
import '../../../data/models/member.dart';

class MemberSearchResult {
  const MemberSearchResult({
    required this.member,
    required this.householdName,
    required this.rationCardType,
    required this.age,
    this.houseNumber,
  });

  final Member member;
  final String householdName;
  final String? houseNumber;
  final RationCardType rationCardType;
  final int age;
}
