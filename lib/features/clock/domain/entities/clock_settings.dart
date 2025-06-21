import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

enum TimeFormat { h12, h24 }

@immutable
class ClockSettings extends Equatable {
  final ThemeMode themeMode;
  final TimeFormat timeFormat;
  final bool isFlipped;
  final bool isWeatherEnabled;

  const ClockSettings({
    this.themeMode = ThemeMode.dark,
    this.timeFormat = TimeFormat.h24,
    this.isFlipped = false,
    this.isWeatherEnabled = true,
  });

  ClockSettings copyWith({
    ThemeMode? themeMode,
    TimeFormat? timeFormat,
    bool? isFlipped,
    bool? isWeatherEnabled,
  }) {
    return ClockSettings(
      themeMode: themeMode ?? this.themeMode,
      timeFormat: timeFormat ?? this.timeFormat,
      isFlipped: isFlipped ?? this.isFlipped,
      isWeatherEnabled: isWeatherEnabled ?? this.isWeatherEnabled,
    );
  }

  @override
  List<Object?> get props => [themeMode, timeFormat, isFlipped, isWeatherEnabled];
}
