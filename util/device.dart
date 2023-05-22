import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

import '../exception/exception.dart';
import '../global/logger.dart';
import '../storage/storage.dart';

class Device {
  static Device _i = Device._();

  Device._() {
    _deviceInfoSink
        .distinct()
        .debounceTime(Duration(milliseconds: 2000))
        .switchMap(_fetchInfo)
        .startWith('')
        .listen((event) {});
  }

  factory Device() => _i;

  final PublishSubject<num> _deviceInfoSink = PublishSubject<num>();

  Future<String> getInfo() async {
    try {
      var jsonData = {};
      if (Platform.isAndroid) {
        var info = await DeviceInfoPlugin().androidInfo;
        jsonData = {
          "osName": info.device,
          "osVersion": info.version.sdkInt,
          "deviceId": await getDeviceId(),
          "manufacturer": info.manufacturer,
          "isPhysicalDevice": info.isPhysicalDevice,
          "model": info.model,
        };
      } else if (Platform.isIOS) {
        var info = await DeviceInfoPlugin().iosInfo;
        jsonData = {
          "osName": info.systemName,
          "osVersion": info.systemVersion,
          "deviceId": await getDeviceId(),
          "manufacturer": info.model,
          "isPhysicalDevice": info.isPhysicalDevice,
          "model": info.name,
        };
      }
      var res = jsonEncode(jsonData);
      var deviceInfo = res.replaceAll(new RegExp('[^\x00-\x7F]'), '_');
      Storage().setDeviceInfo(deviceInfo);
      return deviceInfo;
    } catch (exception, stackTrace) {
      VNMException().capture(exception, stackTrace);
    }
    return "";
  }

  void fetchInfo() {
    var key = DateTime.now().millisecondsSinceEpoch;
    _deviceInfoSink.add(key);
  }

  Stream<String> _fetchInfo(num key) async* {
    VNMLogger().warning("Fetch device info");
    String? value = await getInfo();
    yield value;
  }

  Future<String> getDeviceId() async {
    try {
      final deviceInfoPlugin = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        return (await deviceInfoPlugin.androidInfo).id;
      } else {
        var deviceId = await Storage().getDeviceId();
        if (deviceId == null) {
          deviceId = Uuid().v4();
          await Storage().setDeviceId(deviceId);
          return deviceId;
        } else {
          return deviceId;
        }
      }
    } catch (exception, stackTrace) {
      VNMException().capture(exception, stackTrace);
    }
    return '';
  }
}
