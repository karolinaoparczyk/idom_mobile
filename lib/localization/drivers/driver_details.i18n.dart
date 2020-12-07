import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {

  static var _t = Translations("pl_pl") +
      {
        "pl_pl": "Nazwa",
        "en_uk": "Name",
      } +
      {
        "pl_pl": "Ogólne",
        "en_uk": "General",
      }+
      {
        "pl_pl": "Obsługa sterownika",
        "en_uk": "Driver handler",
      }+
      {
        "pl_pl": "Aktualny stan",
        "en_uk": "Current state",
      } +
      {
        "pl_pl": "Wciśnij przycisk",
        "en_uk": "Press the button",
      } +
      {
        "pl_pl": "WRÓĆ",
        "en_uk": "GO BACK",
      }+
      {
        "pl_pl": "Ustaw kolor",
        "en_uk": "Set color",
      }+
      {
        "pl_pl": "Ustaw jasność",
        "en_uk": "Set brightness",
      }+
      {
        "pl_pl": "włączona",
        "en_uk": "on",
      }+
      {
        "pl_pl": "wyłączona",
        "en_uk": "off",
      }+
      {
        "pl_pl": "Wysłano komendę zmiany koloru żarówki ",
        "en_uk": "The command to change the color of bulb ",
      }+
      {
        "pl_pl": "Wysłano komendę zmiany jasności żarówki ",
        "en_uk": "The command to change the brightness of bulb ",
      }+
      {
        "pl_pl": ".",
        "en_uk": " has been sent.",
      }+
      {
        "pl_pl": "Nie znaleziono sterownika ",
        "en_uk": "Driver ",
      }+
      {
        "pl_pl": " na serwerze. Odswież listę sterowników.",
        "en_uk": " not found on the server. Refresh the driver list. ",
      } +
      {
        "pl_pl": "Nie udało się podłączyć do sterownika ",
        "en_uk": "Failed to connect to driver ",
      }  +
      {
        "pl_pl": ". Sprawdź podłączenie i spróbuj ponownie.",
        "en_uk": ". Check the connection and try again.",
      } +
      {
        "pl_pl": "Wysłano komendę włączenia sterownika ",
        "en_uk": "The command to turn on driver ",
      }  +
      {
        "pl_pl": "Wysłano komendę wyłączenia sterownika ",
        "en_uk": "The command to turn off driver ",
      }  +
      {
        "pl_pl": "Wysłano komendę do sterownika ",
        "en_uk": "The command to driver ",
      }  +
      {
        "pl_pl": "Wysłanie komendy do sterownika ",
        "en_uk": "Sending the command to driver ",
      } +
      {
        "pl_pl": " nie powiodło się.",
        "en_uk": " failed.",
      }  +
      {
        "pl_pl": "Zapisano sterownik.",
        "en_uk": "Driver saved.",
      };

  String get i18n => localize(this, _t);
}