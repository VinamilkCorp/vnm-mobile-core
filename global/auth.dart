import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../material/widgets/alert.dart';
import '../exception/index.dart';
import '../model/auth_token.dart';
import '../model/user.dart';
import '../storage/storage.dart';
import '../util/jwt.dart';
import 'loader.dart';
import 'localization.dart';
import 'navigator.dart';
import 'route.dart';

class AuthNotifier extends ChangeNotifier {
  AuthTokenResponse? _token;

  bool get isUnauthenticated => _token == null;

  bool get isAuthenticated =>
      !isUnauthenticated && !JwtUtil().isExpired(_token!.refreshToken);

  bool get isExpired =>
      !isUnauthenticated && JwtUtil().isExpired(_token!.refreshToken);

  void set(AuthTokenResponse? token) {
    _token = token;
    notifyListeners();
  }

  void setUser(User user) {
    _token = _token?.copyWith(user: user);
  }

  void clear() {
    _token = null;
    notifyListeners();
  }
}

class Auth {
  static final Auth _i = Auth._();
  Completer<bool> _completer = Completer<bool>();
  AuthNotifier? _auth;

  Future Function()? externalLogout;

  Auth._();

  factory Auth() => _i;

  void config({Future Function()? externalLogout}) {
    this.externalLogout = externalLogout;
  }

  User get user => _auth!._token?.user ?? User.empty();

  bool get authenticated => _auth!.isAuthenticated;

  bool get expired => _auth!.isExpired;

  bool get unauthenticated => _auth!.isUnauthenticated;

  String get accessToken => _auth!._token?.accessToken ?? "";

  String get refreshToken => _auth!._token?.refreshToken ?? "";

  Future<bool> initialized() => _completer.future;

  Future<void> init(BuildContext context) async {
    if (_completer.isCompleted) return;
    _auth = Provider.of<AuthNotifier>(context, listen: false);
    var token = await Storage().getToken();
    // token = token?.copyWith(
    //     user: token.user.copyWith(roles: ["ROLE_DISTRIBUTOR_DRIVER"]));
    _auth!.set(token);
    _auth!.addListener(_onListener);
    checkShowDenyByRole();
    _completer.complete(true);
  }

  Future<void> _onListener() async {
    var route = getRoute();
    VNMNavigator().pushRouteAndRemoveUntil(route);
    checkShowDenyByRole();
  }

  Future<void> checkShowDenyByRole() async {
    if (_auth!.isAuthenticated) {
      if (!user.hasStoreOwnerRole) {
        var locale = Localization().locale;
        await Alert.close(message: locale.alert_not_store_owner).show();
        Loader().wrap(func: () async {
          await Storage().clearSession();
          if (externalLogout != null) await externalLogout!();
          _auth!._token = null;
        });
      }
    }
  }

  Future<void> foreLogout() async {
    await Alert.goOn(message: Localization().locale.force_logout_desc).show();
    return Loader().wrap(func: () async {
      await onReLogin();
    });
  }

  AppRoute getRoute() {
    if (_auth!.isAuthenticated) {
      if (user.hasStoreOwnerRole) {
        return AppRoute.Home;
      } else {
        return AppRoute.Login;
      }
    } else if (_auth!.isUnauthenticated) {
      return AppRoute.Login;
    } else {
      if (user.phoneNo.isEmpty) {
        return AppRoute.Login;
      } else {
        return AppRoute.WelcomeBack;
      }
    }
  }

  void setUser(User user) {
    _auth!.setUser(user);
    _updateAnalyticUser();
  }

  Future<void> onLogout() async {
    await Storage().clearSession();
    if (externalLogout != null) await externalLogout!();
    _auth!.clear();
  }

  Future<void> onReLogin() async {
    AuthTokenResponse? token = _auth!._token?.copyWith(refreshToken: "");
    await Storage().clearSession();
    if (token != null) await Storage().setToken(token);
    if (externalLogout != null) await externalLogout!();
    _auth!.set(token);
  }

  void setToken(AuthTokenResponse? token) {
    _auth!.set(token);
    if (token != null) Storage().setToken(token);
    _updateAnalyticUser();
  }

  void _updateAnalyticUser() {
    //set userId sentry
    try {
      if (user.userCode.isEmpty) {
        Sentry.configureScope((scope) => scope.clear());
        FirebaseAnalytics.instance.setUserId(id: null);
      } else {
        var userId = user.userCode + "_" + user.phoneNo;
        Sentry.configureScope((scope) => scope.setUser(SentryUser(id: userId)));
        FirebaseAnalytics.instance.setUserId(id: userId);
      }
    } catch (exception, stackTrace) {
      VNMException().capture(exception, stackTrace);
    }
  }
}
