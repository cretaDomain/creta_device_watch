import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player_media_kit/video_player_media_kit.dart';
import 'package:window_manager/window_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:creta_rsi/presentation/riverpod/providers.dart' as rsi_providers;
import 'package:creta_device_watch/creta_device_watch_widget.dart';
// ignore: depend_on_referenced_packages
//import 'package:creta_music_visualizer/music_visualizer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      rsi_providers.sharedPreferencesProvider.overrideWithValue(prefs),
    ],
  );

  container.read(rsi_providers.settingsProvider.notifier).loadSettings();
  container.read(rsi_providers.stockNotifierProvider.notifier).fetchStocks();

  if (Platform.isWindows) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      fullScreen: true,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  VideoPlayerMediaKit.ensureInitialized(
    windows: true,
    web: true,
  );

  await initializeCretaDeviceWatch();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CretaDeviceWatchWidget();
  }
}
