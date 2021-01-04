import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations("pl_pl") +
      {
        "pl_pl": "Nazwa",
        "en_uk": "Name",
      } +
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
        "pl_pl": "Edycja kamery nie powiodła się. Spróbuj ponownie.",
        "en_uk": "Editing camera failed. Try again.",
      } +
      {
        "pl_pl":
            "Błąd edytowania kamery. Sprawdź połączenie z serwerem i spróbuj ponownie.",
        "en_uk":
            "Camera editing error. Check the server connection and try again.",
      } +
      {
        "pl_pl": "Błąd edytowania kamery. Adres serwera nieprawidłowy.",
        "en_uk": "Camera editing error. The server address is invalid.",
      } +
      {
        "pl_pl": "Potwierdź",
        "en_uk": "Confirm",
      } +
      {
        "pl_pl": "Czy na pewno zapisać zmiany?",
        "en_uk": "Are you sure you want to save the changes?",
      } +
      {
        "pl_pl": "Nie wprowadzono żadnych zmian.",
        "en_uk": "No changes have been made.",
      };

  String get i18n => localize(this, _t);
}
