import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/subjects.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:where_gym/admin_gym_list.dart';
import 'package:where_gym/api_services/api_services.dart';
import 'package:where_gym/current_location.dart';
import 'package:where_gym/gym.dart';
import 'package:where_gym/initialization.dart';
import 'package:where_gym/intro/permission_checker.dart';
import 'package:where_gym/me/cloud_favorites.dart';
import 'package:where_gym/me/favorites.dart';
import 'package:where_gym/me/fcm_initialization.dart';
import 'package:where_gym/me/local_favorites.dart';

class AppBloc extends Bloc<dynamic, AppPhase?> {
  final _hasFinishedIntroKey = 'hasFinishedIntro';
  final permissionChecker = PermissionChecker();

  final _firebaseUserSubject = BehaviorSubject<User?>();
  Stream<User?> get onFirebaseUserChange => _firebaseUserSubject;
  User? get firebaseUser => isLoggedIn ? _firebaseUserSubject.value : null;
  FavoriteGymList get favoriteGymList =>
      _cloudFavoriteGymList ?? _localFavoriteGymList;
  final LocalFavoriteGymList _localFavoriteGymList;
  CloudFavoriteGymList? _cloudFavoriteGymList;
  AdminGymList? get adminGymList => _adminGymList;
  AdminGymList? _adminGymList;
  final CurrentLocation location;
  final _subscriptions = List<StreamSubscription>.empty(growable: true);
  final _userRefSubject = BehaviorSubject<DocumentReference?>();
  DocumentReference? get userRef => _userRefSubject.valueOrNull;
  Stream<DocumentReference?> get onUserRefChange => _userRefSubject;
  AppBloc(initialState, {required InitializedProducts initializedProducts})
      : _localFavoriteGymList = initializedProducts.favoriteGymList,
        location = initializedProducts.location,
        super(initialState) {
    _firebaseUserSubject.add(initializedProducts.user);
    _checkPermission();
    _subscribeEvents();
  }

  void dispose() {
    _userRefSubject.close();
    _subscriptions.forEach((element) {
      element.cancel();
    });
  }

  bool get isLoggedIn => _firebaseUserSubject.valueOrNull == null
      ? false
      : !_firebaseUserSubject.value!.isAnonymous;

  void _subscribeEvents() {
    _subscriptions.add(FirebaseAuth.instance.authStateChanges().listen((event) {
      _handleUserUpdate(event);
    }));
  }

  void _handleUserUpdate(User? user) {
    if (user == null) {
      _firebaseUserSubject.add(null);
      _cloudFavoriteGymList?.dispose();
      _cloudFavoriteGymList = null;
      _userRefSubject.add(null);
      _adminGymList?.dispose();
      _adminGymList = null;
      return;
    }
    final oldUser = _firebaseUserSubject.valueOrNull;
    _firebaseUserSubject.add(user);
    if (!user.isAnonymous) {
      _deleteAnonymousUserIfApplicable(oldUser);
      _cloudFavoriteGymList = CloudFavoriteGymList(this, user);
      _userRefSubject.add(
        FirebaseFirestore.instance.collection('users').doc(user.uid),
      );
      _adminGymList = AdminGymList(userRef);
      FCMInitialization.syncToken(this).catchError(print);
    }
  }

  Future<void> _deleteAnonymousUserIfApplicable(User? user) async {
    if (user == null || !user.isAnonymous) {
      return;
    }
    await APIServices.instances.delete(
      '/users/${user.uid}',
      token: await getIdToken(),
    );
  }

  void _checkPermission() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_hasFinishedIntroKey) ||
        !prefs.getBool(_hasFinishedIntroKey)!) {
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

  Future<String>? getIdToken() =>
      _firebaseUserSubject.valueOrNull?.getIdToken();

  Future syncFavoriteGyms() async {
    await _cloudFavoriteGymList?.syncWithLocalList(_localFavoriteGymList);
  }

  @override
  Stream<AppPhase?> mapEventToState(event) async* {
    yield event as AppPhase;
  }

  void setIntroFinished() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setBool(_hasFinishedIntroKey, true);
      _setUpPermission();
    } catch (e, stack) {
      print(e);
      print(stack);
    }
  }

  bool shouldShowAdminPageForGym(Gym? gym) {
    if (!isLoggedIn) {
      return false;
    }
    return adminGymList!.isAdminOfGym(gym);
  }

  Future<void> deleteUser() async {
    if (!isLoggedIn) {
      return;
    }
    await APIServices.instances.delete('/me', token: await getIdToken());
  }
}

enum AppPhase { intro, permission, app }
