class FrequencyCalculation {
  static String calculateFrequencyValue(int frequency) {
    int hours = frequency ~/ 3600;
    int minutes = ((frequency ~/ 60)) % 60;
    int seconds = frequency % 60;
    if (hours > 0 && minutes > 0 && seconds > 0) {
      return "$hours ${getName(hours, "hours")} $minutes ${getName(minutes, "minutes")} $seconds ${getName(seconds, "seconds")}";
    } else if (hours > 0 && minutes > 0) {
      return "$hours ${getName(hours, "hours")} $minutes ${getName(minutes, "minutes")}";
    } else if (hours > 0 && seconds > 0) {
      return "$hours ${getName(hours, "hours")} $seconds ${getName(seconds, "seconds")}";
    } else if (minutes > 0 && seconds > 0) {
      return "$minutes ${getName(minutes, "minutes")} $seconds ${getName(seconds, "seconds")}";
    } else if (hours > 0) {
      return "$hours ${getName(hours, "hours")}";
    } else if (minutes > 0) {
      return "$minutes ${getName(minutes, "minutes")}";
    } else if (seconds > 0) {
      return "$seconds ${getName(seconds, "seconds")}";
    }
    return "";
  }

  static String getName(int value, String type) {
    var lastDigitFrequencyValue =
        value.toString().substring(value.toString().length - 1);
    var firstVersion;
    switch (type) {
      case "seconds":
        firstVersion = "sekundy";
        break;
      case "minutes":
        firstVersion = "minuty";
        break;
      case "hours":
        firstVersion = "godziny";
        break;
    }
    var secondVersion;
    switch (type) {
      case "seconds":
        secondVersion = "sekund";
        break;
      case "minutes":
        secondVersion = "minut";
        break;
      case "hours":
        secondVersion = "godzin";
        break;
    }

    var thirdVersion;
    switch (type) {
      case "seconds":
        thirdVersion = "sekunda";
        break;
      case "minutes":
        thirdVersion = "minuta";
        break;
      case "hours":
        thirdVersion = "godzina";
        break;
    }

    if (RegExp(r"[2-9]+1$").hasMatch(value.toString()))
      return secondVersion;
    else if (RegExp(r"^[0|5-9]").hasMatch(lastDigitFrequencyValue))
      return secondVersion;
    else if (RegExp(r"^1[0-9]$").hasMatch(value.toString()))
      return secondVersion;
    else if (RegExp(r"^[2-4]").hasMatch(lastDigitFrequencyValue))
      return firstVersion;
    else if (RegExp(r"^1$").hasMatch(lastDigitFrequencyValue))
      return thirdVersion;
    return "";
  }
}
