import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:where_gym/alert_factory.dart';
import 'package:where_gym/app_bar_factory.dart';
import 'package:where_gym/shared_appearances.dart';
import 'package:where_gym/user_verifications/cooldown_timer.dart';
import 'package:where_gym/user_verifications/phone_verification.dart';

class SMSCodePage extends StatefulWidget {
  final PhoneVerification phoneVerification;  
  SMSCodePage(this.phoneVerification);

  @override
  _SMSCodePageState createState() => _SMSCodePageState();
}

class _SMSCodePageState extends State<SMSCodePage> {
  CooldownTimer _timer;
  PhoneVerification get phoneVerification => widget.phoneVerification;
  TextEditingController _editingController;
  StreamSubscription _subscription;
  Future _task;

  void _resendCode(BuildContext context) async {
    if (_task != null) {
      return;
    }
    try {
      _task = phoneVerification.resendSms();
      await _task;
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertFactory.errorAlert(context, error: e),
      );
    } finally {
      _task = null;
    }
  }

  void _submitSmsCode(BuildContext context) async {
    if (_task != null) {
      return;
    }
    try {
      _task = phoneVerification.submitSmsCode(_editingController.text);
      await _task;
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertFactory.errorAlert(context, error: e),
      );
    } finally {
      _task = null;
    }
  }

  @override
  void initState() {
    super.initState();
    _editingController = TextEditingController();
    _subscription = phoneVerification.onPhoneVerified.listen((event) {
      Navigator.popUntil(context, (route) => route.isFirst);
    });
    _timer = CooldownTimer();
    _timer.startCooldown(const Duration(seconds: 60));
  }

  @override
  void dispose() {
    _subscription.cancel();
    _editingController.dispose();
    _timer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarFactory.appBar(
          title: Text(
        '驗證碼已送出',
        style: TextStyles.large.header,
      )),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Spacer(),
          _buildInputField(context),
          SizedBox(height: 8),
          StreamBuilder<int>(
            stream: _timer.onCooldownTime,
            builder: (context, snapshot) {
              return _buildCooldownLabel(context, snapshot.data);
            },
          ),
          SizedBox(height: 12),
          _buildButton(context),
          Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildInputField(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: '請輸入驗證碼',
        labelStyle: TextStyles.large.title.copyWith(color: Colors.black),
        isDense: false,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
      ),
      controller: _editingController,
    );
  }

  Widget _buildCooldownLabel(BuildContext context, int cdTime) {
    if (cdTime == null || cdTime == 0) {
      return RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '驗證碼已送出，如未收到可',
              style: TextStyles.large.detail,
            ),
            TextSpan(
              text: '重新發送',
              style: TextStyles.large.detail
                  .copyWith(decoration: TextDecoration.underline),
              recognizer: TapGestureRecognizer()
                ..onTap = (() {
                  _resendCode(context);
                }),
            ),
          ],
        ),
      );
    } else {
      return Text(
        '驗證碼已送出，$cdTime 秒後可重新發送',
        style: TextStyles.large.detail,
      );
    }
  }

  Widget _buildButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        _submitSmsCode(context);
      },
      child: Text('驗證'),
      style: TextButton.styleFrom(
        textStyle: TextStyles.large.action,
        primary: AppColors.theme,
      ),
    );
  }
}
