import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {

  static var _t = Translations("pl_pl") +
      {
        "pl_pl": " Adres serwera nie został ustawiony",
        "en_uk": " Server address has not been set",
      } +
      {
        "pl_pl": "TWÓJ INTELIGENTNY DOM\nW JEDNYM MIEJSCU",
        "en_uk": "YOUR SMART HOUSE\nIN ONE PLACE",
      } +
      {
        "pl_pl": "Edytuj adres serwera",
        "en_uk": "Edit server address",
      } +
      {
        "pl_pl": "Zaloguj",
        "en_uk": "Sign in",
      } +
      {
        "pl_pl": "Zarejestruj",
        "en_uk": "Sign up",
      } +
      {
        "pl_pl": "Zapomniałeś/aś hasła?",
        "en_uk": "Forgot password?",
      } +
      {
        "pl_pl": "Adres serwera został zapisany.",
        "en_uk": "Server address has been set",
      } +
      {
        "pl_pl": "E-mail został wysłany. Sprawdź pocztę.",
        "en_uk": "E-mail has been sent. Check your mailbox.",
      } +
      {
        "pl_pl": "Trwa ładowanie...",
        "en_uk": "Loading...",
      };

  String get i18n => localize(this, _t);
}