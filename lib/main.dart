import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:where_gym/app_bloc.dart';
import 'package:where_gym/utils/error_view.dart';
import 'package:where_gym/home_page.dart';
import 'package:where_gym/initialization.dart';
import 'package:where_gym/intro/intro_page.dart';
import 'package:where_gym/intro/permission_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
  await AppTrackingTransparency.requestTrackingAuthorization();
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Future<InitializedProducts> _initialization =
      Initialization.initialize();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<InitializedProducts>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return MaterialApp(
            home: ErrorPage(snapshot.error ?? '未知的錯誤，請重新開啟'),
            debugShowCheckedModeBanner: false,
          );
        }
        if (!snapshot.hasData) {
          return Container();
        }
        return _buildApp(context, snapshot.data);
      },
    );
  }

  Widget _buildApp(BuildContext context, InitializedProducts products) {
    return BlocProvider(
      create: (context) => AppBloc(null, initializedProducts: products),
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
        color: Colors.white,
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
