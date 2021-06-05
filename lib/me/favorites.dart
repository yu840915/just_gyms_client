import 'package:rxdart/subjects.dart';
import 'package:where_gym/data_store.dart';
import 'package:hive/hive.dart';

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
  FavoriteGym([this.id, this.addedAt, this.lastContactedAt, this.contactCount]);
}

class FavoriteGymAdapter extends TypeAdapter<FavoriteGym> {
  @override
  FavoriteGym read(BinaryReader reader) {
    final data = List.from(reader.read(typeId));
    return FavoriteGym(data[0], data[1], data[2], data[3]);
  }

  @override
  int get typeId => 1;

  @override
  void write(BinaryWriter writer, FavoriteGym obj) {
    writer.write([obj.id, obj.addedAt, obj.lastContactedAt, obj.contactCount]);
  }
}

class FavoriteGymList {
  DataStore dataStore;
  FavoriteGymList(this.dataStore) {
    _updateList();
  }
  final _list = BehaviorSubject<List<FavoriteGym>>();
  Stream<List<FavoriteGym>> get onListUpdate => _list;
  static Future<FavoriteGymList> createList() async {
    return FavoriteGymList(await DataStore.createWithName('favorites'));
  }

  List<FavoriteGym> get records => List<FavoriteGym>.from(dataStore.box.values);
  void _updateList() {
    print(records);
    _list.add(records);
  }

  add(String gymId) {
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

  bool isFavorite(String gymId) {
    return getGym(gymId) != null;
  }
}
