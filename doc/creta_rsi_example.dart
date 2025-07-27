import 'dart:io' show Platform;
import 'package:creta_rsi/core/background/background_service.dart';
import 'package:creta_rsi/presentation/riverpod/providers.dart';
import 'package:creta_rsi/presentation/riverpod/settings_state.dart';
import 'package:creta_rsi/presentation/screens/splash_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:creta_rsi/presentation/screens/main_screen.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
  );

  // 앱 시작 시 데이터 로딩 시작
  container.read(settingsProvider.notifier).loadSettings();
  container.read(stockNotifierProvider.notifier).fetchStocks();

  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    await initializeService();
  }

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(1920, 480),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);
    final isDarkMode = settingsState is SettingsLoaded ? settingsState.settings.isDarkMode : false;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Creta RSI Widget',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const CretaRSISplashScreen(),
    );
  }
}
