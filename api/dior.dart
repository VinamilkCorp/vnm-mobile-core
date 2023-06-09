import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

import '../../auth/auth.dart';
import '../../auth/model/auth_token.dart';
import '../../extension/if_null.dart';
import '../../material/exception/dio_exception.dart';
import '../../material/exception/index.dart';
import '../base/api.dart';
import '../env.dart';
import '../global/bus.dart';
import '../global/logger.dart';
import '../model/error_message.dart';
import '../model/mappable.dart';
import '../storage/storage.dart';
import '../util/jwt.dart';
import 'interceptors.dart';

class VNMDio {
  final String baseUrl;
  final String contextPath;
  final APIHeaderCreator? headers;

  VNMDio({required this.baseUrl, required this.contextPath, this.headers});

  ResponseMapping? _modelMapping;

  Dio get _dio {
    var dio = Dio();
    dio.interceptors.add(APIInterceptor(headers: headers));
    if (Env().isDev || kDebugMode) {
      dio.interceptors.add(LoggingInterceptor());
      (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }
    return dio;
  }

  VNMDio asModel<T>(ResponseMapping<T> mapping) {
    _modelMapping = mapping;
    return this;
  }

  String _getUrlWithPath(String path) => baseUrl + contextPath + path;

  Stream<T?> STREAM<T extends Mappable>(String path, T model,
      {Map<String, dynamic>? parameters, Function(T response)? onData}) async* {
    T Function(dynamic data) parser = (data) {
      if (data is List) {
        T result = model.fromJson({"list": data}) as T;
        if (onData != null) onData(result);
        return result;
      } else {
        T result = model.fromJson(data) as T;
        if (onData != null) onData(result);
        return result;
      }
    };
    var url = Uri.parse(_getUrlWithPath(path)).toString();

    var data = await Storage().getObjectByRequest(url, parameters);
    if (data != null) {
      try {
        T local = parser(data);
        yield local;
      } catch (exception, stackTrace) {
        Storage().removeObjectByRequest(url, parameters);
        VNMLogger().error(exception, stackTrace);
      }
    }
    var func = () => _dio.get(url, queryParameters: parameters);
    // await Future.delayed(Duration(milliseconds: 2000));
    try {
      if (VNMBus().touch("readyForAuth") == false) return;
      var result = await _dio.catcher(func);
      if (result?.data != null) {
        T data = parser(result?.data!);
        yield data;
        Storage().setObjectByRequest(url, data.toJson(), parameters);
      }
    } catch (exception, stackTrace) {
      VNMException().capture(exception, stackTrace);
    }
  }

  Future<T?> GET<T>(String path, {Map<String, dynamic>? parameters}) async {
    var url = Uri.parse(_getUrlWithPath(path)).toString();
    var result =
        await _dio.catcher(() => _dio.get(url, queryParameters: parameters));
    if (_modelMapping != null) return result?.toModel(_modelMapping!);
    return null;
  }

  Future<T?> POST<T>(String path,
      {Map<String, dynamic>? parameters, Map<String, dynamic>? body}) async {
    var url = Uri.parse(_getUrlWithPath(path)).toString();
    var result = await _dio.catcher(
        () => _dio.post(url, queryParameters: parameters, data: body),
        "/token/refresh" != path);
    if (_modelMapping != null) return result?.toModel(_modelMapping!);
    return null;
  }

  Future<T?> PUT<T>(String path,
      {Map<String, dynamic>? parameters, Map<String, dynamic>? body}) async {
    var url = Uri.parse(_getUrlWithPath(path)).toString();
    var result = await _dio
        .catcher(() => _dio.put(url, queryParameters: parameters, data: body));

    if (_modelMapping != null) return result?.toModel(_modelMapping!);
    return null;
  }
}

extension DioEx on Dio {
  Future<Response?> catcher(Future Function() callback,
      [bool allowRefreshToken = true]) async {
    DioError? dioError;
    Response? response;
    try {
      response = await callback().onError((error, stackTrace) {
        if (error is DioError) {
          dioError = error;
          return error.response;
        }
      });
    } catch (exception) {
      if (exception is DioError) dioError = exception;
    }

    if (dioError != null) {
      if (response == null) throw dioError!;
      await dioErrorHandler(response, allowRefreshToken, callback);
    } else {
      return response;
    }
    return null;
  }

  Future dioErrorHandler(Response response, bool allowRefreshToken,
      Future Function() callback) async {
    var status = response.statusCode ?? -1;
    if (status == HttpStatus.unauthorized) {
      await unauthorizedHandler(response, allowRefreshToken, callback);
    } else if (status == HttpStatus.badRequest) {
      await badRequestHandler(response);
    } else if (status == HttpStatus.internalServerError) {
      throw UnknownMessageException(detail: response.statusMessage);
    } else {
      if (response.data is Map && response.data["message"] is String) {
        throw UnknownMessageException(detail: response.data["message"]);
      }
      throw response;
    }
  }

  Future unauthorizedHandler(Response response, bool allowRefreshToken,
      Future Function() callback) async {
    var errorMsg = await remoteErrorHandler(response);
    if (errorMsg == null) {
      Map<String, MessageException> skipForAuth = {
        "auth/signin/pin": WrongPinException()
      };
      String path = (response.requestOptions.path).ifNull();
      String? key = skipForAuth.keys.firstWhereOrNull((k) => path.endsWith(k));
      if (key != null) {
        throw skipForAuth[key]!;
      }
      if (JwtUtil().isExpired(Auth().refreshToken)) {
        await Auth().foreLogout();
      } else {
        if (allowRefreshToken == true) {
          AuthTokenResponse? authToken;
          authToken = await VNMBus()
              .fire("auth.refreshToken", Auth().refreshToken)
              .onError((error, stackTrace) => null);
          if (authToken == null) {
            await Auth().foreLogout();
          } else {
            Auth().updateToken(authToken);
            await Future.delayed(Duration(milliseconds: 500));
            return catcher(callback, false);
          }
        } else {
          throw UnauthorizedException();
        }
      }
    } else {
      throw RemoteErrorMessageException(errorMsg);
    }
  }

  Future badRequestHandler(Response response) async {
    var errorMsg = await remoteErrorHandler(response);
    if (errorMsg == null) {
      String? errorCode = getErrorCode(response);
      var code =
          ExceptionCode.values.firstWhereOrNull((it) => it.name == errorCode);
      throw code?.exception ??
          UnknownMessageException(detail: response.statusMessage);
    } else {
      throw RemoteErrorMessageException(errorMsg);
    }
  }

  Future<ErrorMessageConfig?> remoteErrorHandler(Response response) async {
    String? errorCode = getErrorCode(response);
    Iterable<ErrorMessageConfig> errors = [];
    errors = await VNMBus().fire("firebase.errorMessages");
    var errorMsg = errors.firstWhereOrNull((it) => it.code == errorCode);
    return errorMsg;
  }

  String? getErrorCode(Response response) {
    try {
      var errorDetails =
          response.data is String ? json.decode(response.data) : response.data;
      String? errorCode = errorDetails['code'];
      return errorCode;
    } catch (exception, stackTrace) {
      // VNMException().capture(exception,stackTrace);
    }
    return null;
  }
}

extension ResponseEx on Response {
  toModel(ResponseMapping mapping) {
    try {
      return mapping(this.data);
    } catch (exception, stackTrace) {
      throw exception;
    }
  }
}
