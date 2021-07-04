import 'package:cloud_firestore/cloud_firestore.dart';
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
  @override
  Future<void> add(String gymId) {
    // TODO: implement add
    throw UnimplementedError();
  }

  @override
  Future<void> delete(String gymId) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  FavoriteGymMixin getGym(String gymId) {
    // TODO: implement getGym
    throw UnimplementedError();
  }

  @override
  bool isFavorite(String gymId) {
    // TODO: implement isFavorite
    throw UnimplementedError();
  }

  @override
  // TODO: implement onListUpdate
  Stream<List<FavoriteGymMixin>> get onListUpdate => throw UnimplementedError();
  
}
