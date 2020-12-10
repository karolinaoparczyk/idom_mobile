import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {

  static var _t = Translations("pl_pl") +
      {
        "pl_pl": "Dodano nową kamerę.",
        "en_uk": "A new camera has been added.",
      } +
      {
        "pl_pl": "Błąd połączenia z serwerem.",
        "en_uk": "Server connection error.",
      } +
      {
        "pl_pl": "Brak kamer w systemie.",
        "en_uk": "No cameras in the system.",
      } +
      {
        "pl_pl": "Kamery",
        "en_uk": "Cameras",
      } +
      {
        "pl_pl": "Trwa usuwanie kamery...",
        "en_uk": "Camera removal in progress...",
      }+
      {
        "pl_pl": "Sesja użytkownika wygasła. \nTrwa wylogowywanie...",
        "en_uk": "User session has expired. \n Logout in progress...",
      } +
      {
        "pl_pl": "Czy na pewno chcesz usunąć kamerę ",
        "en_uk": "Are you sure you want to remove camera ",
      } +
      {
        "pl_pl": "Błąd pobierania kamer. Sprawdź połączenie z serwerem i spróbuj ponownie.",
        "en_uk": "Cameras download error. Check the server connection and try again.",
      } +
      {
        "pl_pl": "Błąd pobierania kamer. Adres serwera nieprawidłowy.",
        "en_uk": "Cameras download error. The server address is invalid.",
      } +
      {
        "pl_pl": "Błąd usuwania kamery. Sprawdź połączenie z serwerem i spróbuj ponownie.",
        "en_uk": "Camera removal error. Check the server connection and try again.",
      } +
      {
        "pl_pl": "Usunięcie kamery nie powiodło się. Spróbuj ponownie.",
        "en_uk": "Camera removal failed. Try again.",
      } +
      {
        "pl_pl": "Potwierdź",
        "en_uk": "Confirm",
      };

  String get i18n => localize(this, _t);
}