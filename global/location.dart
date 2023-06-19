import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:fl_location/fl_location.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vinamilk_sfa/vnm/core/global/loader.dart';
import 'package:vinamilk_sfa/vnm/core/global/localization.dart';
import 'package:vinamilk_sfa/vnm/material/widgets/alert.dart';

class VNMLocation {
  static final VNMLocation _i = VNMLocation._();

  VNMLocation._();

  factory VNMLocation() => _i;

  Future<bool> _checkAndRequestPermission(
      {bool? background, bool retry = true}) async {
    if (!await FlLocation.isLocationServicesEnabled) {
      return false;
    }

    var locationPermission = await FlLocation.checkLocationPermission();
    if (locationPermission == LocationPermission.deniedForever) {
      if (retry) {
        await Alert.close(
                message: Localization()
                    .locale
                    .please_provide_your_permission_location)
            .show();
        AppSettings.openLocationSettings();
        await Future.delayed(const Duration(seconds: 3));
        await Alert.goOn(
          message:
              Localization().locale.please_provide_your_permission_location,
        ).show();
        return _checkAndRequestPermission(background: background, retry: false);
      }
      return false;
    } else if (locationPermission == LocationPermission.denied) {
      locationPermission = await FlLocation.requestLocationPermission();
      if (locationPermission == LocationPermission.denied ||
          locationPermission == LocationPermission.deniedForever) return false;
    }
    if (background == true &&
        locationPermission == LocationPermission.whileInUse) return false;
    return true;
  }

  Future<Location?> getMyLocation() async {
    Location? result;
    if (await _checkAndRequestPermission()) {
      const timeLimit = Duration(seconds: 10);
      await Loader().wrap(func: () async {
        await FlLocation.getLocation(timeLimit: timeLimit).then((location) {
          print('location: ${location.toJson().toString()}');
          result = location;
        }).onError((error, stackTrace) {
          print('error: ${error.toString()}');
          if (kDebugMode &&
              error is PlatformException &&
              error.code == "LOCATION_UPDATE_FAILED") {
            result = Location.fromJson({
              "latitude": 10.730657594165702,
              "longitude": 106.72377774232764
            });
          }
        });
      });
    }
    return result;
  }
}
