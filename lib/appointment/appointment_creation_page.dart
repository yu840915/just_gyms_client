import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:where_gym/app_bar_factory.dart';
import 'package:where_gym/appointment/appointment_time_composer.dart';
import 'package:where_gym/gym.dart';

class AppointmentCreatePage extends StatefulWidget {
  final Gym gym;
  AppointmentCreatePage({@required this.gym});

  @override
  _AppointmentCreatePageState createState() => _AppointmentCreatePageState();
}

class _AppointmentCreatePageState extends State<AppointmentCreatePage> {
  AppointmentTimeComposer _composer;

  @override
  void initState() {
    super.initState();
    _composer =
        AppointmentTimeComposer(businessHours: widget.gym.weekdayBusinessHours);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarFactory.appBar(),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final tomorrow = DateTime.now().add(Duration(days: 1));
    return Column(
      children: [
        TableCalendar(
          locale: Intl.systemLocale,
          focusedDay: tomorrow,
          firstDay: tomorrow,
          lastDay: tomorrow.add(Duration(days: 14)),
          calendarFormat: CalendarFormat.week,
        )
        //Start Time (show picker)
        //End Time (show picker)
      ],
    );
  }
}
