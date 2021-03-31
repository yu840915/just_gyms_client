import 'package:flutter/material.dart';
import 'package:where_gym/app_bar_factory.dart';
import 'package:where_gym/gym.dart';
import 'package:where_gym/shared_appearances.dart';

class GymDetailPage extends StatelessWidget {
  final Gym gym;
  GymDetailPage({@required this.gym});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarFactory.appBar(),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        Container(),
        Text(
          gym.name,
          style: LargeTextStyles.title,
        )
      ],
    );
  }
}
