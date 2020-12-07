import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {

  static var _t = Translations("pl_pl") +
    {
        "pl_pl": "Nazwa",
        "en_uk": "Name",
      }+
      {
        "pl_pl": "Dodaj kamerę",
        "en_uk": "Create camera",
      }  +
      {
        "pl_pl": "Ogólne",
        "en_uk": "General",
      } +
      {
        "pl_pl": "Sesja użytkownika wygasła. \nTrwa wylogowywanie...",
        "en_uk": "User session has expired. \n Logout in progress...",
      } +
      {
        "pl_pl": "Kamera o podanej nazwie już istnieje.",
        "en_uk": "A camera with the given name already exists.",
      } +
      {
        "pl_pl": "Dodawanie kamery nie powiodło się. Spróbuj ponownie.",
        "en_uk": "Creating camera failed. Try again.",
      } +
      {
        "pl_pl": "Błąd dodawania kamery. Sprawdź połączenie z serwerem i spróbuj ponownie.",
        "en_uk": "Camera creating error. Check the server connection and try again.",
      } +
      {
        "pl_pl": "Błąd dodawania kamery. Adres serwera nieprawidłowy.",
        "en_uk": "Camera creating error. The server address is invalid.",
      };

  String get i18n => localize(this, _t);
}