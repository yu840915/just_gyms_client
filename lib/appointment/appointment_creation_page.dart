import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:where_gym/alert_factory.dart';
import 'package:where_gym/app_bar_factory.dart';
import 'package:where_gym/app_bloc.dart';
import 'package:where_gym/appointment/appointment_info.dart';
import 'package:where_gym/appointment/gym_appointment_schedule.dart';
import 'package:where_gym/appointment/appointment_time_composer.dart';
import 'package:where_gym/appointment/user_appointment_cell.dart';
import 'package:where_gym/gym.dart';
import 'package:where_gym/shared_appearances.dart';
import 'package:where_gym/utils/loading_view.dart';

class AppointmentCreatePage extends StatefulWidget {
  final Gym gym;
  AppointmentCreatePage({@required this.gym});

  @override
  _AppointmentCreatePageState createState() => _AppointmentCreatePageState();
}

class _AppointmentCreatePageState extends State<AppointmentCreatePage> {
  AppointmentTimeComposer _composer;
  GymAppointmentSchedule _schedule;

  void _showStartTimePicker(BuildContext context) async {
    final start = await showTimePicker(
      context: context,
      initialTime: _composer.startTime ?? TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.input,
      helpText: '選擇開始時間',
    );
    if (start != null) {
      try {
        _composer.setStart(start);
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertFactory.errorAlert(context, error: e),
        );
      }
    }
  }

  void _showEndTimePicker(BuildContext context) async {
    final end = await showTimePicker(
      context: context,
      initialTime: _composer.endTime ?? TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.input,
      helpText: '選擇結束時間',
    );
    if (end != null) {
      try {
        _composer.setEnd(end);
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertFactory.errorAlert(context, error: e),
        );
      }
    }
  }

  void _book(BuildContext context) async {
    try {
      await showLoadingOverlayOnTask(context,
          task: _schedule.bookWithRange(_composer.getDateRange()));
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertFactory.errorAlert(context, error: e),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _schedule = GymAppointmentSchedule(
      userRef: BlocProvider.of<AppBloc>(context).userRef,
      gym: widget.gym,
      appBloc: BlocProvider.of(context),
    );
    _schedule.myAppointments.listen((event) {
      print(event);
    }).onError((error) {
      print(error);
    });
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
      appBar: AppBarFactory.appBar(
        title: Text(
          widget.gym.name,
          style: TextStyles.large.header,
        ),
      ),
      body: StreamBuilder<DateTime>(
          stream: _composer.onDay,
          builder: (context, snapshot) {
            return _buildBody(context, snapshot.data);
          }),
    );
  }

  Widget _buildBody(BuildContext context, DateTime day) {
    return Column(
      children: [
        StreamBuilder<Object>(
          stream: _schedule.myAppointments,
          builder: (context, snapshot) {
            return _buildCalender(snapshot.data ?? []);
          },
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
        SizedBox(height: 8),
        _buildBookButtons(context),
        Expanded(
          child: StreamBuilder<List<AppointmentInfo>>(
            stream: _schedule.myAppointments,
            builder: (context, snapshot) {
              return _buildAppointments(context, snapshot.data ?? [], day);
            },
          ),
        )
      ],
    );
  }

  Widget _buildCalender(List<AppointmentInfo> list) {
    final tomorrow = DateTime.now().add(Duration(days: 1));
    return TableCalendar(
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
      eventLoader: (date) => list
          .where((a) => DateUtils.isSameDay(date, a.timeRange.start))
          .toList(),
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

  Widget _buildBookButtons(BuildContext context) {
    return TextButton(
      onPressed: () {
        _book(context);
      },
      child: Text('預約'),
      style: TextButton.styleFrom(
        textStyle: TextStyles.large.action,
        primary: Colors.white,
        backgroundColor: AppColors.theme,
        minimumSize: Size(120, 44),
      ),
    );
  }

  Widget _buildAppointments(
      BuildContext context, List<AppointmentInfo> appointments, DateTime day) {
    if (appointments == null || appointments.isEmpty) {
      return Center(
        child: Text(
          '沒有預約',
          style: TextStyles.large.title.copyWith(color: Colors.grey.shade300),
        ),
      );
    }
    appointments = appointments
        .where((e) =>
            day != null ? DateUtils.isSameDay(day, e.timeRange.start) : true)
        .toList();

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemBuilder: (context, idx) =>
          UserAppointmentCell(info: appointments[idx], schedule: _schedule),
      separatorBuilder: (context, idx) => SizedBox(height: 8),
      itemCount: appointments.length,
    );
  }
}
