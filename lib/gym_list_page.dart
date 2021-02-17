import 'package:flutter/material.dart';
import 'package:where_gym/gym_list.dart';

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
