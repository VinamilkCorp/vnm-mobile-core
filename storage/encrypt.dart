import 'package:encrypt/encrypt.dart';

class Encrypt {
  String databaseName = "default";
  String secureKey = "ij6QwqYdfIDylxcljq15CuwA5mxwWfq4";

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

  void initialize({String secureKey = '', String databaseName = ''}) {
    if (databaseName.length >= this.databaseName.length)
      this.databaseName = databaseName;
    if (secureKey.length == this.secureKey.length) this.secureKey = secureKey;
  }

  String encrypt(String text) {
    final key = Key.fromUtf8(SECURE_KEY);
    final iv = IV.fromUtf8(SECURE_IV);
    final e = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted_data = e.encrypt(text, iv: iv);
    return encrypted_data.base64;
  }

  String decrypt(String text) {
    final key = Key.fromUtf8(SECURE_KEY);
    final iv = IV.fromUtf8(SECURE_IV);
    final e = Encrypter(AES(key, mode: AESMode.cbc));
    final decrypted_data = e.decrypt(Encrypted.fromBase64(text), iv: iv);
    return decrypted_data;
  }
}
