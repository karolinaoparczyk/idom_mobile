import 'package:http/http.dart' as http;

class ApiSetup {
  Future<List<dynamic>> signIn(username, password) async {
    var result = await http.post('http://10.0.2.2:8000/api-token-auth/', body: {
      "username": username,
      "password": password,
    });
    return [result.body, result.statusCode];
  }
}