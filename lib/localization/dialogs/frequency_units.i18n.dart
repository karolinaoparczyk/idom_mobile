import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {

  static var _t = Translations("pl_pl") +
      {
        "pl_pl": "Wybierz jednostki",
        "en_uk": "Select units",
      } +
      {
        "pl_pl": "Anuluj",
        "en_uk": "Cancel",
      };

  String get i18n => localize(this, _t);
}