import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:creta_device_watch/core/api/api_key.dart';
import 'package:creta_device_watch/features/weather/data/models/weather_model.dart';

abstract class WeatherRemoteDataSource {
  Future<WeatherModel> getWeather(String cityName);
}

class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  final http.Client client;

  WeatherRemoteDataSourceImpl({required this.client});

  @override
  Future<WeatherModel> getWeather(String cityName) async {
    debugPrint('getWeather $cityName $openWeatherApiKey');
    final uri = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$openWeatherApiKey&units=metric');

    final response = await client.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      debugPrint('response.body: ${response.body}');
      return WeatherModel.fromJson(json.decode(response.body));
    } else {
      // You can define custom exceptions for different error cases
      debugPrint('response.statusCode: ${response.statusCode}');
      throw Exception('Failed to load weather data');
    }
  }
}
