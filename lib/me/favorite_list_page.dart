import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:where_gym/app_bar_factory.dart';
import 'package:where_gym/app_bloc.dart';
import 'package:where_gym/gym.dart';
import 'package:where_gym/me/favorite_detail_list.dart';

class FavoriteListPage extends StatefulWidget {
  @override
  _FavoriteListPageState createState() => _FavoriteListPageState();
}

class _FavoriteListPageState extends State<FavoriteListPage> {
  FavoriteDetailList list;

  @override
  void initState() {
    super.initState();
    AppBloc bloc = BlocProvider.of(context);
    list = FavoriteDetailList(bloc.favoriteGymList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarFactory.appBar(),
      body: StreamBuilder<List<Gym>>(
          stream: list.onUpdate,
          builder: (context, snapshot) {
            return _buildList(context, snapshot.data);
          }),
    );
  }

  Widget _buildList(BuildContext context, List<Gym> gyms) {
    if (gyms == null) {
      return Container();
    }
    return ListView.separated(
      itemBuilder: (context, idx) => _Cell(gyms[idx]),
      separatorBuilder: (context, idx) => Divider(),
      itemCount: gyms.length,
    );
  }
}

class _Cell extends StatelessWidget {
  final Gym gym;
  _Cell(this.gym);

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 20);
  }
}
