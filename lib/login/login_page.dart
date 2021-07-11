import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:where_gym/gen/assets.gen.dart';
import 'package:where_gym/login/authenticators.dart';
import 'package:where_gym/shared_appearances.dart';

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _buildAppleButton(context),
                SizedBox(height: 12),
                _buildFBButton(context),
                SizedBox(height: 12),
                _buildGoogleButton(context),
              ],
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFBButton(BuildContext context) {
    final color = const Color(0xff1877F2);
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        textStyle: TextStyles.large.action,
        side: BorderSide(color: color),
        primary: color,
        minimumSize: Size(double.infinity, 40),
      ),
      onPressed: () {
        _performSignIn(Authenticators.signInWithFacebook());
      },
      child: Row(
        children: [
          SvgPicture.asset(Assets.images.facebookLogo, width: 30, height: 30),
          SizedBox(width: 24),
          Text('使用 Facebook 登入')
        ],
      ),
    );
  }

  Widget _buildGoogleButton(BuildContext context) {
    final color = Colors.black54;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        textStyle: TextStyles.large.action,
        side: BorderSide(color: color),
        primary: color,
        minimumSize: Size(double.infinity, 40),
      ),
      onPressed: () async {
        _performSignIn(Authenticators.signInWithGoogle());
      },
      child: Row(
        children: [
          SvgPicture.asset(Assets.images.googleLogo, width: 30, height: 30),
          SizedBox(width: 24),
          Text('使用 Google 登入')
        ],
      ),
    );
  }

  Widget _buildAppleButton(BuildContext context) {
    final color = Colors.black;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        textStyle: TextStyles.large.action,
        side: BorderSide(color: color),
        primary: color,
        minimumSize: Size(double.infinity, 40),
      ),
      onPressed: () async {
        _performSignIn(Authenticators.signInWithApple());
      },
      child: Row(
        children: [
          SvgPicture.asset(Assets.images.appleLogo, width: 30, height: 30),
          SizedBox(width: 24),
          Text('使用 Apple 登入')
        ],
      ),
    );
  }
}
