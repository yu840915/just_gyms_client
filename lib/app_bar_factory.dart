import 'package:flutter/material.dart';
import 'package:where_gym/shared_appearances.dart';

class AppBarFactory {
  AppBarFactory._();
  static Widget appBar({Widget leading, Widget title, List<Widget> actions}) {
    return PreferredSize(
      preferredSize: Size.fromHeight(42),
      child: AppBar(        
        leading: leading,
        title: title,
        actions: actions,
        iconTheme: IconThemeData(color: AppColors.theme),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }

  static Widget transparentAppBar(
      {Widget leading, Widget title, List<Widget> actions}) {
    return PreferredSize(
      preferredSize: Size.fromHeight(42),
      child: AppBar(
        leading: leading,
        title: title,
        actions: actions,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }

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
