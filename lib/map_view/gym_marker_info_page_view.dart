import 'package:flutter/material.dart';
import 'package:where_gym/gym.dart';
import 'package:where_gym/gym_detail_page.dart';
import 'package:where_gym/map_view/gym_marker_list.dart';
import 'package:where_gym/map_view/open_hour_indicator.dart';
import 'package:where_gym/price_format.dart';
import 'package:where_gym/shared_appearances.dart';

class GymMarkerInfoPageView extends StatefulWidget {
  final GymMarkerList gymMarkerList;
  GymMarkerInfoPageView(this.gymMarkerList);

  @override
  _GymMarkerInfoPageViewState createState() => _GymMarkerInfoPageViewState();
}

class _GymMarkerInfoPageViewState extends State<GymMarkerInfoPageView> {
  GymMarkerList get gymMarkerList => widget.gymMarkerList;
  PageController pageController;
  List<DisplayableGymMarker> markers;

  @override
  void initState() {
    super.initState();
    gymMarkerList.onDisplayableMarkersChange.listen((event) {
      markers = event;
    });
    gymMarkerList.onSelection.listen((event) {
      _handleSelectionChanged(gymMarkerList.selectedMarker);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DisplayableGymMarker>>(
        stream: gymMarkerList.onDisplayableMarkersChange,
        builder: (context, snapshot) {
          return _buildCardViews(
              context, GymInfoCard.convertMarkersToCards(snapshot.data));
        });
  }

  Widget _buildCardViews(BuildContext context, List<GymInfoCard> cards) {
    if (cards == null) {
      return Container();
    }
    if (cards.length == 1) {
      return GymInfoCardView(cards.first);
    }
    return PageView.builder(
      controller: pageController,
      itemBuilder: (context, idx) => GymInfoCardView(cards[idx % cards.length]),
      onPageChanged: (idx) => {_handlePageChanged(cards[idx % cards.length])},
    );
  }

  void _handlePageChanged(GymInfoCard card) {
    gymMarkerList.selecteMarker(card.assosiatedMarker);
  }

  void _handleSelectionChanged(DisplayableGymMarker marker) {
    if (marker == null) {
      return;
    }
    if (markers == null) {
      return;
    }
    if (pageController == null) {
      _initPageControllerWithSelection(marker);
      return;
    }
    final currentIdx = pageController.page.toInt() % markers.length;
    final padding = pageController.page.toInt() - currentIdx;
    if (markers[currentIdx].id == marker.id) {
      return;
    }
    final newIdx = markers.indexWhere((element) => element.id == marker.id);
    pageController.animateToPage(
      newIdx + padding,
      duration: Duration(microseconds: 150),
      curve: Curves.linear,
    );
  }

  void _initPageControllerWithSelection(DisplayableGymMarker marker) {
    final idx = markers.indexWhere((element) => element.id == marker.id);
    pageController =
        PageController(initialPage: 1000 + idx, viewportFraction: 0.8);
  }
}

class GymInfoCardView extends StatelessWidget {
  final GymInfoCard card;
  GymInfoCardView(this.card);

  void _showDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GymDetailPage(gym: card.gym),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ElevatedButton(
        clipBehavior: Clip.none,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.all(10),
          primary: Colors.white,
          shadowColor: Colors.grey.shade200,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () => _showDetail(context),
        child: Column(
          children: [
            Text(
              card.gym.name,
              style: TextStyles.small.header,
            ),
            SizedBox(height: 8),
            Text(
              card.gym.address,
              style: TextStyles.small.detail,
            ),
            SizedBox(height: 8),
            OpenHourIndicator(gym: card.gym, styles: TextStyles.small),
            SizedBox(height: 12),
            Row(
              children: [
                buildPricingTable(card.gym.pricing),
                if (card.gym.hourlyRate != null)
                  Text(
                    '(' + PriceFormat.format(card.gym.hourlyRate) + '/小時)',
                    style: TextStyles.small.subscription,
                  ),
                Spacer(),
                // _buildDistanceLable(),
              ],
            ),
            Spacer(),
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
      ),
    );
  }

  // Widget _buildDistanceLable() {
  //   if (km == null) {
  //     return Container();
  //   }
  //   return Text(
  //     '距離 ${NumberFormats.distance.format(km)} 公里',
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

class GymInfoCard {
  final Gym gym;
  final DisplayableGymMarker assosiatedMarker;
  GymInfoCard({@required this.gym, @required this.assosiatedMarker});

  static List<GymInfoCard> convertMarkersToCards(
      List<DisplayableGymMarker> markers) {
    if (markers == null || markers.isEmpty) {
      return null;
    }
    return markers
        .map(_convertMarkerToCards)
        .reduce((value, element) => value..addAll(element));
  }

  static List<GymInfoCard> _convertMarkerToCards(DisplayableGymMarker marker) {
    return marker.gyms
        .map((e) => GymInfoCard(gym: e, assosiatedMarker: marker))
        .toList();
  }
}
