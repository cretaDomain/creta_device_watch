import 'dart:math';

import 'package:creta_rsi/creta_rsi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:creta_device_watch/core/di/provider.dart';
import 'package:creta_device_watch/features/clock/presentation/pages/clock_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';

// Base size and aspect for the watch UI (1920 : 480)
const double kMinWatchWidth = 1920.0; // Base width for aspect calculation
const double kMinWatchHeight = 480.0; // Base height for aspect calculation
const double kWatchAspectRatio = kMinWatchWidth / kMinWatchHeight; // 1920 : 480

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
  final bool showBorder;
  final bool useOnlyWatch; // 시계 기능만 사용
  final bool showMenuButtons; // 하단 메뉴 표시 여부
  final bool darkMode; // 초기 다크 모드 여부
  final bool flipScreen; // 초기 화면 회전 여부(뒤집기)

  const CretaDeviceWatchWidget({
    super.key,
    this.alarmTimes = const [],
    this.width = 1920,
    this.showBorder = false,
    this.useOnlyWatch = false,
    this.showMenuButtons = true,
    this.darkMode = true,
    this.flipScreen = false,
  });

  @override
  ConsumerState<CretaDeviceWatchWidget> createState() => _CretaDeviceWatchWidgetState();
}

class _CretaDeviceWatchWidgetState extends ConsumerState<CretaDeviceWatchWidget> {
  bool _showRsiScreen = false;
  late final Future<void> _applyInitialOptionsFuture;

  void _toggleScreen() {
    setState(() {
      _showRsiScreen = !_showRsiScreen;
    });
  }

  @override
  void initState() {
    super.initState();
    _applyInitialOptionsFuture = _applyInitialOptionsToPrefs();
  }

  Future<void> _applyInitialOptionsToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', widget.darkMode ? 'dark' : 'light');
    await prefs.setBool('isFlipped', widget.flipScreen);
    // Also update in-memory settings to avoid relying on a later reload
    final desiredTheme = widget.darkMode ? ThemeMode.dark : ThemeMode.light;
    final settingsNow = ref.read(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    if (settingsNow.themeMode != desiredTheme) {
      await settingsNotifier.updateThemeMode(desiredTheme);
    }
    if (settingsNow.isFlipped != widget.flipScreen) {
      await settingsNotifier.toggleFlipped();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sharedPreferencesAsync = ref.watch(sharedPreferencesProvider);

    return sharedPreferencesAsync.when(
      data: (_) {
        return FutureBuilder<void>(
          future: _applyInitialOptionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const SizedBox.shrink();
            }
            final settings = ref.watch(settingsProvider);
            return Transform.rotate(
              angle: settings.isFlipped ? pi : 0,
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Digital Clock',
                theme: widget.darkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
                darkTheme: widget.darkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
                themeMode: settings.themeMode,
                home: Center(
                  child: Container(
                    width: widget.width,
                    height: () {
                      final effectiveWidth = widget.width;
                      final computedHeight = effectiveWidth / kWatchAspectRatio;
                      return _showRsiScreen && !widget.useOnlyWatch
                          ? max(computedHeight, 480.0)
                          : computedHeight;
                    }(),
                    decoration: widget.showBorder
                        ? BoxDecoration(
                            border: Border.all(color: Colors.blue, width: 10),
                          )
                        : null,
                    child: _showRsiScreen && !widget.useOnlyWatch
                        ? Stack(
                            children: [
                              const CretaRSIMainScreen(),
                              Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 4, right: 100.0),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.home_outlined,
                                      color: Colors.white,
                                    ),
                                    iconSize: 32.0,
                                    onPressed: _toggleScreen,
                                    tooltip: '뒤로가기',
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ClockPage(
                            width: widget.width,
                            height: widget.width / kWatchAspectRatio,
                            alarmTimes: widget.alarmTimes,
                            onShowRsi: widget.useOnlyWatch ? () {} : _toggleScreen,
                            useOnlyWatch: widget.useOnlyWatch,
                            showMenuButtons: widget.showMenuButtons,
                          ),
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}
