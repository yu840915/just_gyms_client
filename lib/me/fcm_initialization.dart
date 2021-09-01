import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:where_gym/api_services/api_services.dart';
import 'package:where_gym/app_bloc.dart';

class FCMInitialization {
  static FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  static Future<AuthorizationStatus> requestPermissionIfNeeded() async {
    final settings = await _messaging.requestPermission(
      provisional: true,
      badge: true,
      sound: true,
      alert: true,
    );
    return settings.authorizationStatus;
  }

  static Future<void> syncToken(AppBloc bloc) async {
    final token = await _messaging.getToken();
    print('FCM token: $token');
    await APIServices.instances
        .post(
          '/me/fcm-tokens',
          body: {'token': token},
          token: await bloc.getIdToken(),
        )
        .catchError(print);
  }
}
