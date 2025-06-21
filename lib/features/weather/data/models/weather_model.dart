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
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'],
      temperature: (json['main']['temp'] as num).toDouble(),
      tempMin: (json['main']['temp_min'] as num).toDouble(),
      tempMax: (json['main']['temp_max'] as num).toDouble(),
      condition: json['weather'][0]['main'],
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      windDirection: json['wind']['deg'],
      humidity: json['main']['humidity'],
      pressure: json['main']['pressure'],
      clouds: json['clouds']['all'],
      lastUpdated: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    // Note: toJson might not be needed if we don't save weather data locally.
    // This is a basic implementation for completeness.
    return {
      'name': cityName,
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
      'dt': lastUpdated.toIso8601String(),
    };
  }
}
