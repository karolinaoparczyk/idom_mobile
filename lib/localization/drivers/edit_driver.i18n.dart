import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations("pl_pl") +
      {
        "pl_pl": "Nazwa",
        "en_uk": "Name",
      } +
      {
        "pl_pl": "Kategoria",
        "en_uk": "Category",
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
        "pl_pl": "Sterownik o podanej nazwie już istnieje.",
        "en_uk": "A driver with the given name already exists.",
      } +
      {
        "pl_pl": "Edycja sterownika nie powiodła się. Spróbuj ponownie.",
        "en_uk": "Editing driver failed. Try again.",
      } +
      {
        "pl_pl":
            "Błąd edytowania sterownika. Sprawdź połączenie z serwerem i spróbuj ponownie.",
        "en_uk":
            "Driver editing error. Check the server connection and try again.",
      } +
      {
        "pl_pl": "Błąd edytowania sterownika. Adres serwera nieprawidłowy.",
        "en_uk": "Driver editing error. The server address is invalid.",
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
      } +
      {
        "pl_pl": "naduszacz",
        "en_uk": "clicker",
      } +
      {
        "pl_pl": "pilot",
        "en_uk": "remote control",
      } +
      {
        "pl_pl": "żarówka",
        "en_uk": "bulb",
      } +
      {
        "pl_pl": "rolety",
        "en_uk": "blinds",
      } +
      {
        "pl_pl": "Adres IP",
        "en_uk": "IP address",
      } +
      {
        "pl_pl":
            "Podczas dodawania żarówki nie udało się zapisać adresu IP. Spróbuj ponownie.",
        "en_uk": "IP address could not be saved while adding bulb. Try again.",
      } +
      {
        "pl_pl":
            "Sterownik o podanej nazwie już istnieje. Adres IP jest niepoprawny.",
        "en_uk":
            "A driver with the given name already exists. The IP address is incorrect.",
      } +
      {
        "pl_pl": "Adres IP jest niepoprawny.",
        "en_uk": "The IP address is incorrect.",
      };

  String get i18n => localize(this, _t);
}
