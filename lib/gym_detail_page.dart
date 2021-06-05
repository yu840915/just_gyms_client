import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:where_gym/app_bar_factory.dart';
import 'package:where_gym/app_bloc.dart';
import 'package:where_gym/gym.dart';
import 'package:where_gym/map_view/open_hour_indicator.dart';
import 'package:where_gym/photo_gallery_view.dart';
import 'package:where_gym/price_format.dart';
import 'package:where_gym/shared_appearances.dart';
import 'package:where_gym/tracking/event_names.dart';
import 'package:where_gym/tracking/tracking.dart';

class GymDetailPage extends StatelessWidget {
  final Gym gym;
  GymDetailPage({@required this.gym});

  void _callGym(String phone) {
    track(EventName.contactGym, gym.trackingProps);
    launch('tel://$phone');
  }

  void _openPage(String link) {
    launch(link);
  }

  @override
  Widget build(BuildContext context) {
    AppBloc bloc = BlocProvider.of(context);
    return Scaffold(
      appBar: AppBarFactory.transparentAppBar(actions: [
        StreamBuilder<Object>(
            stream: bloc.favoriteGymList.onListUpdate,
            builder: (context, snapshot) {
              return _buildFavoriteButton(context);
            })
      ]),
      extendBodyBehindAppBar: true,
      body: _buildBody(context),
    );
  }

  Widget _buildFavoriteButton(BuildContext context) {
    AppBloc bloc = BlocProvider.of(context);
    final isFavorite = bloc.favoriteGymList.isFavorite(gym.id);
    return IconButton(
      onPressed: () {
        if (isFavorite) {
          bloc.favoriteGymList.delete(gym.id);
        } else {
          bloc.favoriteGymList.add(gym.id);
        }
      },
      icon: Icon(isFavorite ? SharedIcons.bookmarked : SharedIcons.bookmark),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 100),
          child: Column(
            children: [
              PhotoGalleryView(gym?.images ?? []),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildContents(context),
              ),
            ],
          ),
        ),
        if (gym.hasContactInfos) _buildActions(context),
      ],
    );
  }

  Widget _buildContents(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20),
        Text(
          gym.name,
          style: TextStyles.large.header,
        ),
        SizedBox(height: 20),
        Text('計價方案', style: TextStyles.large.title),
        _buildPricingRow(),
        SizedBox(height: 12),
        Text('今日營業時間', style: TextStyles.large.title),
        _buildBusinessHourRow(),
        SizedBox(height: 12),
        Text('地址', style: TextStyles.large.title),
        Text(gym.address, style: TextStyles.large.detail),
        SizedBox(height: 20),
        Text('器材', style: TextStyles.large.title),
        _buildEquipmentSection(),
        SizedBox(height: 12),
        Text('設施', style: TextStyles.large.title),
        _buildFacilitySection(),
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  Widget _buildPricingRow() {
    if (gym.pricing == null || gym.pricing.isEmpty) {
      return Text('請電洽');
    }
    if (gym.pricing.length == 1) {
      return _buildFareRow(null, gym.pricing.first);
    }
    final rows = List<Widget>.empty(growable: true);
    for (var i = 0; i < gym.pricing.length; i++) {
      rows.add(_buildFareRow(i + 1, gym.pricing[i]));
      rows.add(SizedBox(height: 4));
    }
    return Column(
      children: rows,
    );
  }

  Widget _buildFareRow(int bullet, Fare fare) {
    return Text(
      (bullet != null ? '$bullet. ' : '') + FareFormat.format(fare),
      style: TextStyles.large.detail,
    );
  }

  Widget _buildBusinessHourRow() {
    return Row(
      children: [
        OpenHourIndicator(gym: gym, styles: TextStyles.large),
        if (gym.isOpenNow() != null) ...[
          SizedBox(width: 8),
          _buildBusinessHourDetail(),
        ]
      ],
    );
  }

  Widget _buildBusinessHourDetail() {
    final today = gym.businessHoursOfToday();
    return Text(
      (gym.isOpenNow()
          ? '營業至 ${today.end.stringValue}'
          : '將於 ${today.start.stringValue} 開始營業'),
      style: TextStyles.large.detail.copyWith(color: Colors.grey),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        child: Column(
          children: [
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    if (gym.pageLink != null)
                      Expanded(child: _buildPageButton(gym.pageLink)),
                    if (gym.pageLink != null && gym.phone != null)
                      SizedBox(width: 12),
                    if (gym.phone != null)
                      Expanded(child: _buildReserveButton(gym.phone)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12),
          ],
          mainAxisSize: MainAxisSize.min,
        ),
        color: Colors.white,
      ),
    );
  }

  Widget _buildEquipmentSection() {
    if (gym.equipments == null || gym.equipments.isEmpty) {
      return Text('待加入', style: TextStyles.large.subscription);
    }
    return Text(
      gym.equipments.map((e) => '${e.name} * ${e.number}').join('、'),
      style: TextStyles.large.detail,
    );
  }

  Widget _buildFacilitySection() {
    if (gym.gymFacilities == null || gym.gymFacilities.isEmpty) {
      return Text('未提供', style: TextStyles.large.subscription);
    }
    return Text(
      gym.gymFacilities.map((e) => e.displayName).join('、'),
      style: TextStyles.large.detail,
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
    return OutlinedButton(
      onPressed: () => _callGym(phone),
      child: Text(
        '立即預約',
      ),
      style: ButtonStyles.action,
    );
  }
}
