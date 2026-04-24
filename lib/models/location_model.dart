class LocationModel {
  final String name;
  final String country;
  final double latitude;
  final double longitude;

  LocationModel({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  // Mengubah JSON dari Geocoding API menjadi object LocationModel
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      name: json['name'] ?? 'Unknown',
      country: json['country'] ?? 'Unknown',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  // Mengubah object LocationModel menjadi JSON untuk disimpan ke cache
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // Helper: gabungkan nama kota dan negara untuk ditampilkan di UI
  String get displayName => '$name, $country';
}