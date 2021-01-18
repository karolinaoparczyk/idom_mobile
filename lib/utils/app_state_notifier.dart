import 'package:flutter/material.dart';
import 'package:idom/utils/secure_storage.dart';

/// notifies widgets about app state change
class AppStateNotifier extends ChangeNotifier {
  /// updates state
  void updateState() async {
    notifyListeners();
  }
}

/// holds information about app theme mode
class DarkMode {
  /// is dark mode set in app
  static bool isDarkMode;

  /// init isDarkMode variable
  static Future<void> init() async {
    isDarkMode = await getStorageThemeMode();
  }

  /// get set theme mode
  ///
  /// if not set or set light mode, set isDarkMode to false
  /// if set dark mode, set isDarkMode to true
  static Future<bool> getStorageThemeMode() async {
    SecureStorage storage = SecureStorage();
    var themeMode = await storage.getThemeMode();
    if (themeMode != null && themeMode == "dark") {
      return true;
    } else {
      return false;
    }
  }

  /// set theme mode in storage
  static Future<void> setStorageThemeMode(String themeMode) async {
    isDarkMode = themeMode == "dark" ? true : false;
    SecureStorage storage = SecureStorage();
    storage.setThemeMode(themeMode);
  }

  /// get theme mode
  static bool getTheme() {
    return isDarkMode;
  }
}
