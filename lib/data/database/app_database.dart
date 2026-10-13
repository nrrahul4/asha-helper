import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_sqlcipher/sqflite.dart' as sqlcipher;

import 'database_migrations.dart';

typedef DatabaseOpener = Future<Database> Function(
  String path, {
  required String password,
  required int version,
  OnDatabaseConfigureFn? onConfigure,
  OnDatabaseCreateFn? onCreate,
  OnDatabaseVersionChangeFn? onUpgrade,
});

class AppDatabase {
  AppDatabase({
    required this.path,
    required this.encryptionKey,
    DatabaseOpener? opener,
  }) : _opener = opener ?? _openEncryptedDatabase {
    if (path.trim().isEmpty) {
      throw ArgumentError.value(path, 'path', 'Must not be empty.');
    }
    if (encryptionKey.trim().isEmpty) {
      throw ArgumentError.value(
        encryptionKey,
        'encryptionKey',
        'Must be provided by secure platform storage.',
      );
    }
  }

  final String path;
  final String encryptionKey;
  final DatabaseOpener _opener;
  Database? _database;
  Future<Database>? _opening;

  Future<Database> get database async {
    final opened = _database;
    if (opened != null) return opened;

    final pending = _opening;
    if (pending != null) return pending;

    final opening = _opener(
      path,
      password: encryptionKey,
      version: DatabaseMigrations.latestVersion,
      onConfigure: _configure,
      onCreate: DatabaseMigrations.onCreate,
      onUpgrade: DatabaseMigrations.onUpgrade,
    );
    _opening = opening;
    try {
      return _database = await opening;
    } catch (_) {
      _opening = null;
      rethrow;
    }
  }

  Future<void> close() async {
    final database = _database;
    _database = null;
    _opening = null;
    await database?.close();
  }

  static Future<void> _configure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  static Future<Database> _openEncryptedDatabase(
    String path, {
    required String password,
    required int version,
    OnDatabaseConfigureFn? onConfigure,
    OnDatabaseCreateFn? onCreate,
    OnDatabaseVersionChangeFn? onUpgrade,
  }) => sqlcipher.openDatabase(
    path,
    password: password,
    version: version,
    onConfigure: onConfigure,
    onCreate: onCreate,
    onUpgrade: onUpgrade,
  );
}
