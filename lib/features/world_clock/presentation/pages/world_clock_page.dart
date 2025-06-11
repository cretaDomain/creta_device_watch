import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
//import 'package:creta_device_watch/core/di/provider.dart';
import 'package:creta_device_watch/features/clock/presentation/notifiers/time_notifier.dart';
import 'package:creta_device_watch/features/world_clock/presentation/notifiers/world_clock_notifier.dart';

class WorldClockPage extends ConsumerWidget {
  final VoidCallback? onAddCity;
  const WorldClockPage({super.key, this.onAddCity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Re-build the widget every time the time changes
    ref.watch(timeNotifierProvider);

    final citiesAsync = ref.watch(worldClockNotifierProvider);
    final timeFormat = DateFormat.jm(); // Example: 5:08 PM

    return Scaffold(
      body: citiesAsync.when(
        data: (cities) {
          if (cities.isEmpty) {
            return const Center(child: Text('No cities added yet. Press + to add one.'));
          }
          return ListView.builder(
            itemCount: cities.length,
            itemBuilder: (context, index) {
              final city = cities[index];
              final location = tz.getLocation(city.timezone);
              final now = tz.TZDateTime.now(location);

              return ListTile(
                title: Text(city.city, style: Theme.of(context).textTheme.headlineSmall),
                subtitle: Text(now.timeZoneName),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timeFormat.format(now),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        ref.read(worldClockNotifierProvider.notifier).deleteCity(city.id);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: onAddCity != null
          ? FloatingActionButton(
              onPressed: onAddCity,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
