import 'package:open_store/open_store.dart';
import 'package:package_info_plus/package_info_plus.dart';

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

  Future<void> checkSupportedVersion({String? supportedVersion}) async {
    if (supportedVersion == null) return;
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String version = packageInfo.version;
      if (supportedVersion.isEmpty) return;
      int currentVersion = _getExtendedVersionNumber(version);
      int minVersion = _getExtendedVersionNumber(supportedVersion);
      if (currentVersion < minVersion) {
        var locale = Localization().locale;
        String title = locale.upgrade_application;
        String content = locale.upgrade_application_desc;
        Future.delayed(Duration(seconds: 2)).then((value) {
          Alert.agreeOrClose(
              title: title,
              message: content,
              onAgree: () => OpenStore.instance.open(
                  appStoreId: iOSAppId,
                  androidAppBundleId: packageInfo.packageName)).show();
        });
      }
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
