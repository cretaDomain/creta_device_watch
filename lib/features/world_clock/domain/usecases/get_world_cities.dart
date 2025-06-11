import 'package:creta_device_watch/features/world_clock/domain/entities/world_city.dart';
import 'package:creta_device_watch/features/world_clock/domain/repositories/world_clock_repository.dart';

class GetWorldCities {
  final WorldClockRepository repository;

  GetWorldCities(this.repository);

  Future<List<WorldCity>> call() {
    return repository.getWorldCities();
  }
}
