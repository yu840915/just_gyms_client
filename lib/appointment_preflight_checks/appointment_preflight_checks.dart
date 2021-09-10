import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:where_gym/app_bloc.dart';
import 'package:where_gym/appointment_preflight_checks/appointment_preflight_setup_page.dart';
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
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppointmentPreflightSetupPage(result),
        fullscreenDialog: true,
      ),
    );
    return (await AppointmentPreflightCheck.check(context)).passed;
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
          (await item.getPermissionStatus()) != GrantStatus.undecided,
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
