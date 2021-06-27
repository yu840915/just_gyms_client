import 'package:flutter/material.dart';
import 'package:where_gym/app_bar_factory.dart';
import 'package:where_gym/login/login_manager.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarFactory.appBar(),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        _buildFBButton(context),
        _buildGoogleButton(context),
        _buildAppleButton(context),
      ],
    );
  }

  Widget _buildFBButton(BuildContext context) {
    return TextButton(
        onPressed: () async {
          await LoginManager.signInWithFacebook();
        },
        child: Text('Facebook'));
  }

  Widget _buildGoogleButton(BuildContext context) {
    return TextButton(
        onPressed: () async {
          await LoginManager.signInWithGoogle();
        },
        child: Text('Google'));
  }

  Widget _buildAppleButton(BuildContext context) {
    return TextButton(
        onPressed: () async {
          await LoginManager.signInWithApple();
        },
        child: Text('Apple'));
  }
}
