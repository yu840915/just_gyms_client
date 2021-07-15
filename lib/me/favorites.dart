mixin FavoriteGymMixin {
  String get id;  
}

abstract class FavoriteGymList {
  Stream<List<FavoriteGymMixin>> get onListUpdate;
  Future<void> add(String gymId);
  Future<void> delete(String gymId);
  FavoriteGymMixin getGym(String gymId);
  bool isFavorite(String gymId);
  void dispose();
}
