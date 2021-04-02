import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:where_gym/app_bar_factory.dart';
import 'package:where_gym/gym.dart';
import 'package:where_gym/shared_appearances.dart';

class GymDetailPage extends StatelessWidget {
  final Gym gym;
  GymDetailPage({@required this.gym});

  void _callGym(String phone) {
    launch('tel://$phone');
  }

  void _openPage(String link) {
    launch(link);
  }

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
          style: TextStyles.large.title,
        ),
        Spacer(),
        Row(
          children: [
            
            if (gym.phone != null)
              Expanded(child: _buildReserveButton(gym.phone))
          ],
        ),
      ],
    );
  }

  Widget _buildPageButton(String link) {
    return TextButton(
      onPressed: () => _openPage(link),
      child: Text(
        '商家網頁',
      ),
      style: TextButton.styleFrom(
        textStyle: TextStyles.large.action,
        minimumSize: Size(double.infinity, 50),
      ),
    );
  }

  Widget _buildReserveButton(String phone) {
    return TextButton(
      onPressed: () => _callGym(phone),
      child: Text(
        '立即預約',
      ),
      style: TextButton.styleFrom(
        textStyle: TextStyles.large.action,
        minimumSize: Size(double.infinity, 50),
      ),
    );
  }
}
