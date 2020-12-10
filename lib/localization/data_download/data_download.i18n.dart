import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations("pl_pl") +
      {
        "pl_pl": "Czujniki",
        "en_uk": "Sensors",
      } +
      {
        "pl_pl": "Uzupełnij filtry, aby wygenerować plik .csv z danymi",
        "en_uk": "Fill in filters to generate a .csv file with data",
      } +
      {
        "pl_pl": "Pobierz dane",
        "en_uk": "Download data",
      } +
      {
        "pl_pl": "Ilość ostatnich dni",
        "en_uk": "Amount of past days",
      } +
      {
        "pl_pl": "Sesja użytkownika wygasła. \nTrwa wylogowywanie...",
        "en_uk": "User session has expired. \n Logout in progress...",
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
        "pl_pl": "Usuń wybrane kategorie, aby wybrać czujniki.",
        "en_uk": "Delete selected categories to select sensors.",
      } +
      {
        "pl_pl": "Dodaj",
        "en_uk": "Add",
      } +
      {
        "pl_pl": "Kategorie",
        "en_uk": "Categories",
      } +
      {
        "pl_pl": "Plik ",
        "en_uk": "File ",
      } +
      {
        "pl_pl": "został wygenerowany i zapisany w plikach urządzenia.",
        "en_uk": "has been generated and saved in device files.",
      } +
      {
        "pl_pl": "Nie udało się wygenerować pliku. Spróbuj ponownie.",
        "en_uk": "The file could not be generated. Try again.",
      } +
      {
        "pl_pl": "Generuj plik",
        "en_uk": "Generate file",
      } +
      {
        "pl_pl": "Usuń wybrane czujniki, aby wybrać kategorie.",
        "en_uk": "Delete selected sensors to select categories.",
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
        "pl_pl": "stan powietrza",
        "en_uk": "air condition",
      } +
      {
        "pl_pl": "gaz",
        "en_uk": "gas",
      } +
      {
        "pl_pl": "wilgotność gleby",
        "en_uk": "soil moisture",
      } +
      {
        "pl_pl": "wilgotność powietrza",
        "en_uk": "air humidity",
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
      };

  String get i18n => localize(this, _t);
}
