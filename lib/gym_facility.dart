import 'package:flutter/material.dart';

class GymFacility {
  final String id;
  final String displayName;

  GymFacility._({required this.id, required this.displayName});

  static final table = {
    'changingRoom': GymFacility._(id: 'changingRoom', displayName: '更衣室'),
    'toilet': GymFacility._(id: 'toilet', displayName: '洗手間'),
    'locker': GymFacility._(id: 'locker', displayName: '置物櫃'),
    'firstAid': GymFacility._(id: 'firstAid', displayName: '急救設備'),
    'waterDispenser': GymFacility._(id: 'waterDispenser', displayName: '飲水機'),
  };
}
