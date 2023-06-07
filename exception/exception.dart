import 'dart:io';

import 'package:dio/dio.dart';

import '../../material/widgets/alert.dart';
import '../env.dart';
import '../global/auth.dart';
import '../global/localization.dart';
import '../global/logger.dart';
import '../global/navigator.dart';
import '../storage/storage.dart';
import 'app_exception.dart';
import 'message_exception.dart';

class VNMException {
  static final _instance = VNMException._();
  Function(dynamic exception, dynamic stackTrace)? onCaptureException;
  Function(String title, String message)? onLogException;

  VNMException._();

  factory VNMException() => _instance;

  void config(
      {Function(dynamic exception, dynamic stackTrace)? onCaptureException,
      Function(String title, String message)? onLogException}) {
    this.onCaptureException = onCaptureException;
    this.onLogException = onLogException;
  }

  Future<void> log(String title, String message) async {
    if (Env().isProd && onLogException != null)
      return onLogException!(title, message);
  }

  void capture(exception, [stackTrace]) async {
    VNMLogger().error(exception, stackTrace);
    if (Env().isProd) {
      if (onCaptureException != null)
        onCaptureException!(exception, stackTrace);
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
          String message = exception.message(VNMNavigator().context);
          await Storage().setString("exception", message);
          await Alert.close(message: message).show();
        }
      }
    }
  }
}
