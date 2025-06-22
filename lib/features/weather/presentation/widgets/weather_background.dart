import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:creta_device_watch/core/di/provider.dart';
import 'package:creta_device_watch/features/weather/domain/entities/weather.dart';
import 'package:intl/intl.dart';

class WeatherBackground extends ConsumerStatefulWidget {
  const WeatherBackground({super.key});

  @override
  ConsumerState<WeatherBackground> createState() => _WeatherBackgroundState();
}

class _WeatherBackgroundState extends ConsumerState<WeatherBackground> {
  final Map<String, VideoPlayerController> _videoControllers = {};
  VideoPlayerController? _activeController;
  bool _videosInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAllVideos();
    ref.listenManual(weatherProvider, (previous, next) {
      _updateActiveController(next.weather);
    });
  }

  Future<void> _initializeAllVideos() async {
    final videoAssets = {
      'clear': 'assets/videos/clear.mp4',
      'clouds': 'assets/videos/clouds.mp4',
      'rain': 'assets/videos/rain.mp4',
      'snow': 'assets/videos/snow.mp4',
      'drizzle': 'assets/videos/drizzle.mp4',
      'thunderstorm': 'assets/videos/thunderstorm.mp4',
      'mist': 'assets/videos/mist.mp4',
    };

    try {
      final futures = videoAssets.entries.map((entry) {
        final controller = VideoPlayerController.asset(entry.value);
        _videoControllers[entry.key] = controller;
        return controller.initialize().then((_) {
          controller.setLooping(true);
        });
      }).toList();

      await Future.wait(futures);
    } catch (e) {
      debugPrint("Error initializing videos: $e");
    }

    if (mounted) {
      setState(() {
        _videosInitialized = true;
      });
      _updateActiveController(ref.read(weatherProvider).weather);
    }
  }

  void _updateActiveController(Weather? weather) {
    if (!_videosInitialized || !mounted) return;

    VideoPlayerController? newController;
    if (weather != null) {
      try {
        final videoKey = _getVideoKeyForCondition(weather.condition);
        newController = _videoControllers[videoKey];
      } catch (e) {
        debugPrint("Could not find video for weather condition: $e");
        newController = null;
      }
    }

    if (newController != _activeController) {
      setState(() {
        _activeController?.pause();
        _activeController = newController;
        _activeController?.play();
      });
    }
  }

  String _getVideoKeyForCondition(String condition) {
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
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weatherState = ref.watch(weatherProvider);
    final brightness = Theme.of(context).brightness;
    final fallbackColor = brightness == Brightness.dark ? Colors.black : Colors.white;
    final fallbackWidget = Container(color: fallbackColor);

    if (!_videosInitialized) {
      return Stack(children: [fallbackWidget, const Center(child: CircularProgressIndicator())]);
    }

    final showVideo = _activeController != null &&
        _activeController!.value.isInitialized &&
        weatherState.error == null;

    return Stack(
      children: [
        if (showVideo)
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _activeController!.value.size.width,
                height: _activeController!.value.size.height,
                child: VideoPlayer(_activeController!),
              ),
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
              color: Colors.black.withOpacity(0.25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
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
          style: TextStyle(fontSize: 16, color: textColor.withOpacity(0.8)),
        ),
        const SizedBox(height: 8),
        Text(
          weather.cityName,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: textColor),
        ),
        Text(
          DateFormat('MM-dd HH:mm').format(weather.lastUpdated),
          style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.8)),
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
