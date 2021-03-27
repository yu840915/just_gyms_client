import 'package:json_annotation/json_annotation.dart';
part 'gym.g.dart';

@JsonSerializable()
class Gym {
  final String id;
  final String name;
  final String address;
  final List<Equipments> equipments;
  final List<BusinessHours> businessHours;
  
  final Price hourlyRate;
  final List<String> phones;
  String get phone => phones != null && phones.isNotEmpty ? phones.first : null;
  Gym(
      {this.id,
      this.name,
      this.address,
      this.equipments,
      this.businessHours,
      this.hourlyRate,
      this.phones});

  Map<String, dynamic> toJson() => _$GymToJson(this);
  factory Gym.fromJson(Map<String, dynamic> json) => _$GymFromJson(json);
}

@JsonSerializable()
class Equipments {
  final int typeId;
  final String name;
  final int number;

  Equipments({this.typeId, this.name, this.number});
  factory Equipments.fromJson(Map<String, dynamic> json) =>
      _$EquipmentsFromJson(json);

  Map<String, dynamic> toJson() => _$EquipmentsToJson(this);
}

@JsonSerializable()
class Price {
  final int amount;
  final String currency;
  Price({this.amount, this.currency});

  Map<String, dynamic> toJson() => _$PriceToJson(this);

  factory Price.fromJson(Map<String, dynamic> json) => _$PriceFromJson(json);
}

@JsonSerializable()
class BusinessHours {
  final String start;
  final String end;
  BusinessHours({this.start, this.end});

  Map<String, dynamic> toJson() => _$BusinessHoursToJson(this);
  factory BusinessHours.fromJson(Map<String, dynamic> json) =>
      _$BusinessHoursFromJson(json);
}
