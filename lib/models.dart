import 'package:flutter/foundation.dart';

class Account {
  final int id;
  String username;
  String email;
  String telephone;
  bool smsNotifications;
  bool appNotifications;
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
        smsNotifications: json['sms_notifications'] as bool,
        appNotifications: json['app_notifications'] as bool,
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
  int frequency;
  String lastData;

  Sensor({
    @required this.id,
    @required this.name,
    @required this.category,
    @required this.frequency,
    @required this.lastData,
  });

  factory Sensor.fromJson(Map<String, dynamic> json) {
    return Sensor(
        id: json['id'] as int,
        name: json['name'] as String,
        category: json['category'] as String,
        frequency: json['frequency'] as int,
        lastData: json['last_data'] as String);
  }
}

class SensorData {
  int id;
  String sensorName;
  String data;
  DateTime deliveryTime;

  SensorData({
    @required this.id,
    @required this.sensorName,
    @required this.data,
    @required this.deliveryTime,
  });

  factory SensorData.fromJson(Map<String, dynamic> json, int id) {
    return SensorData(
        id: id,
        sensorName: json['sensor'] as String,
        data: json['sensor_data'] as String,
        deliveryTime: DateTime.parse(json['delivery_time']
            .substring(0, 19)
            .replaceAll("T", " ") as String));
  }
}

class Camera{
  int id;
  String name;
  String ipAddress;

  Camera({@required this.id, this.name, this.ipAddress});

  factory Camera.fromJson(Map<String, dynamic> json) {
    return Camera(
        id: json['id'] as int,
        name: json['name'] as String,
        ipAddress: json['ip_address'] as String);
  }

}
