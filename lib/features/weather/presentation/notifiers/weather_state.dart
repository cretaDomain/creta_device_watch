import 'package:equatable/equatable.dart';
import 'package:creta_device_watch/features/weather/domain/entities/weather.dart';

class WeatherState extends Equatable {
  final bool isLoading;
  final Weather? weather;
  final String? error;

  const WeatherState({
    this.isLoading = false,
    this.weather,
    this.error,
  });

  factory WeatherState.initial() {
    return const WeatherState(isLoading: true);
  }

  WeatherState copyWith({
    bool? isLoading,
    Weather? weather,
    String? error,
  }) {
    return WeatherState(
      isLoading: isLoading ?? this.isLoading,
      weather: weather ?? this.weather,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [isLoading, weather, error];
}
