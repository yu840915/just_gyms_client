import 'package:flutter/material.dart';

class AppColors {
  AppColors._();
  // static final theme = const Color(0xffad4d47);
  static final theme = const Color(0xffa1352b);
}

class LargeTextStyles {
  LargeTextStyles._();

  static const title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );

  static const detail = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Colors.black,
  );

  static const action = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );
}

class SmallTextStyles {
  SmallTextStyles._();

  static const title = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );

  static const detail = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Colors.black,
  );

  static const action = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );
}
