import '../../domain/age_calculator.dart';
import '../database/app_database.dart';
import '../models/database_codes.dart';
import '../models/family_report_summary.dart';

class FamilyReportRepository {
  FamilyReportRepository(this._appDatabase);

  final AppDatabase _appDatabase;

  Future<FamilyReportSummary> load({DateTime? referenceDate}) async {
    final db = await _appDatabase.database;
    final today = referenceDate ?? DateTime.now();
    final households = await db.rawQuery(
      '''
      SELECT ration_card_type, house_type, has_own_well
      FROM household
      WHERE is_archived = 0 AND record_status = ?
    ''',
      [HouseholdRecordStatus.complete.code],
    );
    final members = await db.rawQuery(
      '''
      SELECT m.gender, m.date_of_birth
      FROM member AS m
      JOIN household AS h ON h.household_id = m.household_id
      WHERE m.is_archived = 0
        AND h.is_archived = 0
        AND h.record_status = ?
    ''',
      [HouseholdRecordStatus.complete.code],
    );

    final genderCounts = {for (final value in Gender.values) value: 0};
    final ageBandCounts = {for (final value in FamilyAgeBand.values) value: 0};
    for (final member in members) {
      final gender = Gender.fromCode(member['gender']! as String);
      genderCounts[gender] = genderCounts[gender]! + 1;
      final age = AgeCalculator.completedYears(
        DateTime.parse(member['date_of_birth']! as String),
        today,
      );
      final band = switch (age) {
        <= 5 => FamilyAgeBand.zeroToFive,
        <= 17 => FamilyAgeBand.sixToSeventeen,
        <= 59 => FamilyAgeBand.eighteenToFiftyNine,
        _ => FamilyAgeBand.sixtyPlus,
      };
      ageBandCounts[band] = ageBandCounts[band]! + 1;
    }

    final rationCardCounts = {
      for (final value in RationCardType.values) value: 0,
    };
    final houseTypeCounts = {for (final value in HouseType.values) value: 0};
    final wellOwnershipCounts = {true: 0, false: 0};
    for (final household in households) {
      final card = RationCardType.fromCode(
        household['ration_card_type']! as String,
      );
      final houseType = HouseType.fromCode(household['house_type']! as String);
      final hasWell = household['has_own_well'] == 1;
      rationCardCounts[card] = rationCardCounts[card]! + 1;
      houseTypeCounts[houseType] = houseTypeCounts[houseType]! + 1;
      wellOwnershipCounts[hasWell] = wellOwnershipCounts[hasWell]! + 1;
    }

    return FamilyReportSummary(
      householdCount: households.length,
      memberCount: members.length,
      genderCounts: Map.unmodifiable(genderCounts),
      ageBandCounts: Map.unmodifiable(ageBandCounts),
      rationCardCounts: Map.unmodifiable(rationCardCounts),
      houseTypeCounts: Map.unmodifiable(houseTypeCounts),
      wellOwnershipCounts: Map.unmodifiable(wellOwnershipCounts),
    );
  }
}
