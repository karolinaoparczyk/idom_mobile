import 'package:i18n_extension/i18n_extension.dart';

/// translations for validators in polish and english
extension Localization on String {
  static var _t = Translations("pl_pl") +
      {
        "pl_pl": "Pole wymagane",
        "en_uk": "Required field",
      } +
      {
        "pl_pl": "Login nie może zawierać spacji",
        "en_uk": "The login cannot contain spaces",
      } +
      {
        "pl_pl": "Login nie może zawierać więcej niż 25 znaków",
        "en_uk": "Login cannot contain more than 25 characters",
      } +
      {
        "pl_pl": "Hasło musi zawierać przynajmniej 8 znaków",
        "en_uk": "Password must contain at least 8 characters",
      } +
      {
        "pl_pl": "Hasło nie może zawierać więcej niż 25 znaków",
        "en_uk": "Password must not exceed 25 characters",
      } +
      {
        "pl_pl": "Podaj poprawny adres email",
        "en_uk": "Enter a valid email address",
      } +
      {
        "pl_pl": "Podaj numer telefonu postaci +XX XXX XXX XXX",
        "en_uk": "Provide a cell phone number as + XX XXX XXX XXX",
      } +
      {
        "pl_pl": "Podaj liczbę całkowitą z przedziału 1 - 30",
        "en_uk": "Enter an integer between 1 and 30",
      };

  String get i18n => localize(this, _t);
}
