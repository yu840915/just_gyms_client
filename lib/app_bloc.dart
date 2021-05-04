import 'package:bloc/bloc.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:where_gym/intro/permission_checker.dart';

class AppBloc extends Bloc<dynamic, AppPhase> {
  final _hasFinishedIntroKey = 'hasFinishedIntro';
  final permissionChecker = PermissionChecker();
  AppBloc(initialState) : super(initialState) {
    _checkPermission();
  }

  void _checkPermission() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_hasFinishedIntroKey) ||
        !prefs.getBool(_hasFinishedIntroKey)) {
      add(AppPhase.intro);
    } else {
      _setUpPermission();
    }
  }

  void _setUpPermission() {
    permissionChecker.onHasUnfinishedItems.listen((shouldAsk) {
      if (shouldAsk) {
        add(AppPhase.permission);
      } else {
        add(AppPhase.app);
      }
    });
  }

  @override
  Stream<AppPhase> mapEventToState(event) async* {
    yield event;
  }

  void setIntroFinished() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setBool(_hasFinishedIntroKey, true);
      _setUpPermission();
    } catch (e) {
      print(e);
    }
  }
}

enum AppPhase { intro, permission, app }
