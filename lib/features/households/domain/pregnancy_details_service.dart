import '../../../data/models/pregnancy_record.dart';
import '../../../data/repositories/member_repository.dart';
import 'pregnancy_details_input.dart';

enum PregnancyDetailsField {
  lastMensesDate,
  previousPregnancyCount,
  lastLiveBirthDate,
}

enum PregnancyDetailsIssue { futureDate, invalidCount }

class PregnancyDetailsValidationException implements Exception {
  const PregnancyDetailsValidationException(this.issues);

  final Map<PregnancyDetailsField, PregnancyDetailsIssue> issues;
}

class PregnancyDetailsService {
  PregnancyDetailsService(this._memberRepository);

  final MemberRepository _memberRepository;

  Future<PregnancyRecord?> getCurrent(String memberId) =>
      _memberRepository.getCurrentPregnancy(memberId);

  Map<PregnancyDetailsField, PregnancyDetailsIssue> validate(
    PregnancyDetailsInput input, {
    required DateTime today,
  }) {
    final issues = <PregnancyDetailsField, PregnancyDetailsIssue>{};
    final date = DateTime(today.year, today.month, today.day);
    if (input.lastMensesDate != null &&
        _dateOnly(input.lastMensesDate!).isAfter(date)) {
      issues[PregnancyDetailsField.lastMensesDate] =
          PregnancyDetailsIssue.futureDate;
    }
    if (input.previousPregnancyCount != null &&
        input.previousPregnancyCount! < 0) {
      issues[PregnancyDetailsField.previousPregnancyCount] =
          PregnancyDetailsIssue.invalidCount;
    }
    if (input.lastLiveBirthDate != null &&
        _dateOnly(input.lastLiveBirthDate!).isAfter(date)) {
      issues[PregnancyDetailsField.lastLiveBirthDate] =
          PregnancyDetailsIssue.futureDate;
    }
    return issues;
  }

  Future<void> save({
    required String memberId,
    required PregnancyDetailsInput input,
    required DateTime now,
  }) async {
    final issues = validate(input, today: now);
    if (issues.isNotEmpty) {
      throw PregnancyDetailsValidationException(issues);
    }
    final existing = await getCurrent(memberId);
    final record = PregnancyRecord.create(
      motherMemberId: memberId,
      now: now,
      abaId: input.abaId,
      lastMensesDate: input.lastMensesDate,
      consultingHospital: input.consultingHospital,
      previousPregnancyCount: input.previousPregnancyCount,
      lastLiveBirthDate: input.lastLiveBirthDate,
    );
    await _memberRepository.savePregnancy(
      PregnancyRecord(
        id: existing?.id ?? record.id,
        motherMemberId: memberId,
        abaId: record.abaId,
        lastMensesDate: record.lastMensesDate,
        consultingHospital: record.consultingHospital,
        previousPregnancyCount: record.previousPregnancyCount,
        lastLiveBirthDate: record.lastLiveBirthDate,
        isCurrent: true,
        createdAt: existing?.createdAt ?? record.createdAt,
        updatedAt: record.updatedAt,
      ),
    );
  }
}

enum EstimatedTrimester { first, second, third }

class PregnancyEstimate {
  const PregnancyEstimate({
    required this.elapsedDays,
    required this.completedWeeks,
    required this.trimester,
  });

  final int elapsedDays;
  final int completedWeeks;
  final EstimatedTrimester trimester;
}

PregnancyEstimate? estimatePregnancy(DateTime? lmp, DateTime today) {
  if (lmp == null) return null;
  final start = _dateOnly(lmp);
  final end = _dateOnly(today);
  final elapsedDays = end.difference(start).inDays;
  if (elapsedDays < 0 || elapsedDays > 42 * 7) return null;
  final completedWeeks = elapsedDays ~/ 7;
  final trimester = completedWeeks < 14
      ? EstimatedTrimester.first
      : completedWeeks < 28
      ? EstimatedTrimester.second
      : EstimatedTrimester.third;
  return PregnancyEstimate(
    elapsedDays: elapsedDays,
    completedWeeks: completedWeeks,
    trimester: trimester,
  );
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);
