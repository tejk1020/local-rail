import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  // ==========================================================
  // THEME MODE
  // ==========================================================

  static final ValueNotifier<ThemeMode> themeMode =
  ValueNotifier<ThemeMode>(
    ThemeMode.light,
  );

  // ==========================================================
  // LANGUAGE
  // ==========================================================

  static final ValueNotifier<Locale> locale =
  ValueNotifier<Locale>(
    const Locale('en'),
  );

  // ==========================================================
  // LOAD SAVED SETTINGS
  // ==========================================================

  static Future<void> loadSettings() async {
    final prefs =
    await SharedPreferences.getInstance();

    final bool darkMode =
        prefs.getBool('dark_mode_enabled') ?? false;

    final String language =
        prefs.getString('app_language') ?? 'en';

    themeMode.value = darkMode
        ? ThemeMode.dark
        : ThemeMode.light;

    locale.value = Locale(language);
  }

  // ==========================================================
  // CHANGE DARK MODE
  // ==========================================================

  static Future<void> setDarkMode(
      bool enabled,
      ) async {
    final prefs =
    await SharedPreferences.getInstance();

    await prefs.setBool(
      'dark_mode_enabled',
      enabled,
    );

    themeMode.value = enabled
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  // ==========================================================
  // CHANGE LANGUAGE
  // ==========================================================

  static Future<void> setLanguage(
      String language,
      ) async {
    final prefs =
    await SharedPreferences.getInstance();

    await prefs.setString(
      'app_language',
      language,
    );

    locale.value = Locale(language);
  }
}