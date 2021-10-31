import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:where_gym/api_services/api_services.dart';
import 'package:where_gym/business_hours.dart';
import 'package:where_gym/gym.dart';
import 'package:where_gym/schedule_time_slot.dart';

class AppointmentTimeComposer {
  final _timeRangeSubject = BehaviorSubject<TimeRange?>();
  final _daySubject = BehaviorSubject<DateTime>();
  Stream<DateTime> get onDay => _daySubject.stream;
  Stream<TimeRange?> get onTimeRange => _timeRangeSubject;
  TimeOfDay? get startTime => _timeRangeSubject.valueOrNull?.start;
  TimeOfDay? get endTime => _timeRangeSubject.valueOrNull?.end;
  final Map<Weekday, BusinessHours> businessHours;
  List<Weekday> get openDays => [
        Weekday.sun,
        Weekday.mon,
        Weekday.tue,
        Weekday.wed,
        Weekday.thu,
        Weekday.fri,
        Weekday.sat,
      ].where((day) => !businessHours[day]!.isOff).toList();

  BusinessHours? get businessHoursOnSelectedDay => _daySubject.valueOrNull !=
          null
      ? businessHours[WeekdayMethods.fromInt(_daySubject.valueOrNull?.weekday)!]
      : null;

  AppointmentTimeComposer({required this.businessHours}) {
    DateTime date = DateTime.now().add(Duration(days: 1));
    if (openDays.length > 0) {
      while (businessHours[date.dayOfWeek!]!.isOff) {
        date = date.add(Duration(days: 1));
      }
    }
    setDay(date);
    setStart(businessHours[date.dayOfWeek!]!.start);
  }

  void dispose() {
    _daySubject.close();
    _timeRangeSubject.close();
  }

  void setDay(DateTime date) {
    final startOfDate = DateTime(date.year, date.month, date.day, 0, 0, 0);
    _daySubject.add(startOfDate);
  }

  void setStart(TimeOfDay start) {
    if (_daySubject.valueOrNull == null) {
      throw LocalError('請先選擇日期');
    }
    if (!businessHoursOnSelectedDay!.isOpenAtTime(start)) {
      throw LocalError('開始時間必須在營業時間內');
    }
    TimeOfDay? end = _timeRangeSubject.valueOrNull?.end;
    if (end == null || !start.isBefore(end)) {
      end = TimeOfDay(hour: start.hour + 1, minute: start.minute);
      if (businessHoursOnSelectedDay!.end.isBefore(end)) {
        end = businessHoursOnSelectedDay!.end;
      }
    }
    _updateRange(start, end);
  }

  void setEnd(TimeOfDay end) {
    final range = _timeRangeSubject.valueOrNull;
    if (range == null) {
      throw LocalError('請先選擇開始時間');
    } else if (end.isBefore(range.start)) {
      throw LocalError('結束時間必須在開始時間以後');
    } else if (!businessHoursOnSelectedDay!.isOpenAtTime(end)) {
      throw LocalError('結束時間必須在營業時間內');
    }
    _updateRange(range.start, end);
  }

  void _updateRange(TimeOfDay start, TimeOfDay end) {
    _timeRangeSubject.add(TimeRange(start: start, end: end));
  }

  bool isDaySelected(DateTime date) {
    final selection = _daySubject.valueOrNull;
    if (selection == null) {
      return false;
    }
    return selection.day == date.day &&
        selection.month == date.month &&
        selection.year == date.year;
  }

  DateTimeRange getDateRange() {
    final range = _timeRangeSubject.valueOrNull;
    if (_daySubject.valueOrNull == null) {
      throw LocalError('請先選擇日期');
    } else if (range == null) {
      throw LocalError('請先選擇開始時間');
    }
    return DateTimeRange(
      start: DateTimeMethods.onDayWithTime(_daySubject.value, range.start),
      end: DateTimeMethods.onDayWithTime(_daySubject.value, range.end),
    );
  }

  List<TimeSlot>? generateTimeSlotsOnSelectedDay({required Gym gym}) {
    return gym.generateTimeSlotOnDay(_daySubject.value);
  }
}

class TimeRange {
  final TimeOfDay start;
  final TimeOfDay end;
  TimeRange({required this.start, required this.end})
      : assert(!start.isAfter(end));
}
