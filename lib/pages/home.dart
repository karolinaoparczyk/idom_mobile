import 'package:flutter/material.dart';
import 'package:idom/pages/sensors/sensors.dart';
import 'package:idom/pages/setup/front.dart';

import '../api.dart';
import '../models.dart';

enum AuthStatus {
  notSignedIn,
  signedIn,
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  AuthStatus authStatus = AuthStatus.notSignedIn;
  Api api;
  String currentLoggedInToken;
  Account currentUser;

  /// when user logs in successfully
  void _signedIn(String token, Account user) {
    setState(() {
      authStatus = AuthStatus.signedIn;
      currentLoggedInToken = token;
      currentUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return authStatus == AuthStatus.notSignedIn
        ? Front(api: api, onSignedIn: _signedIn)
        : Sensors(
            currentLoggedInToken: currentLoggedInToken,
            currentUser: currentUser,
            api: api);
  }
}
