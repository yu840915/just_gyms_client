class EventName {
  final String name;
  EventName._(this.name);

  static final finishIntro = EventName._('finish intro');
  static final refreshMap = EventName._('refresh map');
  static final showGymDetail = EventName._('show gym detail');
  static final showGymAppointmentList = EventName._('show gym appointment list');
  static final contactGym = EventName._('contact gym');
  static final showGymList = EventName._('show gym detail');
  static final selectMarker = EventName._('select marker');
  static final addBookmark = EventName._('add bookmark');
  static final removeBookmark = EventName._('remove bookmark');
}

class EventProperties {
  static final String from = 'from';
  static final String price = 'price';
  static final String gymId = 'gym id';
  static final String distance = 'distance';
}
