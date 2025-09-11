import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:creta_rsi/presentation/riverpod/providers.dart' as rsi_providers;
import 'package:creta_device_watch/creta_device_watch_widget.dart';
// ignore: depend_on_referenced_packages
//import 'package:creta_music_visualizer/music_visualizer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SharedPreferences.getInstance();
  final container = ProviderContainer();

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

  // Video libraries removed

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
    return const CretaDeviceWatchWidget(
        //width: 1920,
        );
  }
}
