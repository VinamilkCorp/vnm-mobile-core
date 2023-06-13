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

  Map _generateArguments(VNMAppRoute appRoute, Object? originalArgs) =>
      {"builder": appRoute.builder, "args": originalArgs};

  Future pushRouteAndRemoveUntil(VNMAppRoute appRoute,
      {Object? args, RoutePredicate? predicate}) async {
    return Navigator.of(context).pushNamedAndRemoveUntil(
        appRoute.code, predicate ?? (route) => false,
        arguments: _generateArguments(appRoute, args));
  }

  Future pushRoute(VNMAppRoute appRoute, {Object? args}) async {
    return Navigator.of(context).pushNamed(appRoute.code,
        arguments: _generateArguments(appRoute, args));
  }

  Future pushRouteReplacement(
    VNMAppRoute appRoute, {
    Object? result,
    Object? args,
  }) async {
    return Navigator.of(context).pushReplacementNamed(appRoute.code,
        arguments: _generateArguments(appRoute, args), result: result);
  }

  Future<void> popUntilRoute(VNMAppRoute appRoute) async {
    return Navigator.of(context)
        .popUntil((route) => route.settings.name == appRoute.code);
  }

  Future<void> pop<T extends Object?>([T? result]) async {
    return Navigator.of(context).pop<T>(result);
  }
}
