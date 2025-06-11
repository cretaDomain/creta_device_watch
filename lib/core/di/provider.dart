import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:creta_device_watch/features/clock/data/datasources/time_data_source.dart';
import 'package:creta_device_watch/features/clock/data/repositories/time_repository_impl.dart';
import 'package:creta_device_watch/features/clock/domain/repositories/time_repository.dart';
import 'package:creta_device_watch/features/clock/domain/usecases/get_time_stream.dart';
import 'package:creta_device_watch/features/settings/data/datasources/settings_data_source.dart';
import 'package:creta_device_watch/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:creta_device_watch/features/settings/domain/repositories/settings_repository.dart';
import 'package:creta_device_watch/features/settings/domain/usecases/get_settings.dart';
import 'package:creta_device_watch/features/settings/domain/usecases/save_settings.dart';
import 'package:creta_device_watch/features/settings/presentation/notifiers/settings_notifier.dart';
import 'package:creta_device_watch/features/clock/domain/entities/clock_settings.dart';
import 'package:creta_device_watch/features/world_clock/data/datasources/world_clock_local_data_source.dart';
import 'package:creta_device_watch/features/world_clock/data/repositories/world_clock_repository_impl.dart';
import 'package:creta_device_watch/features/world_clock/domain/repositories/world_clock_repository.dart';
import 'package:creta_device_watch/features/world_clock/domain/usecases/add_world_city.dart';
import 'package:creta_device_watch/features/world_clock/domain/usecases/delete_world_city.dart';
import 'package:creta_device_watch/features/world_clock/domain/usecases/get_world_cities.dart';
import 'package:creta_device_watch/features/clock/data/datasources/font_local_data_source.dart';
import 'package:creta_device_watch/features/clock/data/repositories/font_repository_impl.dart';
import 'package:creta_device_watch/features/clock/domain/repositories/font_repository.dart';
import 'package:creta_device_watch/features/clock/domain/usecases/get_font.dart';
import 'package:creta_device_watch/features/clock/domain/usecases/save_font.dart';
import 'package:creta_device_watch/features/clock/presentation/notifiers/font_notifier.dart';
import 'package:flutter/material.dart';

// --- Core ---
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});

// --- Clock Feature ---
// Data Sources
final timeDataSourceProvider = Provider<TimeDataSource>((ref) {
  return TimeDataSourceImpl();
});

final fontLocalDataSourceProvider = Provider<FontLocalDataSource>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider).asData!.value;
  return FontLocalDataSourceImpl(sharedPreferences);
});

// Repositories
final timeRepositoryProvider = Provider<TimeRepository>((ref) {
  final dataSource = ref.watch(timeDataSourceProvider);
  return TimeRepositoryImpl(dataSource);
});

final fontRepositoryProvider = Provider<FontRepository>((ref) {
  final dataSource = ref.watch(fontLocalDataSourceProvider);
  return FontRepositoryImpl(dataSource);
});

// Use Cases
final getTimeStreamProvider = Provider<GetTimeStream>((ref) {
  final repository = ref.watch(timeRepositoryProvider);
  return GetTimeStream(repository);
});

final getFontProvider = Provider<GetFont>((ref) {
  final repository = ref.watch(fontRepositoryProvider);
  return GetFont(repository);
});

final saveFontProvider = Provider<SaveFont>((ref) {
  final repository = ref.watch(fontRepositoryProvider);
  return SaveFont(repository);
});

// --- Presentation ---

// Time Stream Provider for the UI
/*
final timeStreamProvider = StreamProvider<DateTime>((ref) {
  final getTimeStream = ref.watch(getTimeStreamProvider);
  return getTimeStream();
});
*/

// --- Settings Feature ---

// Data Sources
final settingsDataSourceProvider = Provider<SettingsDataSource>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider).asData!.value;
  return SettingsDataSourceImpl(sharedPreferences);
});

// Repositories
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final dataSource = ref.watch(settingsDataSourceProvider);
  return SettingsRepositoryImpl(dataSource);
});

// Use Cases
final getSettingsProvider = Provider<GetSettings>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return GetSettings(repository);
});

final saveSettingsProvider = Provider<SaveSettings>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return SaveSettings(repository);
});

// Notifier Provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, ClockSettings>((ref) {
  final getSettings = ref.watch(getSettingsProvider);
  final saveSettings = ref.watch(saveSettingsProvider);
  return SettingsNotifier(getSettings, saveSettings);
});

// --- World Clock Feature ---

// Data Sources
final worldClockLocalDataSourceProvider = Provider<WorldClockLocalDataSource>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider).asData!.value;
  return WorldClockLocalDataSourceImpl(sharedPreferences);
});

// Repositories
final worldClockRepositoryProvider = Provider<WorldClockRepository>((ref) {
  final dataSource = ref.watch(worldClockLocalDataSourceProvider);
  return WorldClockRepositoryImpl(dataSource);
});

// Use Cases
final getWorldCitiesProvider = Provider<GetWorldCities>((ref) {
  final repository = ref.watch(worldClockRepositoryProvider);
  return GetWorldCities(repository);
});

final addWorldCityProvider = Provider<AddWorldCity>((ref) {
  final repository = ref.watch(worldClockRepositoryProvider);
  return AddWorldCity(repository);
});

final deleteWorldCityProvider = Provider<DeleteWorldCity>((ref) {
  final repository = ref.watch(worldClockRepositoryProvider);
  return DeleteWorldCity(repository);
});

// --- Presentation Layer Providers ---
enum ClockView { main, world }

final clockViewProvider = StateProvider<ClockView>((ref) => ClockView.main);

final fontProvider = StateNotifierProvider<FontNotifier, TextStyle>((ref) {
  final getFont = ref.watch(getFontProvider);
  final saveFont = ref.watch(saveFontProvider);
  return FontNotifier(getFont, saveFont);
});
