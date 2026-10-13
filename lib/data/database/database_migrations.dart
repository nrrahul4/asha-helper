import 'package:sqflite_common/sqlite_api.dart';

class DatabaseMigrations {
  static const int latestVersion = 6;

  static Future<void> onCreate(Database db, int version) async {
    await migrate(db, 0, version);
  }

  static Future<void> onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    await migrate(db, oldVersion, newVersion);
  }

  static Future<void> migrate(
    DatabaseExecutor db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 1 && newVersion >= 1) {
      await _createCoreTables(db);
    }
    if (oldVersion < 2 && newVersion >= 2) {
      await _createLookupValues(db);
    }
    if (oldVersion < 3 && newVersion >= 3) {
      await _createSearchIndexes(db);
    }
    if (oldVersion < 4 && newVersion >= 4) {
      await _createV2FeatureTables(db);
    }
    if (oldVersion < 5 && newVersion >= 5) {
      await _addPregnancyConstraints(db);
    }
    if (oldVersion < 6 && newVersion >= 6) {
      await _addRelationshipAndFamilyPlanningConstraints(db);
    }
  }

  static Future<void> _createCoreTables(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE household (
        household_id TEXT PRIMARY KEY,
        house_name TEXT NOT NULL CHECK (length(trim(house_name)) > 0),
        house_number TEXT,
        address_line TEXT NOT NULL CHECK (length(trim(address_line)) > 0),
        locality TEXT,
        post_office TEXT,
        pincode TEXT,
        contact_phone TEXT,
        ration_card_type TEXT NOT NULL,
        has_own_well INTEGER NOT NULL CHECK (has_own_well IN (0, 1)),
        house_type TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        record_status TEXT NOT NULL DEFAULT 'draft'
          CHECK (record_status IN ('draft', 'complete')),
        is_archived INTEGER NOT NULL DEFAULT 0 CHECK (is_archived IN (0, 1))
      )
    ''');
    await db.execute('''
      CREATE TABLE member (
        member_id TEXT PRIMARY KEY,
        household_id TEXT NOT NULL
          REFERENCES household(household_id)
          ON UPDATE CASCADE ON DELETE RESTRICT,
        full_name TEXT NOT NULL CHECK (length(trim(full_name)) > 0),
        date_of_birth TEXT NOT NULL,
        gender TEXT NOT NULL,
        relationship_to_head TEXT NOT NULL,
        is_head INTEGER NOT NULL DEFAULT 0 CHECK (is_head IN (0, 1)),
        person_phone TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_archived INTEGER NOT NULL DEFAULT 0 CHECK (is_archived IN (0, 1)),
        CHECK (
          (is_head = 1 AND relationship_to_head = 'head') OR
          (is_head = 0 AND relationship_to_head <> 'head')
        )
      )
    ''');
    await db.execute('''
      CREATE UNIQUE INDEX ux_member_one_head_per_household
      ON member(household_id) WHERE is_head = 1
    ''');
    await db.execute('''
      CREATE INDEX ix_household_card
      ON household(ration_card_type, is_archived)
    ''');
    await db.execute('''
      CREATE INDEX ix_household_house_number
      ON household(house_number)
    ''');
    await db.execute('''
      CREATE INDEX ix_member_household
      ON member(household_id, is_archived)
    ''');
    await db.execute('''
      CREATE INDEX ix_member_gender
      ON member(gender, is_archived)
    ''');
    await db.execute('''
      CREATE INDEX ix_member_dob
      ON member(date_of_birth, is_archived)
    ''');
  }

  static Future<void> _createLookupValues(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE lookup_value (
        category TEXT NOT NULL,
        code TEXT NOT NULL,
        label_key TEXT NOT NULL,
        sort_order INTEGER NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
        PRIMARY KEY (category, code)
      )
    ''');

    final values = <(String, String, String)>[
      ('ration_card_type', 'bpl', 'rationBpl'),
      ('ration_card_type', 'apl', 'rationApl'),
      ('ration_card_type', 'aay', 'rationAay'),
      ('ration_card_type', 'yellow', 'rationCardYellow'),
      ('ration_card_type', 'pink', 'rationCardPink'),
      ('ration_card_type', 'blue', 'rationCardBlue'),
      ('ration_card_type', 'white', 'rationCardWhite'),
      ('ration_card_type', 'other', 'other'),
      ('ration_card_type', 'unknown', 'unknown'),
      ('house_type', 'tiled_roof', 'houseTypeTiledRoof'),
      ('house_type', 'concrete_terrace', 'houseTypeConcreteTerrace'),
      ('house_type', 'sheet_roof', 'houseTypeSheetRoof'),
      ('house_type', 'other', 'other'),
      ('house_type', 'unknown', 'unknown'),
      ('gender', 'female', 'genderFemale'),
      ('gender', 'male', 'genderMale'),
      ('gender', 'other', 'other'),
      ('gender', 'prefer_not_to_say', 'genderPreferNotToSay'),
      ('gender', 'unknown', 'unknown'),
      ('relationship_to_head', 'head', 'relationshipHead'),
      ('relationship_to_head', 'spouse', 'relationshipSpouse'),
      ('relationship_to_head', 'son', 'relationshipSon'),
      ('relationship_to_head', 'daughter', 'relationshipDaughter'),
      ('relationship_to_head', 'parent', 'relationshipParent'),
      ('relationship_to_head', 'sibling', 'relationshipSibling'),
      ('relationship_to_head', 'grandparent', 'relationshipGrandparent'),
      ('relationship_to_head', 'in_law', 'relationshipInLaw'),
      ('relationship_to_head', 'other', 'other'),
    ];

    for (var index = 0; index < values.length; index++) {
      final value = values[index];
      await db.insert('lookup_value', {
        'category': value.$1,
        'code': value.$2,
        'label_key': value.$3,
        'sort_order': index,
      });
    }
  }

  static Future<void> _createV2FeatureTables(DatabaseExecutor db) async {
    await db.execute('''
      ALTER TABLE household
      ADD COLUMN ration_card_review_required INTEGER NOT NULL DEFAULT 0
        CHECK (ration_card_review_required IN (0, 1))
    ''');
    await db.execute('''
      INSERT OR IGNORE INTO lookup_value
        (category, code, label_key, sort_order)
      VALUES ('ration_card_type', 'bpl', 'rationBpl', 0)
    ''');
    await db.execute('''
      INSERT OR IGNORE INTO lookup_value
        (category, code, label_key, sort_order)
      VALUES ('ration_card_type', 'apl', 'rationApl', 1)
    ''');
    await db.execute('''
      INSERT OR IGNORE INTO lookup_value
        (category, code, label_key, sort_order)
      VALUES ('ration_card_type', 'aay', 'rationAay', 2)
    ''');
    await db.execute('''
      UPDATE household
      SET ration_card_review_required = 1
      WHERE ration_card_type NOT IN ('bpl', 'apl', 'aay')
    ''');
    await db.execute('''
      UPDATE lookup_value
      SET is_active = 0
      WHERE category = 'ration_card_type'
        AND code NOT IN ('bpl', 'apl', 'aay')
    ''');

    await db.execute('''
      CREATE TABLE member_general_detail (
        member_id TEXT PRIMARY KEY
          REFERENCES member(member_id) ON UPDATE CASCADE ON DELETE RESTRICT,
        aadhaar_number TEXT,
        education_level TEXT,
        education_other_text TEXT,
        job_title TEXT,
        is_abroad INTEGER CHECK (is_abroad IN (0, 1)),
        blood_group TEXT,
        updated_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE member_health_detail (
        member_id TEXT PRIMARY KEY
          REFERENCES member(member_id) ON UPDATE CASCADE ON DELETE RESTRICT,
        has_cancer TEXT,
        has_asthma TEXT,
        has_heart_disease TEXT,
        updated_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE member_illness (
        member_id TEXT NOT NULL
          REFERENCES member(member_id) ON UPDATE CASCADE ON DELETE RESTRICT,
        illness_code TEXT NOT NULL,
        other_illness_text TEXT,
        PRIMARY KEY (member_id, illness_code)
      )
    ''');
    await db.execute('''
      CREATE TABLE member_marriage_detail (
        member_id TEXT PRIMARY KEY
          REFERENCES member(member_id) ON UPDATE CASCADE ON DELETE RESTRICT,
        is_married TEXT,
        marriage_date TEXT,
        special_care_required TEXT,
        special_care_details TEXT,
        premarital_counselling_received TEXT,
        updated_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE pregnancy_record (
        pregnancy_id TEXT PRIMARY KEY,
        mother_member_id TEXT NOT NULL
          REFERENCES member(member_id) ON UPDATE CASCADE ON DELETE RESTRICT,
        aba_id TEXT,
        last_menses_date TEXT,
        consulting_hospital TEXT,
        previous_pregnancy_count INTEGER
          CHECK (previous_pregnancy_count >= 0),
        last_child_birth_date TEXT,
        is_current INTEGER NOT NULL DEFAULT 1
          CHECK (is_current IN (0, 1)),
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE INDEX ix_pregnancy_mother_current
      ON pregnancy_record(mother_member_id, is_current)
    ''');
    await db.execute('''
      CREATE TABLE child_birth_detail (
        member_id TEXT PRIMARY KEY
          REFERENCES member(member_id) ON UPDATE CASCADE ON DELETE RESTRICT,
        birth_weight_kg REAL,
        birth_time TEXT,
        delivery_type TEXT,
        special_care_required TEXT,
        special_care_details TEXT,
        updated_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE member_relationship (
        relationship_id TEXT PRIMARY KEY,
        from_member_id TEXT NOT NULL
          REFERENCES member(member_id) ON UPDATE CASCADE ON DELETE RESTRICT,
        to_member_id TEXT NOT NULL
          REFERENCES member(member_id) ON UPDATE CASCADE ON DELETE RESTRICT,
        relationship_type TEXT NOT NULL,
        valid_from TEXT,
        valid_to TEXT,
        notes TEXT,
        CHECK (from_member_id <> to_member_id)
      )
    ''');
    await db.execute('''
      CREATE INDEX ix_member_relationship_from
      ON member_relationship(from_member_id, relationship_type)
    ''');
    await db.execute('''
      CREATE INDEX ix_member_relationship_to
      ON member_relationship(to_member_id, relationship_type)
    ''');
    await db.execute('''
      CREATE TABLE family_planning_record (
        family_planning_id TEXT PRIMARY KEY,
        member_id TEXT NOT NULL
          REFERENCES member(member_id) ON UPDATE CASCADE ON DELETE RESTRICT,
        plan_status TEXT,
        plan_type TEXT,
        method TEXT,
        action_date TEXT,
        remarks TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE INDEX ix_family_planning_member
      ON family_planning_record(member_id, updated_at)
    ''');
  }

  static Future<void> _addPregnancyConstraints(DatabaseExecutor db) async {
    await db.execute('''
      CREATE UNIQUE INDEX ux_pregnancy_one_current_per_member
      ON pregnancy_record(mother_member_id)
      WHERE is_current = 1
    ''');
  }

  static Future<void> _addRelationshipAndFamilyPlanningConstraints(
    DatabaseExecutor db,
  ) async {
    await db.execute('''
      ALTER TABLE family_planning_record
      ADD COLUMN intention_status TEXT
    ''');
    await db.execute('''
      ALTER TABLE family_planning_record
      ADD COLUMN method_use_status TEXT
    ''');
    await db.execute('''
      ALTER TABLE family_planning_record
      ADD COLUMN is_current INTEGER NOT NULL DEFAULT 0
        CHECK (is_current IN (0, 1))
    ''');
    await db.execute('''
      UPDATE family_planning_record
      SET is_current = 1
      WHERE family_planning_id IN (
        SELECT latest.family_planning_id
        FROM family_planning_record AS latest
        WHERE latest.rowid = (
          SELECT candidate.rowid
          FROM family_planning_record AS candidate
          WHERE candidate.member_id = latest.member_id
          ORDER BY candidate.updated_at DESC, candidate.rowid DESC
          LIMIT 1
        )
      )
    ''');
    await db.execute('''
      CREATE UNIQUE INDEX ux_family_planning_one_current_per_member
      ON family_planning_record(member_id)
      WHERE is_current = 1
    ''');
    await db.execute('''
      CREATE UNIQUE INDEX ux_relationship_one_active_mother_per_child
      ON member_relationship(to_member_id)
      WHERE relationship_type = 'MOTHER_OF' AND valid_to IS NULL
    ''');
    await db.execute('''
      CREATE UNIQUE INDEX ux_relationship_one_active_spouse_pair
      ON member_relationship(
        min(from_member_id, to_member_id),
        max(from_member_id, to_member_id)
      )
      WHERE relationship_type = 'SPOUSE_OF' AND valid_to IS NULL
    ''');
  }

  static Future<void> _createSearchIndexes(DatabaseExecutor db) async {
    await db.execute('''
      CREATE INDEX ix_member_search_name
      ON member(full_name COLLATE NOCASE, is_archived)
    ''');
    await db.execute('''
      CREATE INDEX ix_member_search_phone
      ON member(person_phone, is_archived)
    ''');
    await db.execute('''
      CREATE INDEX ix_household_search_name
      ON household(house_name COLLATE NOCASE, is_archived)
    ''');
    await db.execute('''
      CREATE INDEX ix_household_search_number
      ON household(house_number COLLATE NOCASE, is_archived)
    ''');
    await db.execute('''
      CREATE INDEX ix_household_search_phone
      ON household(contact_phone, is_archived)
    ''');
  }
}
