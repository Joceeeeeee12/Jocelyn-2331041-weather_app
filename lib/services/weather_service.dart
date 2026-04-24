import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../models/location_model.dart';
import '../utils/constants.dart';

class WeatherService {
  // Mencari daftar kota berdasarkan keyword yang diketik user
  Future<List<LocationModel>> searchCities(String query) async {
    try {
      final url = Uri.parse(
        '${AppConstants.geocodingBaseUrl}${AppConstants.searchEndpoint}'
        '?name=$query&count=5&language=en&format=json',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['results'] == null) return [];

        return (data['results'] as List)
            .map((json) => LocationModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to search cities: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('searchCities error: $e');
    }
  }

  // Mengambil data cuaca + forecast 7 hari berdasarkan koordinat
  Future<WeatherModel> fetchWeather(LocationModel location) async {
    try {
      final url = Uri.parse(
        '${AppConstants.weatherBaseUrl}${AppConstants.forecastEndpoint}'
        '?latitude=${location.latitude}'
        '&longitude=${location.longitude}'
        '&current_weather=true'
        '&hourly=${AppConstants.weatherParams}'
        '&daily=weathercode,temperature_2m_max,temperature_2m_min'
        '&timezone=auto',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return WeatherModel.fromJson(
          data,
          location.name,
          location.country,
          location.latitude,
          location.longitude,
        );
      } else {
        throw Exception('Failed to fetch weather: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('fetchWeather error: $e');
    }
  }
}