import 'package:open_store/open_store.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:vinamilk_b2b/firebase/firebase.dart';
import 'package:vinamilk_b2b/vnm/core/exception/exception.dart';

import '../../material/widgets/alert.dart';
import '../global/localization.dart';

class Version {
  String? iOSAppId;
  static Version _i = Version._();

  Version._();

  factory Version() => _i;

  void config({String? iOSAppId}) {
    this.iOSAppId = iOSAppId;
  }

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

  Future<bool> _checkSupported() async {
    try {
      String? version = await getCurrent();
      if (version == null || version.isEmpty) return false;
      String? supportedVersion =
          await VNMFirebase().remoteConfig.minSupportedVersion();
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
    bool needUpgrade = await _checkSupported();
    if (needUpgrade)
      try {
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        var locale = Localization().locale;
        String title = locale.upgrade_application;
        String content = locale.upgrade_application_desc;
        return Alert.agreeOrClose(
            title: title,
            message: content,
            onAgree: () => OpenStore.instance.open(
                appStoreId: iOSAppId,
                androidAppBundleId: packageInfo.packageName)).show();
      } catch (exception, stackTrace) {
        throw exception;
      }
  }

  int _getExtendedVersionNumber(String version) {
    List versionCells = version.split('.');
    versionCells = versionCells.map((i) => int.parse(i)).toList();
    return versionCells[0] * 100000 + versionCells[1] * 1000 + versionCells[2];
  }
}
