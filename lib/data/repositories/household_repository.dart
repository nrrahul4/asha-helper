import '../database/app_database.dart';
import '../models/database_codes.dart';
import '../models/household.dart';
import '../models/member.dart';

class HouseholdRepository {
  HouseholdRepository(this._appDatabase);

  final AppDatabase _appDatabase;

  Future<void> createDraft(Household household) async {
    if (household.recordStatus != HouseholdRecordStatus.draft ||
        household.isArchived ||
        household.rationCardType.requiresReview) {
      throw ArgumentError('A new household must be an active draft.');
    }
    final db = await _appDatabase.database;
    await db.insert('household', household.toMap());
  }

  Future<Household> createWithHead(Household household, Member head) async {
    if (household.isArchived ||
        household.recordStatus != HouseholdRecordStatus.draft ||
        household.rationCardType.requiresReview) {
      throw ArgumentError('A new household must be an active draft.');
    }
    if (head.householdId != household.id ||
        !head.isHead ||
        head.relationshipToHead != RelationshipToHead.head ||
        head.isArchived) {
      throw ArgumentError('The initial member must be this household\'s head.');
    }

    final db = await _appDatabase.database;
    final timestamp = DateTime.now().toUtc();
    final completedHousehold = household.copyWith(
      recordStatus: HouseholdRecordStatus.complete,
      updatedAt: timestamp,
    );
    await db.transaction((transaction) async {
      await transaction.insert('household', completedHousehold.toMap());
      await transaction.insert('member', head.toMap());
    });
    return completedHousehold;
  }

  Future<List<Household>> findPossibleDuplicates({
    required String houseName,
    String? houseNumber,
    String? contactPhone,
  }) async {
    final matchConditions = <String>[];
    final whereArgs = <Object?>[houseName.trim()];
    final normalizedHouseNumber = _trimToNull(houseNumber);
    final normalizedContactPhone = _trimToNull(contactPhone);

    if (normalizedHouseNumber != null) {
      matchConditions.add('house_number = ?');
      whereArgs.add(normalizedHouseNumber);
    }
    if (normalizedContactPhone != null) {
      matchConditions.add('contact_phone = ?');
      whereArgs.add(normalizedContactPhone);
    }
    if (matchConditions.isEmpty) return const [];

    final db = await _appDatabase.database;
    final rows = await db.query(
      'household',
      where:
          'is_archived = 0 AND house_name = ? COLLATE NOCASE AND '
          '(${matchConditions.join(' OR ')})',
      whereArgs: whereArgs,
      orderBy: 'house_name COLLATE NOCASE',
    );
    return rows.map(Household.fromMap).toList(growable: false);
  }

  Future<Household?> getById(String id, {bool includeArchived = false}) async {
    final db = await _appDatabase.database;
    final rows = await db.query(
      'household',
      where: includeArchived
          ? 'household_id = ?'
          : 'household_id = ? AND is_archived = 0',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : Household.fromMap(rows.single);
  }

  Future<List<Household>> list({bool includeArchived = false}) async {
    final db = await _appDatabase.database;
    final rows = await db.query(
      'household',
      where: includeArchived ? null : 'is_archived = 0',
      orderBy: 'house_name COLLATE NOCASE, house_number COLLATE NOCASE',
    );
    return rows.map(Household.fromMap).toList(growable: false);
  }

  Future<bool> update(Household household) async {
    final db = await _appDatabase.database;
    return db.transaction((transaction) async {
      final existingRows = await transaction.query(
        'household',
        columns: ['record_status'],
        where: 'household_id = ? AND is_archived = 0',
        whereArgs: [household.id],
        limit: 1,
      );
      if (existingRows.isEmpty) return false;

      final existingStatus = HouseholdRecordStatus.fromCode(
        existingRows.single['record_status']! as String,
      );
      if (household.recordStatus != existingStatus) {
        throw StateError(
          'Household completion is controlled by head registration.',
        );
      }

      final values = household.toMap()
        ..remove('household_id')
        ..remove('created_at')
        ..remove('record_status')
        ..remove('is_archived')
        ..['updated_at'] = DateTime.now().toUtc().toIso8601String();
      return (await transaction.update(
            'household',
            values,
            where: 'household_id = ? AND is_archived = 0',
            whereArgs: [household.id],
          )) >
          0;
    });
  }

  Future<bool> updateRationCardType(
    String householdId,
    RationCardType rationCardType,
  ) async {
    if (rationCardType.requiresReview) {
      throw ArgumentError.value(
        rationCardType,
        'rationCardType',
        'Select a current ration-card category.',
      );
    }
    final db = await _appDatabase.database;
    return (await db.update(
          'household',
          {
            'ration_card_type': rationCardType.code,
            'ration_card_review_required': 0,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          },
          where: 'household_id = ? AND is_archived = 0',
          whereArgs: [householdId],
        )) >
        0;
  }

  Future<bool> archive(String id) async {
    final db = await _appDatabase.database;
    return db.transaction((transaction) async {
      final timestamp = DateTime.now().toUtc().toIso8601String();
      final updated = await transaction.update(
        'household',
        {'is_archived': 1, 'updated_at': timestamp},
        where: 'household_id = ? AND is_archived = 0',
        whereArgs: [id],
      );
      if (updated == 0) return false;
      await transaction.update(
        'member',
        {'is_archived': 1, 'updated_at': timestamp},
        where: 'household_id = ? AND is_archived = 0',
        whereArgs: [id],
      );
      return true;
    });
  }

  Future<bool> restore(String id) async {
    final db = await _appDatabase.database;
    return (await db.update(
          'household',
          {
            'is_archived': 0,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          },
          where: 'household_id = ? AND is_archived = 1',
          whereArgs: [id],
        )) >
        0;
  }
}

String? _trimToNull(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}
