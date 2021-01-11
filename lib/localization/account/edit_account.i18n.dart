import 'package:i18n_extension/i18n_extension.dart';

/// translations for account edit page in polish and english
extension Localization on String {
  static var _t = Translations("pl_pl") +
      {
        "pl_pl": "Adres e-mail*",
        "en_uk": "E-mail address*",
      } +
      {
        "pl_pl": "Język powiadomień",
        "en_uk": "Notification language",
      } +
      {
        "pl_pl": "Nr telefonu komórkowego",
        "en_uk": "Cell phone number",
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
        "pl_pl":
            "Konto dla podanego adresu e-mail i numeru telefonu już istnieje.",
        "en_uk":
            "An account for the given e-mail address and cell phone number already exists.",
      } +
      {
        "pl_pl": "Konto dla podanego adresu e-mail już istnieje.",
        "en_uk": "An account for the given e-mail address already exists.",
      } +
      {
        "pl_pl": "Konto dla podanego numeru telefonu już istnieje.",
        "en_uk": "An account for the given cell phone number already exists.",
      } +
      {
        "pl_pl": "Numer telefonu jest nieprawidłowy.",
        "en_uk": "The cell phone number is invalid.",
      } +
      {
        "pl_pl": "Adres e-mail jest nieprawidłowy.",
        "en_uk": "The e-mail address is invalid.",
      } +
      {
        "pl_pl": "Adres e-mail oraz numer telefonu są nieprawidłowe.",
        "en_uk": "The e-mail address and cell phone number are invalid.",
      } +
      {
        "pl_pl":
            "Błąd edytowania użytkownika. Sprawdź połączenie z serwerem i spróbuj ponownie.",
        "en_uk":
            "User editing error. Check the server connection and try again.",
      } +
      {
        "pl_pl": "Błąd edytowania użytkownika. Adres serwera nieprawidłowy.",
        "en_uk": "User editing error. The server address is invalid.",
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
        "pl_pl": "polski",
        "en_uk": "polish",
      } +
      {
        "pl_pl": "angielski",
        "en_uk": "english",
      };

  String get i18n => localize(this, _t);
}
