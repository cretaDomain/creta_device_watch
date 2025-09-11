import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:creta_rsi/presentation/riverpod/providers.dart' as rsi_providers;
import 'package:creta_device_watch/creta_device_watch_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SharedPreferences.getInstance();
  final container = ProviderContainer();

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
      showDate: false,
      useOnlyWatch: true,
      width: 200,
      darkMode: true,
      showSec: true,
      showBorder: false,
      flipScreen: false,
      watchBgColor: Colors.blue,
      fgColor: Colors.red,
      bgColor: Colors.black,
    );
  }
}
