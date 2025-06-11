import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:creta_device_watch/features/clock/domain/usecases/get_font.dart';
import 'package:creta_device_watch/features/clock/domain/usecases/save_font.dart';

class FontNotifier extends StateNotifier<TextStyle> {
  final GetFont _getFont;
  final SaveFont _saveFont;

  FontNotifier(this._getFont, this._saveFont)
      : super(
          GoogleFonts.michroma(
            textStyle: const TextStyle(fontSize: 96, fontWeight: FontWeight.bold),
          ),
        ) {
    _loadFont();
  }

  final List<TextStyle> _fonts = [
    GoogleFonts.michroma(
      textStyle: const TextStyle(fontSize: 96, fontWeight: FontWeight.bold),
    ),
    GoogleFonts.orbitron(
      textStyle: const TextStyle(fontSize: 96, fontWeight: FontWeight.bold),
    ),
    GoogleFonts.poiretOne(
      textStyle: const TextStyle(fontSize: 96, fontWeight: FontWeight.bold),
    ),
    GoogleFonts.rubikGlitch(
      textStyle: const TextStyle(fontSize: 96, fontWeight: FontWeight.bold),
    ),
  ];

  int _currentIndex = 0;

  Future<void> _loadFont() async {
    _currentIndex = await _getFont();
    state = _fonts[_currentIndex];
  }

  Future<void> toggleFont() async {
    _currentIndex = (_currentIndex + 1) % _fonts.length;
    await _saveFont(_currentIndex);
    state = _fonts[_currentIndex];
  }
}
