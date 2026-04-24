import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';
import '../models/location_model.dart';
import '../utils/constants.dart';

class CacheService {
  // Menyimpan data cuaca ke shared_preferences
  Future<void> saveWeather(WeatherModel weather) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final weatherJson = jsonEncode(weather.toJson());
      await prefs.setString(AppConstants.cacheWeatherKey, weatherJson);
      await prefs.setString(
        AppConstants.cacheTimestampKey,
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      // Gagal menyimpan cache tidak perlu crash app
      print('CacheService - saveWeather error: $e');
    }
  }

  // Mengambil data cuaca dari shared_preferences
  Future<WeatherModel?> loadWeather() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final weatherJson = prefs.getString(AppConstants.cacheWeatherKey);

      if (weatherJson == null) return null;

      final Map<String, dynamic> decoded = jsonDecode(weatherJson);
      return WeatherModel.fromCache(decoded);
    } catch (e) {
      print('CacheService - loadWeather error: $e');
      return null;
    }
  }

  // Menyimpan data lokasi terakhir ke shared_preferences
  Future<void> saveLocation(LocationModel location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationJson = jsonEncode(location.toJson());
      await prefs.setString(AppConstants.cacheLocationKey, locationJson);
    } catch (e) {
      print('CacheService - saveLocation error: $e');
    }
  }

  // Mengambil data lokasi terakhir dari shared_preferences
  Future<LocationModel?> loadLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationJson = prefs.getString(AppConstants.cacheLocationKey);

      if (locationJson == null) return null;

      final Map<String, dynamic> decoded = jsonDecode(locationJson);
      return LocationModel.fromJson(decoded);
    } catch (e) {
      print('CacheService - loadLocation error: $e');
      return null;
    }
  }

  // Mengecek apakah cache masih valid (belum melewati cacheDurationHours)
  Future<bool> isCacheValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampStr = prefs.getString(AppConstants.cacheTimestampKey);

      if (timestampStr == null) return false;

      final cachedTime = DateTime.parse(timestampStr);
      final difference = DateTime.now().difference(cachedTime);

      return difference.inHours < AppConstants.cacheDurationHours;
    } catch (e) {
      print('CacheService - isCacheValid error: $e');
      return false;
    }
  }

  // Menghapus semua cache
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.cacheWeatherKey);
      await prefs.remove(AppConstants.cacheLocationKey);
      await prefs.remove(AppConstants.cacheTimestampKey);
    } catch (e) {
      print('CacheService - clearCache error: $e');
    }
  }
}