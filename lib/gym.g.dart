// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gym.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Gym _$GymFromJson(Map<String, dynamic> json) {
  return Gym(
    id: json['id'] as String,
    name: json['name'] as String,
    address: json['address'] as String,
    lat: (json['lat'] as num)?.toDouble(),
    lon: (json['lon'] as num)?.toDouble(),
    equipments: (json['equipments'] as List)
        ?.map((e) =>
            e == null ? null : Equipments.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    businessHours: (json['businessHours'] as List)
        ?.map((e) => e == null
            ? null
            : BusinessHoursDescriptor.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    hourlyRate: json['hourlyRate'] == null
        ? null
        : Price.fromJson(json['hourlyRate'] as Map<String, dynamic>),
    phones: (json['phones'] as List)?.map((e) => e as String)?.toList(),
    pricing: (json['pricing'] as List)
        ?.map(
            (e) => e == null ? null : Fare.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    pageLink: json['pageLink'] as String,
  );
}

Map<String, dynamic> _$GymToJson(Gym instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'equipments': instance.equipments,
      'businessHours': instance.businessHours,
      'pricing': instance.pricing,
      'hourlyRate': instance.hourlyRate,
      'phones': instance.phones,
      'pageLink': instance.pageLink,
      'lat': instance.lat,
      'lon': instance.lon,
    };

Equipments _$EquipmentsFromJson(Map<String, dynamic> json) {
  return Equipments(
    typeId: json['typeId'] as int,
    name: json['name'] as String,
    number: json['number'] as int,
  );
}

Map<String, dynamic> _$EquipmentsToJson(Equipments instance) =>
    <String, dynamic>{
      'typeId': instance.typeId,
      'name': instance.name,
      'number': instance.number,
    };

Price _$PriceFromJson(Map<String, dynamic> json) {
  return Price(
    amount: json['amount'] as int,
    currency: json['currency'] as String,
  );
}

Map<String, dynamic> _$PriceToJson(Price instance) => <String, dynamic>{
      'amount': instance.amount,
      'currency': instance.currency,
    };

BusinessHoursDescriptor _$BusinessHoursDescriptorFromJson(
    Map<String, dynamic> json) {
  return BusinessHoursDescriptor(
    dayOfWeek: json['dayOfWeek'] as String,
    start: json['start'] as String,
    end: json['end'] as String,
  );
}

Map<String, dynamic> _$BusinessHoursDescriptorToJson(
        BusinessHoursDescriptor instance) =>
    <String, dynamic>{
      'dayOfWeek': instance.dayOfWeek,
      'start': instance.start,
      'end': instance.end,
    };

Fare _$FareFromJson(Map<String, dynamic> json) {
  return Fare(
    unit: json['unit'] as String,
    amount: json['amount'] as int,
    price: json['price'] == null
        ? null
        : Price.fromJson(json['price'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$FareToJson(Fare instance) => <String, dynamic>{
      'unit': instance.unit,
      'amount': instance.amount,
      'price': instance.price,
    };
