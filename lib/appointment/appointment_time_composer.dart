import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'package:where_gym/api_services/api_services.dart';
import 'package:where_gym/gym.dart';

class AppointmentTimeComposer {
  final _timeRangeSubject = BehaviorSubject<DateTimeRange>();
  final _daySubject = BehaviorSubject<DateTime>();
  Stream<DateTime> get onDay => _daySubject;
  Stream<DateTimeRange> get onTimeRange => _timeRangeSubject;
  final List<BusinessHours> businessHours;

  AppointmentTimeComposer({@required this.businessHours}) {
    setDay(DateTime.now().add(Duration(days: 1)));
  }

  void dispose() {
    _daySubject.close();
    _timeRangeSubject.close();
  }

  void setDay(DateTime date) {
    final startOfDate = DateTime(date.year, date.month, date.day, 0, 0, 0);
    _daySubject.add(startOfDate);
    final range = _timeRangeSubject.valueWrapper.value;
    _updateRange(range?.start, range?.end);
  }

  void setStart(DateTime start) {
    final mappedStart = _mapTime(start);
    if (!businessHours[mappedStart.weekday].isOpenAt(mappedStart)) {
      throw LocalError('開始時間必須在營業時間內');
    }
    final range = _timeRangeSubject.valueWrapper.value;
    DateTime end = range.end;
    if (end != null && mappedStart.millisecond > end.microsecond) {
      end = null;
    }
    _updateRange(mappedStart, end);
  }

  DateTime _mapTime(DateTime time) {
    final date = _daySubject.valueWrapper.value;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute, 0);
  }

  void setEnd(DateTime end) {
    final mappedEnd = _mapTime(end);
    final range = _timeRangeSubject.valueWrapper.value;
    if (range == null || range.start == null) {
      throw LocalError('請先選擇開始時間');
    } else if (mappedEnd.microsecond <= range.start.microsecond) {
      throw LocalError('結束時間必須在開始時間以後');
    } else if (!businessHours[mappedEnd.weekday].isOpenAt(mappedEnd)) {
      throw LocalError('結束時間必須在營業時間內');
    }
    _updateRange(range.start, mappedEnd);
  }

  void _updateRange(DateTime start, DateTime end) {
    if (start == null) {
      return _timeRangeSubject.add(null);
    }
    final range = DateTimeRange(
      start: _mapTime(start),
      end: end != null ? _mapTime(end) : null,
    );
    _timeRangeSubject.add(range);
  }
}
