import 'dart:math';

import 'package:creta_device_watch/features/weather/domain/entities/weather.dart';

class WeatherModel extends Weather {
  const WeatherModel({
    required super.cityName,
    required super.temperature,
    required super.tempMin,
    required super.tempMax,
    required super.condition,
    required super.description,
    required super.icon,
    required super.windSpeed,
    required super.windDirection,
    required super.humidity,
    required super.pressure,
    required super.clouds,
    required super.lastUpdated,
    super.rainVolume,
    super.snowVolume,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final currentWeather = json['list'][0];
    final weatherList = json['list'] as List;

    final today = DateTime.now();
    double tempMinToday = double.maxFinite;
    double tempMaxToday = -double.maxFinite;

    for (var forecast in weatherList) {
      final forecastDate = DateTime.parse(forecast['dt_txt']);
      if (forecastDate.year == today.year &&
          forecastDate.month == today.month &&
          forecastDate.day == today.day) {
        final temp = (forecast['main']['temp'] as num).toDouble();
        tempMinToday = min(tempMinToday, temp);
        tempMaxToday = max(tempMaxToday, temp);
      }
    }

    if (tempMinToday == double.maxFinite) {
      tempMinToday = (currentWeather['main']['temp_min'] as num).toDouble();
    }
    if (tempMaxToday == -double.maxFinite) {
      tempMaxToday = (currentWeather['main']['temp_max'] as num).toDouble();
    }

    final rain = currentWeather['rain']?['3h'] as num?;
    final snow = currentWeather['snow']?['3h'] as num?;

    return WeatherModel(
      cityName: json['city']['name'],
      temperature: (currentWeather['main']['temp'] as num).toDouble(),
      tempMin: tempMinToday,
      tempMax: tempMaxToday,
      condition: currentWeather['weather'][0]['main'],
      description: currentWeather['weather'][0]['description'],
      icon: currentWeather['weather'][0]['icon'],
      windSpeed: (currentWeather['wind']['speed'] as num).toDouble(),
      windDirection: currentWeather['wind']['deg'],
      humidity: currentWeather['main']['humidity'],
      pressure: currentWeather['main']['pressure'],
      clouds: currentWeather['clouds']['all'],
      lastUpdated: DateTime.now(),
      rainVolume: rain?.toDouble() ?? 0.0,
      snowVolume: snow?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': {'name': cityName},
      'list': [
        {
          'main': {
            'temp': temperature,
            'temp_min': tempMin,
            'temp_max': tempMax,
            'humidity': humidity,
            'pressure': pressure,
          },
          'weather': [
            {
              'main': condition,
              'description': description,
              'icon': icon,
            }
          ],
          'wind': {
            'speed': windSpeed,
            'deg': windDirection,
          },
          'clouds': {
            'all': clouds,
          },
          'dt_txt': lastUpdated.toIso8601String(),
          'rain': rainVolume != null ? {'3h': rainVolume} : null,
          'snow': snowVolume != null ? {'3h': snowVolume} : null,
        }
      ]
    };
  }
}
