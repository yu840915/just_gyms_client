import 'dart:async';
import 'dart:convert';

import 'package:rxdart/subjects.dart';
import 'package:where_gym/api_services/api_services.dart';
import 'package:where_gym/gym.dart';
import 'package:where_gym/me/favorites.dart';

class FavoriteDetailList {
  final _fetchers = Map<String, GymDetailFetcher>();
  final _details = BehaviorSubject<List<Gym>>();
  StreamSubscription<List<FavoriteGym>> _updateSubscription;
  Stream<List<Gym>> get onUpdate => _details;

  FavoriteDetailList(FavoriteGymList list) {
    _updateSubscription = list.onListUpdate.listen(_getDetailsOnUpdate);
  }

  GymDetailFetcher _getFetchers(String gymId) {
    GymDetailFetcher fetcher = _fetchers[gymId];
    if (fetcher != null) {
      return fetcher;
    }
    fetcher = GymDetailFetcher(gymId);
    _fetchers[gymId] = fetcher;
    return fetcher;
  }

  void _getDetailsOnUpdate(List<FavoriteGym> list) async {
    if (_details.isClosed) {
      return;
    }
    final details =
        await Future.wait(list.map((e) => _getFetchers(e.id).fetch()));
    if (_details.isClosed) {
      return;
    }
    _details.add(details);
  }

  void dispose() {
    _updateSubscription.cancel();
    _details.close();
  }
}

class GymDetailFetcher {
  final String gymId;
  Future<Gym> _task;
  GymDetailFetcher(this.gymId);
  Gym _gym;
  Future<Gym> getDetail() async {
    if (_gym != null) {
      return _gym;
    }
    if (_task == null) {
      _task = fetch();
    }
    return await _task;
  }

  Future<Gym> fetch() async {
    final res = await APIServices.instances.get('/gyms/$gymId');
    _gym = Gym.fromJson(jsonDecode(res.body));
    return _gym;
  }
}
