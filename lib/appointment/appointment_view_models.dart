import 'package:flutter/material.dart';
import 'package:where_gym/schedule_time_slot.dart';
import 'package:where_gym/shared_appearances.dart';

class TimeSlotViewModel {
  final TimeSlot timeSlot;
  TimeSlotViewModel({required this.timeSlot});
  String get start => Formats.time.format(timeSlot.range.start);
  String get end => Formats.time.format(timeSlot.range.start);
}

class UtilizationViewModel {
  final ScheduleUtilization utilization;
  final TimeSlotViewModel timeSlotViewModel;
  UtilizationViewModel({required this.utilization})
      : timeSlotViewModel = TimeSlotViewModel(timeSlot: utilization.timeSlot);

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

  String get count => Formats.integer.format(utilization.appointments.length);

  String get capacityInfo {
    if (totalCapacity != null) {
      return '$count/$totalCapacity';
    }
    return count;
  }

  String? get availableSeats => utilization.availableSeats != null
      ? Formats.integer.format(utilization.availableSeats)
      : null;

  String? get totalCapacity => utilization.capacity != null
      ? Formats.integer.format(utilization.capacity)
      : null;
}
