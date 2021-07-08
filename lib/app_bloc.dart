import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:where_gym/current_location.dart';
import 'package:where_gym/initialization.dart';
import 'package:where_gym/intro/permission_checker.dart';
import 'package:where_gym/me/cloud_favorites.dart';
import 'package:where_gym/me/favorites.dart';
import 'package:where_gym/me/local_favorites.dart';

class AppBloc extends Bloc<dynamic, AppPhase> {
  final _hasFinishedIntroKey = 'hasFinishedIntro';
  final permissionChecker = PermissionChecker();
  User _firebaseUser;
  FavoriteGymList get favoriteGymList =>
      _cloudFavoriteGymList ?? _localFavoriteGymList;
  final LocalFavoriteGymList _localFavoriteGymList;
  CloudFavoriteGymList _cloudFavoriteGymList;
  final CurrentLocation location;
  final _subscriptions = List<StreamSubscription>.empty(growable: true);
  DocumentReference get userRef => isLoggedIn
      ? FirebaseFirestore.instance.collection('users').doc(_firebaseUser.uid)
      : null;
  AppBloc(initialState, {@required InitializedProducts initializedProducts})
      : _firebaseUser = initializedProducts.userCredential.user,
        _localFavoriteGymList = initializedProducts.favoriteGymList,
        location = initializedProducts.location,
        super(initialState) {
    _checkPermission();
    _subscribeEvents();
  }

  bool get isLoggedIn =>
      _firebaseUser == null ? false : !_firebaseUser.isAnonymous;

  void _subscribeEvents() {
    _subscriptions.add(FirebaseAuth.instance.authStateChanges().listen((event) {
      _handleUserUpdate(event);
    }));
  }

  void _handleUserUpdate(User user) {
    if (user == null) {
      _firebaseUser = null;
      _cloudFavoriteGymList?.dispose();
      _cloudFavoriteGymList = null;
      return;
    }
    _firebaseUser = user;
    if (!user.isAnonymous) {
      _cloudFavoriteGymList = CloudFavoriteGymList(this);
    }
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

  Future<String> getIdToken() => _firebaseUser?.getIdToken();

  Future syncFavoriteGyms() async {
    await _cloudFavoriteGymList?.syncWithLocalList(_localFavoriteGymList);
  }

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
