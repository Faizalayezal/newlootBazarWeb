class CityModel {
  final String city;
  final String country;

  CityModel({required this.city, required this.country});

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      city: (json['city'] ?? '').toString(),
      country: (json['country'] ?? '').toString(),
    );
  }
}