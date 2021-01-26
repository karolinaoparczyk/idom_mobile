import 'package:i18n_extension/i18n_extension.dart';

/// translations for data download page in polish and english
extension Localization on String {
  static var _t = Translations("pl_pl") +
      {
        "pl_pl": "Usuwanie danych",
        "en_uk": "Data removal",
      } ;

  String get i18n => localize(this, _t);
}
