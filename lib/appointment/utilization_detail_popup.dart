import 'package:flutter/material.dart';
import 'package:where_gym/appointment/appointment_info.dart';
import 'package:where_gym/appointment/appointment_view_models.dart';
import 'package:where_gym/appointment/gym_appointment_schedule.dart';
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
    return Row(
      children: [
        Spacer(flex: 1),
        Expanded(
          flex: 5,
          child: Column(
            children: [
              Spacer(flex: 1),
              Expanded(
                flex: 8,
                child: _buildContent(context),
              ),
              Spacer(flex: 1),
            ],
          ),
        ),
        Spacer(flex: 1),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildList(context)),
          ],
        ),
        color: Colors.white,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(8),
      width: double.infinity,
      color: _viewModel.indicatorColor,
      child: Column(
        children: [
          Text(_viewModel.dayWeekday, style: TextStyles.small.title),
          SizedBox(height: 4),
          Text(
            _viewModel.start + "-" + _viewModel.end,
            style: TextStyles.small.detail,
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Text(
                _viewModel.count,
                style:
                    TextStyles.small.subscription.copyWith(color: Colors.black),
              ),
              if (_viewModel.totalCapacity != null) ...[
                SizedBox(width: 8),
                Text(
                  _viewModel.totalCapacity!,
                  style: TextStyles.small.subscription
                      .copyWith(color: Colors.black),
                )
              ],
              if (_viewModel.availableSeats != null) ...[
                SizedBox(width: 8),
                Text(
                  _viewModel.availableSeats!,
                  style: TextStyles.small.subscription
                      .copyWith(color: Colors.black),
                )
              ],
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          )
        ],
      ),
    );
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
  Color get indicatorColor => utilizationViewModel.indicatorColor;
  String get start => utilizationViewModel.timeSlotViewModel.start;
  String get end => utilizationViewModel.timeSlotViewModel.end;
  String get dayWeekday => utilizationViewModel.timeSlotViewModel.dayWeekday;
  String get count => '預約數：' + utilizationViewModel.count;
  String? get totalCapacity => utilizationViewModel.totalCapacity != null
      ? '容量限制：' + utilizationViewModel.totalCapacity!
      : null;
  String? get availableSeats => utilizationViewModel.availableSeats != null
      ? '剩餘：' + utilizationViewModel.availableSeats!
      : null;
  _ViewModel({required this.utilization})
      : utilizationViewModel = UtilizationViewModel(utilization: utilization);
}
