import 'package:creta_device_watch/features/world_clock/data/datasources/world_clock_local_data_source.dart';
import 'package:creta_device_watch/features/world_clock/data/models/world_city_model.dart';
import 'package:creta_device_watch/features/world_clock/domain/entities/world_city.dart';
import 'package:creta_device_watch/features/world_clock/domain/repositories/world_clock_repository.dart';

class WorldClockRepositoryImpl implements WorldClockRepository {
  final WorldClockLocalDataSource localDataSource;

  WorldClockRepositoryImpl(this.localDataSource);

  @override
  Future<List<WorldCity>> getWorldCities() async {
    return localDataSource.getWorldCities();
  }

  @override
  Future<void> addWorldCity(WorldCity city) async {
    final cityModel = WorldCityModel.fromEntity(city);
    await localDataSource.addWorldCity(cityModel);
  }

  @override
  Future<void> deleteWorldCity(String cityId) async {
    await localDataSource.deleteWorldCity(cityId);
  }
}
