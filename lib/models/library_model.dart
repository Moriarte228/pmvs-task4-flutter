class LibraryModel {
  final int? id;
  final String nameRu;
  final String nameEn;
  final String nameBe;
  final String addressRu;
  final String addressEn;
  final String addressBe;
  final String district;
  final double latitude;
  final double longitude;
  final String phone;
  final String website;
  final String workingHours;

  LibraryModel({
    this.id,
    required this.nameRu,
    required this.nameEn,
    required this.nameBe,
    required this.addressRu,
    required this.addressEn,
    required this.addressBe,
    required this.district,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.website,
    required this.workingHours,
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

  String getAddress(String locale) {
    switch (locale) {
      case 'ru':
        return addressRu;
      case 'be':
        return addressBe;
      default:
        return addressEn;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name_ru': nameRu,
      'name_en': nameEn,
      'name_be': nameBe,
      'address_ru': addressRu,
      'address_en': addressEn,
      'address_be': addressBe,
      'district': district,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'website': website,
      'working_hours': workingHours,
    };
  }

  factory LibraryModel.fromMap(Map<String, dynamic> map) {
    return LibraryModel(
      id: map['id'] as int?,
      nameRu: map['name_ru'] as String,
      nameEn: map['name_en'] as String,
      nameBe: map['name_be'] as String,
      addressRu: map['address_ru'] as String,
      addressEn: map['address_en'] as String,
      addressBe: map['address_be'] as String,
      district: map['district'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      phone: map['phone'] as String? ?? '',
      website: map['website'] as String? ?? '',
      workingHours: map['working_hours'] as String? ?? '',
    );
  }
}
