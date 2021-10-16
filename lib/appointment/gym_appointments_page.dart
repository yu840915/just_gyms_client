import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:where_gym/app_bar_factory.dart';
import 'package:where_gym/appointment/appointment_info.dart';
import 'package:where_gym/appointment/gym_appointment_cell.dart';
import 'package:where_gym/appointment/gym_appointment_schedule.dart';
import 'package:where_gym/gym.dart';
import 'package:where_gym/shared_appearances.dart';

class GymAppointmentsPage extends StatefulWidget {
  final Gym? gym;
  GymAppointmentsPage({required this.gym});

  @override
  State<GymAppointmentsPage> createState() => _GymAppointmentsPageState();
}

class _GymAppointmentsPageState extends State<GymAppointmentsPage> {
  GymAppointmentSchedule? _schedule;
  DateTime? _date;

  @override
  void initState() {
    super.initState();
    _date = DateTime.now();
    _schedule = GymAppointmentSchedule(
        appBloc: BlocProvider.of(context), gym: widget.gym!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarFactory.appBar(
        title: Text(
          '${widget.gym!.name}的預約',
          style: TextStyles.large.header,
        ),
      ) as PreferredSizeWidget?,
      body: StreamBuilder<List<AppointmentInfo>>(
          stream: _schedule!.onAppointments,
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
      lastDay: tomorrow.add(Duration(days: 30)),
      calendarFormat: CalendarFormat.month,
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
          style: TextStyles.large.title!.copyWith(color: Colors.grey.shade300),
        ),
      );
    }
    appointments = appointments
        .where((e) => DateUtils.isSameDay(_date, e.timeRange.start))
        .toList();

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemBuilder: (context, idx) =>
          GymAppointmentCell(info: appointments[idx], schedule: _schedule),
      separatorBuilder: (context, idx) => SizedBox(height: 8),
      itemCount: appointments.length,
    );
  }
}
