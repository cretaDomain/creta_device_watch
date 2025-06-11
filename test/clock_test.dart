import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:creta_device_watch/features/clock/domain/repositories/time_repository.dart';
import 'package:creta_device_watch/features/clock/domain/usecases/get_time_stream.dart';

class MockTimeRepository extends Mock implements TimeRepository {}

void main() {
  late GetTimeStream usecase;
  late MockTimeRepository mockTimeRepository;

  setUp(() {
    mockTimeRepository = MockTimeRepository();
    usecase = GetTimeStream(mockTimeRepository);
  });

  test(
    'should get time stream from the repository',
    () {
      // arrange
      final testStream = Stream.fromIterable([DateTime.now()]);
      when(() => mockTimeRepository.getTimeStream()).thenAnswer((_) => testStream);
      // act
      final result = usecase();
      // assert
      expect(result, isA<Stream<DateTime>>());
      verify(() => mockTimeRepository.getTimeStream());
      verifyNoMoreInteractions(mockTimeRepository);
    },
  );
}
