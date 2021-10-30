import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:where_gym/alert_factory.dart';
import 'package:where_gym/appointment/appointment_info.dart';
import 'package:where_gym/appointment/appointment_schedule.dart';
import 'package:where_gym/shared_appearances.dart';

class UserAppointmentCell extends StatelessWidget {
  final AppointmentInfo info;
  final AppointmentSchedule? schedule;
  UserAppointmentCell({required this.info, required this.schedule});

  void _cancel(BuildContext context) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertFactory.actionAlert(
        context,
        cancelTitle: '保留預約',
        title: '確定要取消在 ${info.gymName} 的預約？',
        message:
            '時間：${Formats.day.format(info.timeRange.start)} ${Formats.time.format(info.timeRange.start)} - ${Formats.time.format(info.timeRange.end)}\n確認後將立即取消該預約',
        actions: [
          PlatformDialogAction(
            child: Text(
              '取消預約',
              style: TextStyle(color: AppColors.destructive),
            ),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    if (confirmed == null || confirmed == false) {
      return;
    }
    try {
      await schedule!.cancel(info);
    } catch (e) {
      showDialog(
          context: context,
          builder: (context) => AlertFactory.errorAlert(context, error: e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      child: Column(
        children: [
          _buildGymInfo(),
          _buildTimeRange(),
          Row(
            children: [
              Spacer(),
              _buildCancelButton(context),
            ],
          ),
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildGymInfo() {
    return Text(
      info.gymName!,
      style: TextStyles.small.title,
    );
  }

  Widget _buildTimeRange() {
    return Text(
      '${Formats.time.format(info.timeRange.start)} - ${Formats.time.format(info.timeRange.end)}',
      style: TextStyles.small.title,
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        _cancel(context);
      },
      child: Text('取消預約'),
      style: TextButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: TextStyles.small.action,
        primary: Colors.grey.shade400,
      ),
    );
  }
}
