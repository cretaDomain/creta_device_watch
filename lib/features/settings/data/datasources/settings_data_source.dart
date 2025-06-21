import 'package:creta_device_watch/features/clock/domain/entities/clock_settings.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class SettingsDataSource {
  Future<String?> getTimeFormat();
  Future<void> setTimeFormat(String timeFormat);
  Future<String?> getThemeMode();
  Future<void> setThemeMode(String themeMode);
  Future<ClockSettings> getSettings();
  Future<void> saveSettings(ClockSettings settings);
}

class SettingsDataSourceImpl implements SettingsDataSource {
  final SharedPreferences sharedPreferences;

  SettingsDataSourceImpl(this.sharedPreferences);

  static const _timeFormatKey = 'time_format';
  static const _themeModeKey = 'theme_mode';

  @override
  Future<String?> getTimeFormat() async {
    return sharedPreferences.getString(_timeFormatKey);
  }

  @override
  Future<void> setTimeFormat(String timeFormat) async {
    await sharedPreferences.setString(_timeFormatKey, timeFormat);
  }

  @override
  Future<String?> getThemeMode() async {
    return sharedPreferences.getString(_themeModeKey);
  }

  @override
  Future<void> setThemeMode(String themeMode) async {
    await sharedPreferences.setString(_themeModeKey, themeMode);
  }

  @override
  Future<ClockSettings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeMode =
        (prefs.getString('themeMode') ?? 'dark') == 'dark' ? ThemeMode.dark : ThemeMode.light;
    final timeFormat =
        (prefs.getString('timeFormat') ?? 'h24') == 'h24' ? TimeFormat.h24 : TimeFormat.h12;
    final isFlipped = prefs.getBool('isFlipped') ?? false;
    final isWeatherEnabled = prefs.getBool('isWeatherEnabled') ?? true;
    return ClockSettings(
      themeMode: themeMode,
      timeFormat: timeFormat,
      isFlipped: isFlipped,
      isWeatherEnabled: isWeatherEnabled,
    );
  }

  @override
  Future<void> saveSettings(ClockSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', settings.themeMode.name);
    await prefs.setString('timeFormat', settings.timeFormat.name);
    await prefs.setBool('isFlipped', settings.isFlipped);
    await prefs.setBool('isWeatherEnabled', settings.isWeatherEnabled);
  }
}
