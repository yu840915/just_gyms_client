import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geojson/geojson.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as GoogleMap;
import 'package:latlong/latlong.dart';
import 'package:rxdart/subjects.dart';
import 'package:where_gym/api_services/api_services.dart';
import 'package:where_gym/gym.dart';
import 'package:where_gym/gym_list.dart';

class GymMarkerList {
  final GoogleMap.GoogleMapController mapController;
  final _markersSubject = BehaviorSubject<List<GymMarker>>();
  final _displayableMarkersSubject =
      BehaviorSubject<List<DisplayableGymMarker>>()..add([]);
  final _selectedMarkerIdSubject = BehaviorSubject<String>();
  final _dirtySubject = BehaviorSubject<bool>();
  Stream<String> get onSelection => _selectedMarkerIdSubject;
  DisplayableGymMarker get selectedMarker {
    final selectedId = _selectedMarkerIdSubject.valueWrapper?.value;
    if (_displayableMarkersSubject.valueWrapper.value.isEmpty ||
        selectedId == null) {
      return null;
    }
    return _displayableMarkersSubject.valueWrapper.value.firstWhere(
      (element) => element.id == selectedId,
      orElse: () => null,
    );
  }

  String get selectedMarkerId => _selectedMarkerIdSubject.valueWrapper?.value;
  Stream<List<GymMarker>> get onMarkersChange => _markersSubject;
  Stream<List<DisplayableGymMarker>> get onDisplayableMarkersChange =>
      _displayableMarkersSubject;
  Stream<bool> get onIsDirty => _dirtySubject;
  MapDataRegion _currentRegion;
  int _zoomLevel;

  GymMarkerList(this.mapController) {
    _dirtySubject.add(true);
  }

  void dispose() {
    _markersSubject.close();
    _selectedMarkerIdSubject.close();
    _dirtySubject.close();
  }

  void markAsDirtyIfNeeded() async {
    if (_currentRegion == null) {
      _dirtySubject.add(true);
      return;
    }
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
      _dirtySubject.add(false);
    } else {
      _dirtySubject.add(true);
    }
  }

  Future<void> updateMarkerIfNeeded() async {
    if (!_dirtySubject.valueWrapper.value) {
      return;
    }
    _dirtySubject.add(false);
    final bounds = await mapController.getVisibleRegion();
    final zoom = (await mapController.getZoomLevel()).toInt();
    final lat = 0.5 * (bounds.northeast.latitude + bounds.southwest.latitude);
    final lon = 0.5 * (bounds.northeast.longitude + bounds.southwest.longitude);
    final dia = distanceGMap(bounds.northeast, bounds.southwest);
    try {
      await fetchMarkersForRegion(
        MapDataRegion(
            center: GoogleMap.LatLng(lat, lon), radiusInM: (0.5 * dia).toInt()),
      );
      _zoomLevel = zoom;
    } catch (e) {
      _dirtySubject.add(true);
    }
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
    if (_selectedMarkerIdSubject.valueWrapper?.value != null) {
      final missing = markers.indexWhere((element) =>
              element.id == _selectedMarkerIdSubject.valueWrapper.value) ==
          -1;
      if (missing) {
        _selectedMarkerIdSubject.add(null);
      }
    }
  }

  void insertDisplayableMarker(DisplayableGymMarker marker) {
    final missing = _markersSubject.valueWrapper.value.indexWhere(
          (element) => element.id == marker.id,
        ) ==
        -1;
    if (missing) {
      return;
    }
    final list = List<DisplayableGymMarker>.from(
        _displayableMarkersSubject.valueWrapper.value ?? []);
    list.add(marker);
    _displayableMarkersSubject.add(list);
  }

  void selecteMarker(DisplayableGymMarker marker) {
    if (marker == null) {
      _selectedMarkerIdSubject.add(null);
    } else if (_displayableMarkersSubject.valueWrapper.value.contains(marker)) {
      _selectedMarkerIdSubject.add(marker.id);
      _scrollToSelectionIfNeeded(marker);
    }
  }

  void _scrollToSelectionIfNeeded(DisplayableGymMarker marker) async {
    final bounds = await mapController.getVisibleRegion();
    if (!bounds.contains(marker.latLng)) {
      mapController
          .animateCamera(GoogleMap.CameraUpdate.newLatLng(marker.latLng));
    }
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
    return GoogleMap.Marker(
      markerId: GoogleMap.MarkerId(id),
      position: latLng,
    );
  }
}

class DisplayableGymMarker {
  GymMarker _gymMarker;

  String get id => _gymMarker.id;

  List<Gym> get gyms => _gymMarker.gyms;

  GoogleMap.LatLng get latLng => _gymMarker.latLng;
  final GoogleMap.BitmapDescriptor icon;
  final GoogleMap.BitmapDescriptor selectionIcon;

  DisplayableGymMarker({
    @required this.icon,
    @required this.selectionIcon,
    GymMarker marker,
  }) : _gymMarker = marker;

  GoogleMap.Marker getNormalMarker({Function onTap}) {
    final marker = _gymMarker.toMarker();
    return GoogleMap.Marker(
      markerId: marker.markerId,
      position: marker.position,
      icon: icon,
      alpha: 0.8,
      onTap: onTap,
    );
  }

  GoogleMap.Marker getSelectedMarker() {
    final marker = _gymMarker.toMarker();
    return GoogleMap.Marker(
      markerId: marker.markerId,
      position: marker.position,
      icon: selectionIcon,
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
