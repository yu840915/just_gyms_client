import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'package:where_gym/gym.dart';

class AppointmentSchedule {
  final DocumentReference userRef;
  final Gym gym;
  final Stream<List<AppointmentInfo>> myAppointments;
  final _dateSubject = BehaviorSubject<DateTime>();
  AppointmentSchedule({@required this.userRef, @required this.gym})
      : myAppointments = FirebaseFirestore.instance
            .collection('gyms')
            .doc(gym.id)
            .collection('gymAppointments')
            .where('user', isEqualTo: userRef)
            .where('status', isEqualTo: AppointmentStatus.scheduled.stringValue)
            .where('startAt', isGreaterThan: DateTime.now())
            //Reset to start of today
            .orderBy('startAt')
            .snapshots()
            .map((event) => event.docs.map((e) => AppointmentInfo(e)).toList());

  void selectDate(DateTime date) {
    _dateSubject.add(date);
  }
}

class AppointmentInfo {
  final String id;
  final DocumentReference gymRef;
  final AppointmentStatus status;
  final DocumentReference userRef;
  final DateTimeRange timeRange;
  AppointmentInfo(DocumentSnapshot<Map> snap)
      : id = snap.id,
        gymRef = snap.data()['gym'],
        userRef = snap.data()['user'],
        timeRange = DateTimeRange(
            start: (snap.data()['startAt'] as Timestamp).toDate(),
            end: (snap.data()['endAt'] as Timestamp).toDate()),
        status = AppointmentStatusMethods.fromString(snap.data()['status']);
}

enum AppointmentStatus { scheduled, cancelled, fulfilled, missed, unkown }

extension AppointmentStatusMethods on AppointmentStatus {
  static AppointmentStatus fromString(String string) {
    if (string == null) {
      return AppointmentStatus.unkown;
    }
    switch (string) {
      case 'scheduled':
        return AppointmentStatus.scheduled;
      case 'cancelled':
        return AppointmentStatus.cancelled;
      case 'fulfilled':
        return AppointmentStatus.fulfilled;
      case 'missed':
        return AppointmentStatus.missed;
      default:
        return AppointmentStatus.unkown;
    }
  }

  String get stringValue {
    switch (this) {
      case AppointmentStatus.scheduled:
        return 'scheduled';
      case AppointmentStatus.cancelled:
        return 'cancelled';
      case AppointmentStatus.fulfilled:
        return 'fulfilled';
      case AppointmentStatus.missed:
        return 'missed';
      default:
        return null;
    }
  }
}
