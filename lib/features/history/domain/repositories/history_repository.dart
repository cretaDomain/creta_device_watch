import 'package:creta_device_watch/features/history/domain/entities/historical_event.dart';

abstract class HistoryRepository {
  Future<List<HistoricalEvent>> getHistoricalEvents(int month, int day);
}
