import 'package:latlong2/latlong.dart';

class District {
  final String id;
  final String nameRu;
  final String nameEn;
  final String nameBe;
  final LatLng center;
  final List<LatLng> bounds;

  const District({
    required this.id,
    required this.nameRu,
    required this.nameEn,
    required this.nameBe,
    required this.center,
    required this.bounds,
  });

  String getName(String locale) {
    switch (locale) {
      case 'ru':
        return nameRu;
      case 'be':
        return nameBe;
      default:
        return nameEn;
    }
  }

  static List<District> getDistricts() {
    return [
      District(
        id: 'centralny',
        nameRu: 'Центральный',
        nameEn: 'Centralny',
        nameBe: 'Цэнтральны',
        center: const LatLng(53.9006, 27.5590),
        bounds: [
          const LatLng(53.9150, 27.5300),
          const LatLng(53.9150, 27.5800),
          const LatLng(53.8850, 27.5800),
          const LatLng(53.8850, 27.5300),
        ],
      ),
      District(
        id: 'sovetsky',
        nameRu: 'Советский',
        nameEn: 'Sovetsky',
        nameBe: 'Савецкі',
        center: const LatLng(53.9220, 27.5820),
        bounds: [
          const LatLng(53.9350, 27.5500),
          const LatLng(53.9350, 27.6200),
          const LatLng(53.9050, 27.6200),
          const LatLng(53.9050, 27.5500),
        ],
      ),
      District(
        id: 'pervomaysky',
        nameRu: 'Первомайский',
        nameEn: 'Pervomaysky',
        nameBe: 'Першамайскі',
        center: const LatLng(53.9250, 27.6400),
        bounds: [
          const LatLng(53.9400, 27.6100),
          const LatLng(53.9400, 27.6800),
          const LatLng(53.9100, 27.6800),
          const LatLng(53.9100, 27.6100),
        ],
      ),
      District(
        id: 'partizansky',
        nameRu: 'Партизанский',
        nameEn: 'Partizansky',
        nameBe: 'Партызанскі',
        center: const LatLng(53.8700, 27.6300),
        bounds: [
          const LatLng(53.8900, 27.6000),
          const LatLng(53.8900, 27.6700),
          const LatLng(53.8500, 27.6700),
          const LatLng(53.8500, 27.6000),
        ],
      ),
      District(
        id: 'zavodskoy',
        nameRu: 'Заводской',
        nameEn: 'Zavodskoy',
        nameBe: 'Завадскі',
        center: const LatLng(53.8600, 27.6050),
        bounds: [
          const LatLng(53.8750, 27.5800),
          const LatLng(53.8750, 27.6350),
          const LatLng(53.8400, 27.6350),
          const LatLng(53.8400, 27.5800),
        ],
      ),
      District(
        id: 'leninsky',
        nameRu: 'Ленинский',
        nameEn: 'Leninsky',
        nameBe: 'Ленінскі',
        center: const LatLng(53.9000, 27.5100),
        bounds: [
          const LatLng(53.9200, 27.4800),
          const LatLng(53.9200, 27.5400),
          const LatLng(53.8800, 27.5400),
          const LatLng(53.8800, 27.4800),
        ],
      ),
      District(
        id: 'oktyabrsky',
        nameRu: 'Октябрьский',
        nameEn: 'Oktyabrsky',
        nameBe: 'Кастрычніцкі',
        center: const LatLng(53.8800, 27.5500),
        bounds: [
          const LatLng(53.8950, 27.5200),
          const LatLng(53.8950, 27.5800),
          const LatLng(53.8650, 27.5800),
          const LatLng(53.8650, 27.5200),
        ],
      ),
      District(
        id: 'frunzensky',
        nameRu: 'Фрунзенский',
        nameEn: 'Frunzensky',
        nameBe: 'Фрунзенскі',
        center: const LatLng(53.8750, 27.5200),
        bounds: [
          const LatLng(53.8900, 27.4900),
          const LatLng(53.8900, 27.5500),
          const LatLng(53.8600, 27.5500),
          const LatLng(53.8600, 27.4900),
        ],
      ),
      District(
        id: 'moskovsky',
        nameRu: 'Московский',
        nameEn: 'Moskovsky',
        nameBe: 'Маскоўскі',
        center: const LatLng(53.8550, 27.5000),
        bounds: [
          const LatLng(53.8700, 27.4700),
          const LatLng(53.8700, 27.5300),
          const LatLng(53.8400, 27.5300),
          const LatLng(53.8400, 27.4700),
        ],
      ),
    ];
  }
}
