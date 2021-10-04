import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:where_gym/gym.dart';

class AdminGymList {
  AdminGymList(DocumentReference userRef) {
    FirebaseFirestore.instance
        .collection('gyms')
        .where('admins', arrayContains: userRef)
        .snapshots()
        .map((event) => event.docs.map((e) => Gym.fromJson(e.data())));
  }
}
