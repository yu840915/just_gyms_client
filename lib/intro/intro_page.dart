import 'package:flutter/material.dart';
import 'package:where_gym/app_bar_factory.dart';

class IntroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarFactory.shrinkedAppBar(),
      body: _buildBody(context),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Spacer(flex: 1),
          Text('找一個不受打擾的場地\n\t\t專心一意做好訓練'),
          Spacer(flex: 2),
        ],
      ),
    );
  }
}
