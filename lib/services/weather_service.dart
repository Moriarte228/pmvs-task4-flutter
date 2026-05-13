import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherData {
  final double temperature;
  final String description;
  final String icon;
  final int humidity;
  final double windSpeed;
  final String cityName;

  WeatherData({
    required this.temperature,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.cityName,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: (json['main']['temp'] as num).toDouble(),
      description: json['weather'][0]['description'] as String,
      icon: json['weather'][0]['icon'] as String,
      humidity: json['main']['humidity'] as int,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      cityName: json['name'] as String,
    );
  }
}

class WeatherService {
  static const String _apiKey = '9607e1be053088b89766797644fa2d32';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  final http.Client _client;

  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  Future<WeatherData> getWeather(
    double lat,
    double lon, {
    String lang = 'ru',
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&lang=$lang',
      );

      final response = await _client.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return WeatherData.fromJson(json);
      } else {
        throw Exception(
          'Ошибка загрузки погоды: HTTP ${response.statusCode} — ${response.body}',
        );
      }
    } catch (e) {
      print('Ошибка сервиса погоды: $e');
      rethrow;
    }
  }

  void dispose() {
    _client.close();
  }
}
