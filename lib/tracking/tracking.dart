import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:where_gym/tracking/event_names.dart';

class Tracker {
  static Tracker _instance;
  static Tracker get instance => _instance;
  final Mixpanel mixpanel;

  Tracker._(this.mixpanel);

  static Future<void> initialize() async {
    _instance =
        Tracker._(await Mixpanel.init('10e3acbe2c0245a34cdb4b232f35878f'));
  }

  void track(EventName event, [Map<String, dynamic> properties]) {
    try {
      mixpanel.track(event.name, properties: properties ?? {});
    } catch (e) {
      print('Failed to track event (${event.name}), error $e');
    }
  }
}

track(EventName eventName, [Map<String, dynamic> properties]) {
  Tracker.instance.track(eventName, properties);
}
