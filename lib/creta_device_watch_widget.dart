import 'dart:math';

import 'package:creta_rsi/creta_rsi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:creta_device_watch/core/di/provider.dart';
import 'package:creta_device_watch/features/clock/presentation/pages/clock_page.dart';

import 'core/theme/app_theme.dart';

/// [CretaDeviceWatchWidget]에 필요한 의존성을 초기화합니다.
///
/// 애플리케이션의 `main` 함수에서 앱을 실행하기 전에 호출해야 합니다.
///
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await initializeCretaDeviceWatch();
///
///   runApp(
///     const ProviderScope(
///       child: MyApp(), // Your app
///     ),
///   );
/// }
/// ```
Future<void> initializeCretaDeviceWatch() async {
  await initializeDateFormatting('ko_KR', null);
  tz_data.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
}

/// 디지털 시계를 표시하는 위젯입니다.
///
/// 이 위젯이 올바르게 작동하려면 `ProviderScope`로 감싸야 합니다.
class CretaDeviceWatchWidget extends ConsumerStatefulWidget {
  final List<String> alarmTimes;
  final double width;
  final double height;
  final bool showBorder;

  const CretaDeviceWatchWidget({
    super.key,
    this.alarmTimes = const [],
    this.width = 1920,
    this.height = 400,
    this.showBorder = false,
  });

  @override
  ConsumerState<CretaDeviceWatchWidget> createState() => _CretaDeviceWatchWidgetState();
}

class _CretaDeviceWatchWidgetState extends ConsumerState<CretaDeviceWatchWidget> {
  int _currentIndex = 0;

  void _showRsiScreen() {
    setState(() {
      _currentIndex = 1;
    });
  }

  void _showClockScreen() {
    setState(() {
      _currentIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sharedPreferencesAsync = ref.watch(sharedPreferencesProvider);

    return sharedPreferencesAsync.when(
      data: (_) {
        final settings = ref.watch(settingsProvider);
        return Transform.rotate(
          angle: settings.isFlipped ? pi : 0,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Digital Clock',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            home: Center(
              child: Container(
                width: widget.width,
                height: widget.height,
                decoration: widget.showBorder
                    ? BoxDecoration(
                        border: Border.all(color: Colors.blue, width: 10),
                      )
                    : null,
                child: IndexedStack(
                  index: _currentIndex,
                  children: [
                    ClockPage(
                      width: widget.width,
                      height: widget.height,
                      alarmTimes: widget.alarmTimes,
                      onShowRsi: _showRsiScreen,
                    ),
                    Stack(
                      children: [
                        const CretaRSIMainScreen(),
                        Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back, color: Colors.white),
                                iconSize: 72.0,
                                onPressed: _showClockScreen,
                                tooltip: '뒤로가기',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}
