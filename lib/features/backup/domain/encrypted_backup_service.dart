import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import '../../../data/models/backup_snapshot.dart';

class EncryptedBackupService {
  EncryptedBackupService({Random? random})
    : _random = random ?? Random.secure();

  static const magic = 'FAMILYTRACKERBACKUP';
  static const formatVersion = 1;
  static const _iterations = 310000;
  static const _saltLength = 16;
  static const _nonceLength = 12;
  static const _tagLength = 16;
  static const _keyLength = 32;
  static const _maxBackupBytes = 100 * 1024 * 1024;
  static const maxBackupFileBytes = _maxBackupBytes + 128;
  static const _maxPassphraseBytes = 1024;

  final Random _random;
  final _pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: _iterations,
    bits: _keyLength * 8,
  );
  final _aesGcm = AesGcm.with256bits();

  Future<Uint8List> encrypt(BackupSnapshot snapshot, String passphrase) async {
    _validatePassphrase(passphrase);
    final plaintext = Uint8List.fromList(
      utf8.encode(jsonEncode(snapshot.toMap())),
    );
    if (plaintext.length > _maxBackupBytes) {
      throw const BackupFormatException('Backup is too large to encrypt.');
    }
    final salt = _randomBytes(_saltLength);
    final nonce = _randomBytes(_nonceLength);
    final key = await _deriveKey(passphrase, salt);
    final box = await _aesGcm.encrypt(
      plaintext,
      secretKey: key,
      nonce: nonce,
      aad: _aad(formatVersion),
    );
    return Uint8List.fromList([
      ...utf8.encode(magic),
      formatVersion,
      ..._uint32(_iterations),
      ...salt,
      ...nonce,
      ...box.mac.bytes,
      ...box.cipherText,
    ]);
  }

  Future<BackupSnapshot> decrypt(List<int> bytes, String passphrase) async {
    _validatePassphrase(passphrase);
    final headerLength =
        utf8.encode(magic).length +
        1 +
        4 +
        _saltLength +
        _nonceLength +
        _tagLength;
    if (bytes.length < headerLength || bytes.length > maxBackupFileBytes) {
      throw const BackupFormatException('Backup file size is invalid.');
    }
    final magicBytes = utf8.encode(magic);
    for (var i = 0; i < magicBytes.length; i++) {
      if (bytes[i] != magicBytes[i]) {
        throw const BackupFormatException('This is not a supported backup.');
      }
    }
    var offset = magicBytes.length;
    final version = bytes[offset++];
    if (version != formatVersion) {
      throw const BackupFormatException('Unsupported backup format.');
    }
    final iterations = _readUint32(bytes, offset);
    offset += 4;
    if (iterations != _iterations) {
      throw const BackupFormatException('Unsupported backup key format.');
    }
    final salt = bytes.sublist(offset, offset += _saltLength);
    final nonce = bytes.sublist(offset, offset += _nonceLength);
    final mac = Mac(bytes.sublist(offset, offset += _tagLength));
    final ciphertext = bytes.sublist(offset);
    final key = await _deriveKey(passphrase, salt);
    try {
      final plaintext = await _aesGcm.decrypt(
        SecretBox(ciphertext, nonce: nonce, mac: mac),
        secretKey: key,
        aad: _aad(version),
      );
      final decoded = jsonDecode(utf8.decode(plaintext));
      if (decoded is! Map) {
        throw const BackupFormatException('Backup contents are invalid.');
      }
      return BackupSnapshot.fromMap(Map<String, Object?>.from(decoded));
    } on SecretBoxAuthenticationError {
      throw const BackupAuthenticationException(
        'Incorrect passphrase or backup integrity check failed.',
      );
    } on FormatException {
      throw const BackupFormatException('Backup contents are invalid.');
    }
  }

  Future<SecretKey> _deriveKey(String passphrase, List<int> salt) => _pbkdf2
      .deriveKey(secretKey: SecretKey(utf8.encode(passphrase)), nonce: salt);

  Uint8List _randomBytes(int length) =>
      Uint8List.fromList(List.generate(length, (_) => _random.nextInt(256)));

  Uint8List _aad(int version) =>
      Uint8List.fromList([...utf8.encode(magic), version]);

  List<int> _uint32(int value) => [
    value >> 24 & 0xff,
    value >> 16 & 0xff,
    value >> 8 & 0xff,
    value & 0xff,
  ];

  int _readUint32(List<int> bytes, int offset) =>
      bytes[offset] << 24 |
      bytes[offset + 1] << 16 |
      bytes[offset + 2] << 8 |
      bytes[offset + 3];

  void _validatePassphrase(String passphrase) {
    final length = utf8.encode(passphrase).length;
    if (length < 12 || length > _maxPassphraseBytes) {
      throw const BackupFormatException(
        'Passphrase must be between 12 and 1024 UTF-8 bytes.',
      );
    }
  }
}

class BackupAuthenticationException implements Exception {
  const BackupAuthenticationException(this.message);

  final String message;
}
