import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations("pl_pl") +
      {
        "pl_pl": "Adres e-mail",
        "en_uk": "E-mail address",
      } +
      {
        "pl_pl": "Reset hasła",
        "en_uk": "Reset password",
      } +
      {
        "pl_pl": "Podaj adres e-mail połączony z Twoim kontem",
        "en_uk": "Enter the e-mail address associated with your account",
      } +
      {
        "pl_pl": "Resetuj hasło",
        "en_uk": "Reset password",
      } +
      {
        "pl_pl": "Link do resetu hasła został wysłany na podany adres e-mail.",
        "en_uk":
            "A link to reset a password has been sent to the provided e-mail address.",
      } +
      {
        "pl_pl": "Konto dla podanego adresu e-mail nie istnieje.",
        "en_uk": "Password reset error. Check the server connection and try again.",
      } +
      {
        "pl_pl": "Błąd resetu hasła. Adres serwera nieprawidłowy.",
        "en_uk": "Password reset error. The server address is invalid.",
      };

  String get i18n => localize(this, _t);
}
