import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class VNMLogger {
  static VNMLogger _i = VNMLogger._();

  var _logger = Logger("VinamilkB2B");

  VNMLogger._() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      log('${record.level.name}: ${record.time}: ${record.message.replaceAll("\n", "")}');
      if (record.stackTrace != null) {
        RegExp regExp = RegExp(r'#([0-9]).*\(.*\)');
        var matches = regExp
            .allMatches(record.stackTrace!.toString())
            .map((e) => e[0])
            .where((e) => e != null)
            .cast<String>()
            .toList();
        for (var m in matches) {
          log('${record.level.name}: $m');
        }
      }
    });
  }

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

  finer(dynamic message) {
    if (kDebugMode) _logger.finer(message);
  }

  finest(dynamic message) {
    if (kDebugMode) _logger.finest(message);
  }

  error(
    dynamic error, [
    StackTrace? stackTrace,
  ]) {
    if (kDebugMode) _logger.severe(error, error, stackTrace);
  }

  tracking(dynamic message) {
    if (kDebugMode) log(message);
  }
}
