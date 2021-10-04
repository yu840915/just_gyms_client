import 'package:where_gym/appointment/appointment_info.dart';

abstract class AppointmentSchedule {
  Stream<List<AppointmentInfo>> get onAppointments;
  Future<void> cancel(AppointmentInfo appointment);
}

