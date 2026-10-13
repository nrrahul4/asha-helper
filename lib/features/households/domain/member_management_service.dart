import '../../../data/models/database_codes.dart';
import '../../../data/models/member.dart';
import '../../../data/repositories/member_repository.dart';
import 'member_form_input.dart';

enum MemberValidationField {
  fullName,
  dateOfBirth,
  gender,
  relationship,
  phone,
}

enum MemberValidationIssue { required, futureDate, invalidPhone }

class MemberValidationException implements Exception {
  const MemberValidationException(this.issues);

  final Map<MemberValidationField, MemberValidationIssue> issues;
}

class MemberManagementService {
  MemberManagementService(this._memberRepository);

  final MemberRepository _memberRepository;

  Map<MemberValidationField, MemberValidationIssue> validate(
    MemberFormInput input, {
    required bool isHead,
    DateTime? now,
  }) {
    final issues = <MemberValidationField, MemberValidationIssue>{};
    if (input.fullName.trim().isEmpty) {
      issues[MemberValidationField.fullName] = MemberValidationIssue.required;
    }
    if (input.gender == null) {
      issues[MemberValidationField.gender] = MemberValidationIssue.required;
    }
    if (!isHead && input.relationshipToHead == null) {
      issues[MemberValidationField.relationship] =
          MemberValidationIssue.required;
    } else if (!isHead && input.relationshipToHead == RelationshipToHead.head) {
      issues[MemberValidationField.relationship] =
          MemberValidationIssue.required;
    }

    final dateOfBirth = input.dateOfBirth;
    if (dateOfBirth == null) {
      issues[MemberValidationField.dateOfBirth] =
          MemberValidationIssue.required;
    } else {
      final referenceDate = now ?? DateTime.now();
      final birthDate = DateTime(
        dateOfBirth.year,
        dateOfBirth.month,
        dateOfBirth.day,
      );
      final today = DateTime(
        referenceDate.year,
        referenceDate.month,
        referenceDate.day,
      );
      if (birthDate.isAfter(today)) {
        issues[MemberValidationField.dateOfBirth] =
            MemberValidationIssue.futureDate;
      }
    }

    final phone = input.phone.trim();
    if (phone.isNotEmpty &&
        (!RegExp(r'^\+?[0-9(). -]+$').hasMatch(phone) ||
            !RegExp(r'[0-9]').hasMatch(phone))) {
      issues[MemberValidationField.phone] = MemberValidationIssue.invalidPhone;
    }
    return issues;
  }

  Future<Member> addMember({
    required String householdId,
    required MemberFormInput input,
    DateTime? now,
  }) async {
    final issues = validate(input, isHead: false, now: now);
    if (issues.isNotEmpty) throw MemberValidationException(issues);

    final member = Member.create(
      householdId: householdId,
      fullName: input.fullName,
      dateOfBirth: input.dateOfBirth!,
      gender: input.gender!,
      relationshipToHead: input.relationshipToHead!,
      personPhone: input.phone,
      now: now,
    );
    await _memberRepository.createAdditionalMember(member);
    return member;
  }

  Future<Member> updateMember({
    required Member existing,
    required MemberFormInput input,
    DateTime? now,
  }) async {
    final issues = validate(input, isHead: existing.isHead, now: now);
    if (issues.isNotEmpty) throw MemberValidationException(issues);

    final updated = Member(
      id: existing.id,
      householdId: existing.householdId,
      fullName: input.fullName.trim(),
      dateOfBirth: DateTime(
        input.dateOfBirth!.year,
        input.dateOfBirth!.month,
        input.dateOfBirth!.day,
      ),
      gender: input.gender!,
      relationshipToHead: existing.isHead
          ? RelationshipToHead.head
          : input.relationshipToHead!,
      isHead: existing.isHead,
      personPhone: _trimToNull(input.phone),
      createdAt: existing.createdAt,
      updatedAt: (now ?? DateTime.now()).toUtc(),
      isArchived: existing.isArchived,
    );
    if (!await _memberRepository.update(updated)) {
      throw StateError('The member is no longer available for editing.');
    }
    return updated;
  }

  Future<void> archiveMember(Member member) async {
    if (member.isHead) {
      throw StateError(
        'The head of a completed household cannot be archived alone.',
      );
    }
    if (!await _memberRepository.archive(member.id)) {
      throw StateError('The member is no longer active.');
    }
  }

  Future<void> restoreMember(Member member) async {
    if (!await _memberRepository.restore(member.id)) {
      throw StateError('The member could not be restored.');
    }
  }
}

String? _trimToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
