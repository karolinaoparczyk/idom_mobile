import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class Account extends Equatable {
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

  @override
  List<Object> get props => [id, username];

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

class Sensor extends Equatable {
  final int id;
  String name;
  String category;
  int frequency;
  String lastData;
  int batteryLevel;

  Sensor({
    @required this.id,
    @required this.name,
    @required this.category,
    @required this.frequency,
    @required this.lastData,
    @required this.batteryLevel,
  });

  @override
  List<Object> get props => [id, name];

  factory Sensor.fromJson(Map<String, dynamic> json) {
    return Sensor(
        id: json['id'] as int,
        name: json['name'] as String,
        category: json['category'] as String,
        frequency: json['frequency'] as int,
        lastData: json['last_data'] as String,
        batteryLevel: json['battery_level'] as int);
  }
}

class SensorData extends Equatable {
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

  @override
  List<Object> get props => [id, sensorName];

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

class Camera extends Equatable {
  int id;
  String name;
  String ipAddress;

  Camera({@required this.id, this.name, this.ipAddress});

  @override
  List<Object> get props => [id, name];

  factory Camera.fromJson(Map<String, dynamic> json) {
    return Camera(
        id: json['id'] as int,
        name: json['name'] as String,
        ipAddress: json['ip_address'] as String);
  }
}

class Driver extends Equatable {
  int id;
  String name;
  String category;
  String ipAddress;
  bool data;

  Driver(
      {@required this.id, this.name, this.category, this.ipAddress, this.data});

  @override
  List<Object> get props => [id, name];

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
        id: json['id'] as int,
        name: json['name'] as String,
        category: json['category'] as String,
        ipAddress: json['ip_address'] as String,
        data: json['data'] as bool);
  }
}

class SensorDriverAction extends Equatable {
  int id;
  String name;
  String sensor;
  int trigger;
  String operator;
  String driver;
  String days;
  String startTime;
  String endTime;
  String action;
  int flag;

  SensorDriverAction(
      {@required this.id,
      this.name,
      this.sensor,
      this.trigger,
      this.operator,
      this.driver,
      this.days,
      this.startTime,
      this.endTime,
      this.action,
      this.flag});

  @override
  List<Object> get props => [id, name];

  factory SensorDriverAction.fromJson(Map<String, dynamic> json) {
    return SensorDriverAction(
      id: json['id'] as int,
      name: json['name'] as String,
      sensor: json['sensor'] as String,
      trigger: json['trigger'] as int,
      operator: json['operator'] as String,
      driver: json['driver'] as String,
      days: json['days'] as String,
      startTime: json['start_event'] as String,
      endTime: json['end_event'] as String,
      action: json['action'] as String,
      flag: json['flag'] as int,
    );
  }
}
