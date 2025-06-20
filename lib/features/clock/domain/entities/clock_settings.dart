import 'package:flutter/material.dart';

enum TimeFormat { h12, h24 }

@immutable
class ClockSettings {
  const ClockSettings({
    this.timeFormat = TimeFormat.h24,
    this.themeMode = ThemeMode.system,
    this.isFlipped = false,
  });

  final TimeFormat timeFormat;
  final ThemeMode themeMode;
  final bool isFlipped;

  ClockSettings copyWith({
    TimeFormat? timeFormat,
    ThemeMode? themeMode,
    bool? isFlipped,
  }) {
    return ClockSettings(
      timeFormat: timeFormat ?? this.timeFormat,
      themeMode: themeMode ?? this.themeMode,
      isFlipped: isFlipped ?? this.isFlipped,
    );
  }
}
