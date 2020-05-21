import 'package:flutter/foundation.dart';

class Account {
  final int id;
  final String username;
  final String email;
  final String telephone;
  final String smsNotifications;
  final String appNotifications;
  final bool isStaff;
  final bool isActive;

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
}
