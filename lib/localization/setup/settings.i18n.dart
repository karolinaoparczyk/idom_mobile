import 'package:i18n_extension/i18n_extension.dart';

/// translations for settings page in polish and english
extension Localization on String {
  static var _t = Translations("pl_pl") +
      {
        "pl_pl": "Adres serwera",
        "en_uk": "Server address",
      } +
      {
        "pl_pl": "Zapisywanie ustawień...",
        "en_uk": "Saving settings...",
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
        "pl_pl":
            "Plik jest niepoprawny. Pobierz go z serwisu Firebase i spróbuj ponownie.",
        "en_uk":
            "The file is invalid. Please download it from Firebase and try again.",
      } +
      {
        "pl_pl":
            "Nie udało się połączyć z serwisem firebase. Sprawdź czy plik google_services.json jest aktualny oraz połączenie z internetem.",
        "en_uk":
            "Failed to connect to firebase. Check if the google_services.json file is up-to-date and an internet connection.",
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
      } +
      {
        "pl_pl": "Konfiguracja",
        "en_uk": "Configuration",
      } +
      {
        "pl_pl": "Preferencje",
        "en_uk": "Preferences",
      } +
      {
        "pl_pl": "Motyw",
        "en_uk": "Theme",
      } +
      {
        "pl_pl": "jasny",
        "en_uk": "light",
      } +
      {
        "pl_pl": "ciemny",
        "en_uk": "dark",
      } +
      {
        "pl_pl": "Dane",
        "en_uk": "Data",
      } +
      {
        "pl_pl": "Jak mogę usunąć dane?",
        "en_uk": "How can I delete my data?",
      };

  String get i18n => localize(this, _t);
}
