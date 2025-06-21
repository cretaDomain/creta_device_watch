import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:creta_device_watch/core/di/provider.dart';
import 'package:creta_device_watch/features/weather/domain/usecases/get_weather.dart';
import 'package:creta_device_watch/features/weather/presentation/notifiers/weather_state.dart';

final weatherProvider = StateNotifierProvider<WeatherNotifier, WeatherState>((ref) {
  final getWeather = ref.watch(getWeatherProvider);
  // Watch the settings provider to react to changes
  final isWeatherEnabled = ref.watch(settingsProvider.select((s) => s.isWeatherEnabled));

  return WeatherNotifier(getWeather, isWeatherEnabled);
});

class WeatherNotifier extends StateNotifier<WeatherState> {
  final GetWeather _getWeather;
  Timer? _timer;
  final bool _isWeatherEnabled;

  // Let's use the default city 'Seoul' for now.
  String _currentCity = 'Seoul';

  WeatherNotifier(this._getWeather, this._isWeatherEnabled) : super(WeatherState.initial()) {
    if (_isWeatherEnabled) {
      fetchWeather();
      _startPeriodicTimer();
    }
  }

  Future<void> fetchWeather([String? cityName]) async {
    if (cityName != null) {
      _currentCity = cityName;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final weather = await _getWeather.execute(_currentCity);
      state = state.copyWith(isLoading: false, weather: weather);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void _startPeriodicTimer() {
    _timer?.cancel();
    // Fetch weather every hour
    _timer = Timer.periodic(const Duration(hours: 1), (timer) {
      fetchWeather();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
