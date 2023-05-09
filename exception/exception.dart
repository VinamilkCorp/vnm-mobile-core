import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:vinamilk_b2b/vnm/core/global/logger.dart';

class VNMException {
  Function(Object exception, StackTrace? stackTrace)? onShowDialog;
  bool isProd = false;

  VNMException._();

  static final _instance = VNMException._();

  factory VNMException() => _instance;

  void config(
      {required bool isProd,
      required Function(Object exception, StackTrace? stackTrace)
          onShowDialog}) {
    this.isProd = isProd;
    this.onShowDialog = onShowDialog;
  }

  void capture(exception, [stackTrace]) async {
    VNMLogger().error(exception, stackTrace);
    if (isProd) {
      Sentry.captureException(exception, stackTrace: stackTrace);
    }
    if (onShowDialog != null) {
      if (exception is Object && stackTrace is StackTrace?)
        onShowDialog!(exception, stackTrace);
    }
    // DialogUtil.showExceptionDialog(exception, stackTrace);
  }

  void captureMessage(String message, List<dynamic>? params) async {
    if (isProd) {
      Sentry.captureMessage(message, params: params);
    }
  }
}
