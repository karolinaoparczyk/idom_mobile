import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations("pl_pl") +
      {
        "pl_pl": "Błąd połączenia z serwerem.",
        "en_uk": "Server connection error.",
      } +
      {
        "pl_pl": "Brak akcji w systemie.",
        "en_uk": "No actions in the system.",
      } +
      {
        "pl_pl": "Brak wyników wyszukiwania.",
        "en_uk": "No search results.",
      } +
      {
        "pl_pl": "Wyszukaj...",
        "en_uk": "Search...",
      } +
      {
        "pl_pl": "Akcje",
        "en_uk": "Actions",
      } +
      {
        "pl_pl": "Dodano nową akcję.",
        "en_uk": "A new action has been added.",
      } +
      {
        "pl_pl": "Trwa usuwanie akcji...",
        "en_uk": "Action removal in progress...",
      } +
      {
        "pl_pl": "Sesja użytkownika wygasła. \nTrwa wylogowywanie...",
        "en_uk": "User session has expired. \n Logout in progress...",
      } +
      {
        "pl_pl": "Czy na pewno chcesz usunąć akcję ",
        "en_uk": "Are you sure you want to remove action ",
      } +
      {
        "pl_pl":
            "Błąd pobierania akcji. Sprawdź połączenie z serwerem i spróbuj ponownie.",
        "en_uk":
            "Actions download error. Check the server connection and try again.",
      } +
      {
        "pl_pl": "Błąd pobierania akcji. Adres serwera nieprawidłowy.",
        "en_uk": "Actions download error. The server address is invalid.",
      } +
      {
        "pl_pl":
            "Błąd usuwania akcji. Sprawdź połączenie z serwerem i spróbuj ponownie.",
        "en_uk":
            "Action removal error. Check the server connection and try again.",
      } +
      {
        "pl_pl": "Błąd usuwania akcji. Adres serwera nieprawidłowy.",
        "en_uk": "Action removal error. The server address is invalid.",
      } +
      {
        "pl_pl": "Usunięcie akcji nie powiodło się. Spróbuj ponownie.",
        "en_uk": "Action removal failed. Try again.",
      } +
      {
        "pl_pl": "Potwierdź",
        "en_uk": "Confirm",
      };

  String get i18n => localize(this, _t);
}
