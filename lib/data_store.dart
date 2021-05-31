import 'package:hive/hive.dart';

class DataStore {
  final Box box;
  DataStore(this.box);

  static Future<DataStore> createWithName(String name) async {
    final box = await Hive.openBox(name);
    return DataStore(box);
  }

  getValue(String key) {
    return box.get(key);
  }

  putValue(String key, HiveObject entry) {
    if (getValue(key) == null) {
      box.put(key, entry);
    } else {
      entry.save();
    }
  }
}
