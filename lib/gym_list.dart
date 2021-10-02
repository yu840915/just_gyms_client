import 'dart:convert';

import 'package:rxdart/subjects.dart';
import 'package:where_gym/api_services/api_services.dart';
import 'package:where_gym/current_location.dart';
import 'package:where_gym/gym.dart';

class GymList {
  final CurrentLocation location;
  final _listSubject = BehaviorSubject<List<Gym>>();
  Stream<List<Gym>> get listStream => _listSubject;
  Future _task;
  GymList(this.location);

  Future<void> refresh() async {
    if (_task != null) {
      return _task;
    }
    try {
      final findLocation = location.getLocation();
      _task = findLocation;
      final pos = await findLocation;
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

  num metersFrom(Gym gym) {
    return location.metersFrom(gym);
  }

  void dispose() {
    _listSubject.close();
  }
}
