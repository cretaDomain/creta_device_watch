import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:creta_device_watch/core/api/api_key.dart';
import 'package:creta_device_watch/features/weather/data/datasources/weather_remote_data_source.dart';
import 'package:creta_device_watch/features/weather/data/models/weather_model.dart';

import 'weather_remote_data_source_test.mocks.dart';

// 1. http.Client 클래스를 목킹 대상으로 지정합니다.
@GenerateMocks([http.Client])
void main() {
  late WeatherRemoteDataSourceImpl dataSource;
  late MockClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockClient();
    dataSource = WeatherRemoteDataSourceImpl(client: mockHttpClient);
  });

  const tCityName = 'Seoul';
  final tUri = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?q=$tCityName&appid=$openWeatherApiKey&units=metric');

  // 테스트에 사용할 가짜 JSON 데이터 (OpenWeatherMap API 응답 형식)
  final tWeatherJson = {
    "coord": {"lon": 126.9778, "lat": 37.5683},
    "weather": [
      {"id": 800, "main": "Clear", "description": "clear sky", "icon": "01d"}
    ],
    "base": "stations",
    "main": {
      "temp": 25.4,
      "feels_like": 25.4,
      "temp_min": 22.94,
      "temp_max": 26.97,
      "pressure": 1012,
      "humidity": 44
    },
    "visibility": 10000,
    "wind": {"speed": 2.06, "deg": 340},
    "clouds": {"all": 0},
    "dt": 1718946408,
    "sys": {"type": 1, "id": 8105, "country": "KR", "sunrise": 1718828005, "sunset": 1718880942},
    "timezone": 32400,
    "id": 1835848,
    "name": "Seoul",
    "cod": 200
  };
  final tWeatherModel = WeatherModel.fromJson(tWeatherJson);

  group('getWeather', () {
    test(
      'should perform a GET request on a URL with city name being the endpoint and with application/json header',
      () async {
        // arrange
        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response(json.encode(tWeatherJson), 200));
        // act
        await dataSource.getWeather(tCityName);
        // assert
        verify(mockHttpClient.get(
          tUri,
          headers: {'Content-Type': 'application/json'},
        ));
      },
    );

    test(
      'should return Weather when the response code is 200 (success)',
      () async {
        // arrange
        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response(json.encode(tWeatherJson), 200));
        // act
        final result = await dataSource.getWeather(tCityName);
        // assert
        // `lastUpdated` is generated dynamically, so we can't do a simple equality check.
        // Instead, we check that the other properties match.
        expect(result.cityName, tWeatherModel.cityName);
        expect(result.condition, tWeatherModel.condition);
        expect(result.temperature, tWeatherModel.temperature);
        // You could add more checks for other fields if needed.
      },
    );

    test(
      'should throw an Exception when the response code is 404 or other',
      () async {
        // arrange
        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response('Something went wrong', 404));
        // act
        final call = dataSource.getWeather;
        // assert
        expect(() => call(tCityName), throwsA(isA<Exception>()));
      },
    );
  });
}
