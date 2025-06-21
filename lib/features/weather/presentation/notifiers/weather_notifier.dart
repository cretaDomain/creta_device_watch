import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:creta_device_watch/features/weather/domain/usecases/get_weather.dart';
import 'weather_state.dart';

class WeatherNotifier extends StateNotifier<WeatherState> {
  final GetWeather _getWeather;
  Timer? _timer;

  // Let's use the default city 'Seoul' for now.
  String _currentCity = 'Seoul';

  WeatherNotifier(this._getWeather) : super(WeatherState.initial()) {
    fetchWeather(_currentCity);
    _startTimer();
  }

  Future<void> fetchWeather(String cityName) async {
    _currentCity = cityName;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final weather = await _getWeather.execute(cityName);
      state = state.copyWith(isLoading: false, weather: weather);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void _startTimer() {
    // Fetch weather every hour
    _timer = Timer.periodic(const Duration(hours: 1), (timer) {
      fetchWeather(_currentCity);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
