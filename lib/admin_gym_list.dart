import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:where_gym/gym.dart';

class AdminGymList {
  final Stream<List<Gym>> onGyms;
  AdminGymList(DocumentReference userRef)
      : onGyms = FirebaseFirestore.instance
            .collection('gyms')
            .where('admins', arrayContains: userRef)
            .snapshots()
            .map((event) => event.docs.map((e) => Gym.fromJson(e.data())).toList())
            .handleError(print);
}
