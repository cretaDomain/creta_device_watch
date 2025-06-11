import 'package:flutter_test/flutter_test.dart';
import 'package:creta_device_watch/features/world_clock/domain/entities/world_city.dart';
import 'package:creta_device_watch/features/world_clock/domain/repositories/world_clock_repository.dart';
import 'package:creta_device_watch/features/world_clock/domain/usecases/add_world_city.dart';
import 'package:creta_device_watch/features/world_clock/domain/usecases/delete_world_city.dart';
import 'package:creta_device_watch/features/world_clock/domain/usecases/get_world_cities.dart';

// Faking the repository to avoid mockito issues
class FakeWorldClockRepository implements WorldClockRepository {
  final List<WorldCity> _cities = [];
  bool getCitiesCalled = false;
  WorldCity? addedCity;
  String? deletedCityId;

  @override
  Future<void> addWorldCity(WorldCity city) async {
    addedCity = city;
    _cities.add(city);
  }

  @override
  Future<void> deleteWorldCity(String cityId) async {
    deletedCityId = cityId;
    _cities.removeWhere((c) => c.id == cityId);
  }

  @override
  Future<List<WorldCity>> getWorldCities() async {
    getCitiesCalled = true;
    return _cities;
  }
}

void main() {
  late FakeWorldClockRepository fakeWorldClockRepository;
  late GetWorldCities getWorldCities;
  late AddWorldCity addWorldCity;
  late DeleteWorldCity deleteWorldCity;

  setUp(() {
    fakeWorldClockRepository = FakeWorldClockRepository();
    getWorldCities = GetWorldCities(fakeWorldClockRepository);
    addWorldCity = AddWorldCity(fakeWorldClockRepository);
    deleteWorldCity = DeleteWorldCity(fakeWorldClockRepository);
  });

  final tCity = WorldCity(id: '1', city: 'Test City', timezone: 'Test/Zone');

  group('GetWorldCities', () {
    test('should get list of cities from the repository', () async {
      // arrange
      await fakeWorldClockRepository.addWorldCity(tCity);
      // act
      final result = await getWorldCities();
      // assert
      expect(result, [tCity]);
      expect(fakeWorldClockRepository.getCitiesCalled, isTrue);
    });
  });

  group('AddWorldCity', () {
    test('should call addWorldCity on the repository', () async {
      // act
      await addWorldCity(tCity);
      // assert
      expect(fakeWorldClockRepository.addedCity, tCity);
    });
  });

  group('DeleteWorldCity', () {
    test('should call deleteWorldCity on the repository', () async {
      // arrange
      await fakeWorldClockRepository.addWorldCity(tCity);
      // act
      await deleteWorldCity(tCity.id);
      // assert
      expect(fakeWorldClockRepository.deletedCityId, tCity.id);
    });
  });
}
