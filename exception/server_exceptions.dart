import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../model/error_message.dart';
import 'message_exception.dart';

class RemoteErrorMessageException extends MessageException {
  final ErrorMessageConfig error;

  RemoteErrorMessageException(this.error);

  @override
  String message(BuildContext context) => error.message;
}

class DioErrorException extends MessageException {
  final DioError error;

  DioErrorException(this.error);

  @override
  String message(BuildContext context) => json.encode({
        "status": error.response?.statusCode,
        "error": error.toString(),
        "message": message,
        "type": error.type.toString(),
        "request": {
          "path": error.requestOptions.path,
          "uri": error.requestOptions.uri.toString(),
          "method": error.requestOptions.method,
          "data": error.requestOptions.data,
          "queryParameters": error.requestOptions.queryParameters,
          "extra": error.requestOptions.extra,
          "header": error.requestOptions.headers
        },
        "response": "${error.response?.data}"
      });
}

class RS01404Exception extends MessageException {
  @override
  String message(BuildContext context) =>
      AppLocalizations.of(context).phone_number_not_registered_as_vnm;
}

class RS01521Exception extends MessageException {
  String message(BuildContext context) =>
      AppLocalizations.of(context).this_store_code_registered_by_another_phone;
}

class AS01403Exception extends MessageException {
  String message(BuildContext context) =>
      AppLocalizations.of(context).exception_auth_phone_number_invalid;
}

class VS01403Exception extends MessageException {
  String message(BuildContext context) =>
      AppLocalizations.of(context).otp_exceeded_error;
}

class VS02401Exception extends MessageException {
  String message(BuildContext context) =>
      AppLocalizations.of(context).otp_many_request_error;
}

class VS03401Exception extends MessageException {
  String message(BuildContext context) =>
      AppLocalizations.of(context).otp_not_valid_error;
}

class AU05400Exception extends MessageException {
  String message(BuildContext context) =>
      AppLocalizations.of(context).pin_many_request_error;
}

class WrongPinException implements MessageException {
  @override
  String message(BuildContext context) =>
      AppLocalizations.of(context).wrong_pin_exception;
}
