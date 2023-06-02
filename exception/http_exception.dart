import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'message_exception.dart';

class ServerException extends MessageException {
  @override
  String message(BuildContext context) =>
      AppLocalizations.of(context).server_error_message;
}

class BadRequestException extends MessageException {
  @override
  String message(BuildContext context) =>
      AppLocalizations.of(context).bad_request_message;
}

class UnauthorizedException extends MessageException {
  @override
  String message(BuildContext context) =>
      AppLocalizations.of(context).unauthorized_message;
}
