import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class VNMLogger {
  static VNMLogger _i = VNMLogger._();

  var _logger = Logger("MyApp");

  VNMLogger._();

  factory VNMLogger() => _i;

  warning(dynamic message) {
    if (kDebugMode) _logger.warning(message);
  }

  fine(dynamic message) {
    if (kDebugMode) _logger.fine(message);
  }

  info(dynamic message) {
    if (kDebugMode) _logger.info(message);
  }

  error(
    dynamic message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) _logger.severe(message, error, stackTrace);
  }

  tracking(dynamic message) {
    if (kDebugMode) log(message);
  }
}
