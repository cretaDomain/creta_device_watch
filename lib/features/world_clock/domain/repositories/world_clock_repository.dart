import 'package:creta_device_watch/features/world_clock/domain/entities/world_city.dart';

abstract class WorldClockRepository {
  Future<List<WorldCity>> getWorldCities();
  Future<void> addWorldCity(WorldCity city);
  Future<void> deleteWorldCity(String cityId);
}
