import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppColors {
  AppColors._();
  // static final theme = const Color(0xffad4d47);
  static final theme = const Color(0xffa1352b);
}

class NumberFormats {
  static final NumberFormat distance = _createDistanceFormat();

  static NumberFormat _createDistanceFormat() {
    final format = NumberFormat.decimalPattern();
    format.maximumFractionDigits = 1;
    format.minimumFractionDigits = 1;
    return format;
  }
}

class TextStyles {
  TextStyle title;
  TextStyle detail;
  TextStyle subscription;
  TextStyle action;
  TextStyles._({this.title, this.detail, this.action, this.subscription});

  static final large = TextStyles._(
    title: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    ),
    detail: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Colors.black,
    ),
    subscription: TextStyle(
      fontSize: 11,
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.w400,
      color: Colors.grey,
    ),
    action: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    ),
  );
  static final small = TextStyles._(
    title: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    ),
    detail: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: Colors.black,
    ),
    subscription: TextStyle(
      fontSize: 10,
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.w400,
      color: Colors.grey,
    ),
    action: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    ),
  );
}
