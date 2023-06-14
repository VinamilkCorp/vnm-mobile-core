import '../../../env.dart';
import '../../firebase/firebase.dart';
import '../storage/storage.dart';
import '../util/device.dart';
import 'dior.dart';

typedef T ResponseMapping<T>(dynamic json);

abstract class VNMAPI {
  String get contextPath;

  String get baseUrl;

  Future<String> get initClientId;

  Future<String> get initDeviceInfo;

  VNMDio get dior =>
      VNMDio(baseUrl: baseUrl, contextPath: contextPath, headers: {
        "client-id": () => initClientId,
        "x-device-info": () => initDeviceInfo,
      });
}

abstract class MyAPI extends VNMAPI {
  @override
  String get baseUrl => MyEnv().baseUrl;

  @override
  // TODO: implement initClientId
  Future<String> get initClientId async {
    var clientId = await Storage().getClientId();
    if (clientId == null) {
      clientId = await VNMFirebase().remoteConfig.clientId();
    } else {
      VNMFirebase().remoteConfig.fetchClientId();
    }
    return clientId ?? "";
  }

  @override
  // TODO: implement initDeviceInfo
  Future<String> get initDeviceInfo async {
    var deviceInfo = await Storage().getDeviceInfo();
    if (deviceInfo == null) {
      deviceInfo = await Device().getInfo();
    } else {
      Device().fetchInfo();
    }
    return deviceInfo;
  }
}
