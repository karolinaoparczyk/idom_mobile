import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:idom/utils/secure_storage.dart';

class Api {
  SecureStorage storage;

  /// sets api url in constructor
  Api() {
    httpClient = Client();
    storage = SecureStorage();
  }

  String url;
  Client httpClient;

  void getApiAddress() async {
    url = await storage.getApiURL();
  }

  /// requests signing in
  Future<List<dynamic>> signIn(username, password) async {
    await getApiAddress();
    var result = await httpClient.post('$url' + '/api-token-auth/', body: {
      "username": username,
      "password": password,
    }).timeout(Duration(seconds: 5));
    return [result.body, result.statusCode];
  }

  /// registers user
  Future<Map<String, String>> signUp(
      username, password1, password2, email, telephone) async {
    await getApiAddress();
    var res = await httpClient.post('$url/users/add', body: {
      "username": username,
      "password1": password1,
      "password2": password2,
      "email": email,
      "telephone": telephone,
    }).timeout(Duration(seconds: 5));
    var resDict = {
      "body": res.body.toString(),
      "statusCode": res.statusCode.toString(),
    };
    return resDict;
  }

  /// gets user data
  Future<List<dynamic>> getUser(username, token) async {
    await getApiAddress();
    var result = await httpClient.get('$url/users/detail/$username', headers: {
      HttpHeaders.authorizationHeader: "Token $token"
    }).timeout(Duration(seconds: 5));
    return [result.body, result.statusCode];
  }

  /// requests logging out
  Future<int> logOut(String token) async {
    await getApiAddress();
    try {
      var res = await httpClient.post('$url/api-logout/$token', headers: {
        HttpHeaders.authorizationHeader: "Token $token"
      }).timeout(Duration(seconds: 5));
      return res.statusCode;
    } catch (e) {
      print(e);
    }
    return null;
  }

  /// requests deactivating user
  Future<int> deactivateAccount(int id, String userToken) async {
    await getApiAddress();
    try {
      var res = await httpClient.delete('$url/users/delete/$id', headers: {
        HttpHeaders.authorizationHeader: "Token $userToken"
      }).timeout(Duration(seconds: 5));
      return res.statusCode;
    } catch (e) {
      print(e);
    }
    return null;
  }

  /// sends request to reset password
  Future<int> resetPassword(String email) async {
    await getApiAddress();
    var res = await httpClient.post('$url/password-reset/',
        body: {"email": email}).timeout(Duration(seconds: 5));
    return res.statusCode;
  }

  /// gets accounts
  Future<Map<String, String>> getAccounts(String userToken) async {
    await getApiAddress();
    try {
      var res = await httpClient.get('$url/users/list', headers: {
        HttpHeaders.authorizationHeader: "Token $userToken"
      }).timeout(Duration(seconds: 5));
      var resDict = {
        "body": res.body.toString(),
        "statusCode": res.statusCode.toString(),
      };
      return resDict;
    } catch (e) {
      print(e);
    }
    return null;
  }

  /// edits users data
  Future<Map<String, String>> editAccount(
      int id, String email, String telephone, String userToken) async {
    await getApiAddress();
    var body;
    if (email != null && telephone != null) {
      body = {"email": email, "telephone": telephone};
    } else if (email != null) {
      body = {"email": email};
    } else if (telephone != null) {
      body = {"telephone": telephone};
    }
    var res = await httpClient
        .put('$url/users/update/$id',
            headers: {HttpHeaders.authorizationHeader: "Token $userToken"},
            body: body)
        .timeout(Duration(seconds: 5));
    var resDict = {
      "body": res.body.toString(),
      "statusCode": res.statusCode.toString(),
    };
    return resDict;
  }

  /// edits users notifications
  Future<Map<String, String>> editNotifications(
      int id, String appNotifications, String smsNotifications, String userToken) async {
    await getApiAddress();
    var body;
    if (appNotifications != null && smsNotifications != null) {
      body = {"app_notifications": appNotifications, "sms_notifications": smsNotifications};
    } else if (appNotifications != null) {
      body = {"app_notifications": appNotifications};
    } else if (smsNotifications != null) {
      body = {"sms_notifications": smsNotifications};
    }
    var res = await httpClient
        .put('$url/users/update/$id',
            headers: {HttpHeaders.authorizationHeader: "Token $userToken"},
            body: body)
        .timeout(Duration(seconds: 5));
    var resDict = {
      "body": res.body.toString(),
      "statusCode": res.statusCode.toString(),
    };
    return resDict;
  }

  /// edits sensor
  Future<Map<String, String>> editSensor(int id, String name, String category,
      int frequency, String userToken) async {
    await getApiAddress();
    var frequencyString = frequency.toString();
    var body;
    if (name != null && category != null && frequency != null) {
      body = {"name": name, "category": category, "frequency": frequencyString};
    } else if (name != null && category != null) {
      body = {"name": name, "category": category};
    } else if (category != null && frequency != null) {
      body = {"category": category, "frequency": frequencyString};
    } else if (name != null && frequency != null) {
      body = {"name": name, "frequency": frequencyString};
    } else if (name != null) {
      body = {"name": name};
    } else if (category != null) {
      body = {"category": category};
    } else if (frequency != null) {
      body = {"frequency": frequencyString};
    }
    var res = await httpClient
        .put(
          '$url/sensors/update/$id',
          headers: {HttpHeaders.authorizationHeader: "Token $userToken"},
          body: body,
        )
        .timeout(Duration(seconds: 5));
    var resDict = {
      "body": res.body.toString(),
      "statusCode": res.statusCode.toString(),
    };
    return resDict;
  }

  /// adds sensor
  Future<Map<String, String>> addSensor(
      String name, String category, int frequency, String userToken) async {
    await getApiAddress();
    var body;
    if (frequency == null) {
      body = {
        "name": name,
        "category": category,
      };
    } else {
      body = {
        "name": name,
        "category": category,
        "frequency": frequency.toString()
      };
    }
    var resSen = await httpClient.post(
      '$url/sensors/add',
      headers: {HttpHeaders.authorizationHeader: "Token $userToken"},
      body: body,
    ).timeout(Duration(seconds: 5));
    var resDict = {
      "bodySen": resSen.body.toString(),
      "statusCodeSen": resSen.statusCode.toString(),
    };
    return resDict;
  }

  /// requests deactivating sensor
  Future<int> deactivateSensor(int id, String userToken) async {
    await getApiAddress();
    try {
      var res = await httpClient.delete('$url/sensors/delete/$id', headers: {
        HttpHeaders.authorizationHeader: "Token $userToken"
      }).timeout(Duration(seconds: 5));
      return res.statusCode;
    } catch (e) {
      print(e);
    }
    return null;
  }

  /// gets sensors
  Future<Map<String, String>> getSensors(String userToken) async {
    await getApiAddress();
    try {
      var resSensors = await httpClient.get('$url/sensors/list', headers: {
        HttpHeaders.authorizationHeader: "Token $userToken"
      }).timeout(Duration(seconds: 5));

      Map<String, String> responses = {
        "bodySensors": resSensors.body.toString(),
        "statusCodeSensors": resSensors.statusCode.toString(),
      };
      return responses;
    } catch (e) {
      print(e);
    }
    return null;
  }

  /// gets sensor details
  Future<Map<String, String>> getSensorDetails(
      int sensorId, String userToken) async {
    await getApiAddress();
    try {
      var res = await httpClient.get('$url/sensors/detail/$sensorId', headers: {
        HttpHeaders.authorizationHeader: "Token $userToken"
      }).timeout(Duration(seconds: 5));

      Map<String, String> responses = {
        "body": res.body.toString(),
        "statusCode": res.statusCode.toString(),
      };
      return responses;
    } catch (e) {
      print(e);
    }
    return null;
  }

  /// gets sensors' frequency
  Future<Map<String, String>> getSensorData(
      String userToken, int sensorId) async {
    await getApiAddress();
    try {
      var resFrequency = await httpClient
          .get('$url/sensors_data/list/$sensorId', headers: {
        HttpHeaders.authorizationHeader: "Token $userToken"
      }).timeout(Duration(seconds: 10));

      Map<String, String> responses = {
        "bodySensorData": resFrequency.body.toString(),
        "statusSensorData": resFrequency.statusCode.toString(),
      };
      return responses;
    } catch (e) {
      print(e);
    }
    return null;
  }

  /// gets cameras
  Future<Map<String, String>> getCameras(String userToken) async {
    await getApiAddress();
    try {
      var res = await httpClient.get('$url/cameras/list', headers: {
        HttpHeaders.authorizationHeader: "Token $userToken"
      }).timeout(Duration(seconds: 5));

      Map<String, String> response = {
        "body": res.body.toString(),
        "statusCode": res.statusCode.toString(),
      };
      return response;
    } catch (e) {
      print(e);
    }
    return null;
  }
}
