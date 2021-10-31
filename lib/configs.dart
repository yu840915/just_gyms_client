import 'package:firebase_remote_config/firebase_remote_config.dart';

class Configs {
  static Configs? _instance;
  static Configs? get instance => _instance;

  static Future<Configs> initialize() async {
    final config = RemoteConfig.instance;
    await config.fetch();
    await config.activate();
    return Configs(config);
  }

  static setInstance(Configs configs) {
    if (_instance != null) {
      throw 'Config instance already exists';
    }
    _instance = configs;
  }

  String get ppLink => _getString('pp_link');
  String get tosLink => _getString('tos_link');
  String get contactLink => _getString('contact_link');

  final RemoteConfig _remoteConfig;
  Configs(this._remoteConfig);

  String _getString(key) {
    return _remoteConfig.getString(key);
  }
}
