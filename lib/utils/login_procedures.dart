import 'dart:convert';

import 'package:idom/api.dart';
import 'package:idom/models.dart';
import 'package:idom/utils/secure_storage.dart';

class LoginProcedures {
  static SecureStorage storage;
  static Api apiServer;

  static Future<void> init(SecureStorage secureStorage, Api api) {
    storage = secureStorage;
    apiServer = api;
  }

  static Future<String> signInWithStoredData() async {
    final username = await storage.getUsername();
    final password = await storage.getPassword();
    storage.setToken('');
    final message = await signIn(username, password);
    return message;
  }

  /// tries to sign in the user with provided credentials
  static Future<String> signIn(String username, String password) async {
    String message;
    try {
      var result = await apiServer.signIn(username, password);
      if (result[1] == 200 && result[0].toString().contains('token')) {
        var userResult = await apiServer.getUser(username,
            userToken: result[0].split(':')[1].substring(1, 41));
        if (userResult[1] == 200) {
          dynamic body = jsonDecode(userResult[0]);
          Account account = Account.fromJson(body);

          storage.setUserData(
              account.username,
              password,
              account.email,
              account.language,
              account.telephone,
              account.id.toString(),
              account.smsNotifications.toString(),
              account.appNotifications.toString(),
              account.isActive.toString(),
              account.isStaff.toString(),
              result[0].split(':')[1].substring(1, 41));

          var isSetLoggedIn = await storage.getIsLoggedIn();
          if (isSetLoggedIn == "true") {
            return null;
          }
        } else if (userResult[1] == 401) {
          message =
              "Błąd pobierania danych użytkownika. Spróbuj zalogować się ponownie.";
        }
      } else if (result[1] == 400) {
        message =
            "Błąd logowania. Błędne hasło lub konto z podaną nazwą użytkownika nie istnieje.";
      } else {
        message =
            "Błąd logowania. Sprawdź połączenie z serwerem i spróbuj ponownie.";
      }
    } catch (e) {
      print(e.toString());
      if (e.toString().contains("TimeoutException")) {
        message =
            "Błąd logowania. Sprawdź połączenie z serwerem i spróbuj ponownie.";
      }
      if (e.toString().contains("SocketException")) {
        message = "Błąd logowania. Adres serwera nieprawidłowy.";
      } else {
        message =
            "Błąd logowania. Sprawdź połączenie z serwerem i spróbuj ponownie.";
      }
    }
    return message;
  }
}
