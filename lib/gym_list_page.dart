import 'package:flutter/material.dart';
import 'package:where_gym/gym_list.dart';
import 'package:where_gym/map_view_page.dart';

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

  void _showMapView(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapViewPage(_gymList),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: _buildMapButton(context)),
      body: _buildBody(context),
    );
  }

  Widget _buildMapButton(BuildContext context) {
    return FlatButton(
      onPressed: () => _showMapView(context),
      child: Text('地圖'),
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
    return ListView.builder(
      itemBuilder: (context, idx) => _Row(gyms[idx]),
      itemCount: gyms.length,
    );
  }
}

class _Row extends StatelessWidget {
  final Gym gym;
  _Row(this.gym);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text(gym.name),
          Text(gym.address),
          if (gym.hourlyRate != null)
            Text(gym.hourlyRate.currency + ' ${gym.hourlyRate.amount}'),
          _buildEquipments()
        ],
      ),
    );
  }

  Widget _buildEquipments() {
    return Text(gym.equipments
        .map((e) => e.name + 'x' + '${e.number}')
        .toList()
        .join(", "));
  }
}
