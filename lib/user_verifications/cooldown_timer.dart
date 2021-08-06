import 'dart:async';

import 'package:rxdart/subjects.dart';

class CooldownTimer {
  final _cooldownTimeSubject = BehaviorSubject<int>()..add(0);
  Stream<int> get onCooldownTime => _cooldownTimeSubject;
  DateTime _deadline;
  Timer _timer;

  void startCooldown(Duration duration) {
    if (_timer != null) {
      return;
    }
    assert(!duration.isNegative);
    _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      _tick();
    });
    _deadline = DateTime.now().add(duration);
  }

  void _tick() {
    assert(_deadline != null);
    final p = _deadline.difference(DateTime.now());
    if (p.inSeconds <= 0) {
      _cooldownTimeSubject.add(0);
      _timer.cancel();
      _timer = null;
    } else {
      _cooldownTimeSubject.add(p.inSeconds);
    }
  }

  void dispose() {
    _timer.cancel();
    _cooldownTimeSubject.close();
  }
}
