import 'dart:convert';
import 'dart:io' show Platform;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'logger.dart';
import 'sentry.dart';

class Analytics {
  static final _i = Analytics._();

  Analytics._();

  factory Analytics() => _i;

  Map<String, dynamic> get _meta => {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'platform': Platform.operatingSystem,
        'platformVersion': Platform.operatingSystemVersion,
      };

  _logEvent({
    required String name,
    Map<String, Object?>? data,
  }) async {
    try {
      Map<String, dynamic>? parameters = (data ?? {})..addAll(_meta);
      VNMLogger()
          .tracking(json.encode({"name": name, "parameters": parameters}));
      if (kDebugMode) {
        return;
      }
      await FirebaseAnalytics.instance
          .logEvent(name: name, parameters: parameters);
    } catch (exception, stackTrace) {
      VNMSentry().log(exception, stackTrace);
    }
  }

  logLogin(
      {required String phoneNo,
      required String customerCode,
      String? storeCode}) async {
    Map<String, dynamic>? parameters;
    try {
      parameters = {
        'phoneNo': phoneNo,
        'customerCode': customerCode,
        'storeCode': storeCode,
      };
    } catch (exception, stackTrace) {
      VNMSentry().log(exception, stackTrace);
    }
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    await _logEvent(
        name: '${packageInfo.appName}_LOGIN'.toUpperCase(), data: parameters);
  }

  logRoute(String appRouteName, Object? args) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String eventName =
        "${packageInfo.appName}_${appRouteName.toUpperCase()}_SCREEN";
    Map<String, dynamic>? parameters;
    try {
      if (args is Map) {
        parameters = {};
        for (var k in args.values) {
          parameters[k] = args[k]?.toString() ?? "";
        }
      }
    } catch (exception, stackTrace) {
      VNMLogger().error(exception, error: exception, stackTrace: stackTrace);
    }
    await _logEvent(name: eventName, data: parameters);
  }

  logButton(String label) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String eventName = "${packageInfo.appName}_APP_BUTTON".toUpperCase();
    Map<String, dynamic> parameters = {"label": label};
    await _logEvent(name: eventName, data: parameters);
  }
}
