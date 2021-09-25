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

  void _showStartTimePicker(BuildContext context) async {
    final start = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (start != null) {
      _composer.setStart(start);
    }
  }

  void _showEndTimePicker(BuildContext context) async {
    final end = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (end != null) {
      _composer.setEnd(end);
    }
  }

  @override
  void initState() {
    super.initState();
    _composer =
        AppointmentTimeComposer(businessHours: widget.gym.weekdayBusinessHours);
  }

  @override
  void dispose() {
    _composer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarFactory.appBar(),
      body: StreamBuilder<void>(
          stream: _composer.onDay,
          builder: (context, snapshot) {
            return _buildBody(context);
          }),
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
          rangeSelectionMode: RangeSelectionMode.disabled,
          onDaySelected: (date, _) => _composer.setDay(date),
          selectedDayPredicate: (date) => _composer.isDaySelected(date),
        ),
        Spacer(),
        SafeArea(
          child: StreamBuilder<TimeRange>(
            stream: _composer.onTimeRange,
            builder: (context, snapshot) {
              return _buildTimeButtons(snapshot.data);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeButtons(TimeRange range) {
    return Column(
      children: [
        TextButton(
          onPressed: () {
            _showStartTimePicker(context);
          },
          child: Text(_formatTime(range?.start, "開始時間")),
        ),
        TextButton(
          onPressed: () {
            _showEndTimePicker(context);
          },
          child: Text(_formatTime(range?.end, "結束時間")),
          style: TextButton.styleFrom(),
        ),
      ],
    );
  }

  String _formatTime(TimeOfDay time, String placeholder) {
    return time != null ? time.stringValue : placeholder;
  }
}
