import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:where_gym/gym_list.dart';

class MapViewPage extends StatefulWidget {
  final GymList gymList;
  MapViewPage(this.gymList, {Key key});

  @override
  _MapViewPageState createState() => _MapViewPageState();
}

class _MapViewPageState extends State<MapViewPage> {
  Completer<GoogleMapController> _controller = Completer();
  GymList get gymList => widget.gymList;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(),
      body: StreamBuilder<Position>(
        stream: gymList.myLocationStream.take(1),
        builder: (context, snapshot) => _buildMapView(context, snapshot.data),
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: _goToTheLake,
      //   label: Text('To the lake!'),
      //   icon: Icon(Icons.directions_boat),
      // ),
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
        zoom: 14,
      ),
      minMaxZoomPreference: MinMaxZoomPreference(10, 20),
      myLocationEnabled: true,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
    );
  }
}
