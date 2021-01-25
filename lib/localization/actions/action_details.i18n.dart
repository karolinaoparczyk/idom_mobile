import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations("pl_pl") +
      {
        "pl_pl": "Sesja użytkownika wygasła. \nTrwa wylogowywanie...",
        "en_uk": "User session has expired. \n Logout in progress...",
      } +
      {
        "pl_pl": "Nazwa",
        "en_uk": "Name",
      } +
      {
        "pl_pl": "Nalezy dodać numer telefonu.",
        "en_uk": "A phone number must be added.",
      } +
      {
        "pl_pl": "Akcja",
        "en_uk": "Action",
      } +
      {
        "pl_pl": "Włącz",
        "en_uk": "Turn on",
      } +
      {
        "pl_pl": "Wyłącz",
        "en_uk": "Turn off",
      } +
      {
        "pl_pl": "Ustaw jasność",
        "en_uk": "Set brightness",
      } +
      {
        "pl_pl": "Ustaw kolor",
        "en_uk": "Set color",
      } +
      {
        "pl_pl": "Czujnik",
        "en_uk": "Sensor",
      } +
      {
        "pl_pl": "Ogólne",
        "en_uk": "General",
      } +
      {
        "pl_pl": "Sterownik",
        "en_uk": "Driver",
      } +
      {
        "pl_pl": "Godzina",
        "en_uk": "Time",
      } +
      {
        "pl_pl": "Godziny",
        "en_uk": "Time",
      } +
      {
        "pl_pl": "Wyzwalacz",
        "en_uk": "Trigger",
      } +
      {
        "pl_pl": "Wartość z czujnika",
        "en_uk": "Sensor value",
      } +
      {
        "pl_pl": "Czas działania akcji",
        "en_uk": "Action time",
      } +
      {
        "pl_pl": "Dni tygodnia",
        "en_uk": "Days of the week",
      } +
      {
        "pl_pl": "pn",
        "en_uk": "Mon",
      } +
      {
        "pl_pl": "wt",
        "en_uk": "Tue",
      } +
      {
        "pl_pl": "śr",
        "en_uk": "Wed",
      } +
      {
        "pl_pl": "czw",
        "en_uk": "Thur",
      } +
      {
        "pl_pl": "pt",
        "en_uk": "Fri",
      } +
      {
        "pl_pl": "sb",
        "en_uk": "Sat",
      } +
      {
        "pl_pl": "nd",
        "en_uk": "Sun",
      } +
      {
        "pl_pl": "Odświeżenie danych akcji nie powiodło się.",
        "en_uk": "Refreshing action data failed.",
      } +
      {
        "pl_pl":
            "Błąd pobierania danych akcji. Sprawdź połączenie z serwerem i spróbuj ponownie.",
        "en_uk":
            "Error getting action data. Check the server connection and try again.",
      } +
      {
        "pl_pl": "Błąd pobierania danych akcji. Adres serwera nieprawidłowy.",
        "en_uk": "Error getting action data. The server address is invalid.",
      } +
      {
        "pl_pl": "Zapisano akcję.",
        "en_uk": "Action saved.",
      };

  String get i18n => localize(this, _t);
}
