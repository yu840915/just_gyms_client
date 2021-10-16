import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:where_gym/alert_factory.dart';
import 'package:where_gym/app_bar_factory.dart';
import 'package:where_gym/shared_appearances.dart';
import 'package:where_gym/user_verifications/phone_verification.dart';
import 'package:where_gym/user_verifications/sms_code_page.dart';

class PhoneVerificationPage extends StatefulWidget {
  @override
  _PhoneVerificationPageState createState() => _PhoneVerificationPageState();
}

class _PhoneVerificationPageState extends State<PhoneVerificationPage> {
  TextEditingController? _editingController;
  PhoneVerification? _verification;
  Future? _sendSmsTask;

  void _sendSmsCode(BuildContext context) async {
    if (_sendSmsTask != null) {
      return;
    }
    try {
      _sendSmsTask = _verification!.sendSMS(_editingController!.text);
      await _sendSmsTask;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SMSCodePage(_verification)),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertFactory.errorAlert(context, error: e),
      );
    } finally {
      _sendSmsTask = null;
    }
  }

  @override
  void initState() {
    super.initState();
    _verification = PhoneVerification(BlocProvider.of(context));
    _editingController = TextEditingController();
  }

  @override
  void dispose() {
    _editingController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarFactory.appBar(
          title: Text(
        '手機驗證',
        style: TextStyles.large.header,
      )) as PreferredSizeWidget?,
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
        labelText: '請輸入手機號碼',
        labelStyle: TextStyles.large.title!.copyWith(color: Colors.black),
        isDense: false,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        hintText: '+886 000 000 000',
      ),
      controller: _editingController,
    );
  }

  Widget _buildButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        _sendSmsCode(context);
      },
      child: Text('發送驗證碼'),
      style: TextButton.styleFrom(
        textStyle: TextStyles.large.action,
        primary: AppColors.theme,
      ),
    );
  }
}
