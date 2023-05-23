import 'dart:async';
import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';

import '../exception/index.dart';
import '../global/logger.dart';
import '../model/auth_token.dart';
import 'encrypt.dart';

class _StorageKey {
  static const String signatureSalt = "signatureSalt";
  static const String token = "auth.token";
  static const String clientId = "clientId";
  static const String deviceInfo = "deviceInfo";
  static const String campaignBanner = "campaign_banner";
  static const String hasCampaignBanner = "has_campaign";
  static const String hasDisplayRules = "FTWRulesDisplay";
  static const String deviceId = "deviceId";
}

class Storage {
  static Storage _i = Storage._();

  Storage._();

  factory Storage() => _i;

  final _SecureStorage _secure = _SecureStorage();

  final _UserStorage _user = _UserStorage();

  Future<void> initialize(String databaseName) async {
    await Encrypt().initialize(databaseName);
    await _secure.init();
    await _user.init();
  }

  String? getString(String key) {
    return _user.getString(key);
  }

  Future<void> setString(String key, String value) async {
    return _user.setString(key, value);
  }

  int? getInt(String key) {
    var value = _user.get(key);
    if (value is int) return value;
    return null;
  }

  Future<void> setInt(String key, int value) async {
    return _user.setInt(key, value);
  }

  //secure storage methods implement
  Future<void> clearSession() async {
    _user.clear();
    await _secure.clearSession();
  }

  Future<String?> getClientId() => _secure.getClientId();

  Future<void> setClientId(String value) => _secure.setClientId(value);

  Future<String?> getDeviceId() => _secure.getDeviceId();

  Future<void> setDeviceId(String value) => _secure.setDeviceId(value);

  Future<AuthTokenResponse?> getToken() => _secure.getToken();

  Future<void> setToken(AuthTokenResponse value) => _secure.setToken(value);

  Future<String?> getSignatureSalt() => _secure.getSignatureSalt();

  Future<void> setSignatureSalt(String value) =>
      _secure.setSignatureSalt(value);

  Future<String?> getDeviceInfo() => _secure.getDeviceInfo();

  Future<void> setDeviceInfo(String value) => _secure.setDeviceInfo(value);

  //user storage methods implement
  Future<bool?> getHasDisplayRules() => _user.getHasDisplayRules();

  Future<void> setHasDisplayRules(bool value) =>
      _user.setHasDisplayRules(value);

  Future<Map<String, dynamic>?> getObjectByRequest(String url,
          [Map<String, dynamic>? parameters]) =>
      _user.getObjectByRequest(url, parameters);

  Future setObjectByRequest(String url, Map<String, dynamic> data,
          [Map<String, dynamic>? parameters]) =>
      _user.setObjectByRequest(url, parameters, data);

  Future removeObjectByRequest(String url,
          [Map<String, dynamic>? parameters]) =>
      _user.removeObjectByRequest(url, parameters);
}

abstract class BaseStorage {
  Box? _box;

  String get databaseName;

  bool encryptEnable = true;

  Future<void> init() async {
    final appDocumentDirectory = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDirectory.path);
    _box = await Hive.openBox(databaseName);
  }

  Future<void> clear() async {
    await _box?.clear();
  }

  Future<void> setString(String key, String value) async {
    return _box?.putSafe(key, value, encrypt: encryptEnable);
  }

  String? getString(String key) {
    return _box?.getStringSafe(key, encryptEnable);
  }

  dynamic get(String key) {
    return _box?.getSafe(key, encryptEnable);
  }

  Future<void> setBool(String key, bool value) async {
    await _box?.putSafe(key, value, encrypt: encryptEnable);
  }

  Future<void> setInt(String key, int value) async {
    await _box?.putSafe(key, value, encrypt: encryptEnable);
  }

  bool? getBool(String key) {
    return _box?.getBoolSafe(key, encryptEnable);
  }

  Future<void> delete(List<String> keys) async {
    VNMLogger().warning("Remove local: $keys");
    return _box?.deleteSafe(keys, encrypt: encryptEnable);
  }
}

extension _BoxEx on Box {
  String? getStringSafe(String key, bool encrypt, [String? defaultValue]) {
    if (key.isNotEmpty)
      try {
        String k = encrypt ? Encrypt().encrypt(key) : key;
        String? value = get(k) as String?;
        return value == null
            ? defaultValue
            : (encrypt ? Encrypt().decrypt(value) : value);
      } catch (exception, stackTrace) {
        VNMLogger().error(exception, stackTrace);
      }
    return null;
  }

  bool? getBoolSafe(String key, bool encrypt, [bool? defaultValue]) {
    if (key.isNotEmpty)
      try {
        String k = encrypt ? Encrypt().encrypt(key) : key;
        return get(k, defaultValue: defaultValue);
      } catch (exception, stackTrace) {
        VNMLogger().error(exception, stackTrace);
      }
    return null;
  }

  dynamic getSafe(String key, bool encrypt, [dynamic defaultValue]) {
    if (key.isNotEmpty)
      try {
        dynamic k = encrypt ? Encrypt().encrypt(key) : key;
        return get(k, defaultValue: defaultValue);
      } catch (exception, stackTrace) {
        VNMLogger().error(exception, stackTrace);
      }
    return null;
  }

  Future<void> putSafe<T>(String key, T value, {bool encrypt = true}) async {
    if (key.isNotEmpty)
      try {
        String k = encrypt ? Encrypt().encrypt(key) : key;
        if (value is String) {
          var v = encrypt ? Encrypt().encrypt(value) : value;
          return put(k, v);
        } else if (value is Map) {
          var v = encrypt
              ? Encrypt().encrypt(jsonEncode(value))
              : jsonEncode(value);
          return put(k, v);
        } else {
          return put(k, value);
        }
      } catch (exception, stackTrace) {
        VNMLogger().error(exception, stackTrace);
      }
  }

  Future<void> deleteSafe(List<String> keys, {bool encrypt = true}) async {
    await deleteAll(keys
        .where((key) => key.isNotEmpty)
        .map((key) => encrypt ? Encrypt().encrypt(key) : key));
    await compact();
  }
}

//Secure Storage: storage secure values
class _SecureStorage extends BaseStorage {
  @override
  String get databaseName => Encrypt().secureDatabaseName;

  Future<void> clearSession() async {
    // await delete([
    //   _StorageKey.token
    // ]);
    await Encrypt().remove(
      _StorageKey.token,
    );
  }

  Future<String?> getClientId() async {
    return getString(_StorageKey.clientId);
  }

  Future<void> setClientId(String value) async {
    await setString(_StorageKey.clientId, value);
  }

  Future<String?> getDeviceId() async {
    return Encrypt().get(_StorageKey.deviceId);
  }

  Future<void> setDeviceId(String value) async {
    await Encrypt().put(_StorageKey.deviceId, value);
  }

  Future<AuthTokenResponse?> getToken() async {
    // var data = await getString(_StorageKey.token);
    var data = await Encrypt().get(_StorageKey.token);
    try {
      if (data == null) return null;
      var jsonData = jsonDecode(data);
      return AuthTokenResponse.fromJson(jsonData);
    } catch (exception, stackTrace) {
      VNMException().capture(exception, stackTrace);
    }
    return null;
  }

  Future<void> setToken(AuthTokenResponse value) async {
    // await setString(_StorageKey.token, jsonEncode(value));
    await Encrypt().put(_StorageKey.token, jsonEncode(value));
  }

  Future<String?> getSignatureSalt() async {
    return getString(_StorageKey.signatureSalt);
  }

  Future<void> setSignatureSalt(String value) async {
    await setString(_StorageKey.signatureSalt, value);
  }

  Future<String?> getDeviceInfo() async {
    return getString(_StorageKey.deviceInfo);
  }

  Future<void> setDeviceInfo(String value) async {
    await setString(_StorageKey.deviceInfo, value);
  }
}

//User Storage: storage user values
class _UserStorage extends BaseStorage {
  final PublishSubject<Iterable> clearExpiredSink = PublishSubject<Iterable>();

  _UserStorage() {
    clearExpiredSink
        .distinct()
        .debounceTime(Duration(milliseconds: 800))
        .switchMap((keys) => clearExpiredObjects(keys))
        .startWith(false)
        .listen((event) {});
  }

  @override
  String get databaseName => Encrypt().userDatabaseName;

  @override
  bool get encryptEnable => false;

  Future<String?> getCampaignBanner() async {
    return getString(_StorageKey.campaignBanner);
  }

  Future<void> setCampaignBanner(String value) async {
    await setString(_StorageKey.campaignBanner, value);
  }

  Future<bool?> getHasCampaignBanner() async {
    return getBool(_StorageKey.hasCampaignBanner);
  }

  Future<void> setHasCampaignBanner(bool value) async {
    await setBool(_StorageKey.hasCampaignBanner, value);
  }

  Future<bool?> getHasDisplayRules() async {
    return getBool(_StorageKey.hasDisplayRules);
  }

  Future<void> setHasDisplayRules(bool value) async {
    await setBool(_StorageKey.hasDisplayRules, value);
  }

  String _keyByRequest(String url, Map<String, dynamic>? parameters) {
    var path = url;
    try {
      if (path.contains("//")) {
        path = path.substring(path.indexOf("//") + 2);
        if (path.contains("/")) {
          path = path.substring(path.indexOf("/") + 1);
        }
      }
    } catch (exception, stackTrace) {}
    var subPath = parameters?.toString() ?? "";
    var key = [path, subPath].where((it) => it.isNotEmpty).join(":");
    return key;
  }

  Future<Map<String, dynamic>?> getObjectByRequest(
      String url, Map<String, dynamic>? parameters) async {
    clearExpiredSink.add(_box?.keys ?? []);
    var key = _keyByRequest(url, parameters);
    VNMLogger().info("Get local: $key");
    String? data = await getString(key);
    if (data != null)
      try {
        Map<String, dynamic> json = jsonDecode(data);
        var timestamp = DateTime.fromMillisecondsSinceEpoch(json["timestamp"]);
        if (DateTime.now().difference(timestamp).inDays > 3) {
          removeObjectByRequest(url, parameters);
        } else {
          return json["data"] as Map<String, dynamic>;
        }
      } catch (exception, stackTrace) {
        removeObjectByRequest(url, parameters);
        VNMLogger().error(exception, stackTrace);
      }
    return null;
  }

  Future setObjectByRequest(String url, Map<String, dynamic>? parameters,
      Map<String, dynamic> data) async {
    var key = _keyByRequest(url, parameters);
    VNMLogger().info("Set local: $key");
    try {
      return await setString(
          key,
          jsonEncode({
            "data": data,
            "timestamp": DateTime.now().millisecondsSinceEpoch
          }));
    } catch (exception, stackTrace) {
      VNMLogger().error(exception, stackTrace);
    }
  }

  Future removeObjectByRequest(
      String url, Map<String, dynamic>? parameters) async {
    var key = _keyByRequest(url, parameters);
    try {
      delete([key]);
    } catch (exception, stackTrace) {
      VNMLogger().error(exception, stackTrace);
    }
  }

  Stream<bool> clearExpiredObjects(Iterable keys) async* {
    VNMLogger().warning("Check expired objects");
    keys.forEach((key) {
      var value = get(key);
      if (value is String)
        try {
          var json = jsonDecode(value);
          List<String> removeKeys = [];
          var timestamp =
              DateTime.fromMillisecondsSinceEpoch(json["timestamp"]);
          if (DateTime.now().difference(timestamp).inDays > 3) {
            removeKeys.add(key);
          }
          if (removeKeys.isNotEmpty) delete(removeKeys);
        } catch (exception, stackTrace) {
          VNMLogger().error(exception, stackTrace);
        }
    });
    await Future.delayed(Duration(milliseconds: 800));
    yield true;
  }
}
