import 'package:flutter/foundation.dart';

class Env {
  String get name => _env;

  String get _env => const String.fromEnvironment("env",
      defaultValue: kDebugMode ? "dev" : "prod");

  bool get isDev => _env == "dev";

  bool get isProd => _env == "prod";

  bool get analyticsEnabled => isProd
      ? true
      : const bool.fromEnvironment("enable-analytics", defaultValue: false);

  String get VN_COUNTRY_CODE => "84";
}
