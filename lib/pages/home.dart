import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:idom/api.dart';
import 'package:idom/pages/logotype_widget.dart';

import 'package:idom/pages/sensors/sensors.dart';
import 'package:idom/pages/setup/front.dart';
import 'package:idom/push_notifications.dart';
import 'package:idom/utils/secure_storage.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static const MethodChannel _channel =
      MethodChannel('flutter.idom/notifications');
  Map<String, String> channelMap = {
    "id": "SENSORS_NOTIFICATIONS",
    "name": "Sensors",
    "description": "Sensors notifications",
  };
  final SecureStorage storage = SecureStorage();
  final pushNotificationsManager = PushNotificationsManager();
  final Api api = Api();
  String isUserSignedIn;

  @override
  void initState() {
    checkIfUserIsSignedIn();
    _createSensorsNotificationsChannel();
    sendDeviceToken();
    super.initState();
  }

  void _createSensorsNotificationsChannel() async {
    try {
      await _channel.invokeMethod('createNotificationChannel', channelMap);
    } on PlatformException catch (e) {
      print(e);
    }
  }

  Future<void> sendDeviceToken() async {
    await pushNotificationsManager.init();
    var deviceResponse =
        await api.checkIfDeviceTokenSent(pushNotificationsManager.deviceToken);
    if (deviceResponse['statusCode'] != "200") {
      var tokenResponse =
          await api.sendDeviceToken(pushNotificationsManager.deviceToken);
      if (tokenResponse['statusCode'] == "201")
        print("Device token sent successfully");
      else {
        print("Error while sending device token. ${tokenResponse['body']}");
      }
    }
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
