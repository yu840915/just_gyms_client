import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:where_gym/app_bar_factory.dart';
import 'package:where_gym/appointment_preflight_checks/appointment_preflight_checks.dart';
import 'package:where_gym/intro/permission_checker.dart';
import 'package:where_gym/intro/permission_page.dart';
import 'package:where_gym/shared_appearances.dart';

class AppointmentPreflightSetupPage extends StatelessWidget {
  final AppointmentPreflightCheckResult preflightCheckResult;
  AppointmentPreflightSetupPage(this.preflightCheckResult);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarFactory.appBar(
        title: Text(
          '歡迎使用預約功能',
          style: TextStyles.large.title,
        ),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 40),
        Text(
          '在使用預約功能前，我們需要先進行以下設定',
          style: TextStyles.large.header,
        ),
        SizedBox(height: 30),
        if (!preflightCheckResult.hasPhone) ...[
          PermissionCheckerRow(
            LinkPhonePermissionItem(BlocProvider.of(context)),
          ),
          SizedBox(height: 20),
        ],
        if (!preflightCheckResult.hasAskedNotificationPermission)
          PermissionCheckerRow(NotificationPermissionItem()),
      ],
      crossAxisAlignment: CrossAxisAlignment.center,
    );
  }
}
