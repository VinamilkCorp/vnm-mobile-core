import 'dart:convert';

import 'package:collection/collection.dart';

import '../../auth/model/user.dart';
import '../../auth/model/verify_flow_type.dart';
import '../global/logger.dart';
import 'bus.dart';

class AccountTest {
  static AccountTest _i = AccountTest._();

  List<Map<String, dynamic>> data = [];

  AccountTest._();

  factory AccountTest() => _i;

  Future<void> fetch() async {
    var data = await VNMBus().fire("firebase.accountTest");
    try {
      var items = jsonDecode(data)
          .map<Map<String, dynamic>>((t) => t as Map<String, dynamic>)
          .toList();
      this.data = items;
    } catch (exception, stackTrace) {
      VNMLogger().error("Account test: $exception");
    }
  }

  UserRole? getUserRole(String phoneNumber) {
    var tag = VNMBus().touch("tag");
    var first = data.firstWhereOrNull((it) => it["tag"] == tag);
    if (first != null) {
      return UserRole.values.firstWhereOrNull((it) => it.name == first["role"]);
    }
    return null;
  }

  VerifyFlowType? getVerifyFlowType(String phoneNumber) {
    var tag = VNMBus().touch("tag");
    var first = data.firstWhereOrNull((it) => it["tag"] == tag);
    if (first != null) {
      return VerifyFlowType.values
          .firstWhereOrNull((it) => it.name == first["verifyFlowType"]);
    }
    return null;
  }
}
