import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:vinamilk_b2b/services/analytics_service.dart';
import 'package:vinamilk_b2b/widgets/material/scaffold.dart';

import 'loader.dart';

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
      AnalyticsService.instance.logRoute(route, arguments);
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
