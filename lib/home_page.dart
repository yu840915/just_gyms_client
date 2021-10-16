import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:where_gym/app_bloc.dart';
import 'package:where_gym/gym_list.dart';
import 'package:where_gym/map_view/map_view_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GymList? _gymList;

  @override
  void initState() {
    super.initState();
    AppBloc bloc = BlocProvider.of(context);
    _gymList = GymList(bloc.location);
    _gymList!.refresh()!.catchError(print);
  }

  @override
  void dispose() {
    _gymList!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MapViewPage(_gymList);
  }
}
