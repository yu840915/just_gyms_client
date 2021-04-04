import 'dart:ui';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:where_gym/gym.dart';
import 'package:where_gym/map_view/gym_marker_list.dart';
import 'package:where_gym/price_format.dart';
import 'package:where_gym/shared_appearances.dart';

class GymMarkerImageMakerContainers extends StatelessWidget {
  final GymMarkerList gymMarkerList;
  GymMarkerImageMakerContainers(this.gymMarkerList);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Material(
        child: StreamBuilder<List<GymMarker>>(
          stream: gymMarkerList.onMarkersChange,
          builder: (context, snapshot) {
            return _buildMarkerMakers(context, snapshot.data);
          },
        ),
        color: Colors.transparent,
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
  final GlobalKey normalKey = GlobalKey();
  final GlobalKey selectionKey = GlobalKey();
  GymMarker get gymMarker => widget.gymMarker;

  @override
  void afterFirstLayout(BuildContext context) async {
    widget.gymMarkerList.insertDisplayableMarker(
      DisplayableGymMarker(
        icon: await _getBitmapDescriptorFromRenderObjser(
          normalKey.currentContext.findRenderObject(),
        ),
        selectionIcon: await _getBitmapDescriptorFromRenderObjser(
          selectionKey.currentContext.findRenderObject(),
        ),
        marker: widget.gymMarker,
      ),
    );
  }

  Future<BitmapDescriptor> _getBitmapDescriptorFromRenderObjser(
      RenderRepaintBoundary boundary) async {
    RenderRepaintBoundary boundary =
        normalKey.currentContext.findRenderObject();
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    final pngBytes = byteData.buffer.asUint8List();
    return BitmapDescriptor.fromBytes(pngBytes);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RepaintBoundary(
          key: selectionKey,
          child: _buildSelectionIcon(Key('selected')),
        ),
        RepaintBoundary(
          key: normalKey,
          child: _buildNormalIcon(Key('normal')),
        ),
      ],
    );
  }

  Widget _buildNormalIcon(Key key) {
    return Container(
      key: key,
      child: gymMarker.gyms.length == 1
          ? _buildMarkerContentForGym(gymMarker.gyms.first)
          : _buildMarkerContentForCollection(gymMarker.gyms),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.theme,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildSelectionIcon(Key key) {
    return Container(
      key: key,
      child: gymMarker.gyms.length == 1
          ? _buildMarkerContentForGym(gymMarker.gyms.first)
          : _buildMarkerContentForCollection(gymMarker.gyms),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red,
        border: Border.all(color: Colors.red.shade900),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildMarkerContentForCollection(List<Gym> list) {
    return Text(
      '${list.length} 項結果',
      style: TextStyle(
        color: Colors.white,
        fontSize: 12,
      ),
    );
  }

  Widget _buildMarkerContentForGym(Gym gym) {
    if (gym.pricing == null || gym.pricing.isEmpty) {
      return Text(
        '請電洽',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      );
    }
    return Text(
      PriceFormat.format(gym.hourlyRate),
      style: TextStyle(
        color: Colors.white,
        fontSize: 12,
      ),
    );
  }
}
