import 'package:flutter/material.dart';

class AppColors {
  AppColors._();
  static final theme = const Color(0xff019858);
}

class TextStyles {
  TextStyle header;
  TextStyle title;
  TextStyle detail;
  TextStyle subscription;
  TextStyle action;
  TextStyles._(
      {this.header, this.title, this.detail, this.action, this.subscription});

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
