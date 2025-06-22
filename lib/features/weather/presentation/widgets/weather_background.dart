import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:creta_device_watch/core/di/provider.dart';
import 'package:creta_device_watch/features/weather/domain/entities/weather.dart';

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
      // Set initial video if weather is already available
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
      //fit: StackFit.expand,
      alignment: Alignment.centerLeft,
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
          _buildWeatherOverlayLeft(weatherState.weather!),
        if (weatherState.weather != null && !weatherState.isLoading && weatherState.error == null)
          _buildWeatherOverlayRight(weatherState.weather!),
      ],
    );
  }

  Widget _buildWeatherOverlayLeft(Weather weather) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: Container(
        width: 150,
        height: 150,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          shape: BoxShape.circle,
          //borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${weather.temperature.round()}°C',
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              '${weather.tempMin} ~ ${weather.tempMax}°C',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherOverlayRight(Weather weather) {
    return Positioned(
      right: 20,
      bottom: (480 - 150) / 2 - 32,
      child: Container(
        width: 150,
        height: 150,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          shape: BoxShape.circle,
          //borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Wind',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              '${weather.windSpeed} m/s',
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              '${weather.windDirection}',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
