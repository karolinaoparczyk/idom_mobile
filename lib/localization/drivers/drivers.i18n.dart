import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {

  static var _t = Translations("pl_pl") +
      {
        "pl_pl": "Dodano nowy sterownik.",
        "en_uk": "A new driver has been added.",
      } +
      {
        "pl_pl": "Wciśnij przycisk",
        "en_uk": "Press the button",
      }+
      {
        "pl_pl": "Błąd połączenia z serwerem.",
        "en_uk": "Server connection error.",
      } +
      {
        "pl_pl": "Brak sterowników w systemie.",
        "en_uk": "No drivers in the system.",
      } +
      {
        "pl_pl": "Sterowniki",
        "en_uk": "Drivers",
      }  +
      {
        "pl_pl": "Włącz/wyłącz pilot",
        "en_uk": "Turn remote control on/off",
      }  +
      {
        "pl_pl": "Włącz/wyłącz żarówkę",
        "en_uk": "Turn bulb on/off",
      } +
      {
        "pl_pl": "Usuń",
        "en_uk": "Remove",
      } +
      {
        "pl_pl": "Trwa usuwanie sterownika...",
        "en_uk": "Driver removal in progress...",
      } +
      {
        "pl_pl": "Sesja użytkownika wygasła. \nTrwa wylogowywanie...",
        "en_uk": "User session has expired. \n Logout in progress...",
      } +
      {
        "pl_pl": "Czy na pewno chcesz usunąć sterownik ",
        "en_uk": "Are you sure you want to remove driver ",
      } +
      {
        "pl_pl": "Błąd pobierania sterowników. Sprawdź połączenie z serwerem i spróbuj ponownie.",
        "en_uk": "Drivers download error. Check the server connection and try again.",
      } +
      {
        "pl_pl": "Błąd pobierania sterowników. Adres serwera nieprawidłowy.",
        "en_uk": "Drivers download error. The server address is invalid.",
      } +
      {
        "pl_pl": "Błąd usuwania sterownika. Sprawdź połączenie z serwerem i spróbuj ponownie.",
        "en_uk": "Driver removal error. Check the server connection and try again.",
      } +
      {
        "pl_pl": "Usunięcie sterownika nie powiodło się. Spróbuj ponownie.",
        "en_uk": "Driver removal failed. Try again.",
      } +
      {
        "pl_pl": "Potwierdź",
        "en_uk": "Confirm",
      } +
      {
        "pl_pl": "Wysłano komendę do sterownika ",
        "en_uk": "The command to driver ",
      }  +
      {
        "pl_pl": "Wysłanie komendy do sterownika ",
        "en_uk": "Sending the command to driver ",
      } +
      {
        "pl_pl": " nie powiodło się.",
        "en_uk": " failed.",
      }+
      {
        "pl_pl": ".",
        "en_uk": " has been sent.",
      };

  String get i18n => localize(this, _t);
}