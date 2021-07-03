import 'package:rxdart/subjects.dart';
import 'package:where_gym/data_store.dart';
import 'package:hive/hive.dart';

part 'favorites.g.dart';

mixin FavoriteGymMixin {
  String get id;
  DateTime get addedAt;
  DateTime get lastContactedAt;
  int get contactCount;
}

@HiveType(typeId: 1)
class FavoriteGym extends HiveObject with FavoriteGymMixin {
  @HiveField(0)
  String id;
  @HiveField(1)
  DateTime addedAt;
  @HiveField(2)
  DateTime lastContactedAt;
  @HiveField(3)
  int contactCount;
}

abstract class FavoriteGymList {
  Stream<List<FavoriteGymMixin>> get onListUpdate;
  Future<void> add(String gymId);
  Future<void> delete(String gymId);
  FavoriteGymMixin getGym(String gymId);
  bool isFavorite(String gymId);
}

class LocalFavoriteGymList implements FavoriteGymList {
  final DataStore dataStore;
  LocalFavoriteGymList(this.dataStore) {
    _updateList();
  }
  final _list = BehaviorSubject<List<FavoriteGym>>();
  Stream<List<FavoriteGym>> get onListUpdate => _list;
  static Future<LocalFavoriteGymList> createList() async {
    return LocalFavoriteGymList(await DataStore.createWithName('favorites'));
  }

  List<FavoriteGym> get records => List<FavoriteGym>.from(dataStore.box.values);
  void _updateList() {
    print(records);
    _list.add(records);
  }

  Future<void> add(String gymId) async {
    final gym = FavoriteGym()
      ..id = gymId
      ..contactCount = 0
      ..addedAt = DateTime.now();
    dataStore.putValue(gymId, gym);
    _updateList();
  }

  Future<void> delete(String gymId) async {
    await dataStore.deleteValue(gymId);
    _updateList();
  }

  FavoriteGym getGym(String gymId) {
    return dataStore.getValue(gymId);
  }

  @override
  bool isFavorite(String gymId) {
    return getGym(gymId) != null;
  }
}
