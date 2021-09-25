import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:where_gym/app_bar_factory.dart';
import 'package:where_gym/appointment/appointment_time_composer.dart';
import 'package:where_gym/gym.dart';
import 'package:where_gym/shared_appearances.dart';

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
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
          calendarStyle: CalendarStyle(            
            selectedDecoration: BoxDecoration(
              color: AppColors.theme,
              shape: BoxShape.circle,
            ),
          ),
          rowHeight: 80,
          lastDay: tomorrow.add(Duration(days: 14)),
          calendarFormat: CalendarFormat.week,
          rangeSelectionMode: RangeSelectionMode.disabled,
          onDaySelected: (date, _) => _composer.setDay(date),
          selectedDayPredicate: (date) => _composer.isDaySelected(date),
          eventLoader: null, //TODO: Add events
        ),
        Container(
          color: Colors.grey.shade200,
          child: StreamBuilder<TimeRange>(
            stream: _composer.onTimeRange,
            builder: (context, snapshot) {
              return _buildTimeButtons(snapshot.data);
            },
          ),
        ),
        Spacer(),
      ],
    );
  }

  Widget _buildTimeButtons(TimeRange range) {
    return Row(
      children: [
        TextButton(
          onPressed: () {
            _showStartTimePicker(context);
          },
          child: Text(_formatTime(range?.start, "開始時間")),
          style: TextButton.styleFrom(
            textStyle: TextStyles.large.action,
            primary: AppColors.theme,
          ),
        ),
        Icon(Icons.navigate_next),
        TextButton(
          onPressed: () {
            _showEndTimePicker(context);
          },
          child: Text(_formatTime(range?.end, "結束時間")),
          style: TextButton.styleFrom(
            textStyle: TextStyles.large.action,
            primary: AppColors.theme,
          ),
        ),
      ],
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  String _formatTime(TimeOfDay time, String placeholder) {
    String result = placeholder;
    if (time != null) {
      result = '$result ${time.stringValue}';
    }
    return result;
  }
}
