import 'package:idom/localization/enums/categories.i18n.dart';

class SensorCategories {
  static final values = [
    {"text": "alkomat".i18n, "value": "breathalyser"},
    {"text": "ciśnienie atmosferyczne".i18n, "value": "atmo_pressure"},
    {"text": "opady atmosferyczne".i18n, "value": "rain_sensor"},
    {"text": "temperatura powietrza".i18n, "value": "temperature"},
    {"text": "temperatura wody".i18n, "value": "water_temp"},
    {"text": "stan powietrza".i18n, "value": "smoke"},
    {"text": "gaz".i18n, "value": "gas"},
    {"text": "wilgotność gleby".i18n, "value": "humidity"},
    {"text": "wilgotność powietrza".i18n, "value": "air_humidity"},
  ];
}

class DriverCategories {
  static final values = [
    {"text": "naduszacz".i18n, "value": "clicker"},
    {"text": "pilot".i18n, "value": "remote_control"},
    {"text": "żarówka".i18n, "value": "bulb"},
    {"text": "rolety".i18n, "value": "roller_blind"},
  ];
}
