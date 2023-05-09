import 'package:jwt_decoder/jwt_decoder.dart';

import '../model/user.dart';

class AuthTokenResponse {
  final String accessToken;
  final String refreshToken;
  final String firebaseToken;
  final User user;

  AuthTokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.firebaseToken,
    required this.user,
  });

  AuthTokenResponse.fromJson(Map<String, dynamic> json)
      : accessToken = json['accessToken'] ?? "",
        refreshToken = json['refreshToken'] ?? "",
        firebaseToken = json['firebaseToken'] ?? "",
        user = User.fromJson(JwtDecoder.decode(json['accessToken']));

  AuthTokenResponse.empty()
      : accessToken = "",
        refreshToken = "",
        firebaseToken = "",
        user = User.empty();

  AuthTokenResponse copyWith({
    String? accessToken,
    String? refreshToken,
    String? firebaseToken,
    User? user,
  }) {
    return AuthTokenResponse(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      firebaseToken: firebaseToken ?? this.firebaseToken,
      user: user ?? this.user,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "accessToken": accessToken,
      "refreshToken": refreshToken,
      "firebaseToken": firebaseToken,
      "user": user,
    };
  }
}
