import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:creta_rsi/presentation/riverpod/providers.dart' as rsi_providers;
import 'package:creta_device_watch/creta_device_watch_widget.dart';

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
      showMenuButtons: false,
      useOnlyWatch: true,
      width: 1920,
      darkMode: true,
    );
  }
}
