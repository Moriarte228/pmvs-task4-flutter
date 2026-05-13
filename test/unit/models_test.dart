import 'package:flutter_test/flutter_test.dart';
import 'package:minsk_libraries/models/library_model.dart';
import 'package:minsk_libraries/models/district.dart';
import 'package:minsk_libraries/services/weather_service.dart';

void main() {
  group('Unit tests', () {
    test('LibraryModel — toMap/fromMap roundtrip и getName/getAddress по локали',
        () {
      final original = LibraryModel(
        id: 5,
        nameRu: 'Библиотека',
        nameEn: 'Library',
        nameBe: 'Бібліятэка',
        addressRu: 'ул. Тест',
        addressEn: 'Test St',
        addressBe: 'вул. Тэст',
        district: 'centralny',
        latitude: 53.9,
        longitude: 27.55,
        phone: '+375 17 000-00-00',
        website: 'https://test.by',
        workingHours: '10:00-18:00',
      );

      final restored = LibraryModel.fromMap(original.toMap());

      expect(restored.id, 5);
      expect(restored.nameRu, original.nameRu);
      expect(restored.district, 'centralny');
      expect(restored.latitude, 53.9);

      expect(restored.getName('ru'), 'Библиотека');
      expect(restored.getName('en'), 'Library');
      expect(restored.getName('be'), 'Бібліятэка');
      expect(restored.getName('fr'), 'Library'); // fallback на en
      expect(restored.getAddress('ru'), 'ул. Тест');
      expect(restored.getAddress('be'), 'вул. Тэст');
    });

    test('District — 9 районов с уникальными id и корректной локализацией', () {
      final districts = District.getDistricts();
      expect(districts.length, 9);

      final ids = districts.map((d) => d.id).toSet();
      expect(ids.length, districts.length, reason: 'все id должны быть уникальны');

      for (final d in districts) {
        expect(d.bounds.length, 4, reason: 'у каждого района 4 точки границ');
      }

      final central = districts.firstWhere((d) => d.id == 'centralny');
      expect(central.getName('ru'), 'Центральный');
      expect(central.getName('en'), 'Centralny');
      expect(central.getName('be'), 'Цэнтральны');
    });

    test('WeatherData.fromJson парсит корректные данные', () {
      final json = {
        'main': {'temp': 20.5, 'humidity': 65},
        'weather': [
          {'description': 'ясно', 'icon': '01d'}
        ],
        'wind': {'speed': 3.5},
        'name': 'Minsk',
      };

      final weather = WeatherData.fromJson(json);

      expect(weather.temperature, 20.5);
      expect(weather.description, 'ясно');
      expect(weather.icon, '01d');
      expect(weather.humidity, 65);
      expect(weather.windSpeed, 3.5);
      expect(weather.cityName, 'Minsk');
    });
  });
}
