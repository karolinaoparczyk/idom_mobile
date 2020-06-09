/// form fields validators
///
/// username field validator
class UsernameFieldValidator {
  static String validate(String value) {
    if (value.isEmpty) {
      return 'Podaj login';
    }
    if (value.contains(' ')) {
      return 'Login nie może zawierać spacji';
    }
    return null;
  }
}

/// password field validator
class PasswordFieldValidator {
  static String validate(String value) {
    if (value.isEmpty) {
      return 'Podaj hasło';
    }
    if (value.length < 8) {
      return 'Hasło musi zawierać przynajmniej 8 znaków';
    }
    return null;
  }
}

/// email field validator
class EmailFieldValidator {
  static String validate(String value) {
    if (value.isEmpty) {
      return 'Email jest wymagany';
    }
    if (!RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(value)) {
      return 'Podaj poprawny adres email';
    }
    return null;
  }
}

/// telephone field validator
class TelephoneFieldValidator {
  static String validate(String value) {
    value = value.replaceAll(' ', '');
    if (value.isNotEmpty && !RegExp(r"^\+\d{11}$").hasMatch(value)) {
      return 'Numer telefonu musi zawierać kierunkowy postaci +XX oraz 9 cyfr';
    }
    return null;
  }
}

/// sensor name field validator
class SensorNameFieldValidator {
  static String validate(String value) {
    if (value.isEmpty) {
      return 'Podaj nazwę';
    }
    return null;
  }
}

/// minimum and maximum frequency values due to chosen frequency units
Map<String, int> unitsToMinValues = {
  "seconds": 30,
  "minutes": 1,
  "hours": 1,
  "days": 1
};
Map<String, int> unitsToMaxValues = {
  "seconds": 21474836,
  "minutes": 357913,
  "hours": 5965,
  "days": 248
};

/// frequency field validator
class SensorFrequencyFieldValidator {
  static String validate(String value) {
    if (value.isEmpty) {
      return 'Podaj wartość';
    }
    return null;
  }

  /// checks if provided frequency value is in the given range of provided frequency units
  static bool isFrequencyValueValid(
      String frequencyValue, String frequencyUnits) {
    var minValue = unitsToMinValues[frequencyUnits];
    var maxValue = unitsToMaxValues[frequencyUnits];

    if (int.parse(frequencyValue) < minValue ||
        int.parse(frequencyValue) > maxValue)
      return false;
    else
      return true;
  }
}
