import '../api/dior.dart';

typedef T ResponseMapping<T>(dynamic json);

abstract class BaseAPI {
  String get contextPath;

  String get baseUrl;

  Future<String> get initClientId;

  Future<String> get initDeviceInfo;

  Future<String> get initSignature;

  VNMDio get dior =>
      VNMDio(baseUrl: baseUrl, contextPath: contextPath, headers: {
        "client-id": () => initClientId,
        "signature": () => initSignature,
        "x-device-info": () => initDeviceInfo,
      });
}
