import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:where_gym/login/authenticators.dart';

class LoginPage extends StatelessWidget {
  void _performSignIn(Future<UserCredential> task) async {
    try {
      await task;
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _buildFBButton(context),
              _buildGoogleButton(context),
              _buildAppleButton(context),
            ],
            mainAxisSize: MainAxisSize.min,
          ),
        ),
      ),
    );
  }

  Widget _buildFBButton(BuildContext context) {
    return TextButton(
        onPressed: () {
          _performSignIn(Authenticators.signInWithFacebook());
        },
        child: Text('Facebook'));
  }

  Widget _buildGoogleButton(BuildContext context) {
    return TextButton(
        onPressed: () async {
          _performSignIn(Authenticators.signInWithGoogle());
        },
        child: Text('Google'));
  }

  Widget _buildAppleButton(BuildContext context) {
    return TextButton(
        onPressed: () async {
          _performSignIn(Authenticators.signInWithApple());
        },
        child: Text('Apple'));
  }
}
