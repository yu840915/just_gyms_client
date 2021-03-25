import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:where_gym/app_bar_factory.dart';
import 'package:where_gym/gym_list.dart';
import 'package:where_gym/gym_list_page.dart';
import 'package:where_gym/map_view/gym_marker_image_maker.dart';
import 'package:where_gym/map_view/gym_marker_info_page_view.dart';
import 'package:where_gym/map_view/gym_marker_list.dart';
import 'package:where_gym/shared_appearances.dart';

class MapViewPage extends StatefulWidget {
  final GymList gymList;
  MapViewPage(this.gymList, {Key key});

  @override
  _MapViewPageState createState() => _MapViewPageState();
}

class _MapViewPageState extends State<MapViewPage> {
  Completer<GoogleMapController> _controller = Completer();
  GymList get gymList => widget.gymList;
  GymMarkerList markerList;
  PersistentBottomSheetController bottomSheetController;
  List<DisplayableGymMarker> _markers = [];
  bool needsInitialFetch = true;

  void _handleMarkerSelection(BuildContext context, String selection) async {
    if (selection == null) {
      bottomSheetController?.close();
      return;
    }
    if (bottomSheetController != null) {
      return;
    }
    bottomSheetController = Scaffold.of(context).showBottomSheet(
      (context) => SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: GymMarkerInfoPageView(markerList),
          height: 200,
          clipBehavior: Clip.none,
        ),
      ),
      backgroundColor: Colors.transparent,
    );
    await bottomSheetController.closed;
    bottomSheetController = null;
  }

  void _showListView(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GymListPage(),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (markerList != null) GymMarkerImageMakerContainers(markerList),
        new Scaffold(
          appBar: AppBarFactory.shrinkedAppBar(),
          body: _buildBody(context),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return Stack(
      children: [
        StreamBuilder<Position>(
          stream: gymList.myLocationStream.take(1),
          builder: (context, snapshot) => _buildMapView(context, snapshot.data),
        ),
        SafeArea(bottom: false, child: _buildOverlay(context)),
      ],
    );
  }

  Widget _buildOverlay(BuildContext context) {
    return Column(
      children: [
        _buildTopBar(context),
        SizedBox(height: 10),
        if (markerList != null)
          StreamBuilder<bool>(
            stream: markerList.onIsDirty,
            builder: (context, snapshot) {
              return _buildRefreshButton(
                  context, snapshot.hasData ? snapshot.data : false);
            },
          ),
        Spacer(),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 16),
        ElevatedButton(
          child: Icon(
            Icons.list,
            color: AppColors.theme,
          ),
          style: ElevatedButton.styleFrom(
            shape: StadiumBorder(),
            primary: Colors.white,
            
            minimumSize: Size.square(40),
          ),
          onPressed: () => _showListView(context),
        ),
        Spacer(),
        SizedBox(width: 16),
      ],
    );
  }

  Widget _buildMapView(BuildContext context, Position position) {
    if (position == null) {
      return Container();
    }
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 15,
      ),
      minMaxZoomPreference: MinMaxZoomPreference(10, 20),
      myLocationEnabled: true,
      markers:
          _markers.map((e) => e.toMarker(onTap: () => _onMarkerTap(e))).toSet(),
      onCameraIdle: () {
        markerList.markAsDirtyIfNeeded();
        if (needsInitialFetch) {
          needsInitialFetch = false;
          markerList.updateMarkerIfNeeded();
        }
      },
      onMapCreated: (GoogleMapController controller) {
        if (!_controller.isCompleted) {
          _controller.complete(controller);
        }
        _prepareMarkerList(context, controller);
      },
    );
  }

  Widget _buildRefreshButton(BuildContext context, bool isDirty) {
    if (!isDirty) {
      return Container();
    }
    return Align(
      alignment: Alignment.topCenter,
      child: TextButton(
        onPressed: () => {markerList.updateMarkerIfNeeded()},
        child: Text('搜尋此處的場館'),
        style: TextButton.styleFrom(
          primary: AppColors.theme,
          backgroundColor: Colors.white,
          textStyle: TextStyles.actionSmall,
          shape: StadiumBorder(),
          elevation: 1,
        ),
      ),
    );
  }

  void _prepareMarkerList(
      BuildContext context, GoogleMapController controller) {
    final list = GymMarkerList(controller);
    list.selectedMarkerIdStream.listen((event) {
      _handleMarkerSelection(context, event);
    });
    setState(() {
      markerList = list;
    });
    markerList.onDisplayableMarkersChange.listen((event) {
      setState(() {
        _markers = event ?? [];
      });
    });
  }

  void _onMarkerTap(DisplayableGymMarker marker) {
    markerList.selecteMarker(marker);
  }
}
