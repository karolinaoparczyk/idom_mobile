import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {

  static var _t = Translations("pl_pl") +
      {
        "pl_pl": "< mniejsze niż",
        "en_uk": "< smaller than",
      } +
      {
        "pl_pl": "> większe niż",
        "en_uk": "> larger than",
      } +
      {
        "pl_pl": "= równe",
        "en_uk": "= equal to",
      };

  String get i18n => localize(this, _t);
}