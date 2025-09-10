import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:creta_device_watch/core/di/provider.dart';
import 'package:creta_device_watch/features/weather/domain/entities/weather.dart';
import 'package:intl/intl.dart';

class WeatherBackground extends ConsumerStatefulWidget {
  const WeatherBackground({super.key});

  @override
  ConsumerState<WeatherBackground> createState() => _WeatherBackgroundState();
}

class _WeatherBackgroundState extends ConsumerState<WeatherBackground> {
  String? _activeImageAsset;

  @override
  void initState() {
    super.initState();
    ref.listenManual(weatherProvider, (previous, next) {
      _updateActiveImage(next.weather);
    });
    _updateActiveImage(ref.read(weatherProvider).weather);
  }

  void _updateActiveImage(Weather? weather) {
    if (!mounted) return;
    String? newAsset;
    if (weather != null) {
      final key = _getKeyForCondition(weather.condition);
      newAsset = 'assets/images/$key.png';
    }
    if (newAsset != _activeImageAsset) {
      setState(() {
        _activeImageAsset = newAsset;
      });
    }
  }

  String _getKeyForCondition(String condition) {
    final lowerCaseCondition = condition.toLowerCase();
    switch (lowerCaseCondition) {
      case 'clear':
      case 'clouds':
      case 'rain':
      case 'snow':
      case 'drizzle':
      case 'thunderstorm':
        return lowerCaseCondition;
      case 'mist':
      case 'fog':
      case 'haze':
        return 'mist';
      default:
        throw Exception('Unknown weather condition: $condition');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weatherState = ref.watch(weatherProvider);
    final brightness = Theme.of(context).brightness;
    final fallbackColor = brightness == Brightness.dark ? Colors.black : Colors.white;
    final fallbackWidget = Container(color: fallbackColor);

    return Stack(
      children: [
        if (_activeImageAsset != null)
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: Image.asset(_activeImageAsset!),
            ),
          )
        else
          fallbackWidget,
        if (weatherState.isLoading) const Center(child: CircularProgressIndicator()),
        if (weatherState.weather != null && !weatherState.isLoading && weatherState.error == null)
          _buildWeatherInfoPanel(weatherState.weather!),
      ],
    );
  }

  Widget _buildWeatherInfoPanel(Weather weather) {
    final textTheme = Theme.of(context).textTheme;
    const textColor = Colors.white;
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMainWeatherInfo(weather, textColor),
                _buildDetailedWeatherInfo(weather, textColor, textTheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainWeatherInfo(Weather weather, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${weather.temperature.round()}°',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: textColor,
            height: 1.1,
          ),
        ),
        Text(
          '${weather.tempMin.round()}° / ${weather.tempMax.round()}°',
          style: TextStyle(fontSize: 16, color: textColor.withValues(alpha: 0.8)),
        ),
        const SizedBox(height: 8),
        Text(
          weather.cityName,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: textColor),
        ),
        Text(
          DateFormat('MM-dd HH:mm').format(weather.lastUpdated),
          style: TextStyle(fontSize: 14, color: textColor.withValues(alpha: 0.8)),
        ),
      ],
    );
  }

  Widget _buildDetailedWeatherInfo(Weather weather, Color textColor, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildInfoRow(
          Icons.air,
          '${weather.windSpeed} m/s',
          textColor,
          extra: Transform.rotate(
            angle: (weather.windDirection + 180) * math.pi / 180,
            child: Icon(Icons.navigation, color: textColor, size: 16),
          ),
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          Icons.water_drop_outlined,
          '${weather.rainVolume?.toStringAsFixed(1) ?? "0.0"} mm',
          textColor,
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          Icons.ac_unit_outlined,
          '${weather.snowVolume?.toStringAsFixed(1) ?? "0.0"} mm',
          textColor,
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color, {Widget? extra}) {
    return Row(
      children: [
        if (extra != null) ...[extra, const SizedBox(width: 4)],
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: color, fontSize: 16)),
      ],
    );
  }
}
