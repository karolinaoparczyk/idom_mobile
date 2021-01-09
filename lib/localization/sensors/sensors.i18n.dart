import 'package:i18n_extension/i18n_extension.dart';

/// translations for sensor list page in polish and english
extension Localization on String {
  static var _t = Translations("pl_pl") +
      {
        "pl_pl": "Dodano nowy czujnik.",
        "en_uk": "A new sensor has been added.",
      } +
      {
        "pl_pl": "ostatnia dana",
        "en_uk": "last data",
      } +
      {
        "pl_pl": "Brak wyników wyszukiwania.",
        "en_uk": "No search results.",
      } +
      {
        "pl_pl": "Błąd połączenia z serwerem.",
        "en_uk": "Server connection error.",
      } +
      {
        "pl_pl": "Brak czujników w systemie.",
        "en_uk": "No sensors in the system.",
      } +
      {
        "pl_pl": "Czujniki",
        "en_uk": "Sensors",
      } +
      {
        "pl_pl": "Trwa usuwanie czujnika...",
        "en_uk": "Sensor removal in progress...",
      } +
      {
        "pl_pl": "Wyszukaj...",
        "en_uk": "Search...",
      } +
      {
        "pl_pl": "Sesja użytkownika wygasła. \nTrwa wylogowywanie...",
        "en_uk": "User session has expired. \n Logout in progress...",
      } +
      {
        "pl_pl": "Czy na pewno chcesz usunąć czujnik ",
        "en_uk": "Are you sure you want to remove sensor ",
      } +
      {
        "pl_pl":
            "Błąd pobierania czujników. Sprawdź połączenie z serwerem i spróbuj ponownie.",
        "en_uk":
            "Sensors download error. Check the server connection and try again.",
      } +
      {
        "pl_pl": "Błąd pobierania czujników. Adres serwera nieprawidłowy.",
        "en_uk": "Sensors download error. The server address is invalid.",
      } +
      {
        "pl_pl":
            "Błąd usuwania czujnika. Sprawdź połączenie z serwerem i spróbuj ponownie.",
        "en_uk":
            "Sensor removal error. Check the server connection and try again.",
      } +
      {
        "pl_pl": "Usunięcie czujnika nie powiodło się. Spróbuj ponownie.",
        "en_uk": "Sensor removal failed. Try again.",
      } +
      {
        "pl_pl": "Potwierdź",
        "en_uk": "Confirm",
      } +
      {
        "pl_pl": "Na pewno wyjść z aplikacji?",
        "en_uk": "Are you sure you want to quit the app?",
      };

  String get i18n => localize(this, _t);
}
