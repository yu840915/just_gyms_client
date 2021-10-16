import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:where_gym/app_bloc.dart';
import 'package:where_gym/login/login_page.dart';

class LoginCheckFlow {
  LoginCheckFlow._();
  static Future<bool> check(BuildContext context,
      {required String where}) async {
    AppBloc bloc = BlocProvider.of(context);
    if (bloc.isLoggedIn) {
      return true;
    }
    await showDialog(context: context, builder: (context) => LoginPage());
    return bloc.isLoggedIn;
  }
}
