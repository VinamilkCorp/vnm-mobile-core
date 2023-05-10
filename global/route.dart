import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../material/widgets/scaffold.dart';
import 'loader.dart';
import 'tracking.dart';

enum AppRoute {
  Splash,
  Onboarding,
  Home,
  Login,
  WelcomeBack,
  Otp,
  OrderDetail,
  PinCodeVerification,
  InactiveAccount,
  EditProfile,
  Feedback,
  NewPin,
  ConfirmNewPin,
  FortuneWheel,
  History,
  FortunePolicy,
}

extension AppRouteSettings on RouteSettings {
  MaterialPageRoute onGenerateRoute(BuildContext context,
      Widget Function(AppRoute route, Object? args) builder) {
    Loader().hide();
    AppRoute? route = AppRoute.values.firstWhereOrNull((t) => t.name == name);
    Widget page = VNMScaffold();
    if (route != null) {
      if (VNMTrackingConfig().logRoute != null)
        VNMTrackingConfig().logRoute!(route, arguments);
      page = builder(route, this.arguments);
    }
    return MaterialPageRoute(
        builder: (_) => GestureDetector(
              child: page,
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              behavior: HitTestBehavior.translucent,
            ),
        settings: this);
  }
}
