/// form fields validators
///
/// username field validator
class UsernameFieldValidator {
  static String validate(String value) {
    if (value.isEmpty) {
      return 'Pole wymagane';
    }
    if (value.contains(' ')) {
      return 'Login nie może zawierać spacji';
    }
    if (value.length > 25) {
      return 'Login nie może zawierać więcej niż 25 znaków';
    }
    return null;
  }
}

/// password field validator
class PasswordFieldValidator {
  static String validate(String value) {
    if (value.isEmpty) {
      return 'Pole wymagane';
    }
    if (value.length < 8) {
      return 'Hasło musi zawierać przynajmniej 8 znaków';
    }
    if (value.length > 25) {
      return 'Hasło nie może zawierać więcej niż 25 znaków';
    }
    return null;
  }
}

/// email field validator
class EmailFieldValidator {
  static String validate(String value) {
    if (value.isEmpty) {
      return 'Pole wymagane';
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
      return 'Podaj numer telefonu postaci +XX XXX XXX XXX';
    }
    return null;
  }
}

/// sensor name field validator
class SensorNameFieldValidator {
  static String validate(String value) {
    if (value.isEmpty) {
      return 'Pole wymagane';
    }
    return null;
  }
}

/// driver name field validator
class DriverNameFieldValidator {
  static String validate(String value) {
    if (value.isEmpty) {
      return 'Pole wymagane';
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
      return 'Pole wymagane';
    }
    var intVal = int.tryParse(value);
    if (intVal == null || intVal <= 0) {
      return 'Podaj ilczbę całkowitą większą od zera';
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

/// validates url field
class UrlFieldValidator {
  static String validate(String value) {
    if (value.isEmpty) {
      return 'Pole wymagane';
    }
    return null;
  }
}

/// validates category field
class CategoryFieldValidator {
  static String validate(String value) {
    if (value.isEmpty) {
      return 'Pole wymagane';
    }
    return null;
  }
}

/// validates last days amount field
class LastDaysAmountFieldValidator {
  static String validate(String value) {
    if (value.isEmpty) {
      return 'Pole wymagane';
    }
    var intValue = int.tryParse(value);
    if (intValue == null || intValue < 1 || intValue > 30){
      return "Podaj liczbę całkowitą z przedziału 1 - 30";
    }
    return null;
  }
}

/// validates frequency units field
class FrequencyUnitsFieldValidator {
  static String validate(String value) {
    if (value.isEmpty) {
      return 'Pole wymagane';
    }
    return null;
  }
}

/// validates port field
class PortFieldValidator {
  static String validate(String value) {
    if (value.isEmpty) {
      return 'Pole wymagane';
    }
    if (!RegExp(
            r'^([0-9]{1,4}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$')
        .hasMatch(value)) {
      return 'Nieprawidłowy numer portu';
    }
    return null;
  }
}
