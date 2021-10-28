import 'package:flutter/material.dart';
import 'package:where_gym/alert_factory.dart';
import 'package:where_gym/appointment/appointment_info.dart';
import 'package:where_gym/appointment/appointment_view_models.dart';
import 'package:where_gym/appointment/gym_appointment_schedule.dart';
import 'package:where_gym/schedule_time_slot.dart';
import 'package:where_gym/shared_appearances.dart';
import 'package:where_gym/utils/empty_view.dart';

class UtilizationDetailPopup extends StatelessWidget {
  final GymAppointmentSchedule schedule;
  final AppointmentCursor cursor;

  UtilizationDetailPopup({required this.cursor, required this.schedule});

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
                child: StreamBuilder<ScheduleUtilization>(
                    stream: cursor.onUtilization,
                    builder: (context, snapshot) {
                      return _buildContent(context, snapshot.data);
                    }),
              ),
              Spacer(flex: 1),
            ],
          ),
        ),
        Spacer(flex: 1),
      ],
    );
  }

  Widget _buildContent(BuildContext context, ScheduleUtilization? utilization) {
    if (utilization == null) {
      return Container();
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        child: Column(
          children: [
            _buildHeader(_ViewModel(utilization: utilization)),
            Container(height: 1, color: Colors.grey.shade100),
            Expanded(child: _buildList(context, utilization.appointments)),
          ],
        ),
        color: Colors.white,
      ),
    );
  }

  Widget _buildHeader(_ViewModel _viewModel) {
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

  Widget _buildList(BuildContext context, List<AppointmentInfo> appointments) {
    if (appointments.isEmpty) {
      return EmptyView(message: '此時段沒有預約');
    }
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemBuilder: (context, idx) =>
          _Cell(info: appointments[idx], schedule: schedule),
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

class _Cell extends StatelessWidget {
  final AppointmentInfo info;
  final GymAppointmentSchedule? schedule;
  _Cell({required this.info, required this.schedule});

  void _cancel(BuildContext context) async {
    try {
      await schedule!.cancel(info);
    } catch (e) {
      showDialog(
          context: context,
          builder: (context) => AlertFactory.errorAlert(context, error: e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      child: Column(
        children: [
          _buildGymInfo(),
          _buildTimeRange(),
          Row(
            children: [
              Spacer(),
              _buildCancelButton(context),
            ],
          ),
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildGymInfo() {
    return Text(
      info.userName!,
      style: TextStyles.small.title,
    );
  }

  Widget _buildTimeRange() {
    return Text(
      '${Formats.time.format(info.timeRange.start)} - ${Formats.time.format(info.timeRange.end)}',
      style: TextStyles.small.title,
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        _cancel(context);
      },
      child: Text('取消此預約'),
      style: TextButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: TextStyles.small.action,
        primary: Colors.grey.shade400,
      ),
    );
  }
}
