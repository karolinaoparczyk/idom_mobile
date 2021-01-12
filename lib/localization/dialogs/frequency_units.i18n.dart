import 'package:i18n_extension/i18n_extension.dart';

/// translations for frequency units dialog in polish and english
extension Localization on String {
  static var _t = Translations("pl_pl") +
      {
        "pl_pl": "Wybierz jednostki",
        "en_uk": "Select units",
      } +
      {
        "pl_pl": "Anuluj",
        "en_uk": "Cancel",
      } +
      {
        "pl_pl": "sekundy",
        "en_uk": "seconds",
      } +
      {
        "pl_pl": "minuty",
        "en_uk": "minutes",
      } +
      {
        "pl_pl": "godziny",
        "en_uk": "hours",
      } +
      {
        "pl_pl": "dni",
        "en_uk": "days",
      };

  String get i18n => localize(this, _t);
}
