import 'dart:async';
import 'package:flutter/material.dart';

class FlipDigit extends StatefulWidget {
  final int initialValue;
  final Stream<int> stream;
  final TextStyle? textStyle;
  final Color backgroundColor;
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const FlipDigit({
    super.key,
    required this.initialValue,
    required this.stream,
    this.textStyle,
    this.backgroundColor = Colors.black,
    this.width = 60.0,
    this.height = 80.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
  });

  @override
  State<FlipDigit> createState() => _FlipDigitState();
}

class _FlipDigitState extends State<FlipDigit> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late StreamSubscription<int> _streamSubscription;

  int _currentValue = 0;
  int _nextValue = 0;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
    _nextValue = widget.initialValue;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentValue = _nextValue;
        });
        _controller.reset();
      }
    });

    _subscribeToStream(widget.stream);
  }

  @override
  void didUpdateWidget(FlipDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.stream != oldWidget.stream) {
      _unsubscribeFromStream();
      _subscribeToStream(widget.stream);
    }
  }

  void _subscribeToStream(Stream<int> stream) {
    _streamSubscription = stream.listen((newValue) {
      if (mounted && newValue != _currentValue) {
        setState(() {
          _nextValue = newValue;
        });
        _controller.forward(from: 0.0);
      }
    });
  }

  void _unsubscribeFromStream() {
    _streamSubscription.cancel();
  }

  @override
  void dispose() {
    _controller.dispose();
    _unsubscribeFromStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final angle = _controller.value * -3.14159 / 2;

        return Stack(
          children: [
            // Static bottom half
            _buildDigitHalf(isTop: false, value: _currentValue),
            // Static top half (to be revealed)
            _buildDigitHalf(isTop: true, value: _nextValue),

            // Flipping top half
            Transform(
              alignment: Alignment.bottomCenter,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(angle),
              child: _buildDigitHalf(isTop: true, value: _currentValue),
            ),
            // Flipping bottom half (starts hidden and rotates in)
            Transform(
              alignment: Alignment.topCenter,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(angle + 3.14159 / 2),
              child: _buildDigitHalf(isTop: false, value: _nextValue),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDigitHalf({required bool isTop, required int value}) {
    final alignment = isTop ? Alignment.topCenter : Alignment.bottomCenter;
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: widget.borderRadius,
      ),
      child: ClipRect(
        child: Align(
          alignment: alignment,
          heightFactor: 0.5,
          child: Center(
            child: Text(
              '$value',
              style: widget.textStyle ??
                  const TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
