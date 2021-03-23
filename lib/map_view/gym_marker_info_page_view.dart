import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:where_gym/gym_list.dart';
import 'package:where_gym/map_view/gym_marker_list.dart';
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
    gymMarkerList.selectedMarkerIdStream.listen((event) {
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

  void _callGym(String phone) {
    launch('tel://$phone');
  }

  void _showDetail(BuildContext context) {}

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ElevatedButton(
        clipBehavior: Clip.none,
        style: ButtonStyle(
          padding: MaterialStateProperty.all(EdgeInsets.all(10)),
          backgroundColor: MaterialStateProperty.all(Colors.white),
          overlayColor: MaterialStateProperty.all(Colors.grey.shade200),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        onPressed: () => _showDetail(context),
        child: Column(
          children: [
            Text(card.gym.name,
                style: TextStyles.title.copyWith(color: Colors.black)),
            Text(card.gym.address,
                style: TextStyles.detail.copyWith(color: Colors.black)),
            if (card.gym.hourlyRate != null)
              Text(
                  card.gym.hourlyRate.currency +
                      ' ${card.gym.hourlyRate.amount}',
                  style: TextStyles.detail.copyWith(color: Colors.black)),
            Spacer(),
            if (card.gym.phone != null) _buildContactButton(card.gym.phone)
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
