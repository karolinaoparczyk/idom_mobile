import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {

  static var _t = Translations("pl_pl") +
      {
        "pl_pl": "Adres serwera",
        "en_uk": "Server address",
      } +
      {
        "pl_pl": "Ustawienia",
        "en_uk": "Settings",
      } +
      {
        "pl_pl": "Plik google_services.json",
        "en_uk": "google_services.json file",
      } +
      {
        "pl_pl": "Plik jest niepoprawny. Pobierz go z serwisu Firebase i spróbuj ponownie.",
        "en_uk": "The file is invalid. Please download it from Firebase and try again.",
      } +
      {
        "pl_pl": "Należy dodać plik.",
        "en_uk": "You must add a file.",
      } +
      {
        "pl_pl": "Nie wprowadzono żadnych zmian.",
        "en_uk": "No changes have been made.",
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
        "pl_pl": "Ustawienia zostały zapisane.",
        "en_uk": "The settings have been saved.",
      }+
      {
        "pl_pl": "Konfiguracja",
        "en_uk": "Configuration",
      }+
      {
        "pl_pl": "Preferencje",
        "en_uk": "Preferences",
      }+
      {
        "pl_pl": "Motyw",
        "en_uk": "Theme",
      }+
      {
        "pl_pl": "jasny",
        "en_uk": "light",
      }+
      {
        "pl_pl": "ciemny",
        "en_uk": "dark",
      };

  String get i18n => localize(this, _t);
}