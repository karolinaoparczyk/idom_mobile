import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationsManager {
  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;

  static final PushNotificationsManager _instance =
      PushNotificationsManager._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  String deviceToken;

  Future<void> init() async {
    String token = await _firebaseMessaging.getToken();
    print("FirebaseMessaging token: $token");

    deviceToken = token;
  }
}
