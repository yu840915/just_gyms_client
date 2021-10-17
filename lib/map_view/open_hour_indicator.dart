import 'package:flutter/material.dart';
import 'package:where_gym/gym.dart';
import 'package:where_gym/shared_appearances.dart';

class OpenHourIndicator extends StatelessWidget {
  final Gym gym;
  final TextStyles styles;
  OpenHourIndicator({required this.gym, required this.styles});

  @override
  Widget build(BuildContext context) {
    final isOpen = gym.isOpenNow();
    if (isOpen == null) {
      return Text(
        '未提供營業時間',
        style: styles.subscription,
      );
    }
    if (!isOpen) {
      return Text(
        '休息中',
        style: styles.detail.copyWith(color: Colors.grey),
      );
    }
    return Text(
      '營業中',
      style: styles.detail.copyWith(color: Colors.green),
    );
  }
}
