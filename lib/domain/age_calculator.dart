class AgeCalculator {
  const AgeCalculator._();

  static int completedYears(DateTime dateOfBirth, DateTime referenceDate) {
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
      throw ArgumentError.value(
        dateOfBirth,
        'dateOfBirth',
        'Cannot be in the future.',
      );
    }

    var age = today.year - birthDate.year;
    if (today.isBefore(_anniversaryInYear(birthDate, today.year))) age--;
    return age;
  }

  static DateTime? latestDateOfBirthForMinimumAge(
    int minimumAge,
    DateTime referenceDate,
  ) {
    if (minimumAge < 0) throw ArgumentError.value(minimumAge, 'minimumAge');
    final targetYear = referenceDate.year - minimumAge;
    final anniversary = _anniversaryInYear(referenceDate, targetYear);

    // A Feb 29 DOB qualifies on Feb 28 in non-leap years. Include that day
    // when the corresponding DOB year has Feb 29.
    if (anniversary.month == 2 &&
        anniversary.day == 28 &&
        _isLeapYear(targetYear)) {
      return DateTime(targetYear, 3, 1).subtract(const Duration(days: 1));
    }
    return anniversary;
  }

  static DateTime? earliestDateOfBirthForMaximumAge(
    int maximumAge,
    DateTime referenceDate,
  ) {
    if (maximumAge < 0) throw ArgumentError.value(maximumAge, 'maximumAge');
    final targetYear = referenceDate.year - maximumAge - 1;
    var anniversary = _anniversaryInYear(referenceDate, targetYear);
    if (anniversary.month == 2 &&
        anniversary.day == 28 &&
        _isLeapYear(targetYear)) {
      anniversary = DateTime(targetYear, 2, 29);
    }
    return anniversary.add(const Duration(days: 1));
  }

  static DateTime _anniversaryInYear(DateTime date, int year) {
    if (date.month == 2 && date.day == 29 && !_isLeapYear(year)) {
      return DateTime(year, 2, 28);
    }
    return DateTime(year, date.month, date.day);
  }

  static bool _isLeapYear(int year) =>
      year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);
}
