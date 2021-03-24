import 'package:flutter/material.dart';

class AppBarFactory {
  AppBarFactory._();
  
  static Widget shrinkedAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(0),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }
}
