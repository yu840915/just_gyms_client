import 'package:flutter/material.dart';
import 'package:where_gym/business_hours.dart';
import 'package:where_gym/schedule_time_slot.dart';
import 'package:where_gym/shared_appearances.dart';

class TimeSlotPicker extends StatelessWidget {
  final List<TimeSlot> timeSlots;
  final TimeOfDay? start;
  final String? header;
  TimeSlotPicker({required this.timeSlots, this.start, this.header});

  void _onSelection(BuildContext context, TimeSlot timeSlot) {
    Navigator.pop(
      context,
      start == null ? timeSlot.timeRange.start : timeSlot.timeRange.end,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Spacer(flex: 1),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                if (header != null) _buildHeader(header!),
                _buildGrid(context),
              ],
            ),
          ),
        ),
        Spacer(flex: 2),
      ],
    );
  }

  Widget _buildHeader(String header) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Text(
        header,
        style: TextStyles.large.header,
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      shrinkWrap: true,
      itemCount: timeSlots.length,
      itemBuilder: (context, index) => TimeSlotCell(
        viewModel: _TimeSlotCellViewModel(
          timeSlot: timeSlots[index],
          start: start,
          action: () {
            _onSelection(context, timeSlots[index]);
          },
        ),
      ),
    );
  }
}

class TimeSlotCell extends StatelessWidget {
  final _TimeSlotCellViewModel viewModel;
  final void Function()? onTap;
  TimeSlotCell({required this.viewModel, this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: viewModel.onTap,
      child: Text(
        viewModel.time.format(context),
      ),
      style: OutlinedButton.styleFrom(
        primary: AppColors.theme,
        side: BorderSide(color: AppColors.theme),
        textStyle: TextStyles.small.action,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _TimeSlotCellViewModel {
  final TimeSlot timeSlot;
  final TimeOfDay? start;
  final void Function() action;
  _TimeSlotCellViewModel(
      {required this.timeSlot, required this.action, this.start});
  TimeOfDay get time =>
      start == null ? timeSlot.timeRange.start : timeSlot.timeRange.end;
  bool get isSelectable =>
      start == null ? true : timeSlot.timeRange.end.isAfter(start!);
  void Function()? get onTap => isSelectable ? action : null;
}
