import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {

  static var _t = Translations("pl_pl") +
      {
        "pl_pl": "Otwórz w przeglądarce",
        "en_uk": "Open in browser",
      } +
      {
        "pl_pl": "Zapisano kamere.",
        "en_uk": "Camera has been saved.",
      } +
      {
        "pl_pl": "Sesja użytkownika wygasła. \nTrwa wylogowywanie...",
        "en_uk": "User session has expired. \n Logout in progress...",
      } +
      {
        "pl_pl": "Odświeżenie danych kamery nie powiodło się. Spróbuj ponownie.",
        "en_uk": "Refreshing the camera data has failed. Try again.",
      } +
      {
        "pl_pl": "Camera data download error. Sprawdź połączenie z serwerem i spróbuj ponownie.",
        "en_uk": "Sensor creating error. Check the server connection and try again.",
      } +
      {
        "pl_pl": "Camera data download error. Adres serwera nieprawidłowy.",
        "en_uk": "Sensor creating error. The server address is invalid.",
      };

  String get i18n => localize(this, _t);
}