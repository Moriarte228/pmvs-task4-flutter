import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const _kThemeMode = 'theme_mode';
  static const _kLocale = 'app_locale';

  ThemeMode _themeMode = ThemeMode.system;
  Locale? _locale;

  ThemeMode get themeMode => _themeMode;
  Locale? get locale => _locale;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_kThemeMode);
      switch (stored) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        default:
          _themeMode = ThemeMode.system;
      }
      final loc = prefs.getString(_kLocale);
      if (loc != null && loc.isNotEmpty) {
        _locale = Locale(loc);
      }
      notifyListeners();
    } catch (e) {
      // ignore: avoid_print
      print('ThemeProvider.load error: $e');
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kThemeMode, _modeToStr(mode));
    } catch (e) {
      // ignore: avoid_print
      print('ThemeProvider.setThemeMode error: $e');
    }
  }

  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      if (locale == null) {
        await prefs.remove(_kLocale);
      } else {
        await prefs.setString(_kLocale, locale.languageCode);
      }
    } catch (e) {
      // ignore: avoid_print
      print('ThemeProvider.setLocale error: $e');
    }
  }

  String _modeToStr(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
