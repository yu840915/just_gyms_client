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
        Row(
          children: [
            Spacer(),
            Expanded(
              flex: 8,
              child: Material(
                color: Colors.transparent,
                child: _buildContent(context),
              ),
            ),
            Spacer(),
          ],
        ),
        Spacer(flex: 2),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            if (header != null) _buildHeader(header!),
            _buildGrid(context),
          ],
          crossAxisAlignment: CrossAxisAlignment.center,
        ),
      ),
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
    return GridView.count(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      shrinkWrap: true,
      childAspectRatio: 2.5,
      crossAxisCount: 3,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: timeSlots
          .map(
            (e) => TimeSlotCell(
              viewModel: _TimeSlotCellViewModel(
                timeSlot: e,
                start: start,
                action: () => _onSelection(context, e),
              ),
            ),
          )
          .toList(),
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
      child: Text(viewModel.formattedTime),
      style: OutlinedButton.styleFrom(
        primary: AppColors.theme,
        side: BorderSide(
            color:
                viewModel.isSelectable ? AppColors.theme : Colors.transparent),
        textStyle: TextStyles.small.action,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        fixedSize: Size.fromHeight(40),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
  String get formattedTime => time.stringValue;
  bool get isSelectable =>
      start == null ? true : timeSlot.timeRange.end.isAfter(start!);
  void Function()? get onTap => isSelectable ? action : null;
}
