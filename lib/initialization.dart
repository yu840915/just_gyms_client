import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:where_gym/configs.dart';
import 'package:where_gym/me/favorites.dart';

class Initialization {
  static Future<InitializedProducts> initialize() async {
    final firebaseApp = await Firebase.initializeApp();
    final cred = await FirebaseAuth.instance.signInAnonymously();
    final dir = await getApplicationDocumentsDirectory();
    Hive
      ..init(dir.path)
      ..registerAdapter(FavoriteGymAdapter());
    final favorites = await FavoriteGymList.createList();
    Configs.setInstance(await Configs.initialize());
    return InitializedProducts(
        firebaseApp: firebaseApp,
        userCredential: cred,
        favoriteGymList: favorites);
  }
}

class InitializedProducts {
  final FirebaseApp firebaseApp;
  final UserCredential userCredential;
  final FavoriteGymList favoriteGymList;
  InitializedProducts({
    @required this.firebaseApp,
    @required this.userCredential,
    @required this.favoriteGymList,
  });
}
