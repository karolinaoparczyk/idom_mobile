import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {

  static var _t = Translations("pl_pl") +
      {
        "pl_pl": "Tak",
        "en_uk": "Yes",
      } +
      {
        "pl_pl": "Nie",
        "en_uk": "No",
      };

  String get i18n => localize(this, _t);
}