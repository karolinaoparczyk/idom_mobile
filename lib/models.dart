import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// account model
class Account extends Equatable {
  /// user's id
  final int id;

  /// username
  String username;

  /// e-mail address
  String email;

  /// notifications language
  String language;

  /// cell phone number
  String telephone;

  /// are sms notifications on
  bool smsNotifications;

  /// are app notifications on
  bool appNotifications;

  /// is user admin
  final bool isStaff;

  /// is user active
  bool isActive;

  /// create account
  Account({
    @required this.id,
    @required this.username,
    @required this.email,
    @required this.language,
    @required this.telephone,
    @required this.smsNotifications,
    @required this.appNotifications,
    @required this.isStaff,
    @required this.isActive,
  });

  /// ensures uniqueness
  @override
  List<Object> get props => [id, username];

  /// generates object form json format
  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
        id: json['id'] as int,
        username: json['username'] as String,
        email: json['email'] as String,
        language: json['language'] as String,
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
        language: this.language,
        telephone: this.telephone,
        smsNotifications: this.smsNotifications,
        appNotifications: this.appNotifications,
        isStaff: this.isStaff,
        isActive: this.isActive);
  }
}

/// sensor model
class Sensor extends Equatable {
  /// sensor's id
  final int id;

  /// name
  String name;

  /// category
  String category;

  /// sensor's data read frequency value
  int frequency;

  /// last data read
  String lastData;

  /// battery level
  int batteryLevel;

  /// create sensor
  Sensor({
    @required this.id,
    @required this.name,
    @required this.category,
    @required this.frequency,
    @required this.lastData,
    @required this.batteryLevel,
  });

  /// ensures uniqueness
  @override
  List<Object> get props => [id, name];

  /// generates object form json format
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

/// sensor data model
class SensorData extends Equatable {
  /// sensor data id
  int id;

  /// name
  String sensorName;

  /// data value
  String data;

  /// data delivery time
  DateTime deliveryTime;

  /// create sensor data
  SensorData({
    @required this.id,
    @required this.sensorName,
    @required this.data,
    @required this.deliveryTime,
  });

  /// ensures uniqueness
  @override
  List<Object> get props => [id, sensorName];

  /// generates object form json format
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

/// camera model
class Camera extends Equatable {
  /// camera id
  int id;

  /// name
  String name;

  /// IP address
  String ipAddress;

  /// creates camera
  Camera({@required this.id, this.name, this.ipAddress});

  /// ensures uniqueness
  @override
  List<Object> get props => [id, name];

  /// generates object form json format
  factory Camera.fromJson(Map<String, dynamic> json) {
    return Camera(
        id: json['id'] as int,
        name: json['name'] as String,
        ipAddress: json['ip_address'] as String);
  }
}

/// driver model
class Driver extends Equatable {
  /// driver's id
  int id;

  /// name
  String name;

  /// category
  String category;

  /// IP address
  String ipAddress;

  /// is driver switched on
  bool data;

  /// create driver
  Driver(
      {@required this.id, this.name, this.category, this.ipAddress, this.data});

  /// ensures uniqueness
  @override
  List<Object> get props => [id, name];

  /// generates object form json format
  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
        id: json['id'] as int,
        name: json['name'] as String,
        category: json['category'] as String,
        ipAddress: json['ip_address'] as String,
        data: json['data'] as bool);
  }
}

/// action model
class SensorDriverAction extends Equatable {
  /// action's id
  int id;

  /// name
  String name;

  /// selected sensor for action
  String sensor;

  /// value of sensor data for driver to be triggered
  int trigger;

  /// operator for trigger value {<, >, =}
  String operator;

  /// selected driver for action
  String driver;

  /// chosen days of action to be executed
  String days;

  /// start time of action's execution
  String startTime;

  /// end time of action's execution
  String endTime;

  /// action itself
  String action;

  /// action type
  ///
  /// 1 - action at given time
  /// 2 - action between given hours
  /// 3 - action based only on sensor data
  /// 4 - action based on sensor data between given hours
  int flag;

  /// creates action
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

  /// ensures uniqueness
  @override
  List<Object> get props => [id, name];

  /// generates object form json format
  factory SensorDriverAction.fromJson(Map<String, dynamic> json) {
    return SensorDriverAction(
      id: json['id'] as int,
      name: json['name'] as String,
      sensor: json['sensor'] as String,
      trigger: json['trigger'] as String,
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
