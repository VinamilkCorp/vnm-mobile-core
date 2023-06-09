import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:open_store/open_store.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../firebase/firebase.dart';
import '../../material/exception/exception.dart';
import '../../material/widget/basic/alert.dart';
import '../global/bus.dart';
import '../global/localization.dart';

class Version {
  static Version _i = Version._();

  Version._();

  factory Version() => _i;

  Future<String?> getCurrent() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String version = packageInfo.version;
      return version;
    } catch (exception, stackTrace) {
      VNMException().capture(exception, stackTrace);
    }
    return null;
  }

  Future<bool> _checkSupported(String packageName) async {
    try {
      String? version = await getCurrent();
      if (version == null || version.isEmpty) return false;
      String? supportedVersion = packageName.startsWith("vn.com.vinamilk.sfa")
          ? await VNMFirebase().remoteConfig.sfaMinSupportedVersion()
          : await VNMFirebase().remoteConfig.minSupportedVersion();

      if (supportedVersion == null || supportedVersion.isEmpty) return false;
      int currentVersion = _getExtendedVersionNumber(version);
      int minVersion = _getExtendedVersionNumber(supportedVersion);
      return currentVersion < minVersion;
    } catch (exception, stackTrace) {
      VNMException().capture(exception, stackTrace);
    }
    return false;
  }

  Future<void> showRequiredUpgradeAlert() async {
    if (kDebugMode) return;
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    bool needUpgrade = await _checkSupported(packageInfo.packageName);
    if (needUpgrade)
      try {
        var locale = Localization().locale;
        String title = locale.upgrade_application;
        String content = locale.upgrade_application_desc;
        return Alert.agreeOrClose(
            title: title,
            message: content,
            onAgree: () async => navigateStore(packageInfo.packageName)).show();
      } catch (exception, stackTrace) {
        throw exception;
      }
  }

  int _getExtendedVersionNumber(String version) {
    List versionCells = version.split('.');
    versionCells = versionCells.map((i) => int.parse(i)).toList();
    return versionCells[0] * 100000 + versionCells[1] * 1000 + versionCells[2];
  }

  void navigateStore(String packageName) async {
    try {
      OpenStore.instance
          .open(
              appStoreId: VNMBus().touch<String>("appStoreId"),
              androidAppBundleId: packageName)
          .catchError((_) async {
        try {
          Uri? uri;
          if (Platform.isAndroid) {
            uri = Uri.parse(
                "https://play.google.com/store/apps/details?id=" + packageName);
          } else if (Platform.isIOS) {
            uri = Uri.parse(
                "https://apps.apple.com/us/app/vinamilk-b2b/${VNMBus().touch<String>("appStoreId")}");
          }
          if (uri != null) if (!await launchUrl(uri)) {
            throw Exception('Could not launch $uri');
          }
        } catch (exception, stackTrace) {
          throw exception;
        }
      });
    } catch (exception, stackTrace) {
      throw exception;
    }
  }
}
