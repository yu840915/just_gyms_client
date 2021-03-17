import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:where_gym/gym_list.dart';
import 'package:where_gym/gym_marker_image_maker.dart';
import 'package:where_gym/gym_marker_list.dart';

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
  List<DisplayableGymMarker> _markers = [];

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
          appBar: AppBar(),
          body: StreamBuilder<Position>(
            stream: gymList.myLocationStream.take(1),
            builder: (context, snapshot) =>
                _buildMapView(context, snapshot.data),
          ),          
        ),
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
      markers: _markers.map((e) => e.toMarker()).toSet(),
      onCameraIdle: () {
        markerList.updateMarkerIfNeeded();
      },
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
        _prepareMarkerList(controller);
      },
    );
  }

  void _prepareMarkerList(GoogleMapController controller) {
    markerList = GymMarkerList(controller);
    markerList.displayableMarkersStream.listen((event) {
      setState(() {
        _markers = event ?? [];
      });
    });
  }
}
