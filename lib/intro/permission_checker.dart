import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:where_gym/api_services/api_services.dart';
import 'package:where_gym/app_bloc.dart';
import 'package:where_gym/me/fcm_initialization.dart';
import 'package:where_gym/named_routes.dart';

class PermissionChecker {
  final _hasUnfinishedItemsSubject = BehaviorSubject<bool>();
  Stream<bool> get onHasUnfinishedItems => _hasUnfinishedItemsSubject;
  final List<PermissionItem> items = [LocationPermissionItem()];
  List<StreamSubscription> _subscriptions;
  PermissionChecker() {
    _subscriptions = items
        .map((e) => e.onUpdate.listen((event) {
              _update();
            }))
        .toList();
    _update();
  }

  void _update() async {
    final values =
        await Future.wait(items.map((e) => e.needsRequestPermission()));
    _hasUnfinishedItemsSubject.add(values.contains(true));
  }

  void dispose() {
    _subscriptions.forEach((e) {
      e.cancel();
    });
  }
}

abstract class PermissionItem {
  Future<bool> needsRequestPermission();
  Stream<dynamic> get onUpdate;
  String get message;
  Widget get icon;
  Future<void> skipPermissionRequest();
  Future<bool> startPermissionRequest(BuildContext context);
}

class NotificationPermissionItem implements PermissionItem {
  final _key = 'permissionItem-Notification';
  final _updateSubject = BehaviorSubject<dynamic>();
  @override
  Stream get onUpdate => _updateSubject;

  @override
  Future<bool> needsRequestPermission() async {
    if (Platform.isAndroid) {
      return false;
    }
    final prefs = await SharedPreferences.getInstance();
    return !prefs.containsKey(_key);
  }

  @override
  Future<void> skipPermissionRequest() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, false);
    _updateSubject.add(null);
  }

  @override
  Future<bool> startPermissionRequest(BuildContext context) async {
    final status = await FCMInitialization.requestPermissionIfNeeded();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
    _updateSubject.add(null);
    return status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional;
  }

  @override
  Widget get icon => Icon(Icons.alarm_on, size: 44);

  @override
  String message = '為了能讓我們提醒您場租預約，需要您授權通知服務。';
}

class LocationPermissionItem implements PermissionItem {
  final _key = 'permissionItem-Location';
  final _updateSubject = BehaviorSubject<dynamic>();
  @override
  Stream get onUpdate => _updateSubject;

  @override
  Future<bool> needsRequestPermission() async {
    final prefs = await SharedPreferences.getInstance();
    return !prefs.containsKey(_key);
  }

  @override
  Future<void> skipPermissionRequest() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, false);
    _updateSubject.add(null);
  }

  @override
  Future<bool> startPermissionRequest(BuildContext context) async {
    final status = await Permission.locationWhenInUse.request();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
    _updateSubject.add(null);
    return status == PermissionStatus.granted ||
        status == PermissionStatus.limited;
  }

  @override
  final Widget icon = Icon(Icons.location_on, size: 44);

  @override
  final String message = '為了能讓我們幫您找尋附近的場租，需要您授權定位服務。';
}

class LinkPhonePermissionItem implements PermissionItem {
  AppBloc bloc;
  LinkPhonePermissionItem(this.bloc);
  @override
  String message = '為了能在預約到期時可以連絡上您，需要您綁定聯絡電話號碼。';

  @override
  Widget icon = Icon(Icons.phone, size: 44);

  @override
  Future<bool> needsRequestPermission() async {
    return bloc.firebaseUser.phoneNumber != null;
  }

  @override
  Stream get onUpdate => bloc.onFirebaseUserChange;

  @override
  Future<void> skipPermissionRequest() {
    throw LocalError('為避免濫用，預約功能將只開放給連結電話的用戶');
  }

  @override
  Future<bool> startPermissionRequest(BuildContext context) async {
    await Navigator.pushNamed(context, RouteNames.phoneVerification);
    return needsRequestPermission();
  }
}
