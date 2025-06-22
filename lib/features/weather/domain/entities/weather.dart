import 'package:equatable/equatable.dart';

class Weather extends Equatable {
  final String cityName;
  final double temperature;
  final double tempMin;
  final double tempMax;
  final String condition;
  final String description;
  final String icon;
  final double windSpeed;
  final int windDirection;
  final int humidity;
  final int pressure;
  final int clouds;
  final DateTime lastUpdated;
  final double? rainVolume;
  final double? snowVolume;

  const Weather({
    required this.cityName,
    required this.temperature,
    required this.tempMin,
    required this.tempMax,
    required this.condition,
    required this.description,
    required this.icon,
    required this.windSpeed,
    required this.windDirection,
    required this.humidity,
    required this.pressure,
    required this.clouds,
    required this.lastUpdated,
    this.rainVolume,
    this.snowVolume,
  });

  @override
  List<Object?> get props => [
        cityName,
        temperature,
        tempMin,
        tempMax,
        condition,
        description,
        icon,
        windSpeed,
        windDirection,
        humidity,
        pressure,
        clouds,
        lastUpdated,
        rainVolume,
        snowVolume,
      ];
}
