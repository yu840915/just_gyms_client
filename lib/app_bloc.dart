import 'package:bloc/bloc.dart';

import 'package:shared_preferences/shared_preferences.dart';

class AppBloc extends Bloc<dynamic, AppPhase> {
  final _hasFinishedIntroKey = 'hasFinishedIntro';
  AppBloc(initialState) : super(initialState) {
    add(null);
  }

  @override
  Stream<AppPhase> mapEventToState(event) async* {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_hasFinishedIntroKey) ||
        !prefs.getBool(_hasFinishedIntroKey)) {
      yield AppPhase.intro;
    }
  }
}

enum AppPhase { intro, permission, app }
