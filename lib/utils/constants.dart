class AppConstants {
  // Base URLs
  static const String weatherBaseUrl = 'https://api.open-meteo.com/v1';
  static const String geocodingBaseUrl = 'https://geocoding-api.open-meteo.com/v1';

  // Endpoints
  static const String forecastEndpoint = '/forecast';
  static const String searchEndpoint = '/search';

  // Cache Keys
  static const String cacheWeatherKey = 'cached_weather_data';
  static const String cacheLocationKey = 'cached_location_data';
  static const String cacheTimestampKey = 'cached_timestamp';

  // Cache Duration (in hours)
  static const int cacheDurationHours = 1;

  // Weather Parameters (what data we request from Open-Meteo)
  static const String weatherParams =
      'temperature_2m,weathercode,windspeed_10m,relativehumidity_2m,apparent_temperature';

  // App UI
  static const String appName = 'WeatherNow';
  static const String noInternetMessage =
      'Oops! No internet connection.\nShowing last saved data.';
  static const String offlineNoDataMessage =
      'You\'re offline and there\'s no cached data.\nPlease connect to the internet to get started.';
  static const String noDataMessage =
      'No weather data available.\nPlease connect to the internet.';
  static const String errorMessage =
      'Something went wrong.\nPlease try again later.';
  static const String searchOfflineMessage =
      'No internet connection.\nSearch is unavailable while offline.';
  static const String searchErrorMessage =
      'Failed to search cities.\nPlease try again.';
  static const String fetchErrorMessage =
      'Failed to fetch weather data.\nPlease try again.';
  static const String serverErrorMessage =
      'Server error occurred.\nPlease try again later.';   
  static const String offlineBannerMessage =
      'You\'re offline — showing cached data, check your connection for the latest weather updates.'; 
}