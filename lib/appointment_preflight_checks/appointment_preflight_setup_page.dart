import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:where_gym/alert_factory.dart';
import 'package:where_gym/app_bar_factory.dart';
import 'package:where_gym/appointment_preflight_checks/appointment_preflight_checks.dart';
import 'package:where_gym/configs.dart';
import 'package:where_gym/intro/permission_checker.dart';
import 'package:where_gym/intro/permission_page.dart';
import 'package:where_gym/shared_appearances.dart';

class AppointmentPreflightSetupPage extends StatelessWidget {
  final AppointmentPreflightCheckResult preflightCheckResult;
  AppointmentPreflightSetupPage(this.preflightCheckResult);

  void _openLink(BuildContext context, String link) async {
    try {
      await launch(link);
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertFactory.errorAlert(context, error: e),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarFactory.appBar(
        title: Text(
          '歡迎使用預約功能',
          style: TextStyles.large.title,
        ),
      ) as PreferredSizeWidget?,
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
        if (!preflightCheckResult.hasPhone!) ...[
          PermissionCheckerRow(
            LinkPhonePermissionItem(BlocProvider.of(context)),
          ),
          SizedBox(height: 20),
        ],
        if (!preflightCheckResult.hasAskedNotificationPermission!)
          PermissionCheckerRow(NotificationPermissionItem()),
        SizedBox(height: 20),
        _buildPolicy(context),
      ],
      crossAxisAlignment: CrossAxisAlignment.center,
    );
  }

  Widget _buildPolicy(BuildContext context) {
    final normal = TextStyle(
      fontSize: 12,
      color: Colors.black54,
      fontWeight: FontWeight.w300,
    );
    final link = normal.copyWith(
        color: Colors.black,
        fontWeight: FontWeight.w500,
        decoration: TextDecoration.underline);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(children: [
            TextSpan(text: '請詳細閱讀', style: normal),
            TextSpan(
                text: '服務條款',
                style: link,
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    _openLink(context, Configs.instance!.tosLink);
                  }),
            TextSpan(text: '及', style: normal),
            TextSpan(
                text: '隱私權政策',
                style: link,
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    _openLink(context, Configs.instance!.ppLink);
                  }),
            TextSpan(text: '。繼續使用代表閣下同意我們的政策。', style: normal),
          ])),
    );
  }
}
