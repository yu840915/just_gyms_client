import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:where_gym/app_bar_factory.dart';

class AppointmentCreatePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarFactory.appBar(),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          locale: Intl.systemLocale,
          focusedDay: DateTime.now(),
          firstDay: DateTime.now(),
          lastDay: DateTime.now().add(Duration(days: 14)),
          calendarFormat: CalendarFormat.week,
        )
        //Start Time (show picker)
        //End Time (show picker)
      ],
    );
  }
}
