import 'package:sqflite_common/sqlite_api.dart' show ConflictAlgorithm;
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../models/database_codes.dart';
import '../models/child_birth_details.dart';
import '../models/family_planning_record.dart';
import '../models/member_general_details.dart';
import '../models/member_health_details.dart';
import '../models/member_marriage_details.dart';
import '../models/member_relationship.dart';
import '../models/member.dart';
import '../models/pregnancy_record.dart';
import '../models/member_search_query.dart';
import '../models/member_search_record.dart';

class MemberRepository {
  MemberRepository(this._appDatabase);

  final AppDatabase _appDatabase;

  Future<MemberGeneralDetails?> getGeneralDetails(String memberId) async {
    final db = await _appDatabase.database;
    final rows = await db.query(
      'member_general_detail',
      where: 'member_id = ?',
      whereArgs: [memberId],
      limit: 1,
    );
    return rows.isEmpty ? null : MemberGeneralDetails.fromMap(rows.single);
  }

  Future<void> saveGeneralDetails(MemberGeneralDetails details) async {
    final db = await _appDatabase.database;
    await db.transaction((transaction) async {
      final members = await transaction.query(
        'member',
        columns: ['member_id'],
        where: 'member_id = ? AND is_archived = 0',
        whereArgs: [details.memberId],
        limit: 1,
      );
      if (members.isEmpty) {
        throw StateError('General details require an active member.');
      }
      await transaction.insert(
        'member_general_detail',
        details.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<PregnancyRecord?> getCurrentPregnancy(String memberId) async {
    final db = await _appDatabase.database;
    final rows = await db.query(
      'pregnancy_record',
      where: 'mother_member_id = ? AND is_current = 1',
      whereArgs: [memberId],
      limit: 1,
    );
    return rows.isEmpty ? null : PregnancyRecord.fromMap(rows.single);
  }

  Future<void> savePregnancy(PregnancyRecord record) async {
    final db = await _appDatabase.database;
    await db.transaction((transaction) async {
      final members = await transaction.query(
        'member',
        columns: ['member_id'],
        where: 'member_id = ? AND is_archived = 0',
        whereArgs: [record.motherMemberId],
        limit: 1,
      );
      if (members.isEmpty) {
        throw StateError('Pregnancy details require an active member.');
      }
      await transaction.insert(
        'pregnancy_record',
        record.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<ChildBirthDetails?> getChildBirthDetails(String memberId) async {
    final db = await _appDatabase.database;
    final rows = await db.query(
      'child_birth_detail',
      where: 'member_id = ?',
      whereArgs: [memberId],
      limit: 1,
    );
    return rows.isEmpty ? null : ChildBirthDetails.fromMap(rows.single);
  }

  Future<void> saveChildBirthDetails(ChildBirthDetails details) async {
    final db = await _appDatabase.database;
    await db.transaction((transaction) async {
      final members = await transaction.query(
        'member',
        columns: ['member_id'],
        where: 'member_id = ? AND is_archived = 0',
        whereArgs: [details.memberId],
        limit: 1,
      );
      if (members.isEmpty) {
        throw StateError('Child birth details require an active member.');
      }
      await transaction.insert(
        'child_birth_detail',
        details.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<MemberHealthDetails?> getHealthDetails(String memberId) async {
    final db = await _appDatabase.database;
    final rows = await db.query(
      'member_health_detail',
      where: 'member_id = ?',
      whereArgs: [memberId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final row = rows.single;
    final illnesses = await db.query(
      'member_illness',
      columns: ['illness_code', 'other_illness_text'],
      where: 'member_id = ?',
      whereArgs: [memberId],
    );
    final otherRows = illnesses
        .where((illness) => illness['illness_code'] == IllnessCode.other.code)
        .toList(growable: false);
    return MemberHealthDetails(
      memberId: memberId,
      illnesses: illnesses
          .map(
            (illness) =>
                IllnessCode.fromCode(illness['illness_code']! as String),
          )
          .toSet(),
      otherIllnessText: otherRows.isEmpty
          ? null
          : otherRows.single['other_illness_text'] as String?,
      hasCancer: _healthAnswer(row['has_cancer']),
      hasAsthma: _healthAnswer(row['has_asthma']),
      hasHeartDisease: _healthAnswer(row['has_heart_disease']),
      updatedAt: DateTime.parse(row['updated_at']! as String).toUtc(),
    );
  }

  Future<MemberMarriageDetails?> getMarriageDetails(String memberId) async {
    final db = await _appDatabase.database;
    final rows = await db.query(
      'member_marriage_detail',
      where: 'member_id = ?',
      whereArgs: [memberId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final row = rows.single;
    final marriageDate = row['marriage_date'];
    final specialCareCode = row['special_care_required'] as String?;
    final counsellingCode = row['premarital_counselling_received'] as String?;
    return MemberMarriageDetails(
      memberId: memberId,
      maritalStatus: MaritalStatus.fromCode(row['is_married']! as String),
      marriageDate: marriageDate is String
          ? DateTime.parse(marriageDate)
          : null,
      specialCareRequired: switch (specialCareCode) {
        'yes' => true,
        'no' => false,
        _ => null,
      },
      specialCareDetails: row['special_care_details'] as String?,
      premaritalCounsellingReceived: counsellingCode == null
          ? null
          : CounsellingAnswer.fromCode(counsellingCode),
      updatedAt: DateTime.parse(row['updated_at']! as String).toUtc(),
    );
  }

  Future<void> saveHealthAndMarriageDetails({
    required MemberHealthDetails health,
    required MemberMarriageDetails marriage,
  }) async {
    if (health.memberId != marriage.memberId) {
      throw ArgumentError('Health and marriage details must share a member.');
    }
    final db = await _appDatabase.database;
    await db.transaction((transaction) async {
      final members = await transaction.query(
        'member',
        columns: ['member_id'],
        where: 'member_id = ? AND is_archived = 0',
        whereArgs: [health.memberId],
        limit: 1,
      );
      if (members.isEmpty) {
        throw StateError('Sensitive details require an active member.');
      }
      await transaction.insert('member_health_detail', {
        'member_id': health.memberId,
        'has_cancer': health.hasCancer?.code,
        'has_asthma': health.hasAsthma?.code,
        'has_heart_disease': health.hasHeartDisease?.code,
        'updated_at': health.updatedAt.toUtc().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      await transaction.delete(
        'member_illness',
        where: 'member_id = ?',
        whereArgs: [health.memberId],
      );
      for (final illness in health.illnesses) {
        await transaction.insert('member_illness', {
          'member_id': health.memberId,
          'illness_code': illness.code,
          'other_illness_text': illness == IllnessCode.other
              ? _trimToNull(health.otherIllnessText)
              : null,
        });
      }
      final married = marriage.maritalStatus == MaritalStatus.yes;
      await transaction.insert('member_marriage_detail', {
        'member_id': marriage.memberId,
        'is_married': marriage.maritalStatus.code,
        'marriage_date': married ? _dateOnly(marriage.marriageDate) : null,
        'special_care_required': married
            ? _yesNo(marriage.specialCareRequired)
            : null,
        'special_care_details': married && marriage.specialCareRequired == true
            ? _trimToNull(marriage.specialCareDetails)
            : null,
        'premarital_counselling_received': married
            ? marriage.premaritalCounsellingReceived?.code
            : null,
        'updated_at': marriage.updatedAt.toUtc().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<List<FamilyPlanningRecord>> listFamilyPlanningRecords(
    String memberId,
  ) async {
    final db = await _appDatabase.database;
    final rows = await db.query(
      'family_planning_record',
      where: 'member_id = ?',
      whereArgs: [memberId],
      orderBy: 'updated_at DESC, family_planning_id DESC',
    );
    return rows.map(FamilyPlanningRecord.fromMap).toList(growable: false);
  }

  Future<void> addFamilyPlanningRecord(FamilyPlanningRecord record) async {
    if (!record.isCurrent) {
      throw ArgumentError('New family-planning records must be current.');
    }
    final db = await _appDatabase.database;
    await db.transaction((transaction) async {
      final members = await transaction.query(
        'member',
        columns: ['member_id'],
        where: 'member_id = ? AND is_archived = 0',
        whereArgs: [record.memberId],
        limit: 1,
      );
      if (members.isEmpty) {
        throw StateError('Family-planning details require an active member.');
      }
      await transaction.update(
        'family_planning_record',
        {'is_current': 0},
        where: 'member_id = ? AND is_current = 1',
        whereArgs: [record.memberId],
      );
      await transaction.insert('family_planning_record', record.toMap());
    });
  }

  Future<List<MemberRelationship>> listRelationshipsForMember(
    String memberId,
  ) async {
    final db = await _appDatabase.database;
    final rows = await db.query(
      'member_relationship',
      where: 'from_member_id = ? OR to_member_id = ?',
      whereArgs: [memberId, memberId],
      orderBy: 'valid_from DESC, relationship_id',
    );
    return rows.map(MemberRelationship.fromMap).toList(growable: false);
  }

  Future<void> addRelationship({
    required String fromMemberId,
    required String toMemberId,
    required MemberRelationshipType type,
    required DateTime now,
  }) async {
    if (fromMemberId == toMemberId) {
      throw ArgumentError('A member cannot be related to themselves.');
    }
    final db = await _appDatabase.database;
    await db.transaction((transaction) async {
      final members = await transaction.query(
        'member',
        columns: ['member_id', 'household_id'],
        where: 'member_id IN (?, ?) AND is_archived = 0',
        whereArgs: [fromMemberId, toMemberId],
      );
      if (members.length != 2) {
        throw StateError('Relationships require two active household members.');
      }
      final householdIds = members
          .map((member) => member['household_id'])
          .toSet();
      if (householdIds.length != 1) {
        throw StateError(
          'Relationships can only connect members in the same household.',
        );
      }

      final from =
          type == MemberRelationshipType.spouseOf &&
              fromMemberId.compareTo(toMemberId) > 0
          ? toMemberId
          : fromMemberId;
      final to = from == fromMemberId ? toMemberId : fromMemberId;
      final existing = type == MemberRelationshipType.motherOf
          ? await transaction.query(
              'member_relationship',
              columns: ['relationship_id'],
              where: '''
                to_member_id = ? AND relationship_type = ? AND valid_to IS NULL
              ''',
              whereArgs: [to, type.code],
              limit: 1,
            )
          : await transaction.query(
              'member_relationship',
              columns: ['relationship_id'],
              where: '''
                relationship_type = ? AND valid_to IS NULL
                AND ((from_member_id = ? AND to_member_id = ?)
                  OR (from_member_id = ? AND to_member_id = ?))
              ''',
              whereArgs: [type.code, from, to, to, from],
              limit: 1,
            );
      if (existing.isNotEmpty) {
        throw StateError('An active relationship already exists.');
      }
      await transaction.insert('member_relationship', {
        'relationship_id': const Uuid().v4(),
        'from_member_id': from,
        'to_member_id': to,
        'relationship_type': type.code,
        'valid_from': _dateOnly(now),
        'valid_to': null,
        'notes': null,
      });
    });
  }

  Future<bool> endRelationship(String relationshipId, DateTime endedAt) async {
    final db = await _appDatabase.database;
    return (await db.update(
          'member_relationship',
          {'valid_to': _dateOnly(endedAt)},
          where: 'relationship_id = ? AND valid_to IS NULL',
          whereArgs: [relationshipId],
        )) >
        0;
  }

  Future<void> createAdditionalMember(Member member) async {
    if (member.isHead ||
        member.relationshipToHead == RelationshipToHead.head ||
        member.isArchived) {
      throw ArgumentError(
        'The member form can only add an active non-head member.',
      );
    }

    final db = await _appDatabase.database;
    await db.transaction((transaction) async {
      final households = await transaction.query(
        'household',
        columns: ['record_status'],
        where: 'household_id = ? AND is_archived = 0',
        whereArgs: [member.householdId],
        limit: 1,
      );
      if (households.isEmpty ||
          households.single['record_status'] !=
              HouseholdRecordStatus.complete.code) {
        throw StateError('Members can only be added to a completed household.');
      }
      await transaction.insert('member', member.toMap());
    });
  }

  Future<Member?> getById(String id, {bool includeArchived = false}) async {
    final db = await _appDatabase.database;
    final rows = await db.query(
      'member',
      where: includeArchived
          ? 'member_id = ?'
          : 'member_id = ? AND is_archived = 0',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : Member.fromMap(rows.single);
  }

  Future<List<Member>> listForHousehold(
    String householdId, {
    bool includeArchived = false,
  }) async {
    final db = await _appDatabase.database;
    final rows = await db.query(
      'member',
      where: includeArchived
          ? 'household_id = ?'
          : 'household_id = ? AND is_archived = 0',
      whereArgs: [householdId],
      orderBy: 'is_head DESC, full_name COLLATE NOCASE',
    );
    return rows.map(Member.fromMap).toList(growable: false);
  }

  Future<List<MemberSearchRecord>> search(MemberSearchQuery query) async {
    final conditions = <String>[
      'm.is_archived = 0',
      'h.is_archived = 0',
      "h.record_status = 'complete'",
    ];
    final arguments = <Object?>[];

    if (query.genderCodes.isNotEmpty) {
      conditions.add(
        'm.gender IN (${List.filled(query.genderCodes.length, '?').join(', ')})',
      );
      arguments.addAll(query.genderCodes);
    }
    if (query.rationCardTypeCodes.isNotEmpty) {
      conditions.add(
        'h.ration_card_type IN '
        '(${List.filled(query.rationCardTypeCodes.length, '?').join(', ')})',
      );
      arguments.addAll(query.rationCardTypeCodes);
    }
    if (query.householdId != null) {
      conditions.add('h.household_id = ?');
      arguments.add(query.householdId);
    }
    if (query.earliestDateOfBirth != null) {
      conditions.add('m.date_of_birth >= ?');
      arguments.add(query.earliestDateOfBirth);
    }
    if (query.latestDateOfBirth != null) {
      conditions.add('m.date_of_birth <= ?');
      arguments.add(query.latestDateOfBirth);
    }
    if (query.currentlyPregnantOnly) {
      conditions.add('''
        EXISTS (
          SELECT 1
          FROM pregnancy_record AS pr
          WHERE pr.mother_member_id = m.member_id
            AND pr.is_current = 1
        )
      ''');
    }
    final textPrefix = query.textPrefix?.trim();
    if (textPrefix != null && textPrefix.isNotEmpty) {
      final pattern = '${_escapeLikePattern(textPrefix)}%';
      conditions.add('''
        (
          m.full_name COLLATE NOCASE LIKE ? ESCAPE '\\' OR
          h.house_name COLLATE NOCASE LIKE ? ESCAPE '\\' OR
          h.house_number COLLATE NOCASE LIKE ? ESCAPE '\\' OR
          m.person_phone LIKE ? ESCAPE '\\' OR
          h.contact_phone LIKE ? ESCAPE '\\'
        )
      ''');
      arguments.addAll(List<Object?>.filled(5, pattern));
    }

    final db = await _appDatabase.database;
    final rows = await db.rawQuery('''
      SELECT m.*, h.house_name AS household_name,
        h.house_number AS household_house_number,
        h.ration_card_type AS household_ration_card_type
      FROM member AS m
      JOIN household AS h ON h.household_id = m.household_id
      WHERE ${conditions.join(' AND ')}
      ORDER BY m.full_name COLLATE NOCASE, h.house_name COLLATE NOCASE
      ''', arguments);

    return rows
        .map(
          (row) => MemberSearchRecord(
            member: Member.fromMap(row),
            householdName: row['household_name']! as String,
            houseNumber: row['household_house_number'] as String?,
            rationCardType: RationCardType.fromCode(
              row['household_ration_card_type']! as String,
            ),
          ),
        )
        .toList(growable: false);
  }

  Future<bool> update(Member member) async {
    final db = await _appDatabase.database;
    return db.transaction((transaction) async {
      final rows = await transaction.query(
        'member',
        columns: ['household_id', 'is_head', 'created_at'],
        where: 'member_id = ? AND is_archived = 0',
        whereArgs: [member.id],
        limit: 1,
      );
      if (rows.isEmpty) return false;

      final existing = rows.single;
      final wasHead = existing['is_head'] == 1;
      if (member.householdId != existing['household_id'] ||
          member.isHead != wasHead ||
          (wasHead != (member.relationshipToHead == RelationshipToHead.head))) {
        throw StateError(
          'A member\'s household and head role cannot be changed.',
        );
      }

      return (await transaction.update(
            'member',
            {
              'full_name': member.fullName.trim(),
              'date_of_birth': _dateOnly(member.dateOfBirth),
              'gender': member.gender.code,
              'relationship_to_head': member.relationshipToHead.code,
              'person_phone': _trimToNull(member.personPhone),
              'updated_at': DateTime.now().toUtc().toIso8601String(),
            },
            where: 'member_id = ? AND is_archived = 0',
            whereArgs: [member.id],
          )) >
          0;
    });
  }

  Future<bool> archive(String id) async {
    final db = await _appDatabase.database;
    return db.transaction((transaction) async {
      final rows = await transaction.rawQuery(
        '''
        SELECT m.household_id, m.is_head, h.record_status
        FROM member AS m
        JOIN household AS h ON h.household_id = m.household_id
        WHERE m.member_id = ? AND m.is_archived = 0
        LIMIT 1
        ''',
        [id],
      );
      if (rows.isEmpty) return false;

      final row = rows.single;
      if (row['is_head'] == 1 &&
          row['record_status'] == HouseholdRecordStatus.complete.code) {
        throw StateError(
          'The head of a completed household cannot be archived alone.',
        );
      }

      return (await transaction.update(
            'member',
            {
              'is_archived': 1,
              'updated_at': DateTime.now().toUtc().toIso8601String(),
            },
            where: 'member_id = ? AND is_archived = 0',
            whereArgs: [id],
          )) >
          0;
    });
  }

  Future<bool> restore(String id) async {
    final db = await _appDatabase.database;
    return db.transaction((transaction) async {
      final rows = await transaction.rawQuery(
        '''
        SELECT h.record_status, h.is_archived
        FROM member AS m
        JOIN household AS h ON h.household_id = m.household_id
        WHERE m.member_id = ? AND m.is_archived = 1
        LIMIT 1
        ''',
        [id],
      );
      if (rows.isEmpty) return false;
      if (rows.single['is_archived'] == 1 ||
          rows.single['record_status'] != HouseholdRecordStatus.complete.code) {
        throw StateError(
          'A member can only be restored to an active household.',
        );
      }

      return (await transaction.update(
            'member',
            {
              'is_archived': 0,
              'updated_at': DateTime.now().toUtc().toIso8601String(),
            },
            where: 'member_id = ? AND is_archived = 1',
            whereArgs: [id],
          )) >
          0;
    });
  }
}

String? _dateOnly(DateTime? value) => value == null
    ? null
    : '${value.year.toString().padLeft(4, '0')}-'
          '${value.month.toString().padLeft(2, '0')}-'
          '${value.day.toString().padLeft(2, '0')}';

String? _yesNo(bool? value) => value == null
    ? null
    : value
    ? 'yes'
    : 'no';

HealthAnswer? _healthAnswer(Object? value) =>
    value is String ? HealthAnswer.fromCode(value) : null;

String? _trimToNull(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

String _escapeLikePattern(String value) =>
    value.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_');
