import 'package:jwt_decoder/jwt_decoder.dart';

import '../../material/exception/exception.dart';

class JwtUtil {
  static JwtUtil _i = JwtUtil._();

  JwtUtil._();

  factory JwtUtil() => _i;

  bool isExpired(String refreshToken) {
    bool value = true;
    try {
      value = JwtDecoder.isExpired(refreshToken);
    } catch (exception, stackTrace) {
      VNMException().capture(exception, stackTrace);
    } finally {
      return value;
    }
  }
}
