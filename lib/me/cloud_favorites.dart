import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/subjects.dart';
import 'package:where_gym/api_services/api_services.dart';
import 'package:where_gym/app_bloc.dart';
import 'package:where_gym/me/favorites.dart';
import 'package:where_gym/me/local_favorites.dart';

class CloudFavoriteGym implements FavoriteGymMixin {
  @override
  final String id;

  CloudFavoriteGym(this.id);
}

class CloudFavoriteGymList implements FavoriteGymList {
  final AppBloc bloc;
  final _gymListSubject = BehaviorSubject<List<FavoriteGymMixin>>();
  late StreamSubscription _subscription;
  CloudFavoriteGymList(this.bloc, User user) {
    _subscription = FirebaseFirestore.instance
        .collection('favorites')
        .doc(user.uid)
        .snapshots()
        .map((event) => !event.exists
            ? []
            : List<FavoriteGymMixin>.from(CloudFavorites.fromMap(event.data()!)
                .gyms
                .map((e) => CloudFavoriteGym(e))))
        .listen(_gymListSubject.add as void Function(List<dynamic>)?);
  }

  @override
  void dispose() {
    _subscription.cancel();
    _gymListSubject.close();
  }

  @override
  Future<void> add(String? gymId) async {
    await APIServices.instances.patch(
      '/me/favorites/gyms',
      body: {
        'gyms': [gymId]
      },
      token: await bloc.getIdToken(),
    );
  }

  @override
  Future<void> delete(String? gymId) async {
    await APIServices.instances.delete(
      '/me/favorites/gyms/$gymId',
      token: await bloc.getIdToken(),
    );
  }

  @override
  FavoriteGymMixin? getGym(String? gymId) {
    if (_gymListSubject.valueOrNull == null) {
      return null;
    }
    return _gymListSubject.value
        .firstWhereOrNull((e) => e.id == gymId);
  }

  @override
  bool isFavorite(String? gymId) {
    return getGym(gymId) != null;
  }

  @override
  Stream<List<FavoriteGymMixin>> get onListUpdate => _gymListSubject;

  Future syncWithLocalList(LocalFavoriteGymList list) async {
    await APIServices.instances.patch(
      '/me/favorites/gyms',
      body: {'gyms': list.records.map((e) => e.id).toList()},
      token: await bloc.getIdToken(),
    );
  }
}

class CloudFavorites {
  final List<String> gyms;
  CloudFavorites.fromMap(Map map)
      : gyms = map['gyms'] != null ? List<String>.from(map['gyms']) : [];
}
