import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:creta_device_watch/features/weather/domain/entities/weather.dart';
import 'package:creta_device_watch/features/weather/domain/repositories/weather_repository.dart';
import 'package:creta_device_watch/features/weather/domain/usecases/get_weather.dart';

import 'get_weather_test.mocks.dart';

@GenerateMocks([WeatherRepository])
void main() {
  late GetWeather usecase;
  late MockWeatherRepository mockWeatherRepository;

  setUp(() {
    mockWeatherRepository = MockWeatherRepository();
    usecase = GetWeather(mockWeatherRepository);
  });

  const tCityName = 'Seoul';
  final tWeather = Weather(
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
    lastUpdated: DateTime.now(),
  );

  test(
    'should get weather for the city from the repository',
    () async {
      // arrange
      when(mockWeatherRepository.getWeather(any)).thenAnswer((_) async => tWeather);
      // act
      final result = await usecase.execute(tCityName);
      // assert
      expect(result, tWeather);
      verify(mockWeatherRepository.getWeather(tCityName));
      verifyNoMoreInteractions(mockWeatherRepository);
    },
  );
}
