import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:rxdart/rxdart.dart';

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
      final info = await DeviceInfoPlugin().deviceInfo;
      Map<String, dynamic> json = Map.from(info.data);
      json.remove("systemFeatures");
      var deviceInfo =
          jsonEncode(json).replaceAll(new RegExp('[^\x00-\x7F]'), '_');
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
}
