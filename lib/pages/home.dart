import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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
  bool apiAddressAdded;
  String apiAddress;

  @override
  void initState() {
    super.initState();
    permissionsGranted();
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

  permissionsGranted() async {
    if (await Permission.storage.request().isGranted) {
      var result = await setApiAddress();
      return result;
    }

    return null;
  }

  setApiAddress() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/serverAddress.txt';
    var apiString;
    try {
      final file = File(path);
      apiString = await file.readAsString();
      apiAddressAdded = true;
      setState(() {
        apiAddress = apiString;
        api = Api(apiAddress);
      });
    } catch (e) {
      print(e);
      apiAddressAdded = false;
    }
    return apiString;
  }

  /// when user logs out successfully
  void _signedOut() {
    setState(() {
      authStatus = AuthStatus.notSignedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return authStatus == AuthStatus.notSignedIn
        ? FutureBuilder<Widget>(
            future: frontWidget(),
            builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
              if (snapshot.hasData) return snapshot.data;

              return Container(
                  child: Center(child: CircularProgressIndicator()));
            })
        : sensorWidget();
  }

  Widget sensorWidget() {
    return Sensors(
        currentLoggedInToken: currentLoggedInToken,
        currentUser: currentUser,
        api: api,
        onSignedOut: _signedOut);
  }

  Future<Widget> frontWidget() async {
    return Front(
        api: api,
        onSignedIn: _signedIn,
        onSignedOut: _signedOut,
        apiAddressAdded: apiAddressAdded,
        apiAddress: apiAddress,
        setApiAddress: permissionsGranted);
  }
}
