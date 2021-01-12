import 'package:i18n_extension/i18n_extension.dart';

/// translations for drawer in polish and english
extension Localization on String {
  static var _t = Translations("pl_pl") +
      {
        "pl_pl": "TWÓJ INTELIGENTNY DOM W JEDNYM MIEJSCU",
        "en_uk": "YOUR SMART HOUSE IN ONE PLACE",
      } +
      {
        "pl_pl": "Moje konto",
        "en_uk": "My account",
      } +
      {
        "pl_pl": "Wszystkie konta",
        "en_uk": "All accounts",
      } +
      {
        "pl_pl": "Czujniki",
        "en_uk": "Sensors",
      } +
      {
        "pl_pl": "Kamery",
        "en_uk": "Cameras",
      } +
      {
        "pl_pl": "Sterowniki",
        "en_uk": "Drivers",
      } +
      {
        "pl_pl": "Ustawienia",
        "en_uk": "Settings",
      } +
      {
        "pl_pl": "Pobierz dane",
        "en_uk": "Download data",
      } +
      {
        "pl_pl": "Wyloguj",
        "en_uk": "Log out",
      } +
      {
        "pl_pl": "O projekcie",
        "en_uk": "About project",
      };

  String get i18n => localize(this, _t);
}
