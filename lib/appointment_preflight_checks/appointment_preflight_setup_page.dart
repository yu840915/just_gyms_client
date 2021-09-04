import 'package:flutter/material.dart';
import 'package:where_gym/app_bar_factory.dart';
import 'package:where_gym/appointment_preflight_checks/appointment_preflight_checks.dart';

class AppointmentPreflightSetupPage extends StatelessWidget {
  final AppointmentPreflightCheckResult preflightCheckResult;
  AppointmentPreflightSetupPage(this.preflightCheckResult);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarFactory.appBar(),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container();
  }
}
