import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:where_gym/configs.dart';
import 'package:where_gym/current_location.dart';
import 'package:where_gym/me/local_favorites.dart';

class Initialization {
  static Future<InitializedProducts> initialize() async {     
    await initializeDateFormatting(Intl.systemLocale, null);
    final firebaseApp = await Firebase.initializeApp();
    User user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      final cred = await FirebaseAuth.instance.signInAnonymously();
      user = cred.user;
    }
    final dir = await getApplicationDocumentsDirectory();
    Hive
      ..init(dir.path)
      ..registerAdapter(FavoriteGymAdapter())
      ..registerAdapter(LocationRecordAdapter());
    Configs.setInstance(await Configs.initialize());
    final favorites = await LocalFavoriteGymList.createList();
    final location = await CurrentLocation.create();
    return InitializedProducts(
        firebaseApp: firebaseApp,
        user: user,
        favoriteGymList: favorites,
        location: location);
  }
}

class InitializedProducts {
  final FirebaseApp firebaseApp;
  final User user;
  final LocalFavoriteGymList favoriteGymList;
  final CurrentLocation location;
  InitializedProducts({
    @required this.firebaseApp,
    @required this.user,
    @required this.favoriteGymList,
    @required this.location,
  });
}
