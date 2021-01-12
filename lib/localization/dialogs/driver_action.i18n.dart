import 'package:i18n_extension/i18n_extension.dart';

/// translations for language dialog in polish and english
extension Localization on String {
  static var _t = Translations("pl_pl") +
      {
        "pl_pl": "Wciśnij przycisk",
        "en_uk": "Press the button",
      } +
      {
        "pl_pl": "Włącz żarówkę",
        "en_uk": "Turn bulb on",
      } +
      {
        "pl_pl": "Wyłącz żarówkę",
        "en_uk": "Turn bulb off",
      } +
      {
        "pl_pl": "Wybierz akcję",
        "en_uk": "Select action",
      } +
      {
        "pl_pl": "Ustaw kolor",
        "en_uk": "Set color",
      } +
      {
        "pl_pl": "Ustaw jasność",
        "en_uk": "Set brightness",
      } +
      {
        "pl_pl": "Podnieś rolety",
        "en_uk": "Raise blinds",
      }+
      {
        "pl_pl": "Opuść rolety",
        "en_uk": "Lower blinds",
      } +
      {
        "pl_pl": "Anuluj",
        "en_uk": "Cancel",
      };

  String get i18n => localize(this, _t);
}
