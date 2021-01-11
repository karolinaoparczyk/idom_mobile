import 'package:idom/localization/utils/validators.i18n.dart';

/// username field validator
class UsernameFieldValidator {
  /// validates username
  static String validate(String value) {
    if (value.isEmpty) {
      return 'Pole wymagane'.i18n;
    }
    if (value.contains(' ')) {
      return 'Login nie może zawierać spacji'.i18n;
    }
    if (value.length > 25) {
      return 'Login nie może zawierać więcej niż 25 znaków'.i18n;
    }
    return null;
  }
}

/// password field validator
class PasswordFieldValidator {
  /// validates password
  static String validate(String value) {
    if (value.isEmpty) {
      return 'Pole wymagane'.i18n;
    }
    if (value.length < 8) {
      return 'Hasło musi zawierać przynajmniej 8 znaków'.i18n;
    }
    if (value.length > 25) {
      return 'Hasło nie może zawierać więcej niż 25 znaków'.i18n;
    }
    return null;
  }
}

/// email field validator
class EmailFieldValidator {
  /// validates e-mail address
  static String validate(String value) {
    if (value.isEmpty) {
      return 'Pole wymagane'.i18n;
    }
    if (!RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(value)) {
      return 'Podaj poprawny adres email'.i18n;
    }
    return null;
  }
}

/// telephone field validator
class TelephoneFieldValidator {
  /// validates cell phone number
  static String validate(String value) {
    value = value.replaceAll(' ', '');
    if (value.isNotEmpty && !RegExp(r"^\+\d{11}$").hasMatch(value)) {
      return 'Podaj numer telefonu postaci +XX XXX XXX XXX'.i18n;
    }
    return null;
  }
}

/// sensor name field validator
class SensorNameFieldValidator {
  /// validates sensor name
  static String validate(String value) {
    if (value.isEmpty) {
      return 'Pole wymagane'.i18n;
    }
    return null;
  }
}

/// driver name field validator
class DriverNameFieldValidator {
  /// validates driver name
  static String validate(String value) {
    if (value.isEmpty) {
      return 'Pole wymagane'.i18n;
    }
    return null;
  }
}

/// minimum frequency values due to chosen frequency units
Map<String, int> unitsToMinValues = {
  "seconds": 30,
  "minutes": 1,
  "hours": 1,
  "days": 1
};

/// maximum frequency values due to chosen frequency units
Map<String, int> unitsToMaxValues = {
  "seconds": 21474836,
  "minutes": 357913,
  "hours": 5965,
  "days": 248
};

/// frequency field validator
class SensorFrequencyFieldValidator {
  /// validates frequency
  static String validate(String value) {
    if (value.isEmpty) {
      return 'Pole wymagane'.i18n;
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
  /// validates url
  static String validate(String value) {
    if (value.isEmpty) {
      return 'Pole wymagane'.i18n;
    }
    return null;
  }
}

/// validates category field
class CategoryFieldValidator {
  /// validates category
  static String validate(String value) {
    if (value.isEmpty) {
      return 'Pole wymagane'.i18n;
    }
    return null;
  }
}

/// validates driver field
class DriverFieldValidator {
  /// validates driver is chosen
  static String validate(String value) {
    if (value.isEmpty) {
      return 'Pole wymagane'.i18n;
    }
    return null;
  }
}

/// validates time field
class TimeFieldValidator {
  /// validates time is picked
  static String validate(String value) {
    if (value.isEmpty) {
      return 'Pole wymagane'.i18n;
    }
    return null;
  }
}

/// validates last days amount field
class LastDaysAmountFieldValidator {
  /// validates last days value
  static String validate(String value) {
    if (value.isEmpty) {
      return 'Pole wymagane'.i18n;
    }
    var intValue = int.tryParse(value);
    if (intValue == null || intValue < 1 || intValue > 30) {
      return "Podaj liczbę całkowitą z przedziału 1 - 30".i18n;
    }
    return null;
  }
}

/// validates frequency units field
class FrequencyUnitsFieldValidator {
  /// validates frequency units is chosen
  static String validate(String value) {
    if (value.isEmpty) {
      return 'Pole wymagane'.i18n;
    }
    return null;
  }
}

/// validates language field
class LanguageFieldValidator {
   static String validate(String value) {
    if (value.isEmpty) {
      return 'Pole wymagane'.i18n;
    }
    return null;
  }
}

/// validates trigger value operator field
class TriggerValueOperatorFieldValidator {
  static String validate(String value) {
    if (value.isEmpty) {
      return 'Pole wymagane'.i18n;
    }
    return null;
  }
}