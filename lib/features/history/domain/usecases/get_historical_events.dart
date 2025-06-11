import 'package:creta_device_watch/features/history/domain/entities/historical_event.dart';
import 'package:creta_device_watch/features/history/domain/repositories/history_repository.dart';

class GetHistoricalEventsUseCase {
  final HistoryRepository repository;

  GetHistoricalEventsUseCase(this.repository);

  Future<List<HistoricalEvent>> call(int month, int day) {
    return repository.getHistoricalEvents(month, day);
  }
}
