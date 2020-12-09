import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations("pl_pl") +
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
        "pl_pl": "sekund",
        "en_uk": "seconds",
      } +
      {
        "pl_pl": "minut",
        "en_uk": "minutes",
      } +
      {
        "pl_pl": "godzin",
        "en_uk": "hours",
      } +
      {
        "pl_pl": "sekunda",
        "en_uk": "second",
      } +
      {
        "pl_pl": "minuta",
        "en_uk": "minute",
      } +
      {
        "pl_pl": "godzina",
        "en_uk": "hour",
      };

  String get i18n => localize(this, _t);
}
