/// allowed driver actions
class DriverActions {
  /// driver actions values
  ///
  /// text: displayed value
  /// value: value in code
  static List<Map<String, String>> getValues(String category) {
    switch (category) {
      case "clicker":
        return [
          {"text": "Wciśnij przycisk", "value": "click"}
        ];
        break;
      case "bulb":
        return [
          {"text": "Włącz żarówkę", "value": "turn_on"},
          {"text": "Wyłącz żarówkę", "value": "turn_off"},
          {"text": "Ustaw kolor", "value": "set_color"},
          {"text": "Ustaw jasność", "value": "set_brightness"}
        ];
        break;
      case "roller_blind":
        return [
          {"text": "Podnieś rolety", "value": "raise_blinds"},
          {"text": "Opuść rolety", "value": "lower_blinds"},
        ];
        break;
    }
  }
}
