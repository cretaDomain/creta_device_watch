import 'package:creta_device_watch/features/history/domain/entities/historical_event.dart';
import 'package:creta_device_watch/features/history/domain/usecases/get_historical_events.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:creta_device_watch/core/di/provider.dart';

class HistoryNotifier extends StateNotifier<AsyncValue<List<HistoricalEvent>>> {
  final GetHistoricalEventsUseCase _getHistoricalEvents;
  final int month;
  final int day;

  HistoryNotifier(this._getHistoricalEvents, this.month, this.day)
      : super(const AsyncValue.loading()) {
    fetchHistoricalEvents();
  }

  Future<void> fetchHistoricalEvents() async {
    state = const AsyncValue.loading();
    try {
      final events = await _getHistoricalEvents(month, day);
      state = AsyncValue.data(events);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final historyNotifierProvider = StateNotifierProvider.autoDispose
    .family<HistoryNotifier, AsyncValue<List<HistoricalEvent>>, DateTime>((ref, date) {
  final getHistoricalEvents = ref.watch(getHistoricalEventsUseCaseProvider);
  return HistoryNotifier(getHistoricalEvents, date.month, date.day);
});
