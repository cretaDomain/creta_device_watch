import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:creta_device_watch/core/di/provider.dart';
import 'package:creta_device_watch/features/clock/domain/usecases/get_time_stream.dart';

class TimeNotifier extends Notifier<AsyncValue<DateTime>> {
  late final GetTimeStream _getTimeStream;
  Stream<DateTime>? _stream;

  @override
  AsyncValue<DateTime> build() {
    _getTimeStream = ref.watch(getTimeStreamProvider);
    _stream = _getTimeStream();

    _stream!.listen((time) {
      state = AsyncValue.data(time);
    }, onError: (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    });

    return const AsyncValue.loading();
  }

  Stream<DateTime> get stream => _stream!;
}

final timeNotifierProvider = NotifierProvider<TimeNotifier, AsyncValue<DateTime>>(TimeNotifier.new);
