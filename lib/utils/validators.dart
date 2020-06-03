class UsernameFieldValidator{
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

class PasswordFieldValidator{
  static String validate(String value){
    if (value.isEmpty) {
      return 'Podaj hasło';
    }
    if (value.length < 8) {
      return 'Hasło musi zawierać przynajmniej 8 znaków';
    }
    return null;
  }
}

class EmailFieldValidator{
  static String validate(String value){
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

class TelephoneFieldValidator{
  static String validate(String value){
    value = value.replaceAll(' ', '');
    if (value.isNotEmpty && !RegExp(r"^\+\d{11}$").hasMatch(value)) {
      return 'Numer telefonu musi zawierać kierunkowy postaci +XX oraz 9 cyfr';
    }
    return null;
  }
}

class SensorNameFieldValidator{
  static String validate(String value) {
    if (value.isEmpty) {
      return 'Podaj nazwę';
    }
    return null;
  }
}

Map<String, int> unitsToMinValues = {"seconds": 30, "minutes": 1, "hours": 1, "days": 1};
Map<String, int> unitsToMaxValues = {"seconds": 2147483647, "minutes": 35791394, "hours": 596523, "days": 24};

class SensorFrequencyFieldValidator{

  static String validate(String value) {
    if (value.isEmpty) {
      return 'Podaj wartość';
    }
    return null;
  }

  static bool isFrequencyValueValid(String frequencyValue, String frequencyUnits){

    var minValue = unitsToMinValues[frequencyUnits];
    var maxValue = unitsToMaxValues[frequencyUnits];

    if (int.parse(frequencyValue) < minValue || int.parse(frequencyValue) > maxValue)
      return false;
    else
      return true;
  }
}