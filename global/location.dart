import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../../material/widgets/alert.dart';
import 'loader.dart';
import 'localization.dart';
import 'logger.dart';

class VNMLocation {
  static final VNMLocation _i = VNMLocation._();

  VNMLocation._();

  factory VNMLocation() => _i;

  Future<Position?> getMyLocation({bool retry = true}) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Alert.close(
              message:
                  Localization().locale.please_provide_your_permission_location)
          .show();
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        await Alert.close(
                message: Localization()
                    .locale
                    .please_provide_your_permission_location)
            .show();
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (retry) {
        await Alert.close(
                message: Localization()
                    .locale
                    .please_provide_your_permission_location)
            .show();
        AppSettings.openLocationSettings();
        await Future.delayed(const Duration(seconds: 3));
        await Alert.goOn(
                message: Localization()
                    .locale
                    .please_provide_your_permission_location)
            .show();
        return getMyLocation(retry: false);
      } else {
        return null;
      }
    }

    if (kDebugMode) {
      return Position.fromMap(
          {"latitude": 10.730657594165702, "longitude": 106.72377774232764});
    }
    Loader().show();
    var position = await Geolocator.getCurrentPosition(
            timeLimit: const Duration(seconds: 10))
        .onError((error, stackTrace) {
      Alert.close(message: Localization().locale.cannot_detect_your_location)
          .show();
      return Future.error(Localization().locale.cannot_detect_your_location);
    }).whenComplete(() {
      Loader().hide();
    });

    //check fake location
    if (position.isMocked && !kDebugMode) {
      await Alert.close(
              message: Localization()
                  .locale
                  .mock_location_cannot_detect_your_location)
          .show();
      return null;
    }
    return position;
  }

  double calDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    var distance =
        Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
    VNMLogger().info(distance);
    return distance;
  }
}
