import 'package:family_tracker/data/database/database_key_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'creates a random key once and reuses the securely stored key',
    () async {
      final store = _MemorySecureValueStore();
      final keyStore = DatabaseKeyStore(store);

      final key = await keyStore.readOrCreate(databaseExists: false);
      final reusedKey = await keyStore.readOrCreate(databaseExists: true);

      expect(key, hasLength(44));
      expect(reusedKey, key);
      expect(store.values[DatabaseKeyStore.storageKey], key);
    },
  );

  test(
    'does not replace a missing key when an existing database exists',
    () async {
      final store = _MemorySecureValueStore();
      final keyStore = DatabaseKeyStore(store);

      await expectLater(
        keyStore.readOrCreate(databaseExists: true),
        throwsStateError,
      );
      expect(store.values, isEmpty);
    },
  );

  test('concurrent first-use callers receive the same key', () async {
    final store = _MemorySecureValueStore();
    final keyStore = DatabaseKeyStore(store);

    final keys = await Future.wait([
      keyStore.readOrCreate(databaseExists: false),
      keyStore.readOrCreate(databaseExists: false),
    ]);

    expect(keys[0], keys[1]);
    expect(store.values, hasLength(1));
  });
}

class _MemorySecureValueStore implements SecureValueStore {
  final Map<String, String> values = {};

  @override
  Future<String?> read({required String key}) async => values[key];

  @override
  Future<void> write({required String key, required String value}) async {
    values[key] = value;
  }
}
