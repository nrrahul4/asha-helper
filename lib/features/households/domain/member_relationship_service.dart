import '../../../data/models/member.dart';
import '../../../data/models/member_relationship.dart';
import '../../../data/repositories/member_repository.dart';

class MemberRelationshipService {
  MemberRelationshipService(this._memberRepository);

  final MemberRepository _memberRepository;

  Future<List<Member>> householdMembers(String householdId) =>
      _memberRepository.listForHousehold(householdId);

  Future<List<MemberRelationship>> forMember(String memberId) =>
      _memberRepository.listRelationshipsForMember(memberId);

  Future<void> add({
    required String memberId,
    required String otherMemberId,
    required MemberRelationshipType type,
    required bool memberIsMother,
    required DateTime now,
  }) => _memberRepository.addRelationship(
    fromMemberId: type == MemberRelationshipType.motherOf && !memberIsMother
        ? otherMemberId
        : memberId,
    toMemberId: type == MemberRelationshipType.motherOf && !memberIsMother
        ? memberId
        : otherMemberId,
    type: type,
    now: now,
  );

  Future<bool> end(String relationshipId, DateTime endedAt) =>
      _memberRepository.endRelationship(relationshipId, endedAt);
}
