import 'package:flutter/material.dart';
import 'package:where_gym/app_bar_factory.dart';
import 'package:where_gym/appointment_preflight_checks/appointment_preflight_checks.dart';
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
        if (!preflightCheckResult.hasPhone) ...[
          _LinkPhoneCell(),
          SizedBox(height: 8),
        ],
        if (!preflightCheckResult.hasAskedNotificationPermission)
          _NotificationCell(),
      ],
    );
  }
}

class _LinkPhoneCell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class _NotificationCell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
