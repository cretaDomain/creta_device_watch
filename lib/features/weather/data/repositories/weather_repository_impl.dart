import 'package:creta_device_watch/features/weather/data/datasources/weather_remote_data_source.dart';
import 'package:creta_device_watch/features/weather/domain/entities/weather.dart';
import 'package:creta_device_watch/features/weather/domain/repositories/weather_repository.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource remoteDataSource;
  // In a real app, you might also have a local data source for caching
  // final WeatherLocalDataSource localDataSource;

  WeatherRepositoryImpl({
    required this.remoteDataSource,
    // required this.localDataSource,
  });

  @override
  Future<Weather> getWeather(String cityName) async {
    // Here you could add logic to check network connection,
    // or try fetching from a local cache first.
    try {
      final remoteWeather = await remoteDataSource.getWeather(cityName);
      // You could cache the data here:
      // localDataSource.cacheWeather(remoteWeather);
      return remoteWeather;
    } catch (e) {
      // If remote fails, you might want to return cached data:
      // return localDataSource.getLastWeather();
      // For now, we just rethrow the exception.
      rethrow;
    }
  }
}
