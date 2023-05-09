import 'package:collection/collection.dart';

import '../global/auth.dart';
import '../global/localization.dart';

enum UserRole { ROLE_RETAIL_SHOP_OWNER, ROLE_DISTRIBUTOR_DRIVER }

extension UserRoleEx on UserRole {
  String get text => [
        [Localization().locale.role_retail_short, Auth().user.b2bCode]
            .join(" "),
        Localization().locale.role_distributor_driver,
      ][index];
}

class User {
  final String userCode;
  final String phoneNo;
  final String avatarUrl;
  final String fullName;
  final String b2bCode;
  final String address;
  final List<String> roles;
  final DateTime createdAt;

  User({
    required this.userCode,
    required this.phoneNo,
    required this.avatarUrl,
    required this.fullName,
    required this.b2bCode,
    required this.address,
    required this.roles,
    required this.createdAt,
  });

  bool get hasStoreOwnerRole =>
      roles.contains(UserRole.ROLE_RETAIL_SHOP_OWNER.name);

  UserRole? get role =>
      UserRole.values.firstWhereOrNull((it) => it.name == roles.firstOrNull);

  User.fromJson(Map<String, dynamic> json)
      : userCode = json['userCode'] ?? "",
        phoneNo = json['phoneNumber'] ?? "",
        avatarUrl = json['avatarUrl'] ?? "",
        fullName = json['fullName'] ?? "",
        b2bCode = json['b2bCode'] ?? "",
        address = json['address'] ?? "",
        roles = ((json['roles'] ?? []) as List).cast<String>(),
        createdAt = json['createdAt'] == null
            ? DateTime.now()
            : DateTime.fromMillisecondsSinceEpoch(json['createdAt']);

  User.empty()
      : userCode = "",
        phoneNo = "",
        avatarUrl = "",
        fullName = "",
        b2bCode = "",
        address = "",
        roles = [],
        createdAt = DateTime.now();

  User copyWith({
    String? userCode,
    String? phoneNo,
    String? avatarUrl,
    String? fullName,
    String? b2bCode,
    String? address,
    List<String>? roles,
    DateTime? createdAt,
  }) {
    return User(
      userCode: userCode ?? this.userCode,
      phoneNo: phoneNo ?? this.phoneNo,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      fullName: fullName ?? this.fullName,
      b2bCode: b2bCode ?? this.b2bCode,
      address: address ?? this.address,
      roles: roles ?? this.roles,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "userCode": userCode,
      "phoneNo": phoneNo,
      "avatarUrl": avatarUrl,
      "fullName": fullName,
      "b2bCode": b2bCode,
      "address": address,
      "roles": roles,
      "createdAt": createdAt.millisecondsSinceEpoch,
    };
  }
}
