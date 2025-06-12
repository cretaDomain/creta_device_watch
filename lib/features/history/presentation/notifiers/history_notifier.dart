import 'package:creta_device_watch/features/history/domain/entities/historical_event.dart';
import 'package:creta_device_watch/features/history/domain/usecases/get_historical_events.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:creta_device_watch/core/di/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:translator/translator.dart';

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

  Future<void> translateEvent(int eventIndex) async {
    state.whenData((events) async {
      if (eventIndex < 0 || eventIndex >= events.length) return;

      final eventToTranslate = events[eventIndex];
      if (eventToTranslate.translatedText != null) return; // Already translated

      try {
        final translator = GoogleTranslator();
        final translated = await translator.translate(eventToTranslate.text, to: 'ko');
        final updatedEvent = eventToTranslate.copyWith(translatedText: translated.text);

        final newEvents = List<HistoricalEvent>.from(events);
        newEvents[eventIndex] = updatedEvent;
        state = AsyncValue.data(newEvents);
      } catch (e, st) {
        // Optionally, handle translation errors on a per-item basis
        // For now, we just don't update the state on failure
        debugPrint('Failed to translate event: $e');
        debugPrint(st.toString());
      }
    });
  }
}

final historyNotifierProvider = StateNotifierProvider.autoDispose
    .family<HistoryNotifier, AsyncValue<List<HistoricalEvent>>, DateTime>((ref, date) {
  final getHistoricalEvents = ref.watch(getHistoricalEventsUseCaseProvider);
  return HistoryNotifier(getHistoricalEvents, date.month, date.day);
});
