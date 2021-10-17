import 'dart:convert';
import 'dart:async';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geojson/geojson.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as GoogleMap;
import 'package:rxdart/subjects.dart';
import 'package:where_gym/api_services/api_services.dart';
import 'package:where_gym/app_bloc.dart';
import 'package:where_gym/gym.dart';

class GymMarkerList {
  final GoogleMap.GoogleMapController mapController;
  final _markersSubject = BehaviorSubject<List<GymMarker>>();
  final _displayableMarkersSubject =
      BehaviorSubject<List<DisplayableGymMarker>>()..add([]);
  final _selectedMarkerIdSubject = BehaviorSubject<String?>();
  final _dirtySubject = BehaviorSubject<bool>();
  Stream<String?> get onSelection => _selectedMarkerIdSubject;
  DisplayableGymMarker? get selectedMarker {
    final selectedId = _selectedMarkerIdSubject.valueOrNull;
    if (_displayableMarkersSubject.valueOrNull?.isEmpty == true ||
        selectedId == null) {
      return null;
    }
    return _displayableMarkersSubject.valueOrNull?.firstWhereOrNull(
      (element) => element.id == selectedId,
    );
  }

  String? get selectedMarkerId => _selectedMarkerIdSubject.valueOrNull;
  Stream<List<GymMarker>> get onMarkersChange => _markersSubject;
  Stream<List<DisplayableGymMarker>> get onDisplayableMarkersChange =>
      _displayableMarkersSubject;
  Stream<bool> get onIsDirty => _dirtySubject;
  MapDataRegion? _currentRegion;
  int? _zoomLevel;

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
        _currentRegion!.includesRegion(MapDataRegion(
            center: GoogleMap.LatLng(lat, lon),
            radiusInM: (0.25 * dia).toInt()))) {
      _dirtySubject.add(false);
    } else {
      _dirtySubject.add(true);
    }
  }

  Future<void> updateMarkerIfNeeded() async {
    if (_dirtySubject.valueOrNull == null || !_dirtySubject.value) {
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
      root.collection.map((e) async => await GymMarker.fromMarkerFeature(
          e as GeoJsonFeature<GeoJsonPoint?>)),
    );
    _currentRegion = region;
    _markersSubject.add(markers);
    _displayableMarkersSubject.add([]);
    if (_selectedMarkerIdSubject.valueOrNull != null) {
      final missing = markers.indexWhere(
              (element) => element.id == _selectedMarkerIdSubject.value) ==
          -1;
      if (missing) {
        _selectedMarkerIdSubject.add(null);
      }
    }
  }

  void insertDisplayableMarker(DisplayableGymMarker marker) {
    final missing = _markersSubject.value.indexWhere(
          (element) => element.id == marker.id,
        ) ==
        -1;
    if (missing) {
      return;
    }
    final list = List<DisplayableGymMarker>.from(
        _displayableMarkersSubject.valueOrNull ?? []);
    list.add(marker);
    _displayableMarkersSubject.add(list);
  }

  void selecteMarker(DisplayableGymMarker marker) {
    if (_displayableMarkersSubject.value.contains(marker)) {
      _selectedMarkerIdSubject.add(marker.id);
      _scrollToSelectionIfNeeded(marker);
    } else {
      _selectedMarkerIdSubject.add(null);
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

  GymMarker({required this.latLng, required this.gyms})
      : id = gyms.first.id! + '-${gyms.length}';

  static Future<GymMarker> fromMarkerFeature(
      GeoJsonFeature<GeoJsonPoint?> feature) async {
    final pt = feature.geometry!.geoPoint;
    final collection =
        await featuresFromGeoJson(jsonEncode(feature.properties));
    final gyms =
        collection.collection.map((e) => Gym.fromJson(e.properties!)).toList();
    return GymMarker(
        latLng: GoogleMap.LatLng(pt.latitude, pt.longitude), gyms: gyms);
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
  final GoogleMap.BitmapDescriptor markedIcon;
  final GoogleMap.BitmapDescriptor markedSelectionIcon;

  DisplayableGymMarker({
    required this.icon,
    required this.selectionIcon,
    required this.markedIcon,
    required this.markedSelectionIcon,
    required GymMarker marker,
  }) : _gymMarker = marker;

  GoogleMap.Marker getNormalMarker(BuildContext context, {Function? onTap}) {
    final marker = _gymMarker.toMarker();
    return GoogleMap.Marker(
      zIndex: 1,
      markerId: marker.markerId,
      position: marker.position,
      icon: _isFavorite(context) ? markedIcon : icon,
      alpha: 0.8,
      onTap: onTap as void Function()?,
    );
  }

  bool _isFavorite(BuildContext context) {
    if (gyms.length == 1) {
      AppBloc bloc = BlocProvider.of(context);
      return bloc.favoriteGymList.isFavorite(gyms.first.id);
    }
    return false;
  }

  GoogleMap.Marker getSelectedMarker(BuildContext context) {
    final marker = _gymMarker.toMarker();
    return GoogleMap.Marker(
      zIndex: 100,
      markerId: marker.markerId,
      position: marker.position,
      icon: _isFavorite(context) ? markedSelectionIcon : selectionIcon,
    );
  }
}

class MapDataRegion {
  final GoogleMap.LatLng center;
  final int radiusInM;
  MapDataRegion({required this.center, required this.radiusInM});

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
  return Geolocator.distanceBetween(
      p1.latitude, p1.longitude, p2.latitude, p2.longitude);
}
