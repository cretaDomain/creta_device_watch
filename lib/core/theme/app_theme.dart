import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: const Color(0xFFF0F2F5),
    colorScheme: const ColorScheme.light(
      primary: Colors.blue,
      secondary: Colors.deepPurple,
      surface: Colors.white,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.blueGrey,
    scaffoldBackgroundColor: const Color(0xFF212121),
    colorScheme: const ColorScheme.dark(
      primary: Colors.blueGrey,
      secondary: Colors.tealAccent,
      surface: Color(0xFF303030),
    ),
  );
}
