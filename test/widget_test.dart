import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:creta_device_watch/core/di/provider.dart';
import 'package:creta_device_watch/creta_device_watch.dart';

void main() {
  testWidgets('CretaDeviceWatchWidget smoke test', (WidgetTester tester) async {
    // Initialize the library.
    await initializeCretaDeviceWatch();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Override the sharedPreferencesProvider to return a completed future.
          // This prevents the test from timing out while waiting for async operations.
          // ignore: null_argument_to_non_null_type
          sharedPreferencesProvider.overrideWith((ref) => Future.value(null))
        ],
        child: const MaterialApp(
          home: CretaDeviceWatchWidget(
            showBorder: true,
          ),
        ),
      ),
    );

    // Allow time for the async operations to complete.
    await tester.pumpAndSettle();

    // Verify that our widget is present.
    expect(find.byType(CretaDeviceWatchWidget), findsOneWidget);

    // You can add more specific tests here.
    // For example, verify that the clock page is displayed.
    // expect(find.text('00:00:00'), findsOneWidget); // This would need the clock to be at a specific time.
  });
}
