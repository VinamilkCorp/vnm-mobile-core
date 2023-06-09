import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

import '../../auth/auth.dart';
import '../../material/exception/index.dart';
import '../global/logger.dart';

typedef APIHeaderCreator = Map<String, Future<String> Function()>;

class APIInterceptor implements Interceptor {
  final APIHeaderCreator? headers;

  APIInterceptor({this.headers});

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    var timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    options.headers["Content-Type"] = "application/json";

    if (Auth().accessToken.isNotEmpty) {
      options.headers["Authorization"] = "Bearer " + Auth().accessToken;
    }

    // //fake refresh token
    // bool isExpired = false;
    // int count = await Storage().getInt("fake_refresh_token") ?? 8;
    // count--;
    // VNMLogger().info("DEBUG: fake refresh token ========> $count");
    // if (count == 0) {
    //   await Storage().setInt("fake_refresh_token", 8);
    //   isExpired = true;
    // } else {
    //   await Storage().setInt("fake_refresh_token", count);
    // }
    // if (isExpired) {
    //   options.headers.remove("Authorization");
    //   // Auth().removeRefreshToken();
    // }

    //client-id
    //x-device-info
    for (int i = 0; i < (headers?.length ?? 0); i++) {
      var key = headers!.keys.elementAt(i);
      var value = await headers![key]!();
      options.headers[key] = value;
    }
    options.headers["accept"] = "*/*";
    options.headers['x-timestamp'] = timestamp;

    var requestPath = "/";
    try {
      requestPath =
          "/${options.uri.toString().split("//").sublist(1).join("//").split("/").sublist(1).join("/")}";
    } catch (exception, stackTrace) {
      VNMException().capture(exception, stackTrace);
    } finally {
      options.headers['x-signature'] = await createApiSignature(
        url: requestPath,
        timestamp: timestamp,
        deviceInfo: options.headers["x-device-info"],
        requestBody: options.data ?? "",
        signatureSalt: options.headers["signature"],
      );
      options.headers.remove("signature");
      handler.next(options);
    }
  }

  @override
  Future<void> onResponse(
      Response response, ResponseInterceptorHandler handler) async {
    if (response.statusCode != null && response.statusCode! >= 400) {
      try {
        VNMException().log(
            "[${response.statusCode}] ${response.requestOptions.uri.toString()}",
            jsonEncode({
              "request": {
                "method": response.requestOptions.method,
                "uri": response.requestOptions.uri.toString(),
                "header": response.requestOptions.headers,
                "queryParameters": response.requestOptions.queryParameters,
                "data": response.requestOptions.data,
              },
              "response": {
                "statusCode": response.statusCode,
                "statusMessage": response.statusMessage,
                "data": response.data,
              }
            }));
      } catch (exception, stackTrace) {
        VNMException().capture(exception, stackTrace);
      }
    }
    handler.next(response);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    try {
      VNMException().log(
          "[${err.type.toString()}] ${err.error?.toString()}",
          jsonEncode({
            "type": err.type.toString(),
            "error": err.error?.toString(),
            "message": err.message,
            "request": {
              "method": err.requestOptions.method,
              "uri": err.requestOptions.uri.toString(),
              "header": err.requestOptions.headers,
              "queryParameters": err.requestOptions.queryParameters,
              "data": err.requestOptions.data,
            },
            "response": {
              "statusCode": err.response?.statusCode,
              "statusMessage": err.response?.statusMessage,
              "data": err.response?.data,
            }
          }));
    } catch (exception, stackTrace) {
      VNMException().capture(exception, stackTrace);
    }
    handler.next(err);
  }

  Future<String> createApiSignature({
    required String url,
    required String timestamp,
    required String deviceInfo,
    required dynamic requestBody,
    required String? signatureSalt,
  }) async {
    List<String> toHash = [url, timestamp, deviceInfo];

    if (requestBody != null) {
      if (requestBody is String) {
        toHash.add(requestBody);
      } else {
        toHash.add(jsonEncode(requestBody));
      }
    }
    if (signatureSalt != null) {
      toHash.add(signatureSalt);
    }
    List<int> messageBytes = utf8.encode(toHash.join("."));
    var digest = sha256.convert(messageBytes);
    return digest.toString();
  }
}

class LoggingInterceptor implements Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    VNMLogger().finer({
      "method": options.method,
      "uri": options.uri,
      "header": options.headers,
      "queryParameters": options.queryParameters,
      "data": options.data,
    });
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    try {
      VNMLogger().finest({
        "request": {
          "method": response.requestOptions.method,
          "uri": response.requestOptions.uri.toString(),
          "header": response.requestOptions.headers,
          "queryParameters": response.requestOptions.queryParameters,
          "data": response.requestOptions.data,
        },
        "response": {
          "statusCode": response.statusCode,
          "statusMessage": response.statusMessage,
          "data": response.data,
        }
      });
    } catch (exception, stackTrace) {
      VNMException().capture(exception, stackTrace);
    }
    handler.next(response);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    try {
      VNMLogger().error({
        "type": err.type.toString(),
        "error": err.error?.toString(),
        "message": err.message,
        "request": {
          "method": err.requestOptions.method,
          "uri": err.requestOptions.uri.toString(),
          "header": err.requestOptions.headers,
          "queryParameters": err.requestOptions.queryParameters,
          "data": err.requestOptions.data,
        },
        "response": {
          "statusCode": err.response?.statusCode,
          "statusMessage": err.response?.statusMessage,
          "data": err.response?.data,
        }
      });
    } catch (exception, stackTrace) {
      VNMException().capture(exception, stackTrace);
    }
    handler.next(err);
  }
}
