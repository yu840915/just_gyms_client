import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'profile.g.dart';

@JsonSerializable()
class MyProfile {
  final String name;

  MyProfile({required this.name});

  factory MyProfile.fromJson(Map<String, dynamic> json) =>
      _$MyProfileFromJson(json);
  static MyProfile? fromSnap(DocumentSnapshot<Object?> snap) =>
      snap.data() != null
          ? MyProfile.fromJson(snap.data() as Map<String, dynamic>)
          : null;
  Map<String, dynamic> toJson() => _$MyProfileToJson(this);
}
