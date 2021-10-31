import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:where_gym/alert_factory.dart';
import 'package:where_gym/app_bar_factory.dart';
import 'package:where_gym/app_bloc.dart';
import 'package:where_gym/distance_format.dart';
import 'package:where_gym/gym.dart';
import 'package:where_gym/gym_detail_page.dart';
import 'package:where_gym/login/login_check_flow.dart';
import 'package:where_gym/map_view/open_hour_indicator.dart';
import 'package:where_gym/me/favorite_detail_list.dart';
import 'package:where_gym/price_format.dart';
import 'package:where_gym/shared_appearances.dart';
import 'package:where_gym/tracking/event_names.dart';
import 'package:where_gym/tracking/tracking.dart';
import 'package:where_gym/utils/empty_view.dart';

class FavoriteListPage extends StatefulWidget {
  @override
  _FavoriteListPageState createState() => _FavoriteListPageState();
}

class _FavoriteListPageState extends State<FavoriteListPage> {
  late FavoriteDetailList list;
  late StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    AppBloc bloc = BlocProvider.of(context);
    _subscription = bloc.onUserRefChange.listen((event) {
      setState(() {
        list.dispose();
        list = FavoriteDetailList(bloc.favoriteGymList, bloc.location);
      });
    });
    list = FavoriteDetailList(bloc.favoriteGymList, bloc.location);
  }

  @override
  void dispose() {
    _subscription.cancel();
    list.dispose();
    super.dispose();
  }

  void _syncWithLocalIfLoggedIn(BuildContext context) async {
    final isLoggedIn =
        await LoginCheckFlow.check(context, where: 'syncFavoriteGyms');
    if (!isLoggedIn) {
      return;
    }
    await Future.delayed(Duration.zero, () {
      _syncWithLocal(context);
    });
  }

  void _syncWithLocal(BuildContext context) async {
    try {
      AppBloc bloc = BlocProvider.of(context);
      await bloc.syncFavoriteGyms();
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertFactory.actionAlert(
          context,
          message: e.toString(),
          actions: null,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    AppBloc bloc = BlocProvider.of(context);
    return Scaffold(
      appBar: AppBarFactory.appBar(
        title: Text(
          '收藏',
          style: TextStyles.large.title,
        ),
        actions: [
          StreamBuilder<DocumentReference?>(
            stream: bloc.onUserRefChange,
            builder: (context, snapshot) {
              if (bloc.isLoggedIn) {
                return SizedBox();
              }
              return TextButton(
                  onPressed: () {
                    _syncWithLocalIfLoggedIn(context);
                  },
                  child: Text(
                    '同步',
                    style: TextStyles.large.title,
                  ));
            },
          )
        ],
      ) as PreferredSizeWidget?,
      body: StreamBuilder<List<FavoriteGymDetail>>(
          stream: list.onUpdate,
          builder: (context, snapshot) {
            return _buildList(context, snapshot.data);
          }),
    );
  }

  Widget _buildList(BuildContext context, List<FavoriteGymDetail>? details) {
    if (details == null) {
      return Container();
    }
    if (details.isEmpty) {
      return EmptyView(message: '在場租頁面按下「☆」即可加入收藏');
    }
    return ListView.separated(
      itemBuilder: (context, idx) => _Row(details[idx]),
      separatorBuilder: (context, idx) => Divider(),
      itemCount: details.length,
    );
  }
}

class _Row extends StatelessWidget {
  final FavoriteGymDetail detail;
  Gym get gym => detail.gym;
  _Row(this.detail);

  void _showDetail(BuildContext context) {
    track(EventName.showGymDetail, {
      ...gym.trackingProps,
      EventProperties.distance: detail.meters,
      EventProperties.from: 'favorite list',
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GymDetailPage(gym: gym),
      ),
    );
  }

  void _remove(BuildContext context) async {
    final wantsRemove = await showDialog(
        context: context,
        builder: (context) {
          return AlertFactory.actionAlert(
            context,
            title: '是否要移除${gym.name}?',
            actions: [
              PlatformDialogAction(
                child: Text('移除'),
                onPressed: () {
                  Navigator.pop(context, true);
                },
              ),
            ],
          );
        });
    if (wantsRemove == null || !wantsRemove) {
      return;
    }
    AppBloc bloc = BlocProvider.of(context);
    bloc.favoriteGymList.delete(gym.id);
    track(EventName.removeBookmark, {
      ...gym.trackingProps,
      EventProperties.distance: detail.meters,
      EventProperties.from: 'favorite list',
    });
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
                                image: NetworkImage(gym.cover!),
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
                  SizedBox(width: 8),
                  _buildRemoveButton(context),
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
                      '(' + PriceFormat.format(gym.hourlyRate!) + '/小時)',
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

  Widget _buildRemoveButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        _remove(context);
      },
      child: Icon(Icons.delete),
      style: TextButton.styleFrom(
        primary: AppColors.theme,
        minimumSize: Size(44, 44),
      ),
    );
  }

  Widget _buildDistanceLable() {
    if (detail.meters == null) {
      return Container();
    }

    return Text(
      DistanceFormat.format(detail.meters!),
      style: TextStyles.small.subscription,
    );
  }

  Widget buildPricingTable(List<Fare>? fares) {
    String plans = '請電洽';
    if (fares != null && fares.isNotEmpty) {
      plans = fares.map((e) => FareFormat.format(e)).join('、');
    }
    return Text('計費方案：' + plans, style: TextStyles.small.detail);
  }
}
