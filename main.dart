import 'api/dior.dart';
import 'exception/exception.dart';
import 'global/auth.dart';
import 'global/logger.dart';
import 'global/route.dart';
import 'model/auth_token.dart';
import 'model/error_message.dart';
import 'storage/storage.dart';
import 'util/version.dart';

class VNMBinding {
  static VNMBinding _i = VNMBinding._();

  Future<dynamic> Function()? _externalLogout;
  Future<dynamic> Function(String userId)? _externalUserIdUpdate;
  Future<dynamic> Function(
      {required String phoneNo,
      required String customerCode,
      required String storeCode})? _externalLoginTracking;

  Future Function()? _onFirebaseInit;
  Future Function()? _onTrackingConfigInit;
  Future<AuthTokenResponse?> Function(String token)? _onRefreshToken;
  Future<Iterable<ErrorMessageConfig>> Function()? _onRemoteErrorMessages;
  Function(dynamic exception, dynamic stackTrace)? _onCaptureException;
  VNMAppRoute? _homeRoute;
  VNMAppRoute? _loginRoute;
  VNMAppRoute? _welcomeBackRoute;

  VNMBinding._();

  factory VNMBinding() => _i;

  Future<void> initialized(
      {required String appName,
      required String databaseName,
      String? iOSAppId}) async {
    //log
    VNMLogger().config(name: appName);

    //exception
    VNMException().config(onCaptureException: _onCaptureException);

    //auth
    Auth().config(
      externalLogout: _externalLogout,
      externalUserIdUpdate: _externalUserIdUpdate,
      externalLoginTracking: _externalLoginTracking,
      homeRoute: _homeRoute!,
      loginRoute: _loginRoute!,
      welcomeBackRoute: _welcomeBackRoute!,
    );

    //version
    Version().config(iOSAppId: iOSAppId);

    //storage
    await Storage().initialize(databaseName);

    //firebase
    if (_onFirebaseInit != null) await _onFirebaseInit!();

    if (_onTrackingConfigInit != null) await _onTrackingConfigInit!();

    //dio
    VNMDioConfig().config(
        onRefreshToken: _onRefreshToken,
        onRemoteErrorMessages: _onRemoteErrorMessages);
  }

  void configAuth(
      {Future<dynamic> Function()? externalLogout,
      Future<dynamic> Function(String userId)? externalUserIdUpdate,
      Future<dynamic> Function(
              {required String phoneNo,
              required String customerCode,
              required String storeCode})?
          externalLoginTracking}) {
    _externalLogout = externalLogout;
    _externalUserIdUpdate = externalUserIdUpdate;
    _externalLoginTracking = externalLoginTracking;
  }

  void configAuthRoute({
    required VNMAppRoute homeRoute,
    required VNMAppRoute loginRoute,
    required VNMAppRoute welcomeBackRoute,
  }) {
    _homeRoute = homeRoute;
    _loginRoute = loginRoute;
    _welcomeBackRoute = welcomeBackRoute;
  }

  void configFirebase({Future Function()? onFirebaseInit}) {
    _onFirebaseInit = onFirebaseInit;
  }

  void configTracking({Future Function()? onTrackingConfigInit}) {
    _onTrackingConfigInit = onTrackingConfigInit;
  }

  void configDio(
      {Future<AuthTokenResponse?> Function(String token)? onRefreshToken,
      Future<Iterable<ErrorMessageConfig>> Function()? onRemoteErrorMessages}) {
    _onRefreshToken = onRefreshToken;
    _onRemoteErrorMessages = onRemoteErrorMessages;
  }

  void configException(
      {Function(dynamic exception, dynamic stackTrace)? onCaptureException}) {
    _onCaptureException = onCaptureException;
  }
}
