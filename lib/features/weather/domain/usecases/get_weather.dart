import 'package:creta_device_watch/features/weather/domain/entities/weather.dart';
import 'package:creta_device_watch/features/weather/domain/repositories/weather_repository.dart';

class GetWeather {
  final WeatherRepository repository;

  GetWeather(this.repository);

  Future<Weather> execute(String cityName) {
    return repository.getWeather(cityName);
  }
}
