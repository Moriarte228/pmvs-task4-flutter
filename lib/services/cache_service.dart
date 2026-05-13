import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/library_model.dart';

/// Сервис кеширования последних загруженных данных.
/// Используется как fallback при отсутствии интернета.
class CacheService {
  static const _kLibraries = 'cache_libraries';
  static const _kTimestamp = 'cache_timestamp';
  static const _kWeather = 'cache_weather_';

  /// Сохраняет список библиотек в кеш.
  Future<void> saveLibraries(List<LibraryModel> libraries) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = libraries.map((l) => l.toMap()).toList();
      await prefs.setString(_kLibraries, jsonEncode(list));
      await prefs.setInt(_kTimestamp, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      // ignore: avoid_print
      print('CacheService.saveLibraries error: $e');
    }
  }

  /// Загружает кешированный список библиотек.
  Future<List<LibraryModel>> loadLibraries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kLibraries);
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => LibraryModel.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      // ignore: avoid_print
      print('CacheService.loadLibraries error: $e');
      return [];
    }
  }

  /// Дата последнего обновления кеша.
  Future<DateTime?> lastUpdate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ts = prefs.getInt(_kTimestamp);
      if (ts == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(ts);
    } catch (e) {
      return null;
    }
  }

  /// Сохраняет данные о погоде.
  Future<void> saveWeather(String key, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_kWeather$key', jsonEncode(data));
    } catch (e) {
      // ignore: avoid_print
      print('CacheService.saveWeather error: $e');
    }
  }

  /// Загружает кешированные данные о погоде.
  Future<Map<String, dynamic>?> loadWeather(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_kWeather$key');
      if (raw == null) return null;
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Очищает весь кеш.
  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) =>
          k == _kLibraries || k == _kTimestamp || k.startsWith(_kWeather));
      for (final k in keys) {
        await prefs.remove(k);
      }
    } catch (e) {
      // ignore: avoid_print
      print('CacheService.clear error: $e');
    }
  }
}
