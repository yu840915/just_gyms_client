import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:where_gym/gym.dart';
import 'package:where_gym/map_view/gym_marker_list.dart';
import 'package:where_gym/price_format.dart';
import 'package:where_gym/shared_appearances.dart';

class GymMarkerImageMakerContainers extends StatelessWidget {
  final GymMarkerList? gymMarkerList;
  GymMarkerImageMakerContainers(this.gymMarkerList);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Material(
        child: StreamBuilder<List<GymMarker>>(
          stream: gymMarkerList!.onMarkersChange,
          builder: (context, listSnapshot) {
            return _buildMarkerMakers(context, listSnapshot.data);
          },
        ),
        color: Colors.transparent,
      ),
    );
  }

  Widget _buildMarkerMakers(BuildContext context, List<GymMarker>? list) {
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
  final GymMarkerList? gymMarkerList;
  final GymMarker gymMarker;

  GymMarkerImageMaker({required this.gymMarker, required this.gymMarkerList})
      : super(key: Key(gymMarker.id));
  @override
  _GymMarkerImageMakerState createState() => _GymMarkerImageMakerState();
}

class _GymMarkerImageMakerState extends State<GymMarkerImageMaker>
    with AfterLayoutMixin<GymMarkerImageMaker> {
  late ScreenshotController normalController;
  late ScreenshotController selectionController;
  late ScreenshotController markedSelectionController;
  late ScreenshotController markedNormalController;
  final normalStyle = TextStyle(
    color: Colors.white,
    fontSize: 12,
  );
  final selectionStyle =
      TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600);
  GymMarker get gymMarker => widget.gymMarker;

  @override
  void initState() {
    super.initState();
    normalController = ScreenshotController();
    selectionController = ScreenshotController();
    markedSelectionController = ScreenshotController();
    markedNormalController = ScreenshotController();
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    final normalIcon = await normalController.capture();
    final selectionIcon = await selectionController.capture();
    final markedNormalIcon = await markedNormalController.capture();
    final markedSelectionIcon = await markedSelectionController.capture();
    widget.gymMarkerList!.insertDisplayableMarker(
      DisplayableGymMarker(
        icon: BitmapDescriptor.fromBytes(normalIcon!),
        selectionIcon: BitmapDescriptor.fromBytes(selectionIcon!),
        markedIcon: BitmapDescriptor.fromBytes(markedNormalIcon!),
        markedSelectionIcon: BitmapDescriptor.fromBytes(markedSelectionIcon!),
        marker: widget.gymMarker,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Screenshot(
          controller: selectionController,
          child: _buildSelectionIcon(Key('selected'), false),
        ),
        Screenshot(
          controller: normalController,
          child: _buildNormalIcon(Key('normal'), false),
        ),
        Screenshot(
          controller: markedSelectionController,
          child: _buildSelectionIcon(Key('marked_selected'), true),
        ),
        Screenshot(
          controller: markedNormalController,
          child: _buildNormalIcon(Key('marked_normal'), true),
        ),
      ],
    );
  }

  Widget _buildNormalIcon(Key key, bool marked) {
    return Container(
      key: key,
      child: gymMarker.gyms.length == 1
          ? _buildMarkerContentForGym(gymMarker.gyms.first, normalStyle, marked)
          : _buildMarkerContentForCollection(gymMarker.gyms, normalStyle),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.theme,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildSelectionIcon(Key key, bool marked) {
    return Container(
      key: key,
      child: gymMarker.gyms.length == 1
          ? _buildMarkerContentForGym(
              gymMarker.gyms.first, selectionStyle, marked)
          : _buildMarkerContentForCollection(gymMarker.gyms, selectionStyle),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.theme,
        border: Border.all(color: Colors.green.shade900, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildMarkerContentForCollection(List<Gym> list, TextStyle textStyle) {
    return Text('${list.length} 項結果', style: textStyle);
  }

  Widget _buildMarkerContentForGym(Gym gym, TextStyle textStyle, bool marked) {
    Text text = Text('請電洽', style: textStyle);
    if (gym.pricing != null && gym.pricing!.isNotEmpty) {
      text = Text(PriceFormat.format(gym.hourlyRate!), style: textStyle);
    }
    if (!marked) {
      return text;
    }
    return Row(
      children: [
        Icon(
          SharedIcons.bookmarked,
          color: Colors.white,
          size: 12,
        ),
        SizedBox(width: 4),
        text
      ],
      mainAxisSize: MainAxisSize.min,
    );
  }
}
