import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:where_gym/alert_factory.dart';
import 'package:where_gym/configs.dart';
import 'package:where_gym/gen/assets.gen.dart';
import 'package:where_gym/login/authenticators.dart';
import 'package:where_gym/shared_appearances.dart';

class LoginPage extends StatelessWidget {
  void _performSignIn(
      BuildContext context, Future<UserCredential?> task) async {
    try {
      await task;
      Navigator.pop(context);
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertFactory.errorAlert(context, error: e),
      );
    }
  }

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
    return Center(
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
              Text(
                '使用者登入',
                style: TextStyles.large.header.copyWith(
                    color: Colors.black, decoration: TextDecoration.none),
              ),
              SizedBox(height: 24),
              FutureBuilder(
                future: Authenticators.isAppleLoginAvailable,
                builder: (context, snap) => snap.hasData
                    ? Column(
                        children: [
                          _buildAppleButton(context),
                          SizedBox(height: 12),
                        ],
                      )
                    : SizedBox(),
              ),
              _buildFBButton(context),
              SizedBox(height: 12),
              _buildGoogleButton(context),
              SizedBox(height: 24),
              _buildPolicy(context),
            ],
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
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
        minimumSize: Size(double.infinity, 44),
      ),
      onPressed: () {
        _performSignIn(context, Authenticators.signInWithFacebook());
      },
      child: Row(
        children: [
          SvgPicture.asset(Assets.images.facebookLogo, width: 30, height: 30),
          SizedBox(width: 24),
          Text('使用 Facebook 登入')
        ],
        mainAxisAlignment: MainAxisAlignment.center,
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
        minimumSize: Size(double.infinity, 44),
      ),
      onPressed: () async {
        _performSignIn(context, Authenticators.signInWithGoogle());
      },
      child: Row(
        children: [
          SvgPicture.asset(Assets.images.googleLogo, width: 30, height: 30),
          SizedBox(width: 24),
          Text('使用 Google 登入')
        ],
        mainAxisAlignment: MainAxisAlignment.center,
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
        minimumSize: Size(double.infinity, 44),
      ),
      onPressed: () async {
        _performSignIn(context, Authenticators.signInWithApple());
      },
      child: Row(
        children: [
          SvgPicture.asset(Assets.images.appleLogo, width: 30, height: 30),
          SizedBox(width: 24),
          Text('使用 Apple 登入')
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      ),
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
            TextSpan(text: '請先詳細閱讀', style: normal),
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
            TextSpan(text: '。開始使用即代表閣下已同意上述政策。', style: normal),
          ])),
    );
  }
}
