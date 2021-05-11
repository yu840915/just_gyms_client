import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class Initialization {
  static Future<InitializedProducts> initialize() async {
    final firebaseApp = await Firebase.initializeApp();
    final cred = await FirebaseAuth.instance.signInAnonymously();
    return InitializedProducts(firebaseApp: firebaseApp, userCredential: cred);
  }
}

class InitializedProducts {
  final FirebaseApp firebaseApp;
  final UserCredential userCredential;
  InitializedProducts(
      {@required this.firebaseApp, @required this.userCredential});
}
