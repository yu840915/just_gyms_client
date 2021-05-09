import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:where_gym/app_bloc.dart';
import 'package:where_gym/error_view.dart';
import 'package:where_gym/home_page.dart';
import 'package:where_gym/intro/intro_page.dart';
import 'package:where_gym/intro/permission_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
  await AppTrackingTransparency.requestTrackingAuthorization();
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseApp>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return MaterialApp(
            home: ErrorPage(snapshot.error ?? '未知的錯誤，請重新開啟'),
            debugShowCheckedModeBanner: false,
          );
        }
        return _buildApp(context);
      },
    );
  }

  Widget _buildApp(BuildContext context) {
    return BlocProvider(
      create: (context) => AppBloc(null),
      child: MaterialApp(
        title: 'Just Gyms',
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
      case AppPhase.permission:
        return PermissionPage();
      default:
    }
    return HomePage();
  }
}
