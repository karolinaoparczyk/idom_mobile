import 'package:i18n_extension/i18n_extension.dart';

/// translations for sensor edit page in polish and english
extension Localization on String {
  static var _t = Translations("pl_pl") +
      {
        "pl_pl": "sekundy",
        "en_uk": "seconds",
      } +
      {
        "pl_pl": "minuty",
        "en_uk": "minutes",
      } +
      {
        "pl_pl": "godziny",
        "en_uk": "hours",
      } +
      {
        "pl_pl": "dni",
        "en_uk": "days",
      } +
      {
        "pl_pl": "Nazwa",
        "en_uk": "Name",
      } +
      {
        "pl_pl": "Kategoria",
        "en_uk": "Category",
      } +
      {
        "pl_pl": "Wartość",
        "en_uk": "Value",
      } +
      {
        "pl_pl": "Jednostki",
        "en_uk": "Units",
      } +
      {
        "pl_pl": "Ogólne",
        "en_uk": "General",
      } +
      {
        "pl_pl": "Częstotliwość pobierania danych",
        "en_uk": "Data gathering frequency",
      } +
      {
        "pl_pl": "Sesja użytkownika wygasła. \nTrwa wylogowywanie...",
        "en_uk": "User session has expired. \n Logout in progress...",
      } +
      {
        "pl_pl": "Czujnik o podanej nazwie już istnieje.",
        "en_uk": "A sensor with the given name already exists.",
      } +
      {
        "pl_pl": "Edycja czujnika nie powiodła się. Spróbuj ponownie.",
        "en_uk": "Editing sensor failed. Try again.",
      } +
      {
        "pl_pl":
            "Błąd edytowania czujnika. Sprawdź połączenie z serwerem i spróbuj ponownie.",
        "en_uk":
            "Sensor editing error. Check the server connection and try again.",
      } +
      {
        "pl_pl": "Błąd edytowania czujnika. Adres serwera nieprawidłowy.",
        "en_uk": "Sensor editing error. The server address is invalid.",
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
        "pl_pl":
            "Wartość częstotliwości pobierania danych musi być nieujemną liczbą całkowitą.",
        "en_uk":
            "The data gathering frequency value must be a non-negative integer.",
      } +
      {
        "pl_pl": "Poprawne wartości dla jednostki ",
        "en_uk": "Valid values for ",
      } +
      {
        "pl_pl": " to ",
        "en_uk": " are ",
      } +
      {
        "pl_pl": "Nie wprowadzono żadnych zmian.",
        "en_uk": "No changes have been made.",
      } +
      {
        "pl_pl": "sekundy",
        "en_uk": "seconds",
      } +
      {
        "pl_pl": "minuty",
        "en_uk": "minutes",
      } +
      {
        "pl_pl": "godziny",
        "en_uk": "hours",
      } +
      {
        "pl_pl": "dni",
        "en_uk": "days",
      } +
      {
        "pl_pl": "alkomat",
        "en_uk": "breathalyser",
      } +
      {
        "pl_pl": "ciśnienie atmosferyczne",
        "en_uk": "atmospheric pressure",
      } +
      {
        "pl_pl": "opady atmosferyczne",
        "en_uk": "precipitation",
      } +
      {
        "pl_pl": "temperatura powietrza",
        "en_uk": "air temperature",
      } +
      {
        "pl_pl": "temperatura wody",
        "en_uk": "water temperature",
      } +
      {
        "pl_pl": "dym",
        "en_uk": "smoke",
      } +
      {
        "pl_pl": "gaz",
        "en_uk": "gas",
      } +
      {
        "pl_pl": "ruch",
        "en_uk": "motion",
      } +
      {
        "pl_pl": "wilgotność gleby",
        "en_uk": "soil moisture",
      } +
      {
        "pl_pl": "wilgotność powietrza",
        "en_uk": "air humidity",
      };

  String get i18n => localize(this, _t);
}
