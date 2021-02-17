import 'package:rxdart/subjects.dart';
import 'package:where_gym/api_services/api_services.dart';

class GymList {
  final _listSubject = BehaviorSubject<List<Gym>>();
  Stream<List<Gym>> get listStream => _listSubject;
  Future _task;

  Future<void> refresh() async {
    if (_task != null) {
      return _task;
    }
    try {
      final task =
          APIServices.instances.get('/gyms?lat=25.131204&lon=121.498629');
      _task = task;
      final res = await task;
      if (res.body == null) {
        _listSubject.add([]);
        return;
      }
      final list = List<Map>.from(res.body).map((e) => Gym.fromMap(e)).toList();
      if (list.isEmpty) {
        _listSubject.add([]);
        return;
      }
      _listSubject.add(list);
    } finally {
      _task = null;
    }
  }

  void dispose() {
    _listSubject.close();
  }
}

class Gym {
  final String id;
  final String name;
  final String address;
  final List<Equipments> equipments;
  final List<BusinessHours> businessHours;
  final Price hourlyRate;
  Gym.fromMap(Map map)
      : id = map['id'],
        name = map['name'],
        address = map['address'],
        hourlyRate = Price.fromMap(map['hourlyRate']),
        equipments = List<Map>.from(map['equipments'])
            .map((e) => Equipments.fromMap(e))
            .toList(),
        businessHours = List<Map>.from(map['businessHours'])
            .map((e) => BusinessHours.fromMap(e))
            .toList();
}

class Equipments {
  final int typeId;
  final String name;
  final int number;

  Equipments.fromMap(Map map)
      : typeId = map['typeId'],
        name = map['name'],
        number = map['number'];
}

class Price {
  final int amount;
  final String currency;
  Price.fromMap(Map map)
      : amount = map['amount'],
        currency = map['currency'];
}

class BusinessHours {
  final int start;
  final int end;
  BusinessHours.fromMap(Map map)
      : start = map['start'],
        end = map['end'];
}
