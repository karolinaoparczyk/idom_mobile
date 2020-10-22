import 'package:flutter/material.dart';
import 'package:idom/pages/logotype_widget.dart';

import 'package:idom/pages/sensors/sensors.dart';
import 'package:idom/pages/setup/front.dart';
import 'package:idom/utils/secure_storage.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final SecureStorage storage = SecureStorage();
  String isUserSignedIn;

  @override
  void initState() {
    checkIfUserIsSignedIn();
    super.initState();
  }

  Future<void> checkIfUserIsSignedIn() async {
    isUserSignedIn = await storage.getIsLoggedIn();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    checkIfUserIsSignedIn();
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
    return Sensors(storage: storage);
  }

  Future<Widget> frontWidget() async {
    return Front(storage: storage);
  }

  Future<Widget> logotypeWidget() async {
    return LogotypeWidget();
  }
}
