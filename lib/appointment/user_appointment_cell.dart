import 'package:flutter/material.dart';
import 'package:where_gym/alert_factory.dart';
import 'package:where_gym/appointment/appointment_info.dart';
import 'package:where_gym/appointment/appointment_schedule.dart';
import 'package:where_gym/shared_appearances.dart';

class UserAppointmentCell extends StatelessWidget {
  final AppointmentInfo info;
  final AppointmentSchedule? schedule;
  UserAppointmentCell({required this.info, required this.schedule});

  void _cancel(BuildContext context) async {
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
