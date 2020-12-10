import 'package:idom/localization/utils/frequency_calculations.i18n.dart';

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
        firstVersion = "sekundy".i18n;
        break;
      case "minutes":
        firstVersion = "minuty".i18n;
        break;
      case "hours":
        firstVersion = "godziny".i18n;
        break;
    }
    var secondVersion;
    switch (type) {
      case "seconds":
        secondVersion = "sekund".i18n;
        break;
      case "minutes":
        secondVersion = "minut".i18n;
        break;
      case "hours":
        secondVersion = "godzin".i18n;
        break;
    }

    var thirdVersion;
    switch (type) {
      case "seconds":
        thirdVersion = "sekunda".i18n;
        break;
      case "minutes":
        thirdVersion = "minuta".i18n;
        break;
      case "hours":
        thirdVersion = "godzina".i18n;
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
