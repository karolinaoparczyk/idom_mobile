import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {

  static var _t = Translations("pl_pl") +
      {
        "pl_pl": "Błąd pobierania danych użytkownika.",
        "en_uk": "User data download error.",
      }+
      {
        "pl_pl": "Ogólne",
        "en_uk": "General",
      }+
      {
        "pl_pl": "Nazwa użytkownika",
        "en_uk": "Username",
      }+
      {
        "pl_pl": "Adres e-mail",
        "en_uk": "E-mail address",
      }+
      {
        "pl_pl": "Nr telefonu komórkowego",
        "en_uk": "Cell phone number",
      } +
      {
        "pl_pl": "Powiadomienia",
        "en_uk": "Notifications",
      } +
      {
        "pl_pl": "Aplikacja",
        "en_uk": "Application",
      }  +
      {
        "pl_pl": "Błąd edycji powiadomień. Spróbuj ponownie.",
        "en_uk": "Editing notifications error. Try again.",
      }  +
      {
        "pl_pl": "Zapisano dane użytkownika.",
        "en_uk": "User data saved.",
      } +
      {
        "pl_pl": "Sesja użytkownika wygasła. \nTrwa wylogowywanie...",
        "en_uk": "User session has expired. \n Logout in progress...",
      }+
      {
        "pl_pl": "Odświeżenie danych użytkownika nie powiodło się.",
        "en_uk": "Refreshing user data failed.",
      }+
      {
        "pl_pl": "Błąd pobierania danych użytkownika. Sprawdź połączenie z serwerem i spróbuj ponownie.",
        "en_uk": "User data retrieval error. Check the server connection and try again.",
      } +
      {
        "pl_pl": "Błąd pobierania danych użytkownika. Adres serwera nieprawidłowy.",
        "en_uk": "User data retrieval error. The server address is invalid.",
      };

  String get i18n => localize(this, _t);
}