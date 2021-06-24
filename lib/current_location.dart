import 'package:geolocator/geolocator.dart';
import 'package:rxdart/subjects.dart';
import 'package:where_gym/gym.dart';

class CurrentLocation {
  Position _fallbackPosition = Position(
      latitude: 25.055049,
      longitude: 121.542653,
      speed: 0,
      accuracy: 30,
      altitude: 0,
      heading: 0,
      timestamp: DateTime.now(),
      speedAccuracy: 0);
  final _myLocationSubject = BehaviorSubject<Position>();
  Stream<Position> get onUpdate => _myLocationSubject;
  Future _task;

  Future<Position> getLocation() async {
    if (_task != null) {
      return _task;
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
            desiredAccuracy: LocationAccuracy.medium)
        .timeout(Duration(seconds: 3), onTimeout: () async {
      return _myLocationSubject.valueWrapper != null
          ? _myLocationSubject.valueWrapper.value ?? _fallbackPosition
          : _fallbackPosition;
    });
    print(pos);
    _myLocationSubject.add(pos);
    return pos;
  }

  num metersFrom(Gym gym) {
    if (_myLocationSubject.valueWrapper == null) {
      return null;
    }
    final location = _myLocationSubject.valueWrapper.value;
    return Geolocator.distanceBetween(
        gym.lat, gym.lon, location.latitude, location.longitude);
  }
}
