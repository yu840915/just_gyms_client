import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rxdart/subjects.dart';
import 'package:where_gym/api_services/api_services.dart';
part 'gym_list.g.dart';

class GymList {
  final _myLocationSubject = BehaviorSubject<Position>();
  Stream<Position> get myLocationStream => _myLocationSubject;
  final _listSubject = BehaviorSubject<List<Gym>>();
  Stream<List<Gym>> get listStream => _listSubject;
  Future _task;

  Future<void> refresh() async {
    if (_task != null) {
      return _task;
    }
    try {
      final findLocation = _determinePosition();
      _task = findLocation;
      final pos = await findLocation;
      print(pos.latitude);
      print(pos.longitude);
      final task = APIServices.instances
          .get('/gyms?lat=${pos.latitude}&lon=${pos.longitude}');
      _task = task;
      final res = await task;
      if (res.body == null) {
        _listSubject.add([]);
        return;
      }
      final list = List<Map>.from(jsonDecode(res.body))
          .map((e) => Gym.fromJson(e))
          .toList();
      if (list.isEmpty) {
        _listSubject.add([]);
        return;
      }
      _listSubject.add(list);
    } finally {
      _task = null;
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permantly denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }
    final pos = await Geolocator.getCurrentPosition();
    _myLocationSubject.add(pos);
    return pos;
  }

  void dispose() {
    _listSubject.close();
  }
}

@JsonSerializable()
class Gym {
  final String id;
  final String name;
  final String address;
  final List<Equipments> equipments;
  final List<BusinessHours> businessHours;
  final Price hourlyRate;
  Gym(
      {this.id,
      this.name,
      this.address,
      this.equipments,
      this.businessHours,
      this.hourlyRate});

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

@JsonSerializable()
class BusinessHours {
  final String start;
  final String end;
  BusinessHours({this.start, this.end});

  Map<String, dynamic> toJson() => _$BusinessHoursToJson(this);
  factory BusinessHours.fromJson(Map<String, dynamic> json) =>
      _$BusinessHoursFromJson(json);
}
