import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
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
  bool get hasContactInfos => phone != null || pageLink != null;
  String get phone => phones != null && phones.isNotEmpty ? phones.first : null;
  Gym(
      {this.id,
      this.name,
      this.address,
      this.lat,
      this.lon,
      this.equipments,
      this.businessHours,
      this.hourlyRate,
      this.phones,
      this.pricing,
      this.pageLink}) {
    _weekdayBusinessHours = BusinessHours.fromDescriptors(businessHours);
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
  final HourMin start;
  final HourMin end;
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
  HourMin _parsedStart;
  HourMin _parsedEnd;
  Weekday get weekday => _weekday;
  HourMin get parsedStart => _parsedStart;
  HourMin get parsedEnd => _parsedEnd;
  BusinessHoursDescriptor({this.dayOfWeek, this.start, this.end}) {
    _weekday = WeekdayMethods.fromString(dayOfWeek);
    _parsedStart = HourMin.fromString(start);
    _parsedEnd = HourMin.fromString(end);
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
        return 1;
      case Weekday.tue:
        return 2;
      case Weekday.wed:
        return 3;
      case Weekday.thu:
        return 4;
      case Weekday.fri:
        return 5;
      case Weekday.sat:
        return 6;
      case Weekday.sun:
        return 7;
    }
    throw 'Unexpected error';
  }
}

class HourMin {
  final int hour;
  final int min;
  final String stringValue;
  HourMin({this.stringValue, this.hour, this.min});
  static HourMin fromString(String str) {
    final components = str.split(':');
    if (components.length != 2) {
      throw 'Invalid format';
    }
    return HourMin(
      stringValue: str,
      hour: int.parse(components.first),
      min: int.parse(components.last),
    );
  }

  bool get isZero => hour == 0 && min == 0;

  bool isBefore(HourMin time) {
    if (hour != time.hour) {
      return hour < time.hour;
    }
    return min < time.min;
  }

  bool isAfter(HourMin time) {
    return !isBefore(time);
  }

  bool isBeforeDate(DateTime time) {
    if (hour != time.hour) {
      return hour < time.hour;
    }
    return min < time.minute;
  }

  bool isAfterDate(DateTime time) {
    return !isBeforeDate(time);
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
