import 'package:flutter/material.dart';
import 'package:where_gym/gym_list.dart';
import 'package:where_gym/map_view/gym_marker_list.dart';

class GymMarkerInfoPageView extends StatefulWidget {
  final GymMarkerList gymMarkerList;
  GymMarkerInfoPageView(this.gymMarkerList);

  @override
  _GymMarkerInfoPageViewState createState() => _GymMarkerInfoPageViewState();
}

class _GymMarkerInfoPageViewState extends State<GymMarkerInfoPageView> {
  PageController pageController;
  Stream<List<GymInfoCard>> markersStream;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: 999, viewportFraction: 0.8);
    markersStream = widget.gymMarkerList.displayableMarkersStream
        .map((e) => GymInfoCard.convertMarkersToCards(e));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DisplayableGymMarker>>(
        stream: widget.gymMarkerList.displayableMarkersStream,
        builder: (context, snapshot) {
          return _buildCardViews(
              context, GymInfoCard.convertMarkersToCards(snapshot.data));
        });
  }

  Widget _buildCardViews(BuildContext context, List<GymInfoCard> cards) {
    if (cards == null) {
      return Container();
    }
    return PageView.builder(
        itemBuilder: (context, idx) =>
            GymInfoCardView(cards[idx % cards.length]));
  }
}

class GymInfoCardView extends StatelessWidget {
  final GymInfoCard card;
  GymInfoCardView(this.card);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text(card.gym.name),
          Text(card.gym.address),
          if (card.gym.hourlyRate != null)
            Text(card.gym.hourlyRate.currency +
                ' ${card.gym.hourlyRate.amount}'),
          _buildEquipments()
        ],
      ),
    );
  }

  Widget _buildEquipments() {
    return Text(card.gym.equipments
        .map((e) => e.name + 'x' + '${e.number}')
        .toList()
        .join(", "));
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
