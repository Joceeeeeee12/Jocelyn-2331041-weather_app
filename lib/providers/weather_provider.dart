import 'package:flutter/foundation.dart';
import '../models/weather_model.dart';
import '../models/location_model.dart';
import '../services/weather_service.dart';
import '../services/cache_service.dart';
import '../utils/constants.dart';

enum WeatherStatus { initial, loading, success, error, offline }

class WeatherProvider with ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  final CacheService _cacheService = CacheService();

  WeatherStatus _status = WeatherStatus.initial;
  WeatherModel? _currentWeather;
  LocationModel? _currentLocation;
  List<LocationModel> _searchResults = [];
  List<WeatherModel> _savedWeathers = [];
  String _errorMessage = '';
  String _activeFilter = 'All';
  String _searchError = '';

  static const List<Map<String, dynamic>> _defaultCities = [
    {'name': 'Jakarta', 'country': 'Indonesia', 'latitude': -6.2088, 'longitude': 106.8456},
    {'name': 'Batam', 'country': 'Indonesia', 'latitude': 1.0456, 'longitude': 104.0305},
    {'name': 'Bali', 'country': 'Indonesia', 'latitude': -8.3405, 'longitude': 115.0920},
    {'name': 'Surabaya', 'country': 'Indonesia', 'latitude': -7.2575, 'longitude': 112.7521},
    {'name': 'Bandung', 'country': 'Indonesia', 'latitude': -6.9175, 'longitude': 107.6191},
  ];

  WeatherStatus get status => _status;
  WeatherModel? get currentWeather => _currentWeather;
  LocationModel? get currentLocation => _currentLocation;
  List<LocationModel> get searchResults => _searchResults;
  String get errorMessage => _errorMessage;
  String get activeFilter => _activeFilter;
  String get searchError => _searchError;

  List<WeatherModel> get filteredWeathers {
    if (_activeFilter == 'All') return _savedWeathers;
    return _savedWeathers
        .where((w) => w.conditionLabel == _activeFilter)
        .toList();
  }

  // Deteksi apakah error disebabkan oleh koneksi
  bool _isConnectionError(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    return errorStr.contains('failed host lookup') ||
        errorStr.contains('network is unreachable') ||
        errorStr.contains('connection refused') ||
        errorStr.contains('socket') ||
        errorStr.contains('xmlhttprequest error') ||
        errorStr.contains('failed to fetch') ||
        errorStr.contains('network');
  }

  Future<void> loadInitialData() async {
    _status = WeatherStatus.loading;
    notifyListeners();

    // Cek cache dulu
    final cacheValid = await _cacheService.isCacheValid();
    final cachedWeather = await _cacheService.loadWeather();
    final cachedLocation = await _cacheService.loadLocation();

    if (cacheValid && cachedWeather != null && cachedLocation != null) {
      _currentWeather = cachedWeather;
      _currentLocation = cachedLocation;
      _addToSavedWeathers(cachedWeather);
      _status = WeatherStatus.success;
      notifyListeners();
    }

    // Selalu coba fetch dari API
    await _loadDefaultCities(hasCachedData: cachedWeather != null);
  }

  Future<void> _loadDefaultCities({bool hasCachedData = false}) async {
    try {
      final locations = _defaultCities.map((city) => LocationModel(
            name: city['name'],
            country: city['country'],
            latitude: city['latitude'],
            longitude: city['longitude'],
          )).toList();

      final weathers = await Future.wait(
        locations.map((loc) => _weatherService.fetchWeather(loc)),
      );

      if (weathers.isNotEmpty) {
        _currentWeather = weathers[0];
        _currentLocation = locations[0];
        await _cacheService.saveWeather(weathers[0]);
        await _cacheService.saveLocation(locations[0]);
      }

      // Reset saved weathers dan isi ulang dengan data fresh
      _savedWeathers.clear();
      for (final weather in weathers) {
        _addToSavedWeathers(weather);
      }

      _status = WeatherStatus.success;
    } catch (e) {
      if (hasCachedData) {
        // Ada cache — tampilkan cache dengan banner offline
        _status = WeatherStatus.offline;
      } else if (_isConnectionError(e)) {
        // Tidak ada cache + tidak ada internet
        _errorMessage = AppConstants.offlineNoDataMessage;
        _status = WeatherStatus.offline;
      } else {
        // Ada internet tapi API bermasalah
        _errorMessage = AppConstants.serverErrorMessage;
        _status = WeatherStatus.error;
      }
    }
    notifyListeners();
  }

  Future<void> fetchWeatherForLocation(LocationModel location) async {
    _status = WeatherStatus.loading;
    notifyListeners();

    try {
      final weather = await _weatherService.fetchWeather(location);
      _currentWeather = weather;
      _currentLocation = location;
      _addToSavedWeathers(weather);

      await _cacheService.saveWeather(weather);
      await _cacheService.saveLocation(location);

      _status = WeatherStatus.success;
    } catch (e) {
      if (_isConnectionError(e)) {
        _errorMessage = AppConstants.offlineNoDataMessage;
        _status = WeatherStatus.offline;
      } else {
        _errorMessage = AppConstants.fetchErrorMessage;
        _status = WeatherStatus.error;
      }
    }

    notifyListeners();
  }

  Future<void> searchCities(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      _searchError = '';
      notifyListeners();
      return;
    }

    try {
      _searchResults = await _weatherService.searchCities(query);
      _searchError = '';
    } catch (e) {
      _searchResults = [];
      if (_isConnectionError(e)) {
        _searchError = AppConstants.searchOfflineMessage;
      } else {
        _searchError = AppConstants.searchErrorMessage;
      }
    }
    notifyListeners();
  }

  void setFilter(String filter) {
    _activeFilter = filter;
    notifyListeners();
  }

  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }

  void _addToSavedWeathers(WeatherModel weather) {
    final exists = _savedWeathers.any((w) => w.cityName == weather.cityName);
    if (!exists) {
      _savedWeathers.add(weather);
    }
  }
}