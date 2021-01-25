/// allowed sensor categories
class SensorCategories {
  /// categories values
  ///
  /// text: displayed value
  /// value: value in code
  static final values = [
    {"text": "alkomat", "value": "breathalyser"},
    {"text": "ciśnienie atmosferyczne", "value": "atmo_pressure"},
    {"text": "opady atmosferyczne", "value": "rain_sensor"},
    {"text": "temperatura powietrza", "value": "temperature"},
    {"text": "temperatura wody", "value": "water_temp"},
    {"text": "dym", "value": "smoke"},
    {"text": "gaz", "value": "gas"},
    {"text": "ruch", "value": "motion_sensor"},
    {"text": "wilgotność gleby", "value": "humidity"},
    {"text": "wilgotność powietrza", "value": "air_humidity"},
  ];
}

/// allowed driver categories
class DriverCategories {
  /// categories values
  ///
  /// text: displayed value
  /// value: value in code
  static final values = [
    {"text": "przycisk", "value": "clicker"},
    {"text": "pilot", "value": "remote_control"},
    {"text": "żarówka", "value": "bulb"},
    {"text": "rolety", "value": "roller_blind"},
  ];
}
