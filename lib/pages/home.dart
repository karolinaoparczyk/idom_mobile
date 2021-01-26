import 'package:flutter/material.dart';
import 'package:idom/api.dart';
import 'package:idom/pages/logotype_widget.dart';

import 'package:idom/pages/sensors/sensors.dart';
import 'package:idom/pages/setup/front.dart';
import 'package:idom/utils/secure_storage.dart';

/// main widget displaying correct page according to user data
class Home extends StatefulWidget {
  Home({this.testStorage, this.testApi});

  final SecureStorage testStorage;
  final Api testApi;

  /// handles state of widgets
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  SecureStorage storage = SecureStorage();
  Api api = Api();
  String isUserSignedIn;

  @override
  void initState() {
    if (widget.testStorage != null) {
      storage = widget.testStorage;
      api = widget.testApi;
    }
    checkIfUserIsSignedIn();
    super.initState();
  }

  Future<void> checkIfUserIsSignedIn() async {
    isUserSignedIn = await storage.getIsLoggedIn();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return isUserSignedIn == "true"
        ? sensorWidget()
        : isUserSignedIn == null
            ? LogotypeWidget()
            : FutureBuilder<Widget>(
                future: frontWidget(),
                builder:
                    (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                  if (snapshot.hasData) return snapshot.data;

                  return Container(
                      child: Center(child: CircularProgressIndicator()));
                });
  }

  Widget sensorWidget() {
    return Sensors(storage: storage, testApi: widget.testApi);
  }

  Future<Widget> frontWidget() async {
    return Front(storage: storage);
  }

  Future<Widget> logotypeWidget() async {
    return LogotypeWidget();
  }
}
