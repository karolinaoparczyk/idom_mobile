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
      };

  String get i18n => localize(this, _t);
}