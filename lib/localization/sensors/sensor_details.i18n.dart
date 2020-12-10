import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {

  static var _t = Translations("pl_pl") +
      {
        "pl_pl": "Dane z czujnika",
        "en_uk": "Sensor data",
      } +
      {
        "pl_pl": "Nazwa",
        "en_uk": "Name",
      } +
      {
        "pl_pl": "Kategoria",
        "en_uk": "Category",
      } +
      {
        "pl_pl": "Ogólne",
        "en_uk": "General",
      }+
      {
        "pl_pl": "Dzisiaj",
        "en_uk": "Today",
      }+
      {
        "pl_pl": "Ostatnie 2 tygodnie",
        "en_uk": "Last 2 weeks",
      }+
      {
        "pl_pl": "Ostatnie 30 dni",
        "en_uk": "Last 30 days",
      } +
      {
        "pl_pl": "Aktualna temperatura",
        "en_uk": "Current temperature",
      } +
      {
        "pl_pl": "Aktualna wilgotność",
        "en_uk": "Current humidity",
      } +
      {
        "pl_pl": "Aktualne ciśnienie",
        "en_uk": "Current pressure",
      }  +
      {
        "pl_pl": "Ostatni pomiar",
        "en_uk": "Last measurement",
      }  +
      {
        "pl_pl": "Zapisano czujnik.",
        "en_uk": "Sensor saved.",
      }  +
      {
        "pl_pl": "Odświeżenie danych czujnika nie powiodło się.",
        "en_uk": "Refreshing sensor data failed.",
      }  +
      {
        "pl_pl": "Okres wyświetlanych danych",
        "en_uk": "Period of displayed data",
      } +
      {
        "pl_pl": "Częstotliwość pobierania danych",
        "en_uk": "Data gathering frequency",
      } +
      {
        "pl_pl": "Sesja użytkownika wygasła. \nTrwa wylogowywanie...",
        "en_uk": "User session has expired. \n Logout in progress...",
      }+
      {
        "pl_pl": "Błąd pobierania danych z czujnika. Sprawdź połączenie z serwerem i spróbuj ponownie.",
        "en_uk": "Error getting data from the sensor. Check the server connection and try again.",
      } +
      {
        "pl_pl": "Błąd pobierania danych z czujnika. Adres serwera nieprawidłowy.",
        "en_uk": "Error getting data from the sensor. The server address is invalid.",
      }+
      {
        "pl_pl": "Błąd pobierania danych czujnika. Sprawdź połączenie z serwerem i spróbuj ponownie.",
        "en_uk": "Error getting sensor data. Check the server connection and try again.",
      } +
      {
        "pl_pl": "Błąd pobierania danych czujnika. Adres serwera nieprawidłowy.",
        "en_uk": "Error getting sensor data. The server address is invalid.",
      } +
      {
        "pl_pl": "Brak danych z wybranego okresu.",
        "en_uk": "No data for the selected period.",
      }+
      {
        "pl_pl": "alkomat",
        "en_uk": "breathalyser",
      }+
      {
        "pl_pl": "ciśnienie atmosferyczne",
        "en_uk": "atmospheric pressure",
      } +
      {
        "pl_pl": "opady atmosferyczne",
        "en_uk": "precipitation",
      } +
      {
        "pl_pl": "temperatura powietrza",
        "en_uk": "air temperature",
      } +
      {
        "pl_pl": "temperatura wody",
        "en_uk": "water temperature",
      } +
      {
        "pl_pl": "stan powietrza",
        "en_uk": "air condition",
      } +
      {
        "pl_pl": "gaz",
        "en_uk": "gas",
      } +
      {
        "pl_pl": "wilgotność gleby",
        "en_uk": "soil moisture",
      } +
      {
        "pl_pl": "wilgotność powietrza",
        "en_uk": "air humidity",
      };

  String get i18n => localize(this, _t);
}