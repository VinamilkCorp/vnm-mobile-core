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
