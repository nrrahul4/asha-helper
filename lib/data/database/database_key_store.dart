import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class SecureValueStore {
  Future<String?> read({required String key});

  Future<void> write({required String key, required String value});
}

class FlutterSecureValueStore implements SecureValueStore {
  FlutterSecureValueStore({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(
              resetOnError: false,
              migrateWithBackup: true,
            ),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.unlocked_this_device,
            ),
          );

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read({required String key}) => _storage.read(key: key);

  @override
  Future<void> write({required String key, required String value}) =>
      _storage.write(key: key, value: value);
}

class DatabaseKeyStore {
  DatabaseKeyStore(this._secureValueStore);

  static const String storageKey = 'family_tracker.database.key.v1';

  final SecureValueStore _secureValueStore;
  Future<String>? _keyOperation;

  Future<String> readOrCreate({required bool databaseExists}) async {
    final pending = _keyOperation;
    if (pending != null) return pending;

    final operation = _readOrCreate(databaseExists: databaseExists);
    _keyOperation = operation;
    try {
      return await operation;
    } catch (_) {
      if (identical(_keyOperation, operation)) _keyOperation = null;
      rethrow;
    }
  }

  Future<String> _readOrCreate({required bool databaseExists}) async {
    final storedKey = await _secureValueStore.read(key: storageKey);
    if (storedKey != null && storedKey.isNotEmpty) {
      await _secureValueStore.write(key: storageKey, value: storedKey);
      return storedKey;
    }
    if (databaseExists) {
      throw StateError(
        'The database encryption key is unavailable. Existing data was left untouched.',
      );
    }

    final keyBytes = List<int>.generate(
      32,
      (_) => Random.secure().nextInt(256),
      growable: false,
    );
    final key = base64UrlEncode(keyBytes);
    await _secureValueStore.write(key: storageKey, value: key);
    return key;
  }
}
