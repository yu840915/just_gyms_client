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
    equipments: (json['equipments'] as List)
        ?.map((e) =>
            e == null ? null : Equipments.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    businessHours: (json['businessHours'] as List)
        ?.map((e) => e == null
            ? null
            : BusinessHours.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    hourlyRate: json['hourlyRate'] == null
        ? null
        : Price.fromJson(json['hourlyRate'] as Map<String, dynamic>),
    phones: (json['phones'] as List)?.map((e) => e as String)?.toList(),
  );
}

Map<String, dynamic> _$GymToJson(Gym instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'equipments': instance.equipments,
      'businessHours': instance.businessHours,
      'hourlyRate': instance.hourlyRate,
      'phones': instance.phones,
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

BusinessHours _$BusinessHoursFromJson(Map<String, dynamic> json) {
  return BusinessHours(
    start: json['start'] as String,
    end: json['end'] as String,
  );
}

Map<String, dynamic> _$BusinessHoursToJson(BusinessHours instance) =>
    <String, dynamic>{
      'start': instance.start,
      'end': instance.end,
    };
