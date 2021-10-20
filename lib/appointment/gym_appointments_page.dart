import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:where_gym/app_bar_factory.dart';
import 'package:where_gym/appointment/appointment_info.dart';
import 'package:where_gym/appointment/gym_appointment_schedule.dart';
import 'package:where_gym/gym.dart';
import 'package:where_gym/schedule_time_slot.dart';
import 'package:where_gym/shared_appearances.dart';

class GymAppointmentsPage extends StatefulWidget {
  final Gym gym;
  GymAppointmentsPage({required this.gym});

  @override
  State<GymAppointmentsPage> createState() => _GymAppointmentsPageState();
}

class _GymAppointmentsPageState extends State<GymAppointmentsPage> {
  GymAppointmentSchedule? _schedule;
  DateTime? _date;
  _ListViewModel? _viewModel;
  StreamSubscription? subscription;

  @override
  void initState() {
    super.initState();
    _date = DateTime.now();
    final schedule = GymAppointmentSchedule(
        appBloc: BlocProvider.of(context), gym: widget.gym);
    subscription = schedule.onAppointments.listen((event) {
      _updateViewModel(event);
    });
    _schedule = schedule;
  }

  void _updateViewModel(List<AppointmentInfo> appointments) {
    setState(() {
      _viewModel = _ListViewModel(
          day: _date!, gym: widget.gym, appointments: appointments);
    });
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarFactory.appBar(
        title: Text(
          '${widget.gym.name}的預約',
          style: TextStyles.large.header,
        ),
      ) as PreferredSizeWidget?,
      body: Column(
        children: [
          StreamBuilder<List<AppointmentInfo>>(
            stream: _schedule!.onAppointments,
            builder: (context, snapshot) {
              return _buildCalender(snapshot.data);
            },
          ),
          Expanded(child: _buildCells(context))
        ],
      ),
    );
  }

  Widget _buildCalender(List<AppointmentInfo>? list) {
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
      eventLoader: (date) =>
          list
              ?.where((a) => DateUtils.isSameDay(date, a.timeRange.start))
              .toList() ??
          [],
    );
  }

  Widget _buildCells(BuildContext context) {
    List<_CellViewModel>? cellModels = _viewModel?.cellModels;
    if (cellModels == null) {
      return SizedBox.shrink();
    }
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemBuilder: (context, idx) =>
          ScheduleUtilizationCell(viewModel: cellModels[idx]),
      separatorBuilder: (context, idx) => SizedBox(height: 1),
      itemCount: cellModels.length,
    );
  }
}

class ScheduleUtilizationCell extends StatelessWidget {
  final _CellViewModel viewModel;
  ScheduleUtilizationCell({required this.viewModel});

  void _showAppointmentDialog(BuildContext context) {}

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showAppointmentDialog(context),
      child: Row(
        children: [
          TimeSlotCell(viewModel.timeSlot),
          Container(
            color: viewModel.indicatorColor,
            height: 40,
            child: Row(
              children: [
                Spacer(),
                _buildCountLabel(),
                SizedBox(width: 12),
                Container(
                  width: 30,
                  child: viewModel.hasDetail
                      ? Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 20,
                        )
                      : null,
                ),
                SizedBox(width: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountLabel() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Colors.grey.shade50,
      ),
      child: Text(
        viewModel.countText,
        style: TextStyles.large.detail.copyWith(color: Colors.grey.shade700),
      ),
    );
  }
}

class TimeSlotCell extends StatelessWidget {
  final TimeSlot timeSlot;
  TimeSlotCell(this.timeSlot);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text(
            Formats.time.format(timeSlot.range.start),
            style: TextStyles.small.title,
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ListViewModel {
  final List<AppointmentInfo> appointments;
  final Gym gym;
  final DateTime day;
  List<_CellViewModel>? get cellModels =>
      _utilizations?.map((e) => _CellViewModel(utilization: e)).toList();
  List<ScheduleUtilization>? _utilizations;
  _ListViewModel(
      {required this.day,
      required this.gym,
      required List<AppointmentInfo> appointments})
      : this.appointments = appointments
            .where((a) => DateUtils.isSameDay(day, a.timeRange.start))
            .toList() {
    _utilizations = gym
        .generateTimeSlotOnDay(day)
        ?.map((e) => ScheduleUtilization.inferFromAppointments(
            this.appointments, e, gym.capacity))
        .toList();
  }
}

class _CellViewModel {
  final ScheduleUtilization utilization;
  _CellViewModel({required this.utilization});
  bool get hasDetail => utilization.appointments.isNotEmpty;
  TimeSlot get timeSlot => utilization.timeSlot;
  Color get indicatorColor {
    switch (utilization.status) {
      case UtilizationStatus.empty:
        return Colors.white;
      case UtilizationStatus.low:
        return Colors.greenAccent.shade100;
      case UtilizationStatus.heavy:
        return Colors.orangeAccent.shade100;
      case UtilizationStatus.full:
        return Colors.redAccent.shade100;
    }
  }

  String get countText {
    final count = Formats.integer.format(utilization.appointments.length);
    if (availableText != null) {
      return '$count/$availableText';
    }
    return count;
  }

  String? get availableText => utilization.availableSeats != null
      ? Formats.integer.format(utilization.availableSeats)
      : null;
}
