import 'dart:io';
import 'package:http/http.dart';

class Api {
  /// sets api url in constructor
  Api(String apiAddress) {
    httpClient =  Client();
    url = apiAddress;
  }

  String url;
  Client httpClient;

  /// requests signing in
  Future<List<dynamic>> signIn(username, password) async {
    var result = await httpClient.post("http://" + '$url' + '/api-token-auth/', body: {
      "username": username,
      "password": password,
    }).timeout(Duration(seconds: 5));
    return [result.body, result.statusCode];
  }

  /// registers user
  Future<Map<String, String>> signUp(
      username, password1, password2, email, telephone) async {
    var res = await httpClient.post("http://" + '$url/users/add', body: {
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
    var result = await httpClient.get("http://" + '$url/users/detail/$username', headers: {
      HttpHeaders.authorizationHeader: "Token $token"
    }).timeout(Duration(seconds: 5));
    return [result.body, result.statusCode];
  }

  /// requests logging out
  Future<int> logOut(String token) async {
    try {
      var res = await httpClient.post("http://" + '$url/api-logout/$token', headers: {
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
    try {
      var res = await httpClient.delete("http://" + '$url/users/delete/$id', headers: {
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
    var res = await httpClient.post("http://" + '$url/password-reset/',
        body: {"email": email}).timeout(Duration(seconds: 5));
    return res.statusCode;
  }

  /// gets accounts
  Future<Map<String, String>> getAccounts(String userToken) async {
    var res = await httpClient.get("http://" + '$url/users/list', headers: {
      HttpHeaders.authorizationHeader: "Token $userToken"
    }).timeout(Duration(seconds: 5));
    var resDict = {
      "body": res.body.toString(),
      "statusCode": res.statusCode.toString(),
    };
    return resDict;
  }

  /// edits users data
  Future<Map<String, String>> editAccount(
      int id, String email, String telephone, String userToken) async {
    var body;
    if (email != null && telephone != null) {
      body = {"email": email, "telephone": telephone};
    } else if (email != null) {
      body = {"email": email};
    } else if (telephone != null) {
      body = {"telephone": telephone};
    }
    var res = await httpClient
        .put("http://" + '$url/users/update/$id',
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
        .put("http://" +
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
    var resSen = await httpClient.post("http://" +
        '$url/sensors/add',
      headers: {HttpHeaders.authorizationHeader: "Token $userToken"},
      body: {
        "name": name,
        "category": category,
        "frequency": frequency.toString()
      },
    ).timeout(Duration(seconds: 5));
    var resDict = {
      "bodySen": resSen.body.toString(),
      "statusCodeSen": resSen.statusCode.toString(),
    };
    return resDict;
  }

  /// requests deactivating sensor
  Future<int> deactivateSensor(int id, String userToken) async {
    try {
      var res = await httpClient.delete("http://" + '$url/sensors/delete/$id', headers: {
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
    try {
      var resSensors = await httpClient.get("http://" + '$url/sensors/list', headers: {
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
    try {
      var res = await httpClient.get("http://" + '$url/sensors/detail/$sensorId', headers: {
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
    try {
      var resFrequency = await httpClient.get("http://" + '$url/sensors_data/list/$sensorId',
          headers: {
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
}
