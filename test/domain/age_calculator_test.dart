import 'package:family_tracker/domain/age_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('calculates completed years before, on, and after a birthday', () {
    final birthDate = DateTime(2000, 10, 12);

    expect(AgeCalculator.completedYears(birthDate, DateTime(2026, 10, 11)), 25);
    expect(AgeCalculator.completedYears(birthDate, DateTime(2026, 10, 12)), 26);
    expect(AgeCalculator.completedYears(birthDate, DateTime(2026, 10, 13)), 26);
  });

  test('treats a Feb 29 birthday as Feb 28 in non-leap years', () {
    final birthDate = DateTime(2004, 2, 29);

    expect(AgeCalculator.completedYears(birthDate, DateTime(2025, 2, 27)), 20);
    expect(AgeCalculator.completedYears(birthDate, DateTime(2025, 2, 28)), 21);
  });

  test('converts inclusive age limits to DOB boundaries', () {
    final referenceDate = DateTime(2026, 10, 12);

    expect(
      AgeCalculator.latestDateOfBirthForMinimumAge(18, referenceDate),
      DateTime(2008, 10, 12),
    );
    expect(
      AgeCalculator.earliestDateOfBirthForMaximumAge(59, referenceDate),
      DateTime(1966, 10, 13),
    );
  });

  test(
    'includes Feb 29 DOB in minimum-age boundary and excludes it above max',
    () {
      final nonLeapReferenceDate = DateTime(2025, 2, 28);

      expect(
        AgeCalculator.latestDateOfBirthForMinimumAge(1, nonLeapReferenceDate),
        DateTime(2024, 2, 29),
      );
      expect(
        AgeCalculator.earliestDateOfBirthForMaximumAge(0, nonLeapReferenceDate),
        DateTime(2024, 3, 1),
      );
    },
  );

  test('rejects negative bounds and future dates of birth', () {
    expect(
      () => AgeCalculator.completedYears(DateTime(2027), DateTime(2026)),
      throwsArgumentError,
    );
    expect(
      () => AgeCalculator.latestDateOfBirthForMinimumAge(-1, DateTime(2026)),
      throwsArgumentError,
    );
    expect(
      () => AgeCalculator.earliestDateOfBirthForMaximumAge(-1, DateTime(2026)),
      throwsArgumentError,
    );
  });
}
