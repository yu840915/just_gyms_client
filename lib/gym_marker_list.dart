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
  final _displayableMarkersSubject =
      BehaviorSubject<List<DisplayableGymMarker>>();
  Stream<List<GymMarker>> get markerStream => _markersSubject;
  Stream<List<DisplayableGymMarker>> get displayableMarkersStream =>
      _displayableMarkersSubject;
  MapDataRegion _currentRegion;
  int _zoomLevel;

  GymMarkerList(this.mapController);

  void dispose() {
    _markersSubject.close();
  }

  Future<void> updateMarkerIfNeeded() async {
    final bounds = await mapController.getVisibleRegion();
    final zoom = (await mapController.getZoomLevel()).toInt();
    final lat = 0.5 * (bounds.northeast.latitude + bounds.southwest.latitude);
    final lon = 0.5 * (bounds.northeast.longitude + bounds.southwest.longitude);
    final dia = distanceGMap(bounds.northeast, bounds.southwest);
    if (_zoomLevel == zoom &&
        _currentRegion != null &&
        _currentRegion.includesRegion(MapDataRegion(
            center: GoogleMap.LatLng(lat, lon),
            radiusInM: (0.25 * dia).toInt()))) {
      return;
    }
    await fetchMarkersForRegion(
      MapDataRegion(
          center: GoogleMap.LatLng(lat, lon), radiusInM: (0.5 * dia).toInt()),
    );
    _zoomLevel = zoom;
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
    _displayableMarkersSubject.add([]);
  }

  void insertDisplayableMarker(DisplayableGymMarker marker) {
    final missing = _markersSubject.value.indexWhere(
          (element) => element.id == marker.id,
        ) ==
        -1;
    if (missing) {
      return;
    }
    final list =
        List<DisplayableGymMarker>.from(_displayableMarkersSubject.value ?? []);
    list.add(marker);
    _displayableMarkersSubject.add(list);
  }
}

class GymMarker {
  final String id;
  final GoogleMap.LatLng latLng;
  final List<Gym> gyms;

  GymMarker({@required this.latLng, @required this.gyms})
      : id = gyms.first.id + '-${gyms.length}';

  static Future<GymMarker> fromMarkerFeature(
      GeoJsonFeature<GeoJsonPoint> feature) async {
    final latLng = feature.geometry.geoPoint.toLatLng();
    final collection =
        await featuresFromGeoJson(jsonEncode(feature.properties));
    final gyms =
        collection.collection.map((e) => Gym.fromJson(e.properties)).toList();
    return GymMarker(latLng: latlongToGMap(latLng), gyms: gyms);
  }

  GoogleMap.Marker toMarker() {
    GoogleMap.InfoWindow infoWindow;
    if (gyms.length == 1) {
      infoWindow = GoogleMap.InfoWindow(
        title: gyms.first.name,
        snippet: gyms.first.address,
      );
    } else {
      infoWindow = GoogleMap.InfoWindow(
        title: '${gyms.length} 項結果',
      );
    }
    return GoogleMap.Marker(
      markerId: GoogleMap.MarkerId(id),
      position: latLng,
      infoWindow: infoWindow,
    );
  }
}

class DisplayableGymMarker {
  GymMarker _gymMarker;

  String get id => _gymMarker.id;

  List<Gym> get gyms => _gymMarker.gyms;

  GoogleMap.LatLng get latLng => _gymMarker.latLng;
  final GoogleMap.BitmapDescriptor icon;

  DisplayableGymMarker({this.icon, GymMarker marker}) : _gymMarker = marker;

  GoogleMap.Marker toMarker() {
    final marker = _gymMarker.toMarker();

    return GoogleMap.Marker(
      markerId: marker.markerId,
      position: marker.position,
      infoWindow: marker.infoWindow,
      icon: icon,
    );
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
    final d = distanceGMap(this.center, region.center);
    return d + region.radiusInM < this.radiusInM;
  }
}

num distanceGMap(GoogleMap.LatLng p1, GoogleMap.LatLng p2) {
  return distanceLatLong(gMapToLatlong(p1), gMapToLatlong(p2));
}

num distanceLatLong(LatLng p1, LatLng p2) {
  return Distance().distance(p1, p2);
}

LatLng gMapToLatlong(GoogleMap.LatLng latLng) =>
    LatLng(latLng.latitude, latLng.longitude);

GoogleMap.LatLng latlongToGMap(LatLng latLng) =>
    GoogleMap.LatLng(latLng.latitude, latLng.longitude);
