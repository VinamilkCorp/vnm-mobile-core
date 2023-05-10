import 'package:jwt_decoder/jwt_decoder.dart';

import '../exception/index.dart';

class JwtUtil {
  static JwtUtil _i = JwtUtil._();

  JwtUtil._();

  factory JwtUtil() => _i;

  bool isExpired(String refreshToken) {
    try {
      return JwtDecoder.isExpired(refreshToken);
    } catch (exception, stackTrace) {
      VNMException().capture(exception, stackTrace);
    }
    ;
    return true;
  }
}
