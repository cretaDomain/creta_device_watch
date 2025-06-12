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
class CretaDeviceWatchWidget extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final sharedPreferencesAsync = ref.watch(sharedPreferencesProvider);

    return sharedPreferencesAsync.when(
      data: (_) {
        final settings = ref.watch(settingsProvider);
        return MaterialApp(
          title: 'Digital Clock',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settings.themeMode,
          home: Center(
            child: Container(
              width: width,
              height: height,
              decoration: showBorder
                  ? BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 10),
                    )
                  : null,
              child: ClockPage(
                width: width,
                height: height,
                alarmTimes: alarmTimes,
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
