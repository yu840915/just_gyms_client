import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PermissionChecker {
  final _hasUnfinishedItemsSubject = BehaviorSubject<bool>();
  Stream<bool> get onHasUnfinishedItems => _hasUnfinishedItemsSubject;
  final List<PermissionItem> items = [LocationPermissionItem()];
  List<StreamSubscription> _subscriptions;
  PermissionChecker() {
    _subscriptions = items.map((e) => e.onUpdate.listen((event) {})).toList();
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
  String message;
  Widget get icon;
  Future<void> skipPermissionRequest();
  Future<bool> startPermissionRequest();
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
  Future<bool> startPermissionRequest() async {
    final status = await Permission.locationWhenInUse.request();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
    _updateSubject.add(null);
    return status == PermissionStatus.granted ||
        status == PermissionStatus.limited;
  }

  @override
  Widget get icon => Icon(Icons.location_on, size: 44);

  @override
  String message = '為了能讓我們幫您找尋附近的場租，需要您授權定位服務。';
}
