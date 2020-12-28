import 'package:flutter/material.dart';
import 'package:idom/utils/secure_storage.dart';

class AppStateNotifier extends ChangeNotifier {
  void updateTheme() async {
    notifyListeners();
  }
}

class DarkMode {
  static bool isDarkMode;

  static Future<void> init() async {
    isDarkMode = await getStorageThemeMode();
  }

  static Future<bool> getStorageThemeMode() async {
    SecureStorage storage = SecureStorage();
    var themeMode = await storage.getThemeMode();
    if (themeMode != null && themeMode == "dark") {
      return true;
    } else {
      return false;
    }
  }

  static Future<void> setStorageThemeMode(String themeMode) async {
    isDarkMode = themeMode == "dark" ? true : false;
    SecureStorage storage = SecureStorage();
    storage.setThemeMode(themeMode);
  }

  static bool getTheme() {
    return isDarkMode;
  }
}
