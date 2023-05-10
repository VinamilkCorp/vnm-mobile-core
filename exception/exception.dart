import 'dart:io';

import 'package:dio/dio.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../material/widgets/alert.dart';
import '../env.dart';
import '../global/auth.dart';
import '../global/localization.dart';
import '../global/logger.dart';
import '../global/navigator.dart';
import 'app_exception.dart';
import 'message_exception.dart';

class VNMException {
  VNMException._();

  static final _instance = VNMException._();

  factory VNMException() => _instance;

  void capture(exception, [stackTrace]) async {
    VNMLogger().error(exception, stackTrace);
    if (Env().isProd) {
      Sentry.captureException(exception, stackTrace: stackTrace);
    }
    if (exception is Object && stackTrace is StackTrace?) {
      if (exception is TokenExpiredException) {
        await Auth().foreLogout();
      } else if (exception is DioError) {
        if (exception.error is SocketException) {
          var locale = Localization().locale;
          await Alert.close(message: locale.no_internet_connection).show();
        }
      } else if (exception is SocketException) {
        var locale = Localization().locale;
        await Alert.close(message: locale.no_internet_connection).show();
      } else {
        if (exception is MessageException) {
          await Alert.close(message: exception.message(VNMNavigator().context))
              .show();
        }
      }
    }
  }

  // DialogUtil.showExceptionDialog(exception, stackTrace);

  void captureMessage(String message, List<dynamic>? params) async {
    if (Env().isProd) {
      Sentry.captureMessage(message, params: params);
    }
  }
}
