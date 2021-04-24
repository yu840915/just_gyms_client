import 'package:bloc/bloc.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:where_gym/intro/permission_checker.dart';

class AppBloc extends Bloc<dynamic, AppPhase> {
  final _hasFinishedIntroKey = 'hasFinishedIntro';
  final permissionChecker = PermissionChecker();
  AppBloc(initialState) : super(initialState) {
    _setNeedsUpdate();
  }

  @override
  Stream<AppPhase> mapEventToState(event) async* {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_hasFinishedIntroKey) ||
        !prefs.getBool(_hasFinishedIntroKey)) {
      yield AppPhase.intro;
    }
  }

  void _setNeedsUpdate() {
    add(null);
  }

  void setIntroFinished() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setBool(_hasFinishedIntroKey, true);
      _setNeedsUpdate();
    } catch (e) {
      print(e);
    }
  }
}

enum AppPhase { intro, permission, app }
