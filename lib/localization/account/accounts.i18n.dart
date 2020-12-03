import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {

  static var _t = Translations("pl_pl") +
     {
        "pl_pl": "Brak wyników wyszukiwania.",
        "en_uk": "No search results.",
      } +
      {
        "pl_pl": "Błąd połączenia z serwerem.",
        "en_uk": "Server connection error.",
      } +
      {
        "pl_pl": "Brak kont w systemie.",
        "en_uk": "No users in the system.",
      } +
      {
        "pl_pl": "Wszystkie konta",
        "en_uk": "All accounts",
      } +
      {
        "pl_pl": "Trwa usuwanie konta...",
        "en_uk": "User removal in progress...",
      } +
      {
        "pl_pl": "Wyszukaj...",
        "en_uk": "Search...",
      } +
      {
        "pl_pl": "Sesja użytkownika wygasła. \nTrwa wylogowywanie...",
        "en_uk": "User session has expired. \n Logout in progress...",
      } +
      {
        "pl_pl": "Czy na pewno chcesz usunąć konto ",
        "en_uk": "Are you sure you want to remove user ",
      } +
      {
        "pl_pl": "Błąd pobierania kont. Sprawdź połączenie z serwerem i spróbuj ponownie.",
        "en_uk": "Users download error. Check the server connection and try again.",
      } +
      {
        "pl_pl": "Błąd pobierania kont. Adres serwera nieprawidłowy.",
        "en_uk": "Users download error. The server address is invalid.",
      } +
      {
        "pl_pl": "Błąd usuwania konta. Sprawdź połączenie z serwerem i spróbuj ponownie.",
        "en_uk": "User removal error. Check the server connection and try again.",
      } +
      {
        "pl_pl": "Błąd usuwania konta. Adres serwera nieprawidłowy.",
        "en_uk": "User removal error. The server address is invalid.",
      } +
      {
        "pl_pl": "Usunięcie konta nie powiodło się. Spróbuj ponownie.",
        "en_uk": "User removal failed. Try again.",
      } +
      {
        "pl_pl": "Potwierdź",
        "en_uk": "Confirm",
      };

  String get i18n => localize(this, _t);
}