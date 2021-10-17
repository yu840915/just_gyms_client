import 'dart:math';

import 'package:flutter/material.dart';
import 'package:where_gym/appointment/appointment_info.dart';
import 'package:where_gym/appointment/appointment_time_composer.dart';
import 'package:where_gym/business_hours.dart';

extension DateTimeRangeMethod on DateTimeRange {
  static DateTimeRange fromDayAndTimeRange(DateTime day, TimeRange timeRange) {
    return DateTimeRange(
      start: DateTimeMethods.onDayWithTime(day, timeRange.start),
      end: DateTimeMethods.onDayWithTime(day, timeRange.end),
    );
  }

  bool overlap(DateTimeRange range) {
    return !(range.start.isAfter(end) && range.end.isBefore(start));
  }
}

class TimeSlot {
  final DateTime day;
  final TimeRange timeRange;
  DateTimeRange get range =>
      DateTimeRangeMethod.fromDayAndTimeRange(day, timeRange);

  TimeSlot({required this.day, required this.timeRange});
}

class ScheduleUtilization {
  final num? capacity;
  final TimeSlot timeSlot;
  num? get availableSeats =>
      capacity != null ? capacity! - maxConcurrentAppointments : null;
  final num maxConcurrentAppointments;
  final List<AppointmentInfo> appointments;
  ScheduleUtilization(
      {required this.capacity,
      required this.maxConcurrentAppointments,
      required this.timeSlot,
      required this.appointments});
  num? get rate {
    return capacity != null
        ? max(0, min(maxConcurrentAppointments / capacity!, 1))
        : null;
  }

  static ScheduleUtilization inferFromAppointments(
      List<AppointmentInfo> appointments, TimeSlot timeSlot, num? capacity) {
    final appointmentsOnSlot =
        appointments.where((a) => timeSlot.range.overlap(a.timeRange));
    if (appointmentsOnSlot.isEmpty) {
      return ScheduleUtilization(
          capacity: capacity,
          timeSlot: timeSlot,
          maxConcurrentAppointments: 0,
          appointments: appointmentsOnSlot.toList());
    }
    final visitorEvents = appointmentsOnSlot
        .map((e) => [
              VisitorEvent(e.timeRange.start, 1),
              VisitorEvent(e.timeRange.end, -1)
            ])
        .reduce((value, element) => value + element)
      ..sort((a, b) => a.date.compareTo(b.date));
    num max = 0;
    visitorEvents.map((e) => e.diff).reduce((value, element) {
      final sum = value + element;
      if (sum > max) {
        max = sum;
      }
      return sum;
    });
    return ScheduleUtilization(
        capacity: capacity,
        timeSlot: timeSlot,
        maxConcurrentAppointments: max,
        appointments: appointmentsOnSlot.toList());
  }

  UtilizationStatus get status {
    if (rate == null) {
      return maxConcurrentAppointments == 0
          ? UtilizationStatus.empty
          : UtilizationStatus.low;
    }
    if (rate! == 0) {
      return UtilizationStatus.empty;
    } else if (rate! <= 0.5) {
      return UtilizationStatus.low;
    } else if (rate! < 1) {
      return UtilizationStatus.heavy;
    } else {
      return UtilizationStatus.full;
    }
  }
}

class VisitorEvent {
  final DateTime date;
  final int diff;
  VisitorEvent(this.date, this.diff);
}

enum UtilizationStatus { empty, low, heavy, full }
