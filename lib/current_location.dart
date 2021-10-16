import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:rxdart/subjects.dart';
import 'package:where_gym/data_store.dart';
import 'package:where_gym/gym.dart';

part 'current_location.g.dart';

@HiveType(typeId: 2)
class LocationRecord extends HiveObject {
  @HiveField(1)
  double? latitude;
  @HiveField(2)
  double? longitude;
}

class CurrentLocation {
  static Future<CurrentLocation> create() async {
    return CurrentLocation(await DataStore.createWithName('userLocations'));
  }

  final DataStore dataStore;
  final _lastLocationKey = 'lastLocation';
  CurrentLocation(this.dataStore);
  final _myLocationSubject = BehaviorSubject<Position>();
  Stream<Position> get onUpdate => _myLocationSubject;
  Future? _task;

  Position _getFallbackLocation() {
    final LocationRecord? record = dataStore.getValue(_lastLocationKey);
    double? latitude = 25.055049;
    double? longitude = 121.542653;
    if (record != null) {
      latitude = record.latitude;
      longitude = record.longitude;
    }
    return Position(
        latitude: latitude!,
        longitude: longitude!,
        speed: 0,
        accuracy: 30,
        altitude: 0,
        heading: 0,
        timestamp: DateTime.now(),
        speedAccuracy: 0);
  }

  Future<Position>? getLocation() async {
    if (_task != null) {
      return _task as FutureOr<Position>;
    }
    try {
      final findLocation = _determinePosition();
      _task = findLocation;
      return await findLocation;
    } finally {
      _task = null;
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      _myLocationSubject.add(_getFallbackLocation());
      return _getFallbackLocation();
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      print(
          'Location permissions are permantly denied, we cannot request permissions.');
      _myLocationSubject.add(_getFallbackLocation());
      return _getFallbackLocation();
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        print('Location permissions are denied (actual value: $permission).');
        _myLocationSubject.add(_getFallbackLocation());
        return _getFallbackLocation();
      }
    }
    final pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium)
        .timeout(Duration(seconds: 3), onTimeout: () async {
      return _myLocationSubject.valueOrNull ?? _getFallbackLocation();
    });
    print(pos);
    _myLocationSubject.add(pos);
    _recordLocation(pos);
    return pos;
  }

  void _recordLocation(Position pos) {
    LocationRecord? loc = dataStore.getValue(_lastLocationKey);
    if (loc == null) {
      loc = LocationRecord();
    }
    loc
      ..latitude = pos.latitude
      ..longitude = pos.longitude;
    dataStore.putValue(_lastLocationKey, loc);
  }

  num? metersFrom(Gym? gym) {
    if (_myLocationSubject.valueOrNull == null) {
      return null;
    }
    final location = _myLocationSubject.value;
    return Geolocator.distanceBetween(
        gym!.lat!, gym.lon!, location.latitude, location.longitude);
  }
}
