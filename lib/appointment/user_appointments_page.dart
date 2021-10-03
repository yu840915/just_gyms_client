import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:where_gym/app_bar_factory.dart';
import 'package:where_gym/app_bloc.dart';
import 'package:where_gym/appointment/appointment_info.dart';
import 'package:where_gym/appointment/appointment_schedule.dart';
import 'package:where_gym/appointment/user_appointment_cell.dart';
import 'package:where_gym/shared_appearances.dart';

class UserAppointmentsPage extends StatefulWidget {
  @override
  State<UserAppointmentsPage> createState() => _UserAppointmentsPageState();
}

class _UserAppointmentsPageState extends State<UserAppointmentsPage> {
  MyAppointmentSchedule _schedule;
  DateTime _date;

  @override
  void initState() {
    super.initState();
    _date = DateTime.now();
    _schedule = MyAppointmentSchedule(
      userRef: BlocProvider.of<AppBloc>(context).userRef,
      appBloc: BlocProvider.of(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarFactory.appBar(
        title: Text(
          '我的預約',
          style: TextStyles.large.header,
        ),
      ),
      body: StreamBuilder<List<AppointmentInfo>>(
          stream: _schedule.onAppointments,
          builder: (context, snapshot) {
            return _buildBody(context, snapshot.data ?? []);
          }),
    );
  }

  Widget _buildBody(BuildContext context, List<AppointmentInfo> appointments) {
    return Column(
      children: [
        _buildCalender(appointments),
        Expanded(child: _buildAppointments(context, appointments)),
      ],
    );
  }

  Widget _buildCalender(List<AppointmentInfo> list) {
    final tomorrow = DateTime.now().add(Duration(days: 1));
    return TableCalendar(
      locale: Intl.systemLocale,
      focusedDay: tomorrow,
      firstDay: DateTime.now(),
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
      onDaySelected: (date, _) {
        setState(() {
          _date = date;
        });
      },
      selectedDayPredicate: (date) => _date == date,
      eventLoader: (date) => list
          .where((a) => DateUtils.isSameDay(date, a.timeRange.start))
          .toList(),
    );
  }

  Widget _buildAppointments(
      BuildContext context, List<AppointmentInfo> appointments) {
    if (appointments == null || appointments.isEmpty) {
      return Center(
        child: Text(
          '沒有預約',
          style: TextStyles.large.title.copyWith(color: Colors.grey.shade300),
        ),
      );
    }
    appointments = appointments
        .where((e) => DateUtils.isSameDay(_date, e.timeRange.start))
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
