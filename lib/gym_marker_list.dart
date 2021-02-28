import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geojson/geojson.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as GoogleMap;
import 'package:latlong/latlong.dart';
import 'package:rxdart/subjects.dart';
import 'package:where_gym/api_services/api_services.dart';
import 'package:where_gym/gym_list.dart';

class GymMarkerList {
  final GoogleMap.GoogleMapController mapController;
  final _markersSubject = BehaviorSubject<List<GymMarker>>();
  MapDataRegion _currentRegion;
  GymMarkerList(this.mapController);

  void dispose() {
    _markersSubject.close();
  }

  Future<void> fetchMarkersForRegion(MapDataRegion region) async {
    final res = await APIServices.instances.get('/gyms/markers', params: {
      'lat': '${region.center.latitude}',
      'lon': '${region.center.longitude}',
      'd': '${region.radiusInM}'
    });
    final root = await featuresFromGeoJson(res.body);
    final markers = await Future.wait(
      root.collection.map((e) async => await GymMarker.fromMarkerFeature(e)),
    );
    _currentRegion = region;
    _markersSubject.add(markers);
    print(markers);
  }
}

class GymMarker {
  final GoogleMap.LatLng latLng;
  final List<Gym> gyms;
  GymMarker({@required this.latLng, @required this.gyms});

  static Future<GymMarker> fromMarkerFeature(
      GeoJsonFeature<GeoJsonPoint> feature) async {
    final latLng = feature.geometry.geoPoint.toLatLng();
    final collection =
        await featuresFromGeoJson(jsonEncode(feature.properties));
    final gyms =
        collection.collection.map((e) => Gym.fromJson(e.properties)).toList();
    return GymMarker(latLng: latlongToGMap(latLng), gyms: gyms);
  }
}

class MapDataRegion {
  final GoogleMap.LatLng center;
  final int radiusInM;
  MapDataRegion({@required this.center, @required this.radiusInM});

  bool includesRegion(MapDataRegion region) {
    if (region.radiusInM > this.radiusInM) {
      return false;
    }
    if (region.radiusInM == this.radiusInM) {
      return this.center.latitude == region.center.latitude &&
          this.center.longitude == region.center.longitude;
    }
    final d = Distance()
        .distance(gMapToLatlong(this.center), gMapToLatlong(region.center));
    return d + region.radiusInM < this.radiusInM;
  }
}

LatLng gMapToLatlong(GoogleMap.LatLng latLng) =>
    LatLng(latLng.latitude, latLng.longitude);

GoogleMap.LatLng latlongToGMap(LatLng latLng) =>
    GoogleMap.LatLng(latLng.latitude, latLng.longitude);
