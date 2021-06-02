import 'package:hive/hive.dart';
import 'package:where_gym/data_store.dart';

@HiveType(typeId: 1)
class FavoriteGym extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  DateTime addedAt;
  @HiveField(2)
  DateTime lastContactedAt;
  @HiveField(3)
  int contactCount;
}

class FavoriteGymList {
  DataStore dataStore;
  FavoriteGymList(this.dataStore);
  static Future<FavoriteGymList> createList() async {
    return FavoriteGymList(await DataStore.createWithName('favorites'));
  }

  List<FavoriteGym> get records => dataStore.box.values.toList();
  add(String gymId) {
    final gym = FavoriteGym()
      ..id = gymId
      ..contactCount = 0
      ..addedAt = DateTime.now();
    dataStore.putValue(gymId, gym);
  }

  FavoriteGym getGym(String gymId) {
    return dataStore.getValue(gymId);
  }

  bool isFavorite(String gymId) {
    return getGym(gymId) != null;
  }
}

