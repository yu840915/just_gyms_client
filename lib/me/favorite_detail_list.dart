import 'dart:async';
import 'dart:convert';

import 'package:rxdart/subjects.dart';
import 'package:where_gym/api_services/api_services.dart';
import 'package:where_gym/current_location.dart';
import 'package:where_gym/gym.dart';
import 'package:where_gym/me/favorites.dart';

class FavoriteDetailList {
  final _fetchers = Map<String?, GymDetailFetcher>();
  final _details = BehaviorSubject<List<FavoriteGymDetail>>();
  final CurrentLocation location;
  late StreamSubscription<List<FavoriteGymMixin>> _updateSubscription;
  Stream<List<FavoriteGymDetail>> get onUpdate => _details;

  FavoriteDetailList(FavoriteGymList list, this.location) {
    _updateSubscription = list.onListUpdate.listen(_getDetailsOnUpdate);
  }

  GymDetailFetcher _getFetchers(String gymId) {
    GymDetailFetcher? fetcher = _fetchers[gymId];
    if (fetcher != null) {
      return fetcher;
    }
    fetcher = GymDetailFetcher(gymId);
    _fetchers[gymId] = fetcher;
    return fetcher;
  }

  void _getDetailsOnUpdate(List<FavoriteGymMixin> list) async {
    if (_details.isClosed) {
      return;
    }
    final gyms = await Future.wait(list.map((e) => _getFetchers(e.id!).fetch()));
    await location.getLocation();
    final details =
        gyms.map((e) => FavoriteGymDetail(e, location.metersFrom(e))).toList();
    details.sort((a, b) => (a.meters! - b.meters!).toInt());
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

class FavoriteGymDetail {
  final Gym gym;
  final num? meters;
  FavoriteGymDetail(this.gym, this.meters);
}

class GymDetailFetcher {
  final String? gymId;
  Future<Gym?>? _task;
  GymDetailFetcher(this.gymId);
  Gym? _gym;
  Future<Gym?> getDetail() async {
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
    return _gym!;
  }
}
