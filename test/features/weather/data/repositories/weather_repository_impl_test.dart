import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:creta_device_watch/features/weather/data/datasources/weather_remote_data_source.dart';
import 'package:creta_device_watch/features/weather/data/models/weather_model.dart';
import 'package:creta_device_watch/features/weather/data/repositories/weather_repository_impl.dart';

import 'weather_repository_impl_test.mocks.dart';

@GenerateMocks([WeatherRemoteDataSource])
void main() {
  late WeatherRepositoryImpl repository;
  late MockWeatherRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockWeatherRemoteDataSource();
    repository = WeatherRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
    );
  });

  const tCityName = 'Seoul';
  final tWeatherModel = WeatherModel(
    cityName: 'Seoul',
    temperature: 25.0,
    tempMin: 22.0,
    tempMax: 28.0,
    condition: 'Clear',
    description: 'clear sky',
    icon: '01d',
    windSpeed: 2.5,
    windDirection: 180,
    humidity: 60,
    pressure: 1012,
    clouds: 0,
    lastUpdated: DateTime(2024),
  );
  // Note: Since WeatherModel extends Weather, tWeatherModel can be used as a Weather entity.
  final tWeather = tWeatherModel;

  group('getWeather', () {
    test(
      'should return weather data when the call to remote data source is successful',
      () async {
        // arrange
        when(mockRemoteDataSource.getWeather(any)).thenAnswer((_) async => tWeatherModel);
        // act
        final result = await repository.getWeather(tCityName);
        // assert
        verify(mockRemoteDataSource.getWeather(tCityName));
        expect(result, equals(tWeather));
      },
    );

    test(
      'should rethrow the exception when the call to remote data source is unsuccessful',
      () async {
        // arrange
        final tException = Exception('Test Exception');
        when(mockRemoteDataSource.getWeather(any)).thenThrow(tException);
        // act
        final call = repository.getWeather;
        // assert
        expect(() => call(tCityName), throwsA(isA<Exception>()));
      },
    );
  });
}
