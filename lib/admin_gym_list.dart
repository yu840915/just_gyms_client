import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:where_gym/gym.dart';

class AdminGymList {
  final DocumentReference userRef;
  Stream<List<Gym>> get onGyms => FirebaseFirestore.instance
      .collection('gyms')
      .where('admins', arrayContains: userRef)
      .snapshots()
      .map((event) => event.docs.map((e) => Gym.fromSnap(e)).toList())
      .handleError(print);
  AdminGymList(this.userRef);
}
