// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_search.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddressSearchResultItem _$AddressSearchResultItemFromJson(
        Map<String, dynamic> json) =>
    AddressSearchResultItem(
      address: json['address'] as String?,
      geometry: json['geometry'] == null
          ? null
          : GMapGeometry.fromJson(json['geometry'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AddressSearchResultItemToJson(
        AddressSearchResultItem instance) =>
    <String, dynamic>{
      'address': instance.address,
      'geometry': instance.geometry,
    };

GMapGeometry _$GMapGeometryFromJson(Map<String, dynamic> json) => GMapGeometry(
      location: json['location'] == null
          ? null
          : GMapCoordinate.fromJson(json['location'] as Map<String, dynamic>),
      location_type: json['location_type'] as String?,
      viewport: json['viewport'] == null
          ? null
          : GMapViewport.fromJson(json['viewport'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GMapGeometryToJson(GMapGeometry instance) =>
    <String, dynamic>{
      'location': instance.location,
      'location_type': instance.location_type,
      'viewport': instance.viewport,
    };

GMapViewport _$GMapViewportFromJson(Map<String, dynamic> json) => GMapViewport(
      northeast: json['northeast'] == null
          ? null
          : GMapCoordinate.fromJson(json['northeast'] as Map<String, dynamic>),
      southwest: json['southwest'] == null
          ? null
          : GMapCoordinate.fromJson(json['southwest'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GMapViewportToJson(GMapViewport instance) =>
    <String, dynamic>{
      'northeast': instance.northeast,
      'southwest': instance.southwest,
    };

GMapCoordinate _$GMapCoordinateFromJson(Map<String, dynamic> json) =>
    GMapCoordinate(
      lat: json['lat'] as num?,
      lng: json['lng'] as num?,
    );

Map<String, dynamic> _$GMapCoordinateToJson(GMapCoordinate instance) =>
    <String, dynamic>{
      'lat': instance.lat,
      'lng': instance.lng,
    };
