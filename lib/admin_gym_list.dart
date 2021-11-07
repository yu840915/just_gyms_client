import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:rxdart/subjects.dart';
import 'package:where_gym/gym.dart';

class AdminGymList {
  final DocumentReference? userRef;
  final _gymSubject = BehaviorSubject<List<Gym>>()..add([]);
  late StreamSubscription _subscription;

  Stream<List<Gym>> get onGyms => _gymSubject;
  AdminGymList(this.userRef) {
    _subscription = FirebaseFirestore.instance
        .collection('gyms')
        .where('admins', arrayContains: userRef)
        .snapshots()
        .map((event) => event.docs.map((e) => Gym.fromSnap(e)).toList())
        .handleError(print)
        .listen(_gymSubject.add);
  }

  bool isAdminOfGym(Gym? gym) {
    if (_gymSubject.valueOrNull == null) {
      return false;
    }
    return _gymSubject.value.firstWhereOrNull(
            (element) => element.id == gym!.id) !=
        null;
  }

  void dispose() {
    _subscription.cancel();
    _gymSubject.close();
  }
}
