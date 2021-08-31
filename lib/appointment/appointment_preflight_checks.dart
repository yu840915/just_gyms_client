import 'package:flutter/material.dart';
import 'package:where_gym/login/login_check_flow.dart';

class AppintmentPreflightCheckFlow {
  AppintmentPreflightCheckFlow._();

  static Future<bool> check(BuildContext context,
      {@required String where}) async {
    if (await LoginCheckFlow.check(context, where: where) == false) {
      return false;
    }
    return true;
  }
}
