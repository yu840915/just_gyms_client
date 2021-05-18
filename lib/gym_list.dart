import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
import 'package:rxdart/subjects.dart';
import 'package:where_gym/api_services/api_services.dart';
import 'package:where_gym/gym.dart';

class GymList {
  final _fallbackPosition = Position(
      latitude: 25.055049,
      longitude: 121.542653,
      speed: 0,
      accuracy: 30,
      altitude: 0,
      heading: 0,
      timestamp: DateTime.now(),
      speedAccuracy: 0);
  final _myLocationSubject = BehaviorSubject<Position>();
  Stream<Position> get myLocationStream => _myLocationSubject;
  final _listSubject = BehaviorSubject<List<Gym>>();
  Stream<List<Gym>> get listStream => _listSubject;
  Future _task;
  final _distance = Distance();

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
      print('Location services are disabled.');
      _myLocationSubject.add(_fallbackPosition);
      return _fallbackPosition;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      print(
          'Location permissions are permantly denied, we cannot request permissions.');
      _myLocationSubject.add(_fallbackPosition);
      return _fallbackPosition;
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        print('Location permissions are denied (actual value: $permission).');
        _myLocationSubject.add(_fallbackPosition);
        return _fallbackPosition;
      }
    }
    final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low);
    _myLocationSubject.add(pos);
    return pos;
  }

  num metersFrom(Gym gym) {
    if (_myLocationSubject.valueWrapper == null) {
      return null;
    }
    final location = _myLocationSubject.valueWrapper.value;
    return _distance.as(LengthUnit.Meter, LatLng(gym.lat, gym.lon),
        LatLng(location.latitude, location.longitude));
  }

  void dispose() {
    _listSubject.close();
  }
}
