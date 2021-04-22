import 'package:flutter/material.dart';

abstract class PermissionItem {
  bool needsRequestPermission;
  String message;
  Widget icon;
  void skipPermissionRequest();
  void startPermissionRequest();
}
