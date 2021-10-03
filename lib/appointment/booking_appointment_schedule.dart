import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:where_gym/api_services/api_services.dart';
import 'package:where_gym/app_bloc.dart';
import 'package:where_gym/appointment/appointment_info.dart';
import 'package:where_gym/appointment/appointment_schedule.dart';
import 'package:where_gym/gym.dart';

class BookingAppointmentSchedule implements AppointmentSchedule {
  final DocumentReference userRef;
  final Gym gym;
  final AppBloc appBloc;
  final Stream<List<AppointmentInfo>> onAppointments;

  BookingAppointmentSchedule(
      {@required this.userRef, @required this.gym, @required this.appBloc})
      : onAppointments = FirebaseFirestore.instance
            .collectionGroup('gymAppointments')
            .where('user', isEqualTo: userRef)
            .where('status', isEqualTo: AppointmentStatus.scheduled.stringValue)
            .where('startAt', isGreaterThan: DateUtils.dateOnly(DateTime.now()))
            .orderBy('startAt')
            .snapshots()
            .map((event) => event.docs.map((e) => AppointmentInfo(e)).toList());

  Future<void> bookWithRange(DateTimeRange range) async {
    final res = await APIServices.instances.post(
      '/gyms/${gym.id}/appointments',
      body: {
        'startAt': range.start.toUtc().toIso8601String(),
        'endAt': range.end.toUtc().toIso8601String(),
      },
      token: await appBloc.getIdToken(),
    );
    APIServices.checkClientError(res);
  }

  Future<void> cancel(AppointmentInfo appointment) async {
    final res = await APIServices.instances.delete(
      '/gyms/${appointment.gymRef.id}/appointments/${appointment.id}',
      token: await appBloc.getIdToken(),
    );
    APIServices.checkClientError(res);
  }
}
