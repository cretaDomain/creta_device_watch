import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:creta_device_watch/features/fortune_cookie/domain/entities/fortune_cookie.dart';
import 'package:creta_device_watch/features/fortune_cookie/domain/usecases/get_fortune_cookie.dart';

class FortuneCookieNotifier extends StateNotifier<AsyncValue<FortuneCookie?>> {
  final GetFortuneCookieUseCase _getFortuneCookieUseCase;

  FortuneCookieNotifier(this._getFortuneCookieUseCase) : super(const AsyncValue.data(null));

  Future<void> fetchFortuneCookie() async {
    // Prevent fetching if already loading
    if (state is AsyncLoading) return;

    state = const AsyncValue.loading();
    try {
      final fortuneCookie = await _getFortuneCookieUseCase();
      state = AsyncValue.data(fortuneCookie);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}
