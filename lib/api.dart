import 'dart:io';

import 'package:http/http.dart' as http;

class Api {
  /// requests signing in
  Future<List<dynamic>> signIn(username, password) async {
    var result = await http.post('http://10.0.2.2:8000/api-token-auth/', body: {
      "username": username,
      "password": password,
    });
    return [result.body, result.statusCode];
  }

  /// registers user
  Future<Map<String, String>> signUp(
      username, password1, password2, email, telephone) async {
    var res = await http.post('http://10.0.2.2:8000/users/add', body: {
      "username": username,
      "password1": password1,
      "password2": password2,
      "email": email,
      "telephone": telephone,
    });
    var resDict = {
      "body": res.body.toString(),
      "statusCode": res.statusCode.toString(),
    };
    return resDict;
  }

  /// requests logging out
  Future<int> logOut(String token) async {
    try {
      var res = await http.post('http://10.0.2.2:8000/api-logout/$token');
      return res.statusCode;
    } catch (e) {
      print(e);
    }
    return null;
  }

  /// requests deactivating user
  Future<int> deactivateAccount(int id, String userToken) async {
    try {
      var res = await http.delete('http://10.0.2.2:8000/users/delete/$id',
          headers: {HttpHeaders.authorizationHeader: "Token $userToken"});
      return res.statusCode;
    } catch (e) {
      print(e);
    }
    return null;
  }

  /// requests deactivating sensor
  Future<int> deactivateSensor(int id, String userToken) async {
    try {
      var res = await http.delete('http://10.0.2.2:8000/sensors/delete/$id',
          headers: {HttpHeaders.authorizationHeader: "Token $userToken"});
      return res.statusCode;
    } catch (e) {
      print(e);
    }
    return null;
  }

  /// requests deactivating user
  Future<http.Response> getSensors(String userToken) async {
    try {
      var res = await http.get('http://10.0.2.2:8000/sensors/list',
          headers: {HttpHeaders.authorizationHeader: "Token $userToken"});
      return res;
    } catch (e) {
      print(e);
    }
    return null;
  }

  /// sends request to reset password
  Future<int> resetPassword(String email) async {
    var res = await http
        .post('http://10.0.2.2:8000/password-reset/', body: {"email": email});
    return res.statusCode;
  }

  /// edits users data
  Future<Map<String, String>> editAccount(id, email, telephone) async {
    var body;
    if (email != null && telephone != null) {
      body = {"email": email, "telephone": telephone};
    } else if (email != null) {
      body = {"email": email};
    } else if (telephone != null) {
      body = {"telephone": telephone};
    }
    var res =
        await http.put('http://10.0.2.2:8000/users/update/$id', body: body);
    var resDict = {
      "body": res.body.toString(),
      "statusCode": res.statusCode.toString(),
    };
    return resDict;
  }
}
