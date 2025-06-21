import 'package:creta_device_watch/features/weather/domain/entities/weather.dart';

abstract class WeatherRepository {
  Future<Weather> getWeather(String cityName);
}
