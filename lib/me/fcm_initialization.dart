import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:where_gym/app_bloc.dart';

class FCMInitialization {
  final AppBloc bloc;
  FirebaseMessaging get _messaging => FirebaseMessaging.instance;
  FCMInitialization(this.bloc);
  bool _hasIntialized = false;

  Future<void> initializeIfNeeded() async {
    if (_hasIntialized) {
      return;
    }
    await _requestPermission();
    await _updateToken();
    _hasIntialized = true;
  }

  Future<void> _requestPermission() async {
    if (!Platform.isIOS) {
      return;
    }
    await _messaging.requestPermission(
      provisional: true,
      badge: true,
      sound: true,
      alert: true,
    );
  }

  Future<void> _updateToken() async {
    final token = await _messaging.getToken();
    print(token);
  }
}
