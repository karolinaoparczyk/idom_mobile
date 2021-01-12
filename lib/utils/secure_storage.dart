import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// local storage
class SecureStorage {
  static const String _apiServerAddress = "apiServerAddress";
  static const String _username = "username";
  static const String _password = "password";
  static const String _email = "email";
  static const String _language = "language";
  static const String _telephone = "telephone";
  static const String _userId = "userId";
  static const String _smsNotifications = "smsNotifications";
  static const String _appNotifications = "appNotifications";
  static const String _isActive = "isActive";
  static const String _token = "token";
  static const String _isLoggedIn = "isLoggedIn";
  static const String _isUserStaff = "isUserStaff";
  static const String _firebaseUrl = "firebaseUrl";
  static const String _storageBucket = "storageBucket";
  static const String _mobileAppId = "mobileAppId";
  static const String _apiKey = "mobileAppId";
  static const String _fileName = "fileName";
  static const String _themeMode = "themeMode";

  /// secure storage
  FlutterSecureStorage storage;

  /// sets storage
  SecureStorage() {
    this.storage = FlutterSecureStorage();
  }

  /// sets api server address
  void setApiServerAddress(String apiServerAddress) {
    storage.write(key: _apiServerAddress, value: apiServerAddress);
  }

  /// gets api server address
  Future<String> getApiServerAddress() {
    return storage.read(key: _apiServerAddress);
  }

  /// sets theme mode
  void setThemeMode(String themeMode) {
    storage.write(key: _themeMode, value: themeMode);
  }

  /// gets theme mode
  Future<String> getThemeMode() {
    return storage.read(key: _themeMode);
  }

  /// sets currently logged in user data
  void setUserData(
      String username,
      String password,
      String email,
      String language,
      String telephone,
      String userId,
      String smsNotifications,
      String appNotifications,
      String isActive,
      String isUserStaff,
      String token) {
    storage.write(key: _username, value: username);
    storage.write(key: _password, value: password);
    storage.write(key: _email, value: email);
    storage.write(key: _language, value: language);
    storage.write(key: _telephone, value: telephone);
    storage.write(key: _userId, value: userId);
    storage.write(key: _smsNotifications, value: smsNotifications);
    storage.write(key: _appNotifications, value: appNotifications);
    storage.write(key: _isActive, value: isActive);
    storage.write(key: _isLoggedIn, value: "true");
    storage.write(key: _isUserStaff, value: isUserStaff);
    storage.write(key: _token, value: token);
  }

  /// gets currently logged in user data
  Future<Map<String, dynamic>> getCurrentUserData() async {
    var username = await storage.read(key: _username);
    var email = await storage.read(key: _email);
    var language = await storage.read(key: _language);
    var telephone = await storage.read(key: _telephone);
    var id = await storage.read(key: _userId);
    var smsNotifications = await storage.read(key: _smsNotifications);
    var appNotifications = await storage.read(key: _appNotifications);
    var isActive = await storage.read(key: _isActive);
    var isStaff = await storage.read(key: _isUserStaff);
    var token = await storage.read(key: _token);
    return {
      "username": username,
      "email": email,
      "language": language,
      "telephone": telephone,
      "id": id,
      "smsNotifications": smsNotifications,
      "appNotifications": appNotifications,
      "isActive": isActive,
      "isStaff": isStaff,
      "token": token
    };
  }

  /// resets currently logged in user data
  void resetUserData() {
    storage.delete(key: _username);
    storage.delete(key: _password);
    storage.delete(key: _email);
    storage.delete(key: _language);
    storage.delete(key: _telephone);
    storage.delete(key: _userId);
    storage.delete(key: _smsNotifications);
    storage.delete(key: _appNotifications);
    storage.delete(key: _isActive);
    storage.write(key: _isLoggedIn, value: "false");
    storage.delete(key: _isUserStaff);
    storage.delete(key: _token);
    storage.delete(key: _themeMode);
  }

  /// sets currently logged in user's username
  void setUsername(String username) {
    storage.write(key: _username, value: username);
  }

  /// gets currently logged in user's username
  Future<String> getUsername() {
    return storage.read(key: _username);
  }

  /// sets currently logged in user's password
  void setPassword(String password) {
    storage.write(key: _password, value: password);
  }

  /// gets currently logged in user's password
  Future<String> getPassword() {
    return storage.read(key: _password);
  }

  /// sets currently logged in user's e-mail address
  void setEmail(String email) {
    storage.write(key: _email, value: email);
  }

  /// gets currently logged in user's e-mail address
  Future<String> getEmail() {
    return storage.read(key: _email);
  }

  /// sets currently logged in user's notifications language
  void setLanguage(String language) {
    storage.write(key: _language, value: language);
  }

  /// gets currently logged in user's notifications language
  Future<String> getLanguage() {
    return storage.read(key: _email);
  }

  /// sets currently logged in user's cell phone number
  void setTelephone(String telephone) {
    storage.write(key: _telephone, value: telephone);
  }

  /// gets currently logged in user's cell phone number
  Future<String> getTelephone() {
    return storage.read(key: _telephone);
  }

  /// sets currently logged in user's id
  void setUserId(String userId) {
    storage.write(key: _userId, value: userId);
  }

  /// gets currently logged in user's id
  Future<String> getUserId() {
    return storage.read(key: _userId);
  }

  /// sets currently logged in user's app notifications turned on/off
  void setAppNotifications(String appNotifications) {
    storage.write(key: _appNotifications, value: appNotifications);
  }

  /// gets currently logged in user's app notifications turned on/off
  Future<String> getAppNotifications() {
    return storage.read(key: _appNotifications);
  }

  /// sets currently logged in user's sms notifications turned on/off
  void setSmsNotifications(String smsNotifications) {
    storage.write(key: _smsNotifications, value: smsNotifications);
  }

  /// gets currently logged in user's sms notifications turned on/off
  Future<String> getSmsNotifications() {
    return storage.read(key: _smsNotifications);
  }

  /// sets currently logged in user's token
  void setToken(String token) {
    storage.write(key: _token, value: token);
  }

  /// gets currently logged in user's token
  Future<String> getToken() {
    return storage.read(key: _token);
  }

  /// sets is a user signed in
  void setIsLoggedIn(String isLoggedIn) {
    storage.write(key: _isLoggedIn, value: isLoggedIn);
  }

  /// gets is a user signed in
  Future<String> getIsLoggedIn() async {
    var isLoggedIn = await storage.read(key: _isLoggedIn);
    if (isLoggedIn == null)
      return "false";
    else
      return isLoggedIn;
  }

  /// sets is a user an admin
  void setIsUserStaff(String isUserStaff) {
    storage.write(key: _isUserStaff, value: isUserStaff);
  }

  /// gets is a user an admin
  Future<String> getIsUserStaff() {
    return storage.read(key: _isUserStaff);
  }

  /// sets firebase parameters for notifications
  void setFirebaseParams(String firebaseUrl, String storageBucket,
      String mobileAppId, String apiKey, String fileName) {
    storage.write(key: _firebaseUrl, value: firebaseUrl);
    storage.write(key: _storageBucket, value: storageBucket);
    storage.write(key: _mobileAppId, value: mobileAppId);
    storage.write(key: _apiKey, value: apiKey);
    storage.write(key: _fileName, value: fileName);
  }

  /// gets firebase parameters for notifications
  Future<Map<String, String>> getFirebaseParams() async {
    var firebaseParams = {
      "firebaseUrl": await storage.read(key: _firebaseUrl),
      "storageBucket": await storage.read(key: _storageBucket),
      "mobileAppId": await storage.read(key: _mobileAppId),
      "apiKey": await storage.read(key: _apiKey),
      "fileName": await storage.read(key: _fileName),
    };
    return firebaseParams;
  }
}
