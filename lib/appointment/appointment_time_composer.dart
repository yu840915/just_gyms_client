import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:where_gym/api_services/api_services.dart';
import 'package:where_gym/gym.dart';

class AppointmentTimeComposer {
  final _timeRangeSubject = BehaviorSubject<TimeRange>();
  final _daySubject = BehaviorSubject<DateTime>();
  Stream<DateTime> get onDay => _daySubject.stream;
  Stream<TimeRange> get onTimeRange => _timeRangeSubject;
  TimeOfDay get startTime => _timeRangeSubject.valueWrapper?.value?.start;
  TimeOfDay get endTime => _timeRangeSubject.valueWrapper?.value?.end;
  final Map<Weekday, BusinessHours> businessHours;
  List<Weekday> get openDays => [
        Weekday.sun,
        Weekday.mon,
        Weekday.tue,
        Weekday.wed,
        Weekday.thu,
        Weekday.fri,
        Weekday.sat,
      ].where((day) => !businessHours[day].isOff).toList();

  BusinessHours get businessHoursOnSelectedDay =>
      _daySubject.valueWrapper != null
          ? businessHours[
              WeekdayMethods.fromInt(_daySubject.valueWrapper.value.weekday)]
          : null;

  AppointmentTimeComposer({@required this.businessHours}) {
    DateTime date = DateTime.now().add(Duration(days: 1));
    if (openDays.length > 0) {
      while (businessHours[date.dayOfWeek].isOff) {
        date = date.add(Duration(days: 1));
      }
    }
    setDay(date);
    setStart(businessHours[date.dayOfWeek].start);
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
    if (_daySubject.valueWrapper == null) {
      throw LocalError('請先選擇日期');
    }
    if (!businessHoursOnSelectedDay.isOpenAtTime(start)) {
      throw LocalError('開始時間必須在營業時間內');
    }
    TimeOfDay end = _timeRangeSubject.valueWrapper?.value?.end;
    if (end == null || start.isAfter(end)) {
      end = TimeOfDay(hour: start.hour + 1, minute: start.minute);
      if (businessHoursOnSelectedDay.end.isBefore(end)) {
        end = businessHoursOnSelectedDay.end;
      }
    }
    _updateRange(start, end);
  }

  void setEnd(TimeOfDay end) {
    final range = _timeRangeSubject.valueWrapper?.value;
    if (range == null || range.start == null) {
      throw LocalError('請先選擇開始時間');
    } else if (end.isBefore(range.start)) {
      throw LocalError('結束時間必須在開始時間以後');
    } else if (!businessHoursOnSelectedDay.isOpenAtTime(end)) {
      throw LocalError('結束時間必須在營業時間內');
    }
    _updateRange(range.start, end);
  }

  void _updateRange(TimeOfDay start, TimeOfDay end) {
    if (start == null) {
      return _timeRangeSubject.add(null);
    }
    _timeRangeSubject.add(TimeRange(start: start, end: end));
  }

  bool isDaySelected(DateTime date) {
    final selection = _daySubject.valueWrapper?.value;
    if (selection == null) {
      return false;
    }
    return selection.day == date.day &&
        selection.month == date.month &&
        selection.year == date.year;
  }

  DateTimeRange getDateRange() {
    final day = _daySubject.valueWrapper?.value;
    final range = _timeRangeSubject.valueWrapper?.value;
    if (_daySubject.valueWrapper == null) {
      throw LocalError('請先選擇日期');
    } else if (range == null || range.start == null) {
      throw LocalError('請先選擇開始時間');
    } else if (range.start == null) {
      throw LocalError('請先選擇結束時間');
    }
    return DateTimeRange(
      start: DateTimeMethods.onDayWithTime(day, range.start),
      end: DateTimeMethods.onDayWithTime(day, range.end),
    );
  }
}

class TimeRange {
  final TimeOfDay start;
  final TimeOfDay end;
  TimeRange({@required this.start, @required this.end})
      : assert(start != null),
        assert(end == null || !start.isAfter(end));
}
