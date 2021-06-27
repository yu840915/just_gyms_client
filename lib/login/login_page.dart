import 'package:flutter/material.dart';
import 'package:where_gym/app_bar_factory.dart';
import 'package:where_gym/login/authenticators.dart';

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
          await Authenticators.signInWithFacebook();
        },
        child: Text('Facebook'));
  }

  Widget _buildGoogleButton(BuildContext context) {
    return TextButton(
        onPressed: () async {
          await Authenticators.signInWithGoogle();
        },
        child: Text('Google'));
  }

  Widget _buildAppleButton(BuildContext context) {
    return TextButton(
        onPressed: () async {
          await Authenticators.signInWithApple();
        },
        child: Text('Apple'));
  }
}
