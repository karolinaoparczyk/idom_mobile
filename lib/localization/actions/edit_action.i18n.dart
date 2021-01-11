import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {

  static var _t = Translations("pl_pl") +
      {
        "pl_pl": "Sesja użytkownika wygasła. \nTrwa wylogowywanie...",
        "en_uk": "User session has expired. \n Logout in progress...",
      } +
      {
        "pl_pl":
        "Błąd pobierania czujników. Sprawdź połączenie z serwerem i spróbuj ponownie.",
        "en_uk":
        "Sensors download error. Check the server connection and try again.",
      } +
      {
        "pl_pl": "Błąd pobierania czujników. Adres serwera nieprawidłowy.",
        "en_uk": "Sensors download error. The server address is invalid.",
      } +
      {
        "pl_pl":
        "Błąd pobierania sterowników. Sprawdź połączenie z serwerem i spróbuj ponownie.",
        "en_uk":
        "Drivers download error. Check the server connection and try again.",
      } +
      {
        "pl_pl": "Błąd pobierania sterowników. Adres serwera nieprawidłowy.",
        "en_uk": "Drivers download error. The server address is invalid.",
      } +
      {
        "pl_pl": "Nazwa",
        "en_uk": "Name",
      } +
      {
        "pl_pl": "Czujnik",
        "en_uk": "Sensor",
      } +
      {
        "pl_pl": "Wartość",
        "en_uk": "Value",
      } +
      {
        "pl_pl": "Pole wymagane",
        "en_uk": "Required field",
      }  +
      {
        "pl_pl": "Podaj liczbę",
        "en_uk": "Enter a number",
      } +
      {
        "pl_pl": "Edytuj akcję",
        "en_uk": "Edit action",
      } +
      {
        "pl_pl": "Ogólne",
        "en_uk": "General",
      } +
      {
        "pl_pl": "Sterownik",
        "en_uk": "Driver",
      } +
      {
        "pl_pl": "Akcja o podanej nazwie już istnieje.",
        "en_uk": "An action with the given name already exists.",
      } +
      {
        "pl_pl": "Edytowanie akcji nie powiodło się. Spróbuj ponownie.",
        "en_uk": "Editing action failed. Try again.",
      } +
      {
        "pl_pl":
        "Błąd edytowania akcji. Sprawdź połączenie z serwerem i spróbuj ponownie.",
        "en_uk":
        "Action editing error. Check the server connection and try again.",
      } +
      {
        "pl_pl": "Błąd edytowania akcji. Adres serwera nieprawidłowy.",
        "en_uk": "Action editing error. The server address is invalid.",
      } +
      {
        "pl_pl": "Potwierdź",
        "en_uk": "Confirm",
      }  +
      {
        "pl_pl": "Czy na pewno zapisać zmiany?",
        "en_uk": "Are you sure you want to save the changes?",
      }+
      {
        "pl_pl": "Anuluj",
        "en_uk": "Cancel",
      } +
      {
        "pl_pl": "Wybierz godzinę",
        "en_uk": "Choose time",
      } +
      {
        "pl_pl": "Koniec",
        "en_uk": "End",
      } +
      {
        "pl_pl": "Wyzwalacz na czujniku",
        "en_uk": "Trigger on the sensor",
      } +
      {
        "pl_pl": "Czas działania akcji",
        "en_uk": "Action time",
      } +
      {
        "pl_pl": "pn",
        "en_uk": "Mon",
      } +
      {
        "pl_pl": "wt",
        "en_uk": "Tue",
      } +
      {
        "pl_pl": "śr",
        "en_uk": "Wed",
      } +
      {
        "pl_pl": "czw",
        "en_uk": "Thur",
      } +
      {
        "pl_pl": "pt",
        "en_uk": "Fri",
      } +
      {
        "pl_pl": "sb",
        "en_uk": "Sat",
      } +
      {
        "pl_pl": "nd",
        "en_uk": "Sun",
      } +
      {
        "pl_pl":
        "Godzina zakończenia musi być późniejsza od godziny rozpoczęcia.",
        "en_uk": "The end time must be later than the start time.",
      } +
      {
        "pl_pl": "Należy wybrać przynajmniej jeden dzień działania akcji.",
        "en_uk": "You must select at least one day for the action to run.",
      } +
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
      } +
      {
        "pl_pl": "Nie wprowadzono żadnych zmian.",
        "en_uk": "No changes have been made.",
      };

  String get i18n => localize(this, _t);
}