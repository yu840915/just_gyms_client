import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:where_gym/app_bar_factory.dart';
import 'package:where_gym/app_bloc.dart';
import 'package:where_gym/gym.dart';
import 'package:where_gym/gym_detail_page.dart';
import 'package:where_gym/map_view/open_hour_indicator.dart';
import 'package:where_gym/me/favorite_detail_list.dart';
import 'package:where_gym/price_format.dart';
import 'package:where_gym/shared_appearances.dart';
import 'package:where_gym/tracking/event_names.dart';
import 'package:where_gym/tracking/tracking.dart';

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
      appBar: AppBarFactory.appBar(
          title: Text(
        '收藏',
        style: TextStyles.large.title,
      )),
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
      itemBuilder: (context, idx) => _Row(gyms[idx]),
      separatorBuilder: (context, idx) => Divider(),
      itemCount: gyms.length,
    );
  }
}

class _Row extends StatelessWidget {
  final Gym gym;
  _Row(this.gym);

  void _showDetail(BuildContext context) {
    track(EventName.showGymDetail, {
      ...gym.trackingProps,
      // EventProperties.distance: meters,
      EventProperties.from: 'favorite list',
    });
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
        constraints: BoxConstraints(minHeight: 120),
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
                    child: Column(
                      children: [
                        Text(
                          gym.name,
                          style: TextStyles.small.header,
                        ),
                        SizedBox(height: 8),
                        OpenHourIndicator(gym: gym, styles: TextStyles.small),
                      ],
                      crossAxisAlignment: CrossAxisAlignment.start,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                gym.address,
                style: TextStyles.small.detail,
              ),
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
                  // _buildDistanceLable(),
                ],
              ),
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        ),
      ),
    );
  }

  // Widget _buildDistanceLable() {
  //   if (meters == null) {
  //     return Container();
  //   }

  //   return Text(
  //     DistanceFormat.format(meters),
  //     style: TextStyles.small.subscription,
  //   );
  // }

  Widget buildPricingTable(List<Fare> fares) {
    String plans = '請電洽';
    if (fares != null && fares.isNotEmpty) {
      plans = fares.map((e) => FareFormat.format(e)).join('、');
    }
    return Text('計費方案：' + plans, style: TextStyles.small.detail);
  }
}
