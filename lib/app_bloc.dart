import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:where_gym/current_location.dart';
import 'package:where_gym/initialization.dart';
import 'package:where_gym/intro/permission_checker.dart';
import 'package:where_gym/me/favorites.dart';

class AppBloc extends Bloc<dynamic, AppPhase> {
  final _hasFinishedIntroKey = 'hasFinishedIntro';
  final permissionChecker = PermissionChecker();
  final UserCredential _userCredential;
  final FavoriteGymList favoriteGymList;
  final CurrentLocation location = CurrentLocation();
  AppBloc(initialState, {@required InitializedProducts initializedProducts})
      : _userCredential = initializedProducts.userCredential,
        favoriteGymList = initializedProducts.favoriteGymList,
        super(initialState) {
    _checkPermission();
  }

  void _checkPermission() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_hasFinishedIntroKey) ||
        !prefs.getBool(_hasFinishedIntroKey)) {
      add(AppPhase.intro);
    } else {
      _setUpPermission();
    }
  }

  void _setUpPermission() {
    permissionChecker.onHasUnfinishedItems.listen((shouldAsk) {
      if (shouldAsk) {
        add(AppPhase.permission);
      } else {
        add(AppPhase.app);
      }
    });
  }

  Future<String> getIdToken() => _userCredential.user.getIdToken();

  @override
  Stream<AppPhase> mapEventToState(event) async* {
    yield event;
  }

  void setIntroFinished() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setBool(_hasFinishedIntroKey, true);
      _setUpPermission();
    } catch (e) {
      print(e);
    }
  }
}

enum AppPhase { intro, permission, app }
