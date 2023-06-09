import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../global/route.dart';

class VNMNavigator {
  static VNMNavigator _i = VNMNavigator._();
  final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();

  BuildContext get context {
    // if (key.currentContext == null) {
    //   await Future.delayed(Duration(milliseconds: 200));
    //   return context;
    // }
    return key.currentContext!;
  }

  bool get isReady {
    return key.currentContext != null;
  }

  VNMNavigator._();

  factory VNMNavigator() => _i;

  Future pushRouteAndRemoveUntil(AppRoute appRoute,
      {Object? args, RoutePredicate? predicate}) async {
    return Navigator.of(context).pushNamedAndRemoveUntil(
        appRoute.name, predicate ?? (route) => false,
        arguments: args);
  }

  Future pushRoute(AppRoute appRoute, {Object? args}) async {
    return Navigator.of(context).pushNamed(appRoute.name, arguments: args);
  }

  Future pushRouteReplacement(
    AppRoute appRoute, {
    Object? result,
    Object? args,
  }) async {
    return Navigator.of(context)
        .pushReplacementNamed(appRoute.name, arguments: args, result: result);
  }

  Future<void> popUntilRoute(AppRoute appRoute) async {
    return Navigator.of(context)
        .popUntil((route) => route.settings.name == appRoute.name);
  }

  Future<void> pop<T extends Object?>([T? result]) async {
    return Navigator.of(context).pop<T>(result);
  }
}
