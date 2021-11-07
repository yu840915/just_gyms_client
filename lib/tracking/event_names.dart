class EventName {
  final String name;
  EventName._(this.name);

  static final finishIntro = EventName._('finish intro');
  static final refreshMap = EventName._('refresh map');
  static final showGymDetail = EventName._('show gym detail');
  static final showGymAppointmentList =
      EventName._('show gym appointment list');
  static final contactGym = EventName._('contact gym');
  static final showGymList = EventName._('show gym detail');
  static final selectMarker = EventName._('select marker');
  static final addBookmark = EventName._('add bookmark');
  static final removeBookmark = EventName._('remove bookmark');
  static final showBookingPage = EventName._('show booking');
  static final showBookingPreflight = EventName._('show booking preflight');
  static final startPermissionFlow = EventName._('start permission flow');
  static final skipPermissionFlow = EventName._('skip permission flow');
  static final updatePermissionStatus = EventName._('update permission status');
  static final createAppointment = EventName._('create appointment');
  static final cancelAppointment = EventName._('cancel appointment');
}

class EventProperties {
  static final String from = 'from';
  static final String price = 'price';
  static final String gymId = 'gym id';
  static final String distance = 'distance';
  static final String type = 'type';
  static final String status = 'status';
  static final String role = 'role';
  static final String user = 'user';
}
