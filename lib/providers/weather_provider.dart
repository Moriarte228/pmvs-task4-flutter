import 'package:flutter/foundation.dart';
import '../services/weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService;

  WeatherData? _weatherData;
  bool _isLoading = false;
  String? _error;

  WeatherData? get weatherData => _weatherData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  WeatherProvider({WeatherService? weatherService})
      : _weatherService = weatherService ?? WeatherService();

  Future<void> loadWeather(double lat, double lon, {String lang = 'ru'}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _weatherData = await _weatherService.getWeather(lat, lon, lang: lang);
    } catch (e) {
      _error = 'Ошибка загрузки погоды: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
