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
  Future<int> deactivateAccount(int id) async{
    try {
      var res = await http.delete('http://10.0.2.2:8000/register/$id');
      print(res.statusCode);
      print(res.body);
      return res.statusCode;
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<int> resetPassword(String email) async {
    var res = await http
        .post('http://10.0.2.2:8000/password-reset/', body: {"email": email});
    print(res.statusCode);
    print(res.body);
    return res.statusCode;
  }
}
