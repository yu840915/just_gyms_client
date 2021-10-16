import 'package:hive/hive.dart';
import 'package:rxdart/subjects.dart';
import 'package:where_gym/data_store.dart';
import 'package:where_gym/me/favorites.dart';

part 'local_favorites.g.dart';

@HiveType(typeId: 1)
class FavoriteGym extends HiveObject with FavoriteGymMixin {
  @HiveField(0)
  String? id;
  @HiveField(1)
  DateTime? addedAt;
  @HiveField(2)
  DateTime? lastContactedAt;
  @HiveField(3)
  int? contactCount;
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

  @override
  void dispose() {
    _list.close();
  }

  List<FavoriteGym> get records => List<FavoriteGym>.from(dataStore.box.values);
  void _updateList() {
    _list.add(records);
  }

  Future<void> add(String? gymId) async {
    final gym = FavoriteGym()
      ..id = gymId
      ..contactCount = 0
      ..addedAt = DateTime.now();
    dataStore.putValue(gymId, gym);
    _updateList();
  }

  Future<void> delete(String? gymId) async {
    await dataStore.deleteValue(gymId);
    _updateList();
  }

  FavoriteGym? getGym(String? gymId) {
    return dataStore.getValue(gymId);
  }

  @override
  bool isFavorite(String? gymId) {
    return getGym(gymId) != null;
  }
}
