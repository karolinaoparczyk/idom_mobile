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
  Home({Key key, this.signedOut}) : super(key: key);
  bool signedOut;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  AuthStatus authStatus = AuthStatus.notSignedIn;
  Api api;
  String currentLoggedInToken;
  Account currentUser;

  @override
  void initState() {
    super.initState();
    api = Api();
    if (widget.signedOut != null && widget.signedOut == true)
      authStatus = AuthStatus.notSignedIn;
  }

  /// when user logs in successfully
  void _signedIn(String token, Account user, Api apiClass) {
    setState(() {
      authStatus = AuthStatus.signedIn;
      currentLoggedInToken = token;
      currentUser = user;
      api = apiClass;
    });
  }

  /// when user logs in successfully
  void _signedOut() {
    setState(() {
      authStatus = AuthStatus.notSignedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return authStatus == AuthStatus.notSignedIn
        ? Front(api: api, onSignedIn: _signedIn, onSignedOut: _signedOut)
        : sensorWidget();
  }

  Widget sensorWidget() {
    return Sensors(
        currentLoggedInToken: currentLoggedInToken,
        currentUser: currentUser,
        api: api,
        onSignedOut: _signedOut);
  }
}
