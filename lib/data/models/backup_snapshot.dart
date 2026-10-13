import '../database/database_migrations.dart';

class BackupSnapshot {
  const BackupSnapshot({required this.schemaVersion, required this.tables});

  final int schemaVersion;
  final Map<String, List<Map<String, Object?>>> tables;

  int get householdCount => tables['household']?.length ?? 0;
  int get memberCount => tables['member']?.length ?? 0;

  Map<String, Object?> toMap() => {
    'formatVersion': 1,
    'schemaVersion': schemaVersion,
    'tables': tables,
  };

  static BackupSnapshot fromMap(Map<String, Object?> map) {
    if (map['formatVersion'] != 1) {
      throw const BackupFormatException('Unsupported backup format.');
    }
    if (map['schemaVersion'] != DatabaseMigrations.latestVersion) {
      throw const BackupFormatException(
        'This backup uses an unsupported database version.',
      );
    }
    final rawTables = map['tables'];
    if (rawTables is! Map) {
      throw const BackupFormatException('Backup table data is missing.');
    }
    final expectedTables = BackupTables.ordered;
    if (rawTables.keys.toSet().difference(expectedTables.toSet()).isNotEmpty ||
        expectedTables.any((table) => !rawTables.containsKey(table))) {
      throw const BackupFormatException(
        'Backup tables do not match this app version.',
      );
    }
    final tables = <String, List<Map<String, Object?>>>{};
    for (final table in expectedTables) {
      final rawRows = rawTables[table];
      if (rawRows is! List) {
        throw const BackupFormatException('Backup table data is invalid.');
      }
      final rows = <Map<String, Object?>>[];
      for (final rawRow in rawRows) {
        if (rawRow is! Map) {
          throw const BackupFormatException('Backup record is invalid.');
        }
        rows.add(Map<String, Object?>.from(rawRow));
      }
      tables[table] = rows;
    }
    return BackupSnapshot(
      schemaVersion: DatabaseMigrations.latestVersion,
      tables: Map.unmodifiable(tables),
    );
  }
}

class BackupFormatException implements Exception {
  const BackupFormatException(this.message);

  final String message;
}

class BackupTables {
  const BackupTables._();

  static const ordered = [
    'lookup_value',
    'household',
    'member',
    'member_general_detail',
    'member_health_detail',
    'member_illness',
    'member_marriage_detail',
    'pregnancy_record',
    'child_birth_detail',
    'member_relationship',
    'family_planning_record',
  ];

  static const reverseOrder = [
    'family_planning_record',
    'member_relationship',
    'child_birth_detail',
    'pregnancy_record',
    'member_marriage_detail',
    'member_illness',
    'member_health_detail',
    'member_general_detail',
    'member',
    'household',
    'lookup_value',
  ];
}
