import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:where_gym/api_services/api_services.dart';
import 'package:where_gym/app_bloc.dart';
part 'location_search.g.dart';

class LocationSearch {
  final _querySubject = BehaviorSubject<String>();
  final _resultSubject = BehaviorSubject<AddressSearchResult>();
  final _taskSubject = BehaviorSubject<Future>();
  Stream<AddressSearchResult> get onResult => _resultSubject;
  StreamSubscription _subscription;
  Stream<Future> get onRunningTask => _taskSubject;
  final Function(AddressSearchResultItem) _onSelectAddress;
  final AppBloc appBloc;
  LocationSearch(
      {@required Function(AddressSearchResultItem) onSelectAddress,
      @required this.appBloc})
      : _onSelectAddress = onSelectAddress {
    _subscription =
        _querySubject.debounceTime(Duration(milliseconds: 300)).listen((event) {
      _startSearch(event);
    });
  }

  void selectAddress(AddressSearchResultItem item) {
    _onSelectAddress(item);
  }

  void dispose() {
    _subscription.cancel();
    _querySubject.close();
    _resultSubject.close();
    _taskSubject.close();
  }

  void updateQuery(String q) {
    _querySubject.add(q);
  }

  void _startSearch(String q) async {
    if (q == null || q.isEmpty) {
      return _resultSubject.add(null);
    }
    try {
      final getToken = appBloc.getIdToken();
      _taskSubject.add(getToken);
      final fetch = APIServices.instances.get('/geocode/search',
          params: {'q': q, 'country': 'TW'}, token: await getToken);
      _taskSubject.add(fetch);
      final res = await fetch;
      if (_querySubject != null && _querySubject.value != q) {
        return;
      }
      final List<AddressSearchResultItem> items = res.statusCode == 200
          ? List<Map>.from(jsonDecode(res.body))
              .map((e) => AddressSearchResultItem.fromJson(e))
              .toList()
          : [];
      _resultSubject.add(AddressSearchResult(items: items, query: q));
    } finally {
      _taskSubject.add(null);
    }
  }
}

class AddressSearchResult {
  final String query;
  final List<AddressSearchResultItem> items;
  AddressSearchResult({@required this.items, @required this.query});
}

@JsonSerializable()
class AddressSearchResultItem {
  final String address;
  final GMapGeometry geometry;

  AddressSearchResultItem({this.address, this.geometry});
  factory AddressSearchResultItem.fromJson(Map<String, dynamic> json) =>
      _$AddressSearchResultItemFromJson(json);
}

@JsonSerializable()
class GMapGeometry {
  final GMapCoordinate location;
  final String location_type;
  final GMapViewport viewport;

  GMapGeometry({this.location, this.location_type, this.viewport});

  factory GMapGeometry.fromJson(Map<String, dynamic> json) =>
      _$GMapGeometryFromJson(json);
}

@JsonSerializable()
class GMapViewport {
  final GMapCoordinate northeast;
  final GMapCoordinate southwest;

  GMapViewport({this.northeast, this.southwest});

  factory GMapViewport.fromJson(Map<String, dynamic> json) =>
      _$GMapViewportFromJson(json);
}

@JsonSerializable()
class GMapCoordinate {
  final num lat;
  final num lng;
  LatLng toLatLng() => LatLng(lat, lng);

  GMapCoordinate({this.lat, this.lng});
  factory GMapCoordinate.fromJson(Map<String, dynamic> json) =>
      _$GMapCoordinateFromJson(json);
}
