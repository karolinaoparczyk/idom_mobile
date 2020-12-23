import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations("pl_pl") +
      {
        "pl_pl": "Wybierz kategorię",
        "en_uk": "Select a category",
      } +
      {
        "pl_pl": "Anuluj",
        "en_uk": "Cancel",
      } +
      {
        "pl_pl": "alkomat",
        "en_uk": "breathalyser",
      } +
      {
        "pl_pl": "ciśnienie atmosferyczne",
        "en_uk": "atmospheric pressure",
      } +
      {
        "pl_pl": "opady atmosferyczne",
        "en_uk": "precipitation",
      } +
      {
        "pl_pl": "temperatura powietrza",
        "en_uk": "air temperature",
      } +
      {
        "pl_pl": "temperatura wody",
        "en_uk": "water temperature",
      } +
      {
        "pl_pl": "dym",
        "en_uk": "smoke",
      } +
      {
        "pl_pl": "gaz",
        "en_uk": "gas",
      } +
      {
        "pl_pl": "wilgotność gleby",
        "en_uk": "soil moisture",
      } +
      {
        "pl_pl": "wilgotność powietrza",
        "en_uk": "air humidity",
      }+
      {
        "pl_pl": "Wybierz kategorie",
        "en_uk": "Choose categories",
      }+
      {
        "pl_pl": "Wyszukaj...",
        "en_uk": "Search...",
      } +
      {
        "pl_pl": "naduszacz",
        "en_uk": "clicker",
      } +
      {
        "pl_pl": "pilot",
        "en_uk": "remote control",
      } +
      {
        "pl_pl": "żarówka",
        "en_uk": "bulb",
      }+
      {
        "pl_pl": "rolety",
        "en_uk": "blinds",
      };

  String get i18n => localize(this, _t);
}
