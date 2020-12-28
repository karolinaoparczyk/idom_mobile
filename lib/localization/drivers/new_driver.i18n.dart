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
        "pl_pl": "Dodaj sterownik",
        "en_uk": "Create driver",
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
        "pl_pl": "Dodawanie sterownika nie powiodło się. Spróbuj ponownie.",
        "en_uk": "Creating driver failed. Try again.",
      } +
      {
        "pl_pl":
            "Błąd dodawania sterownika. Sprawdź połączenie z serwerem i spróbuj ponownie.",
        "en_uk":
            "Driver creating error. Check the server connection and try again.",
      } +
      {
        "pl_pl": "Błąd dodawania sterownika. Adres serwera nieprawidłowy.",
        "en_uk": "Driver creating error. The server address is invalid.",
      } +
      {
        "pl_pl": "przycisk",
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
      };

  String get i18n => localize(this, _t);
}
