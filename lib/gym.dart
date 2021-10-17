import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:json_annotation/json_annotation.dart';
import 'package:where_gym/business_hours.dart';
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
  final List<BusinessHoursDescriptor>? businessHours;
  Map<Weekday, BusinessHours>? _weekdayBusinessHours;
  Map<Weekday, BusinessHours>? get weekdayBusinessHours =>
      _weekdayBusinessHours;
  final List<Fare> pricing;
  final Price? hourlyRate;
  final List<String>? phones;
  final String? pageLink;
  final double lat;
  final double lon;
  final List<String>? facilities;
  final List<String>? images;
  String? get cover =>
      images != null && images!.isNotEmpty ? images!.first : null;
  List<GymFacility?>? _gymFacilities;
  List<GymFacility?>? get gymFacilities => _gymFacilities;
  bool get hasContactInfos => phone != null || pageLink != null;
  String? get phone =>
      phones != null && phones!.isNotEmpty ? phones!.first : null;
  bool? supportsBooking;
  num? capacity;
  Gym(
      {required this.id,
      required this.name,
      required this.address,
      required this.lat,
      required this.lon,
      required this.equipments,
      required this.pricing,
      this.facilities,
      this.businessHours,
      this.hourlyRate,
      this.phones,
      this.pageLink,
      this.images,
      this.supportsBooking,
      this.capacity})
      : _weekdayBusinessHours = businessHours != null
            ? BusinessHours.fromDescriptors(businessHours)
            : null {
    _gymFacilities = facilities != null
        ? facilities!.map((e) => GymFacility.table[e]).toList()
        : [];
    supportsBooking ??= false;
  }

  bool? isOpenNow() {
    return _weekdayBusinessHours != null && _weekdayBusinessHours!.isNotEmpty
        ? _weekdayBusinessHours!.values.firstWhereOrNull(
              (element) => element.isOpenAt(DateTime.now()),
            ) !=
            null
        : null;
  }

  BusinessHours? businessHoursOfToday() {
    final openingDay = _weekdayBusinessHours?.values.firstWhereOrNull(
      (element) => element.isOpenAt(DateTime.now()),
    );
    if (openingDay != null) {
      return openingDay;
    }
    return _weekdayBusinessHours?.values.firstWhereOrNull(
      (element) => element.opensAfter(DateTime.now()),
    );
  }

  Map<String, dynamic>? toJson() => _$GymToJson(this);
  factory Gym.fromJson(Map<String, dynamic> json) => _$GymFromJson(json);
  factory Gym.fromSnap(DocumentSnapshot snap) {
    final Map<String, dynamic> json = snap.data() as Map<String, dynamic>;
    json['id'] = snap.id;
    return _$GymFromJson(json);
  }

  Map<String, dynamic> get trackingProps => {
        EventProperties.gymId: id,
        EventProperties.price:
            hourlyRate != null ? PriceFormat.format(hourlyRate!) : null,
      };
}

@JsonSerializable()
class Equipments {
  final int? typeId;
  final String? name;
  final int? number;

  Equipments({this.typeId, this.name, this.number});
  factory Equipments.fromJson(Map<String, dynamic> json) =>
      _$EquipmentsFromJson(json);

  Map<String, dynamic>? toJson() => _$EquipmentsToJson(this);
}

@JsonSerializable()
class Price {
  final int? amount;
  final String? currency;
  Price({this.amount, this.currency});

  Map<String, dynamic>? toJson() => _$PriceToJson(this);

  factory Price.fromJson(Map<String, dynamic> json) => _$PriceFromJson(json);
}

@JsonSerializable()
class Fare {
  final String? unit;
  FareTimeUnit? get timeUnit => FareTimeUnitMethods.fromString(unit);
  final int? amount;
  final Price? price;
  Fare({this.unit, this.amount, this.price});

  Map<String, dynamic>? toJson() => _$FareToJson(this);
  factory Fare.fromJson(Map<String, dynamic> json) => _$FareFromJson(json);
}

enum FareTimeUnit { day, hour, min, time }

extension FareTimeUnitMethods on FareTimeUnit? {
  static FareTimeUnit? fromString(String? str) {
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

  String? get displayName {
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
