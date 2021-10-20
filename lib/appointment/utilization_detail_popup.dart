import 'package:flutter/material.dart';
import 'package:where_gym/appointment/appointment_info.dart';
import 'package:where_gym/appointment/appointment_view_models.dart';
import 'package:where_gym/appointment/gym_appointment_schedule.dart';
import 'package:where_gym/appointment/gym_appointments_page.dart';
import 'package:where_gym/appointment/user_appointment_cell.dart';
import 'package:where_gym/schedule_time_slot.dart';
import 'package:where_gym/shared_appearances.dart';

class UtilizationDetailPopup extends StatelessWidget {
  final GymAppointmentSchedule schedule;
  final ScheduleUtilization utilization;
  final _ViewModel _viewModel;
  List<AppointmentInfo> get appointments => utilization.appointments;
  UtilizationDetailPopup({required this.utilization, required this.schedule})
      : _viewModel = _ViewModel(utilization: utilization);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      width: 300,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildList(context)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container();
  }

  Widget _buildList(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemBuilder: (context, idx) =>
          UserAppointmentCell(info: appointments[idx], schedule: schedule),
      separatorBuilder: (context, idx) => SizedBox(height: 8),
      itemCount: appointments.length,
    );
  }
}

class _ViewModel {
  final ScheduleUtilization utilization;
  final UtilizationViewModel utilizationViewModel;
  _ViewModel({required this.utilization})
      : utilizationViewModel = UtilizationViewModel(utilization: utilization);
}
