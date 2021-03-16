import 'dart:ui';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:where_gym/gym_marker_list.dart';

class GymMarkerImageMakerContainers extends StatelessWidget {
  final GymMarkerList gymMarkerList;
  GymMarkerImageMakerContainers(this.gymMarkerList);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<GymMarker>>(
      stream: gymMarkerList.markerStream,
      builder: (context, snapshot) {
        return _buildMarkerMakers(context, snapshot.data);
      },
    );
  }

  Widget _buildMarkerMakers(BuildContext context, List<GymMarker> list) {
    if (list == null) {
      return Container();
    }
    return GridView.count(
      crossAxisCount: 10,
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
      height: 30,
      width: 30,
      color: Colors.red,
    );
  }
}
