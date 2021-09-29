import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:where_gym/gym_facility.dart';
import 'package:where_gym/price_format.dart';
import 'package:where_gym/tracking/event_names.dart';
part 'gym.g.dart';

@JsonSerializable()
class Gym {
  final String id;
  final String name;
  final String address;
  final List<Equipments> equipments;
  final List<BusinessHoursDescriptor> businessHours;
  Map<Weekday, BusinessHours> _weekdayBusinessHours;
  Map<Weekday, BusinessHours> get weekdayBusinessHours => _weekdayBusinessHours;
  final List<Fare> pricing;
  final Price hourlyRate;
  final List<String> phones;
  final String pageLink;
  final double lat;
  final double lon;
  final List<String> facilities;
  final List<String> images;
  String get cover => images != null && images.isNotEmpty ? images.first : null;
  List<GymFacility> _gymFacilities;
  List<GymFacility> get gymFacilities => _gymFacilities;
  bool get hasContactInfos => phone != null || pageLink != null;
  String get phone => phones != null && phones.isNotEmpty ? phones.first : null;
  bool supportsBooking;
  Gym(
      {this.id,
      this.name,
      this.address,
      this.lat,
      this.lon,
      this.equipments,
      this.facilities,
      this.businessHours,
      this.hourlyRate,
      this.phones,
      this.pricing,
      this.pageLink,
      this.images,
      this.supportsBooking}) {
    _weekdayBusinessHours = BusinessHours.fromDescriptors(businessHours);
    _gymFacilities = facilities != null
        ? facilities.map((e) => GymFacility.table[e]).toList()
        : [];
    supportsBooking ??= false;
  }

  bool isOpenNow() {
    return _weekdayBusinessHours != null
        ? _weekdayBusinessHours.values.firstWhere(
              (element) => element.isOpenAt(DateTime.now()),
              orElse: () => null,
            ) !=
            null
        : null;
  }

  BusinessHours businessHoursOfToday() {
    if (_weekdayBusinessHours == null) {
      return null;
    }
    final openingDay = _weekdayBusinessHours.values.firstWhere(
      (element) => element.isOpenAt(DateTime.now()),
      orElse: () => null,
    );
    if (openingDay != null) {
      return openingDay;
    }
    return _weekdayBusinessHours.values.firstWhere(
      (element) => element.opensAfter(DateTime.now()),
      orElse: () => null,
    );
  }

  Map<String, dynamic> toJson() => _$GymToJson(this);
  factory Gym.fromJson(Map<String, dynamic> json) => _$GymFromJson(json);

  Map<String, dynamic> get trackingProps => {
        EventProperties.gymId: id,
        EventProperties.price:
            hourlyRate != null ? PriceFormat.format(hourlyRate) : null,
      };
}

@JsonSerializable()
class Equipments {
  final int typeId;
  final String name;
  final int number;

  Equipments({this.typeId, this.name, this.number});
  factory Equipments.fromJson(Map<String, dynamic> json) =>
      _$EquipmentsFromJson(json);

  Map<String, dynamic> toJson() => _$EquipmentsToJson(this);
}

@JsonSerializable()
class Price {
  final int amount;
  final String currency;
  Price({this.amount, this.currency});

  Map<String, dynamic> toJson() => _$PriceToJson(this);

  factory Price.fromJson(Map<String, dynamic> json) => _$PriceFromJson(json);
}

class BusinessHours {
  final Weekday weekday;
  final TimeOfDay start;
  final TimeOfDay end;
  bool get isOff => start.isZero && end.isZero;
  bool get isCrossing => !isOff && end.isBefore(start);
  BusinessHours({
    @required this.weekday,
    @required this.start,
    @required this.end,
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
    return start.isBefore(time) && end.isAfter(time);
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

  static Map<Weekday, BusinessHours> fromDescriptors(
      List<BusinessHoursDescriptor> descriptors) {
    if (descriptors == null || descriptors.isEmpty) {
      return null;
    }
    BusinessHoursDescriptor base;
    Map<Weekday, BusinessHoursDescriptor> dayDescriptors = {};
    for (var descriptor in descriptors) {
      if (descriptor.weekday == null) {
        base = descriptor;
      } else {
        dayDescriptors[descriptor.weekday] = descriptor;
      }
    }
    if (base == null && dayDescriptors.length != 7) {
      return null;
    }
    final weekdays = [
      Weekday.mon,
      Weekday.tue,
      Weekday.wed,
      Weekday.thu,
      Weekday.fri,
      Weekday.sat,
      Weekday.sun,
    ];
    Map<Weekday, BusinessHours> retVal = {};
    for (var weekday in weekdays) {
      final descriptor = dayDescriptors[weekday] ?? base;
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
  final String dayOfWeek;
  final String start;
  final String end;
  Weekday _weekday;
  TimeOfDay _parsedStart;
  TimeOfDay _parsedEnd;
  Weekday get weekday => _weekday;
  TimeOfDay get parsedStart => _parsedStart;
  TimeOfDay get parsedEnd => _parsedEnd;
  BusinessHoursDescriptor({this.dayOfWeek, this.start, this.end}) {
    _weekday = WeekdayMethods.fromString(dayOfWeek);
    _parsedStart = TimeOfDayMethods.fromString(start);
    _parsedEnd = TimeOfDayMethods.fromString(end);
  }

  Map<String, dynamic> toJson() => _$BusinessHoursDescriptorToJson(this);
  factory BusinessHoursDescriptor.fromJson(Map<String, dynamic> json) =>
      _$BusinessHoursDescriptorFromJson(json);
}

enum Weekday { mon, tue, wed, thu, fri, sat, sun }

extension WeekdayMethods on Weekday {
  static Weekday fromString(String str) {
    if (str == null) {
      return null;
    }
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
    throw 'Unexpected error';
  }

  static Weekday fromInt(int val) {
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
}

extension DateTimeMethods on DateTime {
  static DateTime onDayWithTime(DateTime day, TimeOfDay time) {
    return DateTime(day.year, day.month, day.day, time.hour, time.minute);
  }
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
    return !isBefore(time);
  }

  bool isBeforeDate(DateTime time) {
    if (hour != time.hour) {
      return hour < time.hour;
    }
    return isBefore(TimeOfDay.fromDateTime(time));
  }

  bool isAfterDate(DateTime time) {
    return !isBeforeDate(time);
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
}

@JsonSerializable()
class Fare {
  final String unit;
  FareTimeUnit get timeUnit => FareTimeUnitMethods.fromString(unit);
  final int amount;
  final Price price;
  Fare({this.unit, this.amount, this.price});

  Map<String, dynamic> toJson() => _$FareToJson(this);
  factory Fare.fromJson(Map<String, dynamic> json) => _$FareFromJson(json);
}

enum FareTimeUnit { day, hour, min, time }

extension FareTimeUnitMethods on FareTimeUnit {
  static FareTimeUnit fromString(String str) {
    if (str == null) {
      return null;
    }
    switch (str) {
      case 'day':
        return FareTimeUnit.day;
      case 'hour':
        return FareTimeUnit.hour;
      case 'min':
        return FareTimeUnit.min;
      case 'time':
        return FareTimeUnit.time;
      default:
        return null;
    }
  }

  String get displayName {
    switch (this) {
      case FareTimeUnit.day:
        return '天';
      case FareTimeUnit.hour:
        return '小時';
      case FareTimeUnit.min:
        return '分';
      case FareTimeUnit.time:
        return '次';
      default:
        return null;
    }
  }
}
