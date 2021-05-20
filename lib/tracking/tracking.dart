import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:native_mixpanel/native_mixpanel.dart';
import 'package:where_gym/tracking/event_names.dart';

class Tracker {
  static Tracker _instance;
  static Tracker get instance => _instance;
  final Mixpanel mixpanel;

  Tracker._(this.mixpanel);

  static Future<void> initialize() async {
    Mixpanel mixpanel;
    if (Platform.isIOS) {
      mixpanel = Mixpanel(isOptedOut: false, shouldLogEvents: !kReleaseMode);
    } else {
      mixpanel = Mixpanel(isOptedOut: false, shouldLogEvents: !kReleaseMode);
    }
    await mixpanel.initialize('10e3acbe2c0245a34cdb4b232f35878f');
    _instance = Tracker._(mixpanel);
  }

  Future track(EventName event, [Map<String, dynamic> properties]) async {
    try {
      await mixpanel.track(event.name, properties ?? {});
    } catch (e) {
      print('Failed to track event (${event.name}), error $e');
    }
  }
}

track(EventName eventName, [Map<String, dynamic> properties]) {
  Tracker.instance.track(eventName, properties);
}
