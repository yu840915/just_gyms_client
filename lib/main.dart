import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:where_gym/app_bloc.dart';
import 'package:where_gym/home_page.dart';
import 'package:where_gym/intro/intro_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppBloc(null),
      child: MaterialApp(
        title: 'JustGym',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        debugShowCheckedModeBanner: false,
        home: BlocBuilder<AppBloc, AppPhase>(builder: _buildMainFlow),
      ),
    );
  }

  Widget _buildMainFlow(BuildContext context, AppPhase phase) {
    if (phase == null) {
      return Container(
        color: Colors.green,
      );
    }
    switch (phase) {
      case AppPhase.intro:
        return IntroPage();
      default:
    }
    return HomePage();
  }
}
