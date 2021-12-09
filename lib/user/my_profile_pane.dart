import 'package:flutter/material.dart';
import 'package:where_gym/user/avatar_button.dart';

class MyProfilePane extends StatefulWidget {
  @override
  State<MyProfilePane> createState() => _MyProfilePaneState();
}

class _MyProfilePaneState extends State<MyProfilePane> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      height: 120,
      width: double.infinity,
    );
  }

  Widget _build(BuildContext context) {
    return AvatarButton();
  }
}
