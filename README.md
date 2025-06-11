# Creta Device Watch Widget

A Flutter widget to display a digital clock. This package is designed to be used as a part of the Creta devices ecosystem.

![example](assets/images/digital_clock.png)

## Usage

Here is a basic example of how to use `CretaDeviceWatchWidget`.

You need to initialize the library before running your app. This is typically done in your `main.dart` file.

```dart
import 'package:creta_device_watch/creta_device_watch_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  // Ensure that Flutter bindings are initialized.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the CretaDeviceWatch library.
  await initializeCretaDeviceWatch();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      // CretaDeviceWatchWidget을 사용하는 예제입니다.
      // 필요에 따라 적절한 파라미터를 전달해야 할 수 있습니다.
      // 현재는 기본 생성자를 사용합니다.
      child: CretaDeviceWatchWidget(),
    );
  }
}
```
