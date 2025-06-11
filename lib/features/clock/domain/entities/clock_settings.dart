import 'package:flutter/material.dart';

enum TimeFormat { h12, h24 }

@immutable
class ClockSettings {
  const ClockSettings({
    this.timeFormat = TimeFormat.h24,
    this.themeMode = ThemeMode.system,
  });

  final TimeFormat timeFormat;
  final ThemeMode themeMode;

  ClockSettings copyWith({
    TimeFormat? timeFormat,
    ThemeMode? themeMode,
  }) {
    return ClockSettings(
      timeFormat: timeFormat ?? this.timeFormat,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}
