import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppColors {
  AppColors._();
  static const theme = const Color(0xff019858);
  static final progressing = Colors.grey.shade600;
}

class TextStyles {
  TextStyle header;
  TextStyle title;
  TextStyle detail;
  TextStyle subscription;
  TextStyle action;
  TextStyles._(
      {required this.header, required this.title, required this.detail, required this.action, required this.subscription});

  static final large = TextStyles._(
    header: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: Colors.black,
    ),
    title: TextStyle(
      fontSize: 14,
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
    header: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.black,
    ),
    title: TextStyle(
      fontSize: 12,
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

class ButtonStyles {
  static final ButtonStyle action = OutlinedButton.styleFrom(
    textStyle: TextStyles.large.action,
    minimumSize: Size(double.infinity, 44),
    shape: RoundedRectangleBorder(
      side: BorderSide(color: Colors.grey),
      borderRadius: BorderRadius.circular(8),
    ),
    primary: Colors.black,
  );
  static final ButtonStyle callToAction = TextButton.styleFrom(
    textStyle: TextStyles.large.action,
    minimumSize: Size(double.infinity, 44),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    primary: Colors.white,
    backgroundColor: AppColors.theme,
  );
}

class SharedIcons {
  static IconData get bookmark => Icons.star_border;
  static IconData get bookmarked => Icons.star;
}

class Formats {
  static final time = DateFormat(DateFormat.HOUR_MINUTE);
  static final day = DateFormat(DateFormat.NUM_MONTH_DAY);
  static final weekday = DateFormat(DateFormat.ABBR_WEEKDAY);
  static final integer = NumberFormat("#,###");
}
