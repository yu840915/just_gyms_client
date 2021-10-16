import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:where_gym/appointment/appointment_info.dart';
import 'package:where_gym/appointment/gym_appointment_schedule.dart';
import 'package:where_gym/shared_appearances.dart';

class AppointmentBadge extends StatefulWidget {
  final GymAppointmentSchedule? schedule;
  AppointmentBadge({required this.schedule});

  @override
  State<AppointmentBadge> createState() => _AppointmentBadgeState();
}

class _AppointmentBadgeState extends State<AppointmentBadge> {
  late AppointmentBadgeSource source;

  @override
  void initState() {
    super.initState();
    source = AppointmentBadgeSource(widget.schedule!);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: source.appointmentCount,
      builder: (context, snapshot) {
        return _buildBadge(snapshot.data);
      },
    );
  }

  Widget _buildBadge(int? count) {
    if (count == null || count == 0) {
      return SizedBox.shrink();
    }
    return Container(
      child: Text(
        Formats.integer.format(count),
        style: TextStyles.small.subscription,
      ),
      height: 20,
      decoration: BoxDecoration(
        color: Colors.green.shade900,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class AppointmentBadgeSource {
  final GymAppointmentSchedule schedule;
  AppointmentBadgeSource(this.schedule)
      : appointmentCount =
            Rx.combineLatest2<List<AppointmentInfo>, dynamic, int>(
                schedule.onAppointments,
                Stream.periodic(Duration(minutes: 1)),
                (list, _b) => list
                    .where((a) => a.timeRange.end.isAfter(DateTime.now()))
                    .length).asBroadcastStream();

  final Stream<int> appointmentCount;
}
