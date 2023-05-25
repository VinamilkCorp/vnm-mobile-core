import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'message_exception.dart';

class ConnectionTimeoutException extends MessageException {
  @override
  String message(BuildContext context) =>
      AppLocalizations.of(context).connection_timeout_message;
}

class SendTimeoutException extends MessageException {
  @override
  String message(BuildContext context) =>
      AppLocalizations.of(context).send_timeout_message;
}

class ReceiveTimeoutException extends MessageException {
  @override
  String message(BuildContext context) =>
      AppLocalizations.of(context).receive_timeout_message;
}

class BadCertificateException extends MessageException {
  @override
  String message(BuildContext context) =>
      AppLocalizations.of(context).bad_certificate_message;
}

class BadResponseException extends MessageException {
  @override
  String message(BuildContext context) =>
      AppLocalizations.of(context).bad_response_message;
}

class RequestCancelException extends MessageException {
  @override
  String message(BuildContext context) =>
      AppLocalizations.of(context).request_cancel_message;
}

class ConnectionErrorException extends MessageException {
  @override
  String message(BuildContext context) =>
      AppLocalizations.of(context).connection_error_message;
}

class UnknownMessageException extends MessageException {
  final String? detail;

  UnknownMessageException({this.detail});

  @override
  String message(BuildContext context) =>
      AppLocalizations.of(context).unknown_message;
}
