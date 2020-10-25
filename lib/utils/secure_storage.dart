import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const String _apiServerAddress = "apiServerAddress";
  static const String _apiServerAddressProtocol = "apiServerAddressProtocol";
  static const String _apiServerAddressPort = "apiServerAddressPort";
  static const String _username = "username";
  static const String _password = "password";
  static const String _email = "email";
  static const String _telephone = "telephone";
  static const String _userId = "userId";
  static const String _smsNotifications = "smsNotifications";
  static const String _appNotifications = "appNotifications";
  static const String _isActive = "isActive";
  static const String _token = "token";
  static const String _isLoggedIn = "isLoggedIn";
  static const String _isUserStaff = "isUserStaff";

  FlutterSecureStorage storage;

  SecureStorage() {
    this.storage = FlutterSecureStorage();
  }

  void setApiServerAddress(String apiServerAddress) {
    storage.write(key: _apiServerAddress, value: apiServerAddress);
  }

  Future<String> getApiServerAddress() {
    return storage.read(key: _apiServerAddress);
  }

  void setApiServerAddressProtocol(String apiServerAddressProtocol) {
    storage.write(
        key: _apiServerAddressProtocol, value: apiServerAddressProtocol);
  }

  Future<String> getApiServerAddressProtocol() {
    return storage.read(key: _apiServerAddressProtocol);
  }

  void setApiServerAddressPort(String apiServerAddressPort) {
    storage.write(key: _apiServerAddressPort, value: apiServerAddressPort);
  }

  Future<String> getApiServerAddressPort() {
    return storage.read(key: _apiServerAddressPort);
  }

  void setUserData(
      String username,
      String password,
      String email,
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
    storage.write(key: _userId, value: userId);
    storage.write(key: _smsNotifications, value: smsNotifications);
    storage.write(key: _appNotifications, value: appNotifications);
    storage.write(key: _isActive, value: isActive);
    storage.write(key: _isLoggedIn, value: "true");
    storage.write(key: _isUserStaff, value: isUserStaff);
    storage.write(key: _token, value: token);
  }

  Future<Map<String, dynamic>> getCurrentUserData() async {
    var username = await storage.read(key: _username);
    var email = await storage.read(key: _email);
    var id = await storage.read(key: _userId);
    var smsNotifications = await storage.read(key: _smsNotifications);
    var appNotifications = await storage.read(key: _appNotifications);
    var isActive = await storage.read(key: _isActive);
    var isStaff = await storage.read(key: _isUserStaff);
    var token = await storage.read(key: _token);
    return {
      "username": username,
      "email": email,
      "id": id,
      "smsNotifications": smsNotifications,
      "appNotifications": appNotifications,
      "isActive": isActive,
      "isStaff": isStaff,
      "token": token
    };
  }

  void resetUserData() {
    storage.delete(key: _username);
    storage.delete(key: _password);
    storage.delete(key: _email);
    storage.delete(key: _userId);
    storage.delete(key: _smsNotifications);
    storage.delete(key: _appNotifications);
    storage.delete(key: _isActive);
    storage.write(key: _isLoggedIn, value: "false");
    storage.delete(key: _isUserStaff);
    storage.delete(key: _token);
  }

  void setUsername(String username) {
    storage.write(key: _username, value: username);
  }

  Future<String> getUsername() {
    return storage.read(key: _username);
  }

  void setPassword(String password) {
    storage.write(key: _password, value: password);
  }

  Future<String> getPassword() {
    return storage.read(key: _password);
  }

  void setEmail(String email) {
    storage.write(key: _email, value: email);
  }

  Future<String> getEmail() {
    return storage.read(key: _email);
  }

  void setTelephone(String telephone) {
    storage.write(key: _telephone, value: telephone);
  }

  Future<String> getTelephone() {
    return storage.read(key: _telephone);
  }

  void setUserId(String userId) {
    storage.write(key: _userId, value: userId);
  }

  Future<String> getUserId() {
    return storage.read(key: _userId);
  }

  void setToken(String token) {
    storage.write(key: _token, value: token);
  }

  Future<String> getToken() {
    return storage.read(key: _token);
  }

  void setIsLoggedIn(String isLoggedIn) {
    storage.write(key: _isLoggedIn, value: isLoggedIn);
  }

  Future<String> getIsLoggedIn() async {
    var isLoggedIn = await storage.read(key: _isLoggedIn);
    if (isLoggedIn == null)
      return "false";
    else
      return isLoggedIn;
  }

  void setIsUserStaff(String isUserStaff) {
    storage.write(key: _isUserStaff, value: isUserStaff);
  }

  Future<String> getIsUserStaff() {
    return storage.read(key: _isUserStaff);
  }
}
