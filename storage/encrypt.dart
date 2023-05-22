import 'dart:math';

import 'package:encrypt/encrypt.dart';
import 'package:flutter_keychain/flutter_keychain.dart';
import 'package:vinamilk_b2b/vnm/core/global/logger.dart';

class Encrypt {
  String databaseName = "default";
  String secureKey = "";

  static Encrypt _i = Encrypt._();

  Encrypt._();

  factory Encrypt() => _i;

  String get SECURE_DATABASE_NAME => databaseName;

  String get USER_DATABASE_NAME => "${SECURE_DATABASE_NAME}_user";

  String get SECURE_KEY => secureKey; //32 characters
  String get SECURE_IV =>
      "${SECURE_DATABASE_NAME}-${SECURE_KEY}".substring(0, 12) +
      "-key"; //16 characters

  String get secureDatabaseName => encrypt(SECURE_DATABASE_NAME)
      .replaceAll("=", "")
      .replaceAll("+", "")
      .replaceAll("/", "");

  String get userDatabaseName => encrypt(USER_DATABASE_NAME)
      .replaceAll("=", "")
      .replaceAll("+", "")
      .replaceAll("/", "");

  Future<void> initialize(String databaseName) async {
    if (databaseName.length >= this.databaseName.length)
      this.databaseName = databaseName;
    try {
      String key = "${databaseName}_secure_Key";
      secureKey = (await get(key)) ?? "";
      VNMLogger().info("Get my secure key: ${secureKey}");
      if (secureKey.length < 32) {
        secureKey = _generateRandomKeys();
        VNMLogger().info("Generate new secure key: ${secureKey}");
        await put(key, secureKey);
      }
    } catch (exception, stackTrace) {
      VNMLogger().error(exception, stackTrace);
      secureKey = _generateRandomKeys();
    }
  }

  Future<void> put(String key, String value) async {
    try {
      await FlutterKeychain.put(key: key, value: encrypt(value));
    } catch (exception, stackTrace) {}
  }

  Future<String?> get(String key) async {
    try {
      String? value = await FlutterKeychain.get(key: key);
      if (value != null) return decrypt(value);
    } catch (exception, stackTrace) {}
    return null;
  }

  Future<void> remove(String key) {
    return FlutterKeychain.remove(key: key);
  }

  String _generateRandomKeys() {
    String characters =
        "QWERTYUIOPASDFGHJKLZXCVBNMqwertyuiopasdfghjklzxcvbnm1234567890";
    String key = '';
    for (int i = 0; i < 32; i++) {
      key += characters[Random().nextInt(characters.length)];
    }
    return key;
  }

  String encrypt(String text) {
    if (SECURE_KEY.isEmpty) return text;
    final key = Key.fromUtf8(SECURE_KEY);
    final iv = IV.fromUtf8(SECURE_IV);
    final e = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted_data = e.encrypt(text, iv: iv);
    return encrypted_data.base64;
  }

  String decrypt(String text) {
    if (SECURE_KEY.isEmpty) return text;
    final key = Key.fromUtf8(SECURE_KEY);
    final iv = IV.fromUtf8(SECURE_IV);
    final e = Encrypter(AES(key, mode: AESMode.cbc));
    final decrypted_data = e.decrypt(Encrypted.fromBase64(text), iv: iv);
    return decrypted_data;
  }
}
