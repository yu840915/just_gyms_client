import 'dart:ui';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:where_gym/gym_list.dart';
import 'package:where_gym/map_view/gym_marker_list.dart';
import 'package:where_gym/shared_appearances.dart';

class GymMarkerImageMakerContainers extends StatelessWidget {
  final GymMarkerList gymMarkerList;
  GymMarkerImageMakerContainers(this.gymMarkerList);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: StreamBuilder<List<GymMarker>>(
        stream: gymMarkerList.markerStream,
        builder: (context, snapshot) {
          return _buildMarkerMakers(context, snapshot.data);
        },
      ),
    );
  }

  Widget _buildMarkerMakers(BuildContext context, List<GymMarker> list) {
    if (list == null) {
      return Container();
    }
    return Stack(
      children: list
          .map((e) =>
              GymMarkerImageMaker(gymMarker: e, gymMarkerList: gymMarkerList))
          .toList(),
    );
  }
}

class GymMarkerImageMaker extends StatefulWidget {
  final GymMarkerList gymMarkerList;
  final GymMarker gymMarker;

  GymMarkerImageMaker({@required this.gymMarker, @required this.gymMarkerList})
      : super(key: Key(gymMarker.id));
  @override
  _GymMarkerImageMakerState createState() => _GymMarkerImageMakerState();
}

class _GymMarkerImageMakerState extends State<GymMarkerImageMaker>
    with AfterLayoutMixin<GymMarkerImageMaker> {
  final GlobalKey iconKey = GlobalKey();
  GymMarker get gymMarker => widget.gymMarker;

  @override
  void afterFirstLayout(BuildContext context) async {
    RenderRepaintBoundary boundary = iconKey.currentContext.findRenderObject();
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    final pngBytes = byteData.buffer.asUint8List();
    widget.gymMarkerList.insertDisplayableMarker(
      DisplayableGymMarker(
        icon: BitmapDescriptor.fromBytes(pngBytes),
        marker: widget.gymMarker,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: iconKey,
      child: _buildMarkerContent(),
    );
  }

  Widget _buildMarkerContent() {
    return Container(
      child: gymMarker.gyms.length == 1
          ? _buildMarkerContentForGym(gymMarker.gyms.first)
          : _buildMarkerContentForCollection(gymMarker.gyms),
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.theme,
        border: Border.all(color: Colors.green.shade900),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildMarkerContentForCollection(List<Gym> list) {
    return Text(
      '${list.length} 項結果',
      style: TextStyle(
        color: Colors.green.shade900,
        fontSize: 12,
      ),
    );
  }

  Widget _buildMarkerContentForGym(Gym gym) {
    if (gym.hourlyRate == null) {
      return Text(
        '1 項結果',
        style: TextStyle(
          color: Colors.green.shade900,
          fontSize: 12,
        ),
      );
    }
    return Text(
      '${gym.hourlyRate.currency} ${gym.hourlyRate.amount}',
      style: TextStyle(
        color: Colors.green.shade900,
        fontSize: 12,
      ),
    );
  }
}
