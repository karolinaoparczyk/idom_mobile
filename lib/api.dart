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
  String token;
  Client httpClient;

  void getApiAddress() async {
    url = "https://" + await storage.getApiServerAddress();
  }

  void getToken() async {
    token = await storage.getToken();
  }

  /// requests signing in
  Future<List<dynamic>> signIn(username, password) async {
    await getApiAddress();
    var result = await httpClient.post('$url' + '/api-token-auth/', body: {
      "username": username,
      "password": password,
    }).timeout(Duration(seconds: 5));
    return [utf8.decode(result.bodyBytes), result.statusCode];
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
  Future<List<dynamic>> getUser(username, {userToken}) async {
    await getApiAddress();
    await getToken();
    if (token != null) {
      userToken = token;
    }
    var result = await httpClient.get('$url/users/detail/$username', headers: {
      HttpHeaders.authorizationHeader: "Token $userToken"
    }).timeout(Duration(seconds: 5));
    return [utf8.decode(result.bodyBytes), result.statusCode];
  }

  /// requests logging out
  Future<int> logOut() async {
    await getApiAddress();
    await getToken();
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
  Future<int> deactivateAccount(int id) async {
    await getApiAddress();
    await getToken();
    try {
      var res = await httpClient.delete('$url/users/delete/$id', headers: {
        HttpHeaders.authorizationHeader: "Token $token"
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
  Future<Map<String, String>> getAccounts() async {
    await getApiAddress();
    await getToken();
    try {
      var res = await httpClient.get('$url/users/list', headers: {
        HttpHeaders.authorizationHeader: "Token $token"
      }).timeout(Duration(seconds: 5));
      var resDict = {
        "body": utf8.decode(res.bodyBytes),
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
      int id, String email, String telephone) async {
    await getApiAddress();
    await getToken();
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
            headers: {HttpHeaders.authorizationHeader: "Token $token"},
            body: body)
        .timeout(Duration(seconds: 5));
    var resDict = {
      "body": utf8.decode(res.bodyBytes),
      "statusCode": res.statusCode.toString(),
    };
    return resDict;
  }

  /// edits users notifications
  Future<Map<String, String>> editNotifications(
      int id, String appNotifications, String smsNotifications) async {
    await getApiAddress();
    await getToken();
    var body;
    if (appNotifications != null && smsNotifications != null) {
      body = {
        "app_notifications": appNotifications,
        "sms_notifications": smsNotifications
      };
    } else if (appNotifications != null) {
      body = {"app_notifications": appNotifications};
    } else if (smsNotifications != null) {
      body = {"sms_notifications": smsNotifications};
    }
    var res = await httpClient
        .put('$url/users/update/$id',
            headers: {HttpHeaders.authorizationHeader: "Token $token"},
            body: body)
        .timeout(Duration(seconds: 5));
    var resDict = {
      "body": res.body.toString(),
      "statusCode": res.statusCode.toString(),
    };
    return resDict;
  }

  /// edits sensor
  Future<Map<String, String>> editSensor(
      int id, String name, String category, int frequency) async {
    await getApiAddress();
    await getToken();
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
          headers: {HttpHeaders.authorizationHeader: "Token $token"},
          body: body,
        )
        .timeout(Duration(seconds: 5));
    var resDict = {
      "body": utf8.decode(res.bodyBytes),
      "statusCode": res.statusCode.toString(),
    };
    return resDict;
  }

  /// adds sensor
  Future<Map<String, String>> addSensor(
      String name, String category, int frequency) async {
    await getApiAddress();
    await getToken();
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
    var resSen = await httpClient
        .post(
          '$url/sensors/add',
          headers: {HttpHeaders.authorizationHeader: "Token $token"},
          body: body,
        )
        .timeout(Duration(seconds: 5));
    var resDict = {
      "bodySen": utf8.decode(resSen.bodyBytes),
      "statusCodeSen": resSen.statusCode.toString(),
    };
    return resDict;
  }

  /// requests deactivating sensor
  Future<int> deactivateSensor(int id) async {
    await getApiAddress();
    await getToken();
    try {
      var res = await httpClient.delete('$url/sensors/delete/$id', headers: {
        HttpHeaders.authorizationHeader: "Token $token"
      }).timeout(Duration(seconds: 5));
      return res.statusCode;
    } catch (e) {
      print(e);
    }
    return null;
  }

  /// gets sensors
  Future<Map<String, String>> getSensors() async {
    await getApiAddress();
    await getToken();
    try {
      var resSensors = await httpClient.get('$url/sensors/list', headers: {
        HttpHeaders.authorizationHeader: "Token $token"
      }).timeout(Duration(seconds: 5));

      Map<String, String> responses = {
        "bodySensors": utf8.decode(resSensors.bodyBytes),
        "statusCodeSensors": resSensors.statusCode.toString(),
      };
      return responses;
    } catch (e) {
      print(e);
    }
    return null;
  }

  /// gets sensor details
  Future<Map<String, String>> getSensorDetails(int sensorId) async {
    await getApiAddress();
    await getToken();
    try {
      var res = await httpClient.get('$url/sensors/detail/$sensorId', headers: {
        HttpHeaders.authorizationHeader: "Token $token"
      }).timeout(Duration(seconds: 5));

      Map<String, String> responses = {
        "body": utf8.decode(res.bodyBytes),
        "statusCode": res.statusCode.toString(),
      };
      return responses;
    } catch (e) {
      print(e);
    }
    return null;
  }

  /// gets sensors' frequency
  Future<Map<String, String>> getSensorData(int sensorId) async {
    await getApiAddress();
    await getToken();
    try {
      var resFrequency = await httpClient
          .get('$url/sensors_data/list/$sensorId', headers: {
        HttpHeaders.authorizationHeader: "Token $token"
      }).timeout(Duration(seconds: 10));

      Map<String, String> responses = {
        "bodySensorData": utf8.decode(resFrequency.bodyBytes),
        "statusSensorData": resFrequency.statusCode.toString(),
      };
      return responses;
    } catch (e) {
      print(e);
    }
    return null;
  }

  /// gets cameras
  Future<Map<String, String>> getCameras() async {
    await getApiAddress();
    await getToken();
    try {
      var res = await httpClient.get('$url/cameras/list', headers: {
        HttpHeaders.authorizationHeader: "Token $token"
      }).timeout(Duration(seconds: 5));

      Map<String, String> response = {
        "body": utf8.decode(res.bodyBytes),
        "statusCode": res.statusCode.toString(),
      };
      return response;
    } catch (e) {
      print(e);
    }
    return null;
  }

  /// requests deleting camera
  Future<int> deleteCamera(int id) async {
    await getApiAddress();
    await getToken();
    try {
      var res = await httpClient.delete('$url/cameras/delete/$id', headers: {
        HttpHeaders.authorizationHeader: "Token $token"
      }).timeout(Duration(seconds: 5));
      return res.statusCode;
    } catch (e) {
      print(e);
    }
    return null;
  }

  /// adds camera
  Future<Map<String, String>> addCamera(String name) async {
    await getApiAddress();
    await getToken();
    var res = await httpClient
        .post(
          '$url/cameras/add',
          headers: {
            HttpHeaders.authorizationHeader: "Token $token",
            HttpHeaders.contentTypeHeader: 'application/json',
          },
          body: jsonEncode({
            "name": name,
          }),
        )
        .timeout(Duration(seconds: 5));
    var resDict = {
      "body": utf8.decode(res.bodyBytes),
      "statusCode": res.statusCode.toString(),
    };
    return resDict;
  }

  /// edits camera
  Future<Map<String, String>> editCamera(int id, String name) async {
    await getApiAddress();
    await getToken();
    var body = {"name": name};

    var res = await httpClient
        .put(
          '$url/cameras/update/$id',
          headers: {HttpHeaders.authorizationHeader: "Token $token"},
          body: body,
        )
        .timeout(Duration(seconds: 5));
    var resDict = {
      "body": utf8.decode(res.bodyBytes),
      "statusCode": res.statusCode.toString(),
    };
    return resDict;
  }

  /// gets camera details
  Future<Map<String, String>> getCameraDetails(int cameraId) async {
    await getApiAddress();
    await getToken();
    try {
      var res = await httpClient.get('$url/cameras/detail/$cameraId', headers: {
        HttpHeaders.authorizationHeader: "Token $token"
      }).timeout(Duration(seconds: 5));

      Map<String, String> responses = {
        "body": utf8.decode(res.bodyBytes),
        "statusCode": res.statusCode.toString(),
      };
      return responses;
    } catch (e) {
      print(e);
    }
    return null;
  }

  /// checks if device token is sent
  Future<Map<String, String>> checkIfDeviceTokenSent(String deviceToken) async {
    await getApiAddress();
    await getToken();
    try {
      var res = await httpClient.get('$url/devices/$deviceToken', headers: {
        HttpHeaders.authorizationHeader: "Token $token"
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

  /// sends device token
  Future<Map<String, String>> sendDeviceToken(String deviceToken) async {
    await getApiAddress();
    await getToken();
    var username = await storage.getUsername();
    try {
      var res = await httpClient.post('$url/devices/', headers: {
        HttpHeaders.authorizationHeader: "Token $token"
      }, body: {
        "name": username,
        "registration_id": deviceToken,
        "type": "android"
      }).timeout(Duration(seconds: 10));

      var resDict = {
        "body": res.body.toString(),
        "statusCode": res.statusCode.toString(),
      };
      return resDict;
    } catch (e) {
      print(e);
      return null;
    }
  }

  /// gets drivers
  Future<Map<String, String>> getDrivers() async {
    await getApiAddress();
    await getToken();
    try {
      var res = await httpClient.get('$url/drivers/list', headers: {
        HttpHeaders.authorizationHeader: "Token $token"
      }).timeout(Duration(seconds: 5));

      Map<String, String> response = {
        "body": utf8.decode(res.bodyBytes),
        "statusCode": res.statusCode.toString(),
      };
      return response;
    } catch (e) {
      print(e);
    }
    return null;
  }

  /// adds driver
  Future<Map<String, String>> addDriver(String name, String category,
      {bool data = false}) async {
    await getApiAddress();
    await getToken();
    var res = await httpClient
        .post(
          '$url/drivers/add',
          headers: {
            HttpHeaders.authorizationHeader: "Token $token",
            HttpHeaders.contentTypeHeader: 'application/json',
          },
          body: jsonEncode({
            "name": name,
            "category": category,
            "data": data,
          }),
        )
        .timeout(Duration(seconds: 5));
    var resDict = {
      "body": utf8.decode(res.bodyBytes),
      "statusCode": res.statusCode.toString(),
    };
    return resDict;
  }

  /// edits driver
  Future<Map<String, String>> editDriver(
      int id, String name, String category) async {
    await getApiAddress();
    await getToken();
    var body;
    if (name != null && category != null) {
      body = {"name": name, "category": category};
    } else if (name != null) {
      body = {"name": name};
    } else if (category != null) {
      body = {"category": category};
    }
    var res = await httpClient
        .put(
          '$url/drivers/update/$id',
          headers: {HttpHeaders.authorizationHeader: "Token $token"},
          body: body,
        )
        .timeout(Duration(seconds: 5));
    var resDict = {
      "body": utf8.decode(res.bodyBytes),
      "statusCode": res.statusCode.toString(),
    };
    return resDict;
  }

  /// gets driver details
  Future<Map<String, String>> getDriverDetails(int driverId) async {
    await getApiAddress();
    await getToken();
    try {
      var res = await httpClient.get('$url/drivers/detail/$driverId', headers: {
        HttpHeaders.authorizationHeader: "Token $token"
      }).timeout(Duration(seconds: 5));

      Map<String, String> responses = {
        "body": utf8.decode(res.bodyBytes),
        "statusCode": res.statusCode.toString(),
      };
      return responses;
    } catch (e) {
      print(e);
    }
    return null;
  }

  /// requests deleting driver
  Future<int> deleteDriver(int id) async {
    await getApiAddress();
    await getToken();
    try {
      var res = await httpClient.delete('$url/drivers/delete/$id', headers: {
        HttpHeaders.authorizationHeader: "Token $token"
      }).timeout(Duration(seconds: 5));
      return res.statusCode;
    } catch (e) {
      print(e);
    }
    return null;
  }

  /// requests starting driver
  Future<int> startDriver(String name) async {
    await getApiAddress();
    await getToken();
    try {
      var res = await httpClient.post('$url/drivers/action',
          headers: {HttpHeaders.authorizationHeader: "Token $token"},
          body: {"name": name}).timeout(Duration(seconds: 5));
      return res.statusCode;
    } catch (e) {
      print(e);
    }
    return null;
  }

  /// requests generating csv file with sensor data
  Future<Map<String, dynamic>> generateFile(
      List<String> sensorIds, List<String> categoriesValues, int days) async {
    await getApiAddress();
    await getToken();
    try {
      var res = await httpClient
          .post('$url/sensors_data/csv',
              headers: {
                HttpHeaders.authorizationHeader: "Token $token",
                HttpHeaders.contentTypeHeader: 'application/json',
              },
              body: jsonEncode({
                "sensors_ids": sensorIds,
                "categories": categoriesValues,
                "days": days.toString()
              }))
          .timeout(Duration(seconds: 5));
      Map<String, dynamic> response = {
        "body": utf8.decode(res.bodyBytes),
        "statusCode": res.statusCode,
      };
      return response;
    } catch (e) {
      print(e);
    }
    return null;
  }
}
