import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {

  static var _t = Translations("pl_pl") +
     {
        "pl_pl": "Nazwa użytkownika*",
        "en_uk": "Username*",
      } +
      {
        "pl_pl": "Hasło*",
        "en_uk": "Password*",
      } +
      {
        "pl_pl": "Powtórz hasło*",
        "en_uk": "Confirm password*",
      } +
      {
        "pl_pl": "Hasła nie mogą się różnić",
        "en_uk": "Passwords cannot be different",
      }  +
      {
        "pl_pl": "Adres e-mail*",
        "en_uk": "E-mail address*",
      }  +
      {
        "pl_pl": "Nr telefonu komórkowego",
        "en_uk": "Cell phone number",
      } +
      {
        "pl_pl": "Zarejestruj się",
        "en_uk": "Register",
      } +
      {
        "pl_pl": "Potwierdź",
        "en_uk": "Confirm",
      } +
      {
        "pl_pl": "Czy na pewno wyczyścić wszystkie pola?",
        "en_uk": "Are you sure you want to clear all fields?",
      } +
      {
        "pl_pl": "Konto dla podanej nazwy użytkownika, adresu e-mail i numeru telefonu już istnieje.",
        "en_uk": "An account for the given username, e-mail address and cell phone number already exists.",
      } +
      {
        "pl_pl": "Konto dla podanej nazwy użytkownika i adresu e-mail już istnieje.",
        "en_uk": "An account for the given username and e-mail address already exists.",
      } +
      {
        "pl_pl": "Konto dla podanej nazwy użytkownika i numeru telefonu już istnieje.",
        "en_uk": "An account for the given username and cell phone number already exists.",
      } +
      {
        "pl_pl": "Konto dla podanego adresu e-mail i numeru telefonu już istnieje.",
        "en_uk": "An account for the given e-mail address and cell phone number already exists.",
      } +
      {
        "pl_pl": "Konto dla podanego adresu e-mail już istnieje.",
        "en_uk": "An account for the given e-mail address already exists.",
      } +
      {
        "pl_pl": "Konto dla podanej nazwy użytkownika już istnieje.",
        "en_uk": "An account for the given username already exists.",
      } +
      {
        "pl_pl": "Konto dla podanego numeru telefonu już istnieje.",
        "en_uk": "An account for the given cell phone number already exists.",
      } +
      {
        "pl_pl": " Podaj poprawny numeru telefonu.",
        "en_uk": " Enter a valid phone number.",
      } +
      {
        "pl_pl": "Błąd rejestracji. Sprawdź połączenie z serwerem i spróbuj ponownie.",
        "en_uk": "Registration failed. Check the server connection and try again.",
      } +
      {
        "pl_pl": "Błąd rejestracji. Adres serwera nieprawidłowy.",
        "en_uk": "Registration failed. The server address is invalid.",
      };

  String get i18n => localize(this, _t);
}