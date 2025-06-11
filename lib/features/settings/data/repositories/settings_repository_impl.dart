import 'package:flutter/material.dart';
import 'package:creta_device_watch/features/clock/domain/entities/clock_settings.dart';
import 'package:creta_device_watch/features/settings/data/datasources/settings_data_source.dart';
import 'package:creta_device_watch/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsDataSource dataSource;

  SettingsRepositoryImpl(this.dataSource);

  @override
  Future<ClockSettings> getSettings() async {
    final timeFormatStr = await dataSource.getTimeFormat();
    final themeModeStr = await dataSource.getThemeMode();

    final timeFormat = TimeFormat.values.firstWhere(
      (e) => e.toString() == timeFormatStr,
      orElse: () => TimeFormat.h24,
    );

    final themeMode = ThemeMode.values.firstWhere(
      (e) => e.toString() == themeModeStr,
      orElse: () => ThemeMode.system,
    );

    return ClockSettings(timeFormat: timeFormat, themeMode: themeMode);
  }

  @override
  Future<void> saveSettings(ClockSettings settings) async {
    await dataSource.setTimeFormat(settings.timeFormat.toString());
    await dataSource.setThemeMode(settings.themeMode.toString());
  }
}
