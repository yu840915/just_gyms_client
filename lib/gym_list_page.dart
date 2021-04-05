import 'package:flutter/material.dart';
import 'package:where_gym/app_bar_factory.dart';
import 'package:where_gym/distance_format.dart';
import 'package:where_gym/gym.dart';
import 'package:where_gym/gym_detail_page.dart';
import 'package:where_gym/gym_list.dart';
import 'package:where_gym/map_view/open_hour_indicator.dart';
import 'package:where_gym/price_format.dart';
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
    _gymList.refresh().catchError((e) {
      print(e);
    });
  }

  @override
  void dispose() {
    _gymList.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarFactory.appBar(),
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
      itemBuilder: (context, idx) {
        final gym = gyms[idx];
        return _Row(gym, meters: _gymList.metersFrom(gym));
      },
      separatorBuilder: (context, idx) => Container(
        height: 1,
        color: Colors.grey.shade300,
      ),
      itemCount: gyms.length,
    );
  }
}

class _Row extends StatelessWidget {
  final num meters;
  final Gym gym;
  _Row(this.gym, {this.meters});

  void _showDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GymDetailPage(gym: gym),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showDetail(context),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 140),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 70,
                    height: 50,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        image: gym.cover != null
                            ? DecorationImage(
                                image: NetworkImage(gym.cover),
                                fit: BoxFit.cover,
                              )
                            : null),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      gym.name,
                      style: TextStyles.small.header,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                gym.address,
                style: TextStyles.small.detail,
              ),
              SizedBox(height: 8),
              OpenHourIndicator(gym: gym, styles: TextStyles.small),
              SizedBox(height: 12),
              Row(
                children: [
                  buildPricingTable(gym.pricing),
                  if (gym.hourlyRate != null)
                    Text(
                      '(' + PriceFormat.format(gym.hourlyRate) + '/小時)',
                      style: TextStyles.small.subscription,
                    ),
                  Spacer(),
                  _buildDistanceLable(),
                ],
              ),
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        ),
      ),
    );
  }

  Widget _buildDistanceLable() {
    if (meters == null) {
      return Container();
    }

    return Text(
      DistanceFormat.format(meters),
      style: TextStyles.small.subscription,
    );
  }

  Widget buildPricingTable(List<Fare> fares) {
    String plans = '請電洽';
    if (fares != null && fares.isNotEmpty) {
      plans = fares.map((e) => FareFormat.format(e)).join('、');
    }
    return Text('計費方案：' + plans, style: TextStyles.small.detail);
  }
}
