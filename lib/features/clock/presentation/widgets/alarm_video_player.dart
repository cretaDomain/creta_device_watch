import 'package:flutter/material.dart';

class AlarmVideoPlayer extends StatelessWidget {
  const AlarmVideoPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: Image.asset('assets/images/alarm.png'),
      ),
    );
  }
}
