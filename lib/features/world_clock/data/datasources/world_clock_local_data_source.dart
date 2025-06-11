//import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:creta_device_watch/features/world_clock/data/models/world_city_model.dart';

abstract class WorldClockLocalDataSource {
  Future<List<WorldCityModel>> getWorldCities();
  Future<void> addWorldCity(WorldCityModel city);
  Future<void> deleteWorldCity(String cityId);
}

const kWorldCitiesKey = 'world_cities';

class WorldClockLocalDataSourceImpl implements WorldClockLocalDataSource {
  final SharedPreferences sharedPreferences;

  WorldClockLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<List<WorldCityModel>> getWorldCities() async {
    final jsonStringList = sharedPreferences.getStringList(kWorldCitiesKey);
    if (jsonStringList != null) {
      return jsonStringList.map((jsonString) {
        return WorldCityModel.fromJson(jsonString);
      }).toList();
    } else {
      return [];
    }
  }

  @override
  Future<void> addWorldCity(WorldCityModel city) async {
    final cities = await getWorldCities();
    cities.add(city);
    await _saveCities(cities);
  }

  @override
  Future<void> deleteWorldCity(String cityId) async {
    final cities = await getWorldCities();
    cities.removeWhere((city) => city.id == cityId);
    await _saveCities(cities);
  }

  Future<void> _saveCities(List<WorldCityModel> cities) async {
    final jsonStringList = cities.map((city) => city.toJson()).toList();
    await sharedPreferences.setStringList(kWorldCitiesKey, jsonStringList);
  }
}
