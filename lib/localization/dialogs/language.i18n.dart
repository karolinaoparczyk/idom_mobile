import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations("pl_pl") +
      {
        "pl_pl": "polski",
        "en_uk": "polish",
      } +
      {
        "pl_pl": "angielski",
        "en_uk": "english",
      }+
      {
        "pl_pl": "Wybierz język powiadomień",
        "en_uk": "Select the language for the notifications",
      }+
      {
        "pl_pl": "Anuluj",
        "en_uk": "Cancel",
      };

  String get i18n => localize(this, _t);
}
