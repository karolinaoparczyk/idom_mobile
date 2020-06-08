import 'package:flutter/foundation.dart';

class Account {
  final int id;
  String username;
  String email;
  String telephone;
  String smsNotifications;
  String appNotifications;
  final bool isStaff;
  bool isActive;

  Account({
    @required this.id,
    @required this.username,
    @required this.email,
    @required this.telephone,
    @required this.smsNotifications,
    @required this.appNotifications,
    @required this.isStaff,
    @required this.isActive,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
        id: json['id'] as int,
        username: json['username'] as String,
        email: json['email'] as String,
        telephone: json['telephone'] as String,
        smsNotifications: json['sms_notiications'] as String,
        appNotifications: json['app_notiications'] as String,
        isStaff: json['is_staff'] as bool,
        isActive: json['is_active'] as bool);
  }

  /// copies Account instance into another
  Account copy() {
    return new Account(
        id: this.id,
        username: this.username,
        email: this.email,
        telephone: this.telephone,
        smsNotifications: this.smsNotifications,
        appNotifications: this.appNotifications,
        isStaff: this.isStaff,
        isActive: this.isActive);
  }
}

class Sensor {
  final int id;
  String name;
  String category;
  int batteryLevel;
  bool notifications;
  String data;
  String lastData;

  Sensor({
    @required this.id,
    @required this.name,
    @required this.category,
    @required this.batteryLevel,
    @required this.notifications,
    @required this.lastData,
  });

  factory Sensor.fromJson(Map<String, dynamic> json) {
    return Sensor(
        id: json['id'] as int,
        name: json['name'] as String,
        category: json['category'] as String,
        batteryLevel: json['batteryLevel'] as int,
        notifications: json['sms_notifications'] as bool,
   //     lastData: "27.0");
       lastData: json['last_data'] as String);
  }
}
