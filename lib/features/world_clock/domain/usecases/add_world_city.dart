import 'package:creta_device_watch/features/world_clock/domain/entities/world_city.dart';
import 'package:creta_device_watch/features/world_clock/domain/repositories/world_clock_repository.dart';

class AddWorldCity {
  final WorldClockRepository repository;

  AddWorldCity(this.repository);

  Future<void> call(WorldCity city) {
    return repository.addWorldCity(city);
  }
}
