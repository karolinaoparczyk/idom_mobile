import 'package:i18n_extension/i18n_extension.dart';

/// translations for sign in page in polish and english
extension Localization on String {
  static var _t = Translations("pl_pl") +
      {
        "pl_pl": "Konto zostało utworzone. Możesz się zalogować.",
        "en_uk": "The account has been created. You can log in.",
      } +
      {
        "pl_pl": "Nazwa użytkownika",
        "en_uk": "Username",
      } +
      {
        "pl_pl": "Hasło",
        "en_uk": "Password",
      } +
      {
        "pl_pl":
            "Błąd pobierania danych użytkownika. Spróbuj zalogować się ponownie.",
        "en_uk": "User data download error. Please try logging in again.",
      } +
      {
        "pl_pl":
            "Błąd logowania. Błędne hasło lub konto z podaną nazwą użytkownika nie istnieje.",
        "en_uk":
            "Login error. Wrong password or account with the given login does not exist.",
      } +
      {
        "pl_pl":
            "Błąd logowania. Sprawdź połączenie z serwerem i spróbuj ponownie.",
        "en_uk": "Login error. Check the server connection and try again.",
      } +
      {
        "pl_pl": "Błąd logowania. Adres serwera nieprawidłowy.",
        "en_uk": "Login error. The server address is invalid.",
      } +
      {
        "pl_pl": "Zaloguj się",
        "en_uk": "Sign in",
      } +
      {
        "pl_pl": "Zaloguj",
        "en_uk": "Sign in",
      } +
      {
        "pl_pl": "Zapomniałeś/aś hasła?",
        "en_uk": "Forgot password?",
      } +
      {
        "pl_pl": "E-mail został wysłany. Sprawdź pocztę.",
        "en_uk": "E-mail has been sent. Check your mailbox.",
      };

  String get i18n => localize(this, _t);
}
