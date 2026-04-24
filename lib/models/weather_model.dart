class ForecastDay {
  final DateTime date;
  final double maxTemperature;
  final double minTemperature;
  final int weatherCode;

  ForecastDay({
    required this.date,
    required this.maxTemperature,
    required this.minTemperature,
    required this.weatherCode,
  });

  factory ForecastDay.fromJson(Map<String, dynamic> json, int index) {
    return ForecastDay(
      date: DateTime.parse(json['time'][index]),
      maxTemperature: (json['temperature_2m_max'][index] as num).toDouble(),
      minTemperature: (json['temperature_2m_min'][index] as num).toDouble(),
      weatherCode: (json['weathercode'][index] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': date.toIso8601String(),
      'temperature_2m_max': maxTemperature,
      'temperature_2m_min': minTemperature,
      'weathercode': weatherCode,
    };
  }

  String get conditionEmoji {
    if (weatherCode == 0) return '☀️';
    if (weatherCode <= 3) return '⛅';
    if (weatherCode <= 67) return '🌧️';
    if (weatherCode <= 77) return '❄️';
    if (weatherCode <= 99) return '⛈️';
    return '🌡️';
  }

  String get dayName {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }
}

class WeatherModel {
  final String cityName;
  final String country;
  final double latitude;
  final double longitude;
  final double temperature;
  final double apparentTemperature;
  final double windSpeed;
  final int humidity;
  final int weatherCode;
  final DateTime fetchedAt;
  final List<ForecastDay> forecastDays;

  WeatherModel({
    required this.cityName,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.temperature,
    required this.apparentTemperature,
    required this.windSpeed,
    required this.humidity,
    required this.weatherCode,
    required this.fetchedAt,
    required this.forecastDays,
  });

  factory WeatherModel.fromJson(
      Map<String, dynamic> json, String cityName, String country,
      double latitude, double longitude) {
    final current = json['current_weather'];
    final hourly = json['hourly'];
    final daily = json['daily'];

    final List<ForecastDay> forecasts = [];
    if (daily != null) {
      final int count = (daily['time'] as List).length;
      for (int i = 0; i < count; i++) {
        forecasts.add(ForecastDay.fromJson(daily, i));
      }
    }

    return WeatherModel(
      cityName: cityName,
      country: country,
      latitude: latitude,
      longitude: longitude,
      temperature: (current['temperature'] as num).toDouble(),
      apparentTemperature:
          (hourly['apparent_temperature'][0] as num).toDouble(),
      windSpeed: (current['windspeed'] as num).toDouble(),
      humidity: (hourly['relativehumidity_2m'][0] as num).toInt(),
      weatherCode: (current['weathercode'] as num).toInt(),
      fetchedAt: DateTime.now(),
      forecastDays: forecasts,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cityName': cityName,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'temperature': temperature,
      'apparentTemperature': apparentTemperature,
      'windSpeed': windSpeed,
      'humidity': humidity,
      'weatherCode': weatherCode,
      'fetchedAt': fetchedAt.toIso8601String(),
      'forecastDays': forecastDays.map((f) => f.toJson()).toList(),
    };
  }

  factory WeatherModel.fromCache(Map<String, dynamic> json) {
    final List<ForecastDay> forecasts = [];
    if (json['forecastDays'] != null) {
      for (final f in json['forecastDays']) {
        forecasts.add(ForecastDay(
          date: DateTime.parse(f['time']),
          maxTemperature: (f['temperature_2m_max'] as num).toDouble(),
          minTemperature: (f['temperature_2m_min'] as num).toDouble(),
          weatherCode: (f['weathercode'] as num).toInt(),
        ));
      }
    }

    return WeatherModel(
      cityName: json['cityName'],
      country: json['country'] ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      temperature: (json['temperature'] as num).toDouble(),
      apparentTemperature: (json['apparentTemperature'] as num).toDouble(),
      windSpeed: (json['windSpeed'] as num).toDouble(),
      humidity: (json['humidity'] as num).toInt(),
      weatherCode: (json['weatherCode'] as num).toInt(),
      fetchedAt: DateTime.parse(json['fetchedAt']),
      forecastDays: forecasts,
    );
  }

  // Convert WeatherModel ke LocationModel untuk re-fetch
  Map<String, dynamic> toLocation() {
    return {
      'name': cityName,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  String get conditionLabel {
    if (weatherCode == 0) return 'Sunny';
    if (weatherCode <= 3) return 'Cloudy';
    if (weatherCode <= 67) return 'Rainy';
    if (weatherCode <= 77) return 'Snowy';
    if (weatherCode <= 99) return 'Stormy';
    return 'Unknown';
  }

  String get conditionEmoji {
    if (weatherCode == 0) return '☀️';
    if (weatherCode <= 3) return '⛅';
    if (weatherCode <= 67) return '🌧️';
    if (weatherCode <= 77) return '❄️';
    if (weatherCode <= 99) return '⛈️';
    return '🌡️';
  }

  String get formattedFetchTime {
    final hour = fetchedAt.hour.toString().padLeft(2, '0');
    final minute = fetchedAt.minute.toString().padLeft(2, '0');
    final day = fetchedAt.day.toString().padLeft(2, '0');
    final month = fetchedAt.month.toString().padLeft(2, '0');
    final year = fetchedAt.year;
    return '$day/$month/$year $hour:$minute';
  }
}