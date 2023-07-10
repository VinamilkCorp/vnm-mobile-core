import '../base/api.dart';
import '../global/bus.dart';
import '../storage/storage.dart';
import '../util/device.dart';

abstract class VNMAPI extends BaseAPI {
  @override
  String get baseUrl => VNMBus().touch<String>('baseUrl') ?? "";

  @override
  // TODO: implement initClientId
  Future<String> get initClientId async {
    var clientId = await Storage().getClientId();
    if (clientId == null) {
      clientId = await VNMBus().fire("firebase.clientId");
    } else {
      VNMBus().fire("firebase.clientId");
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
