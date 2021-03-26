import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:where_gym/gym_list.dart';
import 'package:where_gym/shared_appearances.dart';

class GymListPage extends StatefulWidget {
  @override
  _GymListPageState createState() => _GymListPageState();
}

class _GymListPageState extends State<GymListPage> {
  GymList _gymList;

  @override
  void initState() {
    super.initState();
    _gymList = GymList();
    _gymList.refresh().catchError(print);
  }

  @override
  void dispose() {
    _gymList.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<List<Gym>>(
      stream: _gymList.listStream,
      builder: (context, snap) => _buildList(context, snap.data),
    );
  }

  Widget _buildList(BuildContext context, List<Gym> gyms) {
    if (gyms == null) {
      return Container();
    }
    return ListView.separated(
      padding: EdgeInsets.only(top: 20, bottom: 80),
      itemBuilder: (context, idx) => _Row(gyms[idx]),
      separatorBuilder: (context, idx) => Container(
        height: 1,
        color: Colors.grey.shade300,
      ),
      itemCount: gyms.length,
    );
  }
}

class _Row extends StatelessWidget {
  final Gym gym;
  _Row(this.gym);

  void _callGym(String phone) {
    launch('tel://$phone');
  }

  void _showDetail(BuildContext context) {}

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showDetail(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            Text(
              gym.name,
              style: TextStyles.title.copyWith(color: Colors.black),
            ),
            SizedBox(height: 8),
            if (gym.hourlyRate != null)
              Text(gym.hourlyRate.currency + ' ${gym.hourlyRate.amount}'),
            SizedBox(height: 8),
            Text(
              gym.address,
              style: TextStyles.detail.copyWith(color: Colors.black),
            ),
            if (gym.phone != null) ...[
              SizedBox(height: 8),
              Row(
                children: [
                  Spacer(),
                  _buildContactButton(gym.phone),
                ],
              )
            ],
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
      ),
    );
  }

  Widget _buildContactButton(String phone) {
    return ElevatedButton(
      onPressed: () => _callGym(phone),
      child: Text(
        '立即預約',
      ),
      style: ButtonStyle(
        shape: MaterialStateProperty.all(StadiumBorder()),
        textStyle: MaterialStateProperty.all(TextStyles.actionSmall),
        minimumSize: MaterialStateProperty.all(Size(60, 30)),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
