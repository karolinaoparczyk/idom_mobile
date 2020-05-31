import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class Api {
  /// requests signing in
  Future<List<dynamic>> signIn(username, password) async {
    var result = await http.post('http://10.0.2.2:8000/api-token-auth/', body: {
      "username": username,
      "password": password,
    });
    return [result.body, result.statusCode];
  }

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

  /// requests deactivating user
  Future<Response> getSensors(String userToken) async {
    try {
      var res = await http.get('http://10.0.2.2:8000/sensors/list',
          headers: {HttpHeaders.authorizationHeader: "Token $userToken"});
      return res;
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<int> resetPassword(String email) async {
    var res = await http
        .post('http://10.0.2.2:8000/password-reset/', body: {"email": email});
    return res.statusCode;
  }

  Future<int> editAccount(id, email, telephone) async {
    var res = await http.put('http://10.0.2.2:8000/users/update/$id',
        body: {"email": email, "telephone": telephone});
    return res.statusCode;
  }
}
