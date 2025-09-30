import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:creta_device_watch/core/di/provider.dart';
import 'package:creta_device_watch/features/clock/presentation/notifiers/time_notifier.dart';
import 'package:creta_device_watch/features/clock/presentation/widgets/flip_digit.dart';
import 'package:creta_device_watch/features/clock/domain/entities/clock_settings.dart';
import 'package:creta_device_watch/features/settings/presentation/widgets/settings_controls.dart';
import 'package:creta_device_watch/features/history/presentation/widgets/history_events_dialog.dart';
// import 'package:creta_device_watch/features/clock/presentation/widgets/alarm_video_player.dart';
// import 'package:creta_rsi/creta_rsi.dart';
// import 'package:creta_rsi/presentation/riverpod/providers.dart' as rsi_providers;
// import 'package:shared_preferences/shared_preferences.dart';
//import 'package:creta_device_watch/features/world_clock/presentation/pages/world_clock_page.dart';
//import 'package:creta_device_watch/features/world_clock/presentation/widgets/add_city_dialog.dart';
// ignore: unused_shown_name
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb, listEquals;

import '../../../weather/presentation/widgets/weather_background.dart';

class ClockPage extends ConsumerStatefulWidget {
  final List<String>? alarmTimes; // "YYYY/MM/DD HH:MM"
  final double width;
  final double height;
  final VoidCallback onShowRsi;
  final bool useOnlyWatch;
  final bool showMenuButtons;
  final bool showSec;
  final Color? bgColor;
  final Color? fgColor;
  final Color? watchBgColor;
  final bool showDate;

  const ClockPage({
    super.key,
    this.alarmTimes,
    required this.width,
    required this.height,
    required this.onShowRsi,
    this.useOnlyWatch = false,
    this.showMenuButtons = true,
    this.showSec = true,
    this.bgColor,
    this.fgColor,
    this.watchBgColor,
    this.showDate = true,
  });

  @override
  ConsumerState<ClockPage> createState() => _ClockPageState();
}

class _ClockPageState extends ConsumerState<ClockPage> {
  List<DateTime> _alarmDateTimes = [];
  late List<String> _managedAlarmTimes;
  bool _isAlarmRinging = false;
  Timer? _alarmTimeout;
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription? _timeSubscription;
  bool _isWebAudioReady = !kIsWeb;
  bool _showWebAudioMessage = kIsWeb;
  Timer? _overlayTimer;

  @override
  void initState() {
    super.initState();
    _managedAlarmTimes = List<String>.from(widget.alarmTimes ?? []);
    if (_showWebAudioMessage && widget.useOnlyWatch == false) {
      _overlayTimer = Timer(const Duration(seconds: 7), () {
        if (mounted) {
          setState(() {
            _showWebAudioMessage = false;
          });
        }
      });
    }
    if (widget.useOnlyWatch == false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _parseAlarmTime();
        _setupAlarmListener();
      });
    }
  }

  @override
  void didUpdateWidget(covariant ClockPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(widget.alarmTimes, oldWidget.alarmTimes)) {
      setState(() {
        _managedAlarmTimes = List<String>.from(widget.alarmTimes ?? []);
      });
      _dismissAlarm();
      _parseAlarmTime();
      _setupAlarmListener(); // Re-setup listener with new alarm time
    }
  }

  void _parseAlarmTime() {
    _alarmDateTimes = [];
    if (_managedAlarmTimes.isNotEmpty) {
      for (var timeStr in _managedAlarmTimes) {
        try {
          _alarmDateTimes.add(DateFormat('yyyy/MM/dd HH:mm').parse(timeStr));
        } catch (e) {
          debugPrint("Error parsing alarm time: $e");
        }
      }
    }
  }

  void _addAlarm(DateTime newAlarm) {
    final newAlarmString = DateFormat('yyyy/MM/dd HH:mm').format(newAlarm);
    setState(() {
      _managedAlarmTimes.add(newAlarmString);
    });
    _parseAlarmTime();
    _setupAlarmListener();
  }

  void _deleteAlarm(int index) {
    setState(() {
      _managedAlarmTimes.removeAt(index);
    });
    _parseAlarmTime();
    _setupAlarmListener();
  }

  void _setupAlarmListener() {
    _timeSubscription?.cancel(); // Cancel previous subscription
    final timeStream = ref.read(timeNotifierProvider.notifier).stream;
    _timeSubscription = timeStream.listen((now) {
      if (_isAlarmRinging) return;

      final nowTruncated = DateTime(now.year, now.month, now.day, now.hour, now.minute);
      final triggeredAlarm = _alarmDateTimes.firstWhere(
        (alarm) => alarm.isAtSameMomentAs(nowTruncated),
        orElse: () => DateTime(0), // Sentinel value
      );

      if (triggeredAlarm.year != 0) {
        if (mounted) {
          setState(() {
            _alarmDateTimes.remove(triggeredAlarm);
          });
        }
        _triggerAlarm();
      }
    });
  }

  void _triggerAlarm() async {
    if (!mounted) return;
    setState(() {
      _isAlarmRinging = true;
    });

    // if (_isWebAudioReady) {
    //   // NOTE: User must add a sound file to `assets/sounds/`
    //   // Example: `assets/sounds/alarm.m4a`
    //   await _audioPlayer.play(AssetSource('sounds/alarm.mp3'), volume: 1.0);
    //   _audioPlayer.setReleaseMode(ReleaseMode.loop);
    // }

    //자동 알람 off 기능은 사용하지 않는다.
    // _alarmTimeout = Timer(const Duration(seconds: 30), () {
    //   _dismissAlarm();
    // });
  }

  void _dismissAlarm() {
    _alarmTimeout?.cancel();
    // _audioPlayer.stop();
    if (mounted && _isAlarmRinging) {
      setState(() {
        _isAlarmRinging = false;
      });
    }
  }

  @override
  void dispose() {
    _overlayTimer?.cancel();
    _alarmTimeout?.cancel();
    _timeSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final settings = ref.watch(settingsProvider);
    // Compute responsive scale: constrain by width and height to prevent overflow
    final widthScale = widget.width / 1920.0; // base width
    const double baseDateRow = 40.0; // approximate at scale=1
    const double baseSpacingTop = 20.0;
    const double baseDigitHeight = 320.0; // match digitHeight baseline used in display
    const double baseSpacingBottom = 20.0;
    final double baseControls = widget.showMenuButtons ? 56.0 : 0.0; // approx controls height
    final double baseTotalHeight =
        baseDateRow + baseSpacingTop + baseDigitHeight + baseSpacingBottom + baseControls;
    final heightScale = widget.height / baseTotalHeight;
    final scale = widthScale.clamp(0.03, 3.0);
    final fitScale = scale <= heightScale ? scale : heightScale;
    final adjustedScale = widget.useOnlyWatch ? fitScale : (fitScale * 0.75);
    final pageContent = Scaffold(
        backgroundColor: _isAlarmRinging
            ? Colors.red.withValues(alpha: 0.7)
            : (widget.bgColor ?? Theme.of(context).scaffoldBackgroundColor),
        body: //clockView == ClockView.main          ?
            MainClockView(
          width: widget.width,
          height: widget.height,
          isAlarmRinging: _isAlarmRinging,
          onDismissAlarm: _dismissAlarm,
          onShowRsi: widget.onShowRsi,
          alarmTimes: _managedAlarmTimes,
          onAddAlarm: _addAlarm,
          onDeleteAlarm: _deleteAlarm,
          useOnlyWatch: widget.useOnlyWatch,
          showMenuButtons: widget.showMenuButtons,
          showSec: widget.showSec,
          scale: adjustedScale.clamp(0.2, 3.0),
          fgColor: widget.fgColor,
          watchBgColor: widget.watchBgColor,
          showDate: widget.showDate,
        )
        // : WorldClockPage(
        //     onAddCity: () {
        //       showDialog(
        //         context: context,
        //         builder: (context) => const AddCityDialog(),
        //       );
        //     },
        //   ),
        );

    return Stack(
      children: [
        //if (settings.isWeatherEnabled) const WeatherBackground(),
        if (!_isWebAudioReady && widget.useOnlyWatch == false)
          Positioned.fill(
            child: LayoutBuilder(builder: (context, constraints) {
              final bodyHeight = constraints.maxHeight - MediaQuery.of(context).padding.top;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  await _audioPlayer.resume();
                  if (mounted) {
                    setState(() {
                      _isWebAudioReady = true;
                    });
                    _overlayTimer?.cancel();
                  }
                },
                child: _showWebAudioMessage && widget.useOnlyWatch == false
                    ? Align(
                        alignment: Alignment.bottomCenter,
                        child: SizedBox(
                          height: bodyHeight * 0.2,
                          width: double.infinity,
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.5),
                            child: const Center(
                              child: Text(
                                '웹에서는 소리를 재생하려면 화면을 한 번 클릭해야 합니다.\nClick to enable sound.',
                                style: TextStyle(color: Colors.white, fontSize: 20),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(),
              );
            }),
          ),
        pageContent,
      ],
    );
  }
}

class MainClockView extends ConsumerWidget {
  final double width;
  final double height;
  final bool isAlarmRinging;
  final VoidCallback onDismissAlarm;
  final VoidCallback onShowRsi;
  final List<String>? alarmTimes;
  final Function(DateTime) onAddAlarm;
  final Function(int) onDeleteAlarm;
  final bool useOnlyWatch;
  final bool showMenuButtons;
  final double scale;
  final bool showSec;
  final Color? fgColor;
  final Color? watchBgColor;
  final bool showDate;

  const MainClockView({
    super.key,
    required this.width,
    required this.height,
    this.isAlarmRinging = false,
    required this.onDismissAlarm,
    required this.onShowRsi,
    this.alarmTimes,
    required this.onAddAlarm,
    required this.onDeleteAlarm,
    this.useOnlyWatch = false,
    this.showMenuButtons = true,
    this.scale = 1.0,
    this.showSec = true,
    this.fgColor,
    this.watchBgColor,
    this.showDate = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final fontStyle = ref.watch(fontProvider);
    final asyncTime = ref.watch(timeNotifierProvider);

    return Center(
      child: Stack(
        children: [
          if (isAlarmRinging)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: Image.asset('assets/images/alarm.png'),
              ),
            )
          else if (settings.isWeatherEnabled && !useOnlyWatch)
            const WeatherBackground(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showDate)
                asyncTime.when(
                  data: (time) => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat.yMMMMd('en_US').add_E().format(time),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontSize:
                                  (Theme.of(context).textTheme.headlineSmall?.fontSize ?? 24) *
                                      scale,
                              color: fgColor ??
                                  (Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white
                                      : Colors.black87),
                            ),
                      ),
                      SizedBox(width: 8 * scale),
                      if (!useOnlyWatch)
                        IconButton(
                          tooltip: '오늘 있었던 역사적 사건',
                          icon: const Icon(Icons.history),
                          iconSize: 24 * scale,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => HistoryEventsDialog(
                                date: time,
                                width: width,
                                height: height,
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                  loading: () => SizedBox(height: 30 * scale),
                  error: (err, stack) => const Text('Error'),
                ),
              if (showDate) SizedBox(height: 20 * scale),
              // Flip Clock
              asyncTime.when(
                data: (time) => _buildClockDisplay(context, time,
                    ref.read(timeNotifierProvider.notifier).stream, settings.timeFormat, fontStyle),
                loading: () => _buildClockDisplay(
                    context, DateTime.now(), const Stream.empty(), settings.timeFormat, fontStyle),
                error: (err, stack) => const Text('Error displaying clock'),
              ),
              SizedBox(height: 20 * scale),
              // Settings, Alarm, and Dismiss controls
              if (showMenuButtons)
                SettingsControls(
                  isAlarmRinging: isAlarmRinging,
                  onDismissAlarm: onDismissAlarm,
                  onShowRsi: onShowRsi,
                  alarmTimes: alarmTimes,
                  onAddAlarm: onAddAlarm,
                  onDeleteAlarm: onDeleteAlarm,
                  width: width,
                  height: height,
                  useOnlyWatch: useOnlyWatch,
                  scale: scale,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClockDisplay(BuildContext context, DateTime time, Stream<DateTime> stream,
      TimeFormat timeFormat, TextStyle fontStyle) {
    int hour = time.hour;
    String amPm = '';

    if (timeFormat == TimeFormat.h12) {
      amPm = hour >= 12 ? 'PM' : 'AM';
      hour = hour % 12;
      if (hour == 0) hour = 12; // 12 AM and 12 PM
    }

    final minute = time.minute;
    final second = time.second;

    final brightness = Theme.of(context).brightness;
    final textColor = (fgColor != null)
        ? fgColor!
        : (brightness == Brightness.dark ? Colors.white : Colors.black87);

    final scale = (this.scale).clamp(0.03, 3.0);
    // Tune base digit sizes for new 1920:480 baseline so digits fill more width
    final digitWidth = 280.0 * scale;
    final digitHeight = 320.0 * scale;
    final textStyle = fontStyle.copyWith(
      color: textColor,
      fontSize: digitHeight * 0.66,
    );
    final digitBackgroundColor =
        (watchBgColor ?? Theme.of(context).colorScheme.surface).withValues(alpha: 0.8);
    //final digitBackgroundColor = Theme.of(context).colorScheme.surface;

    return FittedBox(
      fit: BoxFit.contain,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (timeFormat == TimeFormat.h12) ...[
            Text(
              amPm,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: (Theme.of(context).textTheme.headlineMedium?.fontSize ?? 32) * scale),
            ),
            SizedBox(width: 16 * scale),
          ],
          // Hour
          FlipDigit(
            initialValue: hour ~/ 10,
            stream: stream.map((t) {
              int h = t.hour;
              if (timeFormat == TimeFormat.h12) {
                h = h % 12;
                if (h == 0) h = 12;
              }
              return h ~/ 10;
            }).distinct(),
            textStyle: textStyle,
            width: digitWidth,
            height: digitHeight,
            backgroundColor: digitBackgroundColor,
          ),
          SizedBox(width: 8 * scale),
          FlipDigit(
            initialValue: hour % 10,
            stream: stream.map((t) {
              int h = t.hour;
              if (timeFormat == TimeFormat.h12) {
                h = h % 12;
                if (h == 0) h = 12;
              }
              return h % 10;
            }).distinct(),
            textStyle: textStyle,
            width: digitWidth,
            height: digitHeight,
            backgroundColor: digitBackgroundColor,
          ),
          _buildSeparator(context, fontStyle),
          // Minute
          FlipDigit(
            initialValue: minute ~/ 10,
            stream: stream.map((t) => t.minute ~/ 10).distinct(),
            textStyle: textStyle,
            width: digitWidth,
            height: digitHeight,
            backgroundColor: digitBackgroundColor,
          ),
          SizedBox(width: 8 * scale),
          FlipDigit(
            initialValue: minute % 10,
            stream: stream.map((t) => t.minute % 10).distinct(),
            textStyle: textStyle,
            width: digitWidth,
            height: digitHeight,
            backgroundColor: digitBackgroundColor,
          ),
          if (showSec) ...[
            _buildSeparator(context, fontStyle),
            // Second
            FlipDigit(
              initialValue: second ~/ 10,
              stream: stream.map((t) => t.second ~/ 10).distinct(),
              textStyle: textStyle,
              width: digitWidth,
              height: digitHeight,
              backgroundColor: digitBackgroundColor,
            ),
            SizedBox(width: 8 * scale),
            FlipDigit(
              initialValue: second % 10,
              stream: stream.map((t) => t.second % 10).distinct(),
              textStyle: textStyle,
              width: digitWidth,
              height: digitHeight,
              backgroundColor: digitBackgroundColor,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSeparator(BuildContext context, TextStyle fontStyle) {
    final brightness = Theme.of(context).brightness;
    final separatorColor = brightness == Brightness.dark ? Colors.white54 : Colors.black54;
    final scale = (this.scale).clamp(0.03, 3.0);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.0 * scale),
      child: Text(
        ':',
        style: TextStyle(
          fontFamily: fontStyle.fontFamily,
          fontSize: (Theme.of(context).textTheme.displayLarge?.fontSize ?? 96) * scale,
          fontWeight: FontWeight.bold,
          color: separatorColor,
        ),
      ),
    );
  }
}
