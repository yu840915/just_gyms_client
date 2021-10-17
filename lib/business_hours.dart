import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:where_gym/appointment/appointment_time_composer.dart';
import 'package:where_gym/schedule_time_slot.dart';
part 'business_hours.g.dart';

class BusinessHours {
  final Weekday weekday;
  final TimeOfDay start;
  final TimeOfDay end;
  bool get isOff => start.isZero && end.isZero;
  bool get isCrossing => !isOff && end.isBefore(start);
  BusinessHours({
    required this.weekday,
    required this.start,
    required this.end,
  });

  bool isOpenAt(DateTime dateTime) {
    if (isOff) {
      return false;
    }
    if (weekday.intValue == dateTime.weekday) {
      return start.isBeforeDate(dateTime) &&
          (isCrossing || end.isAfterDate(dateTime));
    }
    if (isCrossing && weekday.intValue + 1 == dateTime.weekday) {
      return end.isAfterDate(dateTime);
    }
    return false;
  }

  bool isOpenAtTime(TimeOfDay time) {
    return !start.isAfter(time) && !end.isBefore(time);
  }

  bool opensAfter(DateTime dateTime) {
    if (dateTime.weekday == 7 && weekday.intValue == 1) {
      return true;
    }
    if (weekday.intValue < dateTime.weekday) {
      return false;
    }
    if (weekday.intValue > dateTime.weekday) {
      return true;
    }
    return start.isAfterDate(dateTime);
  }

  List<TimeSlot> generateTimeSlots(DateTime day) {
    assert(WeekdayMethods.fromInt(day.weekday) == weekday);
    if (isOff) {
      return [];
    }
    List<TimeSlot> slots = [];
    TimeOfDay slotStart = start;
    TimeOfDay slotEnd = slotStart.adding(minutes: 30);
    while (slotEnd.isBefore(end)) {
      slots.add(TimeSlot(
          day: day, timeRange: TimeRange(start: slotStart, end: slotEnd)));
      slotStart = slotEnd;
      slotEnd = slotStart.adding(minutes: 30);
    }
    slotEnd = slotEnd.isAfter(end) ? slotEnd : end;
    slots.add(TimeSlot(
        day: day, timeRange: TimeRange(start: slotStart, end: slotEnd)));
    return slots;
  }

  static Map<Weekday, BusinessHours> fromDescriptors(
      List<BusinessHoursDescriptor> descriptors) {
    BusinessHoursDescriptor? base;
    Map<Weekday?, BusinessHoursDescriptor> dayDescriptors = {};
    for (var descriptor in descriptors) {
      if (descriptor.weekday != null) {
        dayDescriptors[descriptor.weekday!] = descriptor;
      } else {
        base = descriptor;
      }
    }
    final weekdays = [
      Weekday.sun,
      Weekday.mon,
      Weekday.tue,
      Weekday.wed,
      Weekday.thu,
      Weekday.fri,
      Weekday.sat,
    ];
    Map<Weekday, BusinessHours> retVal = {};
    for (var weekday in weekdays) {
      final descriptor = dayDescriptors[weekday] ?? base!;
      retVal[weekday] = BusinessHours(
        weekday: weekday,
        start: descriptor.parsedStart,
        end: descriptor.parsedEnd,
      );
    }
    return retVal;
  }
}

@JsonSerializable()
class BusinessHoursDescriptor {
  final String? dayOfWeek;
  final String start;
  final String end;
  Weekday? _weekday;
  TimeOfDay _parsedStart;
  TimeOfDay _parsedEnd;
  Weekday? get weekday => _weekday;
  TimeOfDay get parsedStart => _parsedStart;
  TimeOfDay get parsedEnd => _parsedEnd;
  BusinessHoursDescriptor(
      {required this.dayOfWeek, required this.start, required this.end})
      : _weekday =
            dayOfWeek != null ? WeekdayMethods.fromString(dayOfWeek) : null,
        _parsedStart = TimeOfDayMethods.fromString(start),
        _parsedEnd = TimeOfDayMethods.fromString(end);

  Map<String, dynamic>? toJson() => _$BusinessHoursDescriptorToJson(this);
  factory BusinessHoursDescriptor.fromJson(Map<String, dynamic> json) =>
      _$BusinessHoursDescriptorFromJson(json);
}

enum Weekday { mon, tue, wed, thu, fri, sat, sun }

extension WeekdayMethods on Weekday {
  static Weekday fromString(String str) {
    switch (str.toLowerCase()) {
      case 'mon':
        return Weekday.mon;
      case 'tue':
        return Weekday.tue;
      case 'wed':
        return Weekday.wed;
      case 'thu':
        return Weekday.thu;
      case 'fri':
        return Weekday.fri;
      case 'sat':
        return Weekday.sat;
      case 'sun':
        return Weekday.sun;
      default:
        throw 'Invalid string value $str';
    }
  }

  int get intValue {
    switch (this) {
      case Weekday.mon:
        return DateTime.monday;
      case Weekday.tue:
        return DateTime.tuesday;
      case Weekday.wed:
        return DateTime.wednesday;
      case Weekday.thu:
        return DateTime.thursday;
      case Weekday.fri:
        return DateTime.friday;
      case Weekday.sat:
        return DateTime.saturday;
      case Weekday.sun:
        return DateTime.sunday;
    }
  }

  static Weekday? fromInt(int? val) {
    if (val == null) {
      return null;
    }
    switch (val) {
      case DateTime.monday:
        return Weekday.mon;
      case DateTime.tuesday:
        return Weekday.tue;
      case DateTime.wednesday:
        return Weekday.wed;
      case DateTime.thursday:
        return Weekday.thu;
      case DateTime.friday:
        return Weekday.fri;
      case DateTime.saturday:
        return Weekday.sat;
      case DateTime.sunday:
        return Weekday.sun;
      default:
        throw 'Invalid value $val';
    }
  }

  Weekday? get next => fromInt(this == Weekday.sun ? 1 : intValue + 1);
}

extension DateTimeMethods on DateTime {
  static DateTime onDayWithTime(DateTime day, TimeOfDay time) {
    return DateTime(day.year, day.month, day.day, time.hour, time.minute);
  }

  Weekday? get dayOfWeek => WeekdayMethods.fromInt(weekday);
}

extension TimeOfDayMethods on TimeOfDay {
  static TimeOfDay fromString(String str) {
    final components = str.split(':');
    if (components.length != 2) {
      throw 'Invalid format';
    }
    return TimeOfDay(
      hour: int.parse(components.first),
      minute: int.parse(components.last),
    );
  }

  bool get isZero => hour == 0 && minute == 0;

  bool isBefore(TimeOfDay time) {
    if (hour != time.hour) {
      return hour < time.hour;
    }
    return minute < time.minute;
  }

  bool isAfter(TimeOfDay time) {
    return !isBefore(time) && !isSame(time);
  }

  bool isSame(TimeOfDay time) {
    return hour == time.hour && minute == time.minute;
  }

  bool isBeforeDate(DateTime time) {
    if (hour != time.hour) {
      return hour < time.hour;
    }
    return isBefore(TimeOfDay.fromDateTime(time));
  }

  bool isAfterDate(DateTime time) {
    if (hour != time.hour) {
      return hour < time.hour;
    }
    return !isAfter(TimeOfDay.fromDateTime(time));
  }

  String get stringValue {
    String _addLeadingZeroIfNeeded(int value) {
      if (value < 10) return '0$value';
      return value.toString();
    }

    final String hourLabel = _addLeadingZeroIfNeeded(hour);
    final String minuteLabel = _addLeadingZeroIfNeeded(minute);
    return "$hourLabel:$minuteLabel";
  }

  TimeOfDay adding({int hours = 0, int minutes = 0}) {
    final sumMin = hour * 60 + minute + hours * 60 + minutes;
    return TimeOfDay(hour: (sumMin ~/ 60) % 24, minute: sumMin % 60);
  }
}
