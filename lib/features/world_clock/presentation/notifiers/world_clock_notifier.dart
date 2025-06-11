import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:creta_device_watch/core/di/provider.dart';
import 'package:creta_device_watch/features/world_clock/domain/entities/world_city.dart';
import 'package:creta_device_watch/features/world_clock/domain/usecases/add_world_city.dart';
import 'package:creta_device_watch/features/world_clock/domain/usecases/delete_world_city.dart';
import 'package:creta_device_watch/features/world_clock/domain/usecases/get_world_cities.dart';

class WorldClockNotifier extends StateNotifier<AsyncValue<List<WorldCity>>> {
  final GetWorldCities _getWorldCities;
  final AddWorldCity _addWorldCity;
  final DeleteWorldCity _deleteWorldCity;

  WorldClockNotifier({
    required GetWorldCities getWorldCities,
    required AddWorldCity addWorldCity,
    required DeleteWorldCity deleteWorldCity,
  })  : _getWorldCities = getWorldCities,
        _addWorldCity = addWorldCity,
        _deleteWorldCity = deleteWorldCity,
        super(const AsyncValue.loading()) {
    loadCities();
  }

  Future<void> loadCities() async {
    try {
      state = const AsyncValue.loading();
      final cities = await _getWorldCities();
      state = AsyncValue.data(cities);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> addCity(String cityName, String timezone) async {
    try {
      final newCity = WorldCity(
        id: const Uuid().v4(),
        city: cityName,
        timezone: timezone,
      );
      await _addWorldCity(newCity);
      loadCities(); // Refresh the list
    } catch (e, _) {
      // Optionally handle error state specifically for add
    }
  }

  Future<void> deleteCity(String cityId) async {
    try {
      await _deleteWorldCity(cityId);
      loadCities(); // Refresh the list
    } catch (e, _) {
      // Optionally handle error state specifically for delete
    }
  }
}

final worldClockNotifierProvider =
    StateNotifierProvider<WorldClockNotifier, AsyncValue<List<WorldCity>>>((ref) {
  return WorldClockNotifier(
    getWorldCities: ref.watch(getWorldCitiesProvider),
    addWorldCity: ref.watch(addWorldCityProvider),
    deleteWorldCity: ref.watch(deleteWorldCityProvider),
  );
});
