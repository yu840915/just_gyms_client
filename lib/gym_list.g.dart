// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gym_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
    start: json['start'] as int,
    end: json['end'] as int,
  );
}

Map<String, dynamic> _$BusinessHoursToJson(BusinessHours instance) =>
    <String, dynamic>{
      'start': instance.start,
      'end': instance.end,
    };
