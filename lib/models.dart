import 'package:flutter/foundation.dart';

class Account {
  final String username;
  final String email;
  final String telephone;

  Account({
    @required this.username,
    @required this.email,
    @required this.telephone,
  });

  factory Account.fromJson(Map<String, dynamic> json){
    return Account(
        username: json['username'] as String,
        email: json['email'] as String,
        telephone: json['telephone'] as String);
  }
}