import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/subjects.dart';
import 'package:where_gym/api_services/api_services.dart';
import 'package:where_gym/app_bloc.dart';
import 'package:where_gym/me/favorites.dart';

class CloudFavoriteGym implements FavoriteGymMixin {
  @override
  final DateTime addedAt;

  @override
  final int contactCount;

  @override
  final String id;

  @override
  final DateTime lastContactedAt;

  CloudFavoriteGym.fromMap(this.id, Map map)
      : addedAt = (map['addedAt'] as Timestamp).toDate(),
        contactCount = map['contactCount'] ?? 0,
        lastContactedAt = map['lastContactedAt'] != null
            ? (map['lastContactedAt'] as Timestamp).toDate()
            : null;
}

class CloudFavoriteGymList implements FavoriteGymList {
  final AppBloc bloc;
  final _gymListSubject = BehaviorSubject<List<FavoriteGymMixin>>();
  CloudFavoriteGymList(this.bloc) {
    //TODO: get list from user's doc
  }

  @override
  void dispost() {
    _gymListSubject.close();
  }

  @override
  Future<void> add(String gymId) async {
    await APIServices.instances.patch(
      '/me/favorites/gyms',
      body: {
        'gyms',
        [gymId]
      },
      token: await bloc.getIdToken(),
    );
  }

  @override
  Future<void> delete(String gymId) async {
    await APIServices.instances.delete(
      '/me/favorites/gyms/$gymId',
      token: await bloc.getIdToken(),
    );
  }

  @override
  FavoriteGymMixin getGym(String gymId) {
    if (_gymListSubject.valueWrapper == null) {
      return null;
    }
    return _gymListSubject.valueWrapper.value
        .firstWhere((e) => e.id == gymId, orElse: () => null);
  }

  @override
  bool isFavorite(String gymId) {
    return getGym(gymId) != null;
  }

  @override
  Stream<List<FavoriteGymMixin>> get onListUpdate => _gymListSubject;
}
