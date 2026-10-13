import 'database_codes.dart';
import 'member.dart';

class MemberSearchRecord {
  const MemberSearchRecord({
    required this.member,
    required this.householdName,
    required this.rationCardType,
    this.houseNumber,
  });

  final Member member;
  final String householdName;
  final String? houseNumber;
  final RationCardType rationCardType;
}
