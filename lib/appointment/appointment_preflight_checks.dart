import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:where_gym/app_bloc.dart';
import 'package:where_gym/intro/permission_checker.dart';
import 'package:where_gym/login/login_check_flow.dart';

class AppointmentPreflightCheckFlow {
  AppointmentPreflightCheckFlow._();

  static Future<bool> check(BuildContext context,
      {@required String where}) async {
    if (await LoginCheckFlow.check(context, where: where) == false) {
      return false;
    }
    final result = await AppointmentPreflightCheck.check(context);
    if (result.passed) {
      return true;
    }
    //Show
    return true;
  }
}

class AppointmentPreflightCheck {
  static Future<AppointmentPreflightCheckResult> check(
      BuildContext context) async {
    AppBloc bloc = BlocProvider.of(context);
    final item = NotificationPermissionItem();
    return AppointmentPreflightCheckResult(
      hasPhone: bloc.firebaseUser.phoneNumber != null,
      hasAskedNotificationPermission:
          (await item.needsRequestPermission()) == false,
    );
  }
}

class AppointmentPreflightCheckResult {
  final bool hasPhone;
  final bool hasAskedNotificationPermission;
  bool get passed => hasPhone && hasAskedNotificationPermission;
  AppointmentPreflightCheckResult(
      {this.hasPhone, this.hasAskedNotificationPermission});
}
