import 'package:sentry/sentry.dart';

class VNMSentry {
  static final _i = VNMSentry._();

  VNMSentry._();

  factory VNMSentry() => _i;

  Future log(Object exception, StackTrace stackTrace) async {
    await Sentry.captureException(
      exception,
      stackTrace: stackTrace,
    );
  }
}
