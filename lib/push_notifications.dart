import 'package:firebase_messaging/firebase_messaging.dart';
/// handles push notifications
class PushNotificationsManager {
  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;

  /// creates instance
  static final PushNotificationsManager _instance =
      PushNotificationsManager._();

  /// firebase messaging object
  static final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  /// device token
  String deviceToken;

  /// gets device token based on firebase settings
  Future<void> init() async {
    String token = await firebaseMessaging.getToken();
    print("FirebaseMessaging token: $token");

    deviceToken = token;
  }

  FirebaseMessaging getFM(){
    return firebaseMessaging;
  }
}
