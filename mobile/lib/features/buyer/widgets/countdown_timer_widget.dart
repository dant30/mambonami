// lib/features/buyer/widgets/countdown_timer_widget.dart

import 'dart:async';
import 'package:flutter/material.dart';

/// Displays a live MM:SS countdown.
/// Call [onExpired] when it reaches zero.
class CountdownTimerWidget extends StatefulWidget {
  final int durationSeconds;
  final TextStyle? style;
  final VoidCallback? onExpired;

  const CountdownTimerWidget({
    super.key,
    required this.durationSeconds,
    this.style,
    this.onExpired,
  });

  @override
  State<CountdownTimerWidget> createState() =>
      _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  late int _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.durationSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remaining <= 0) {
        _timer?.cancel();
        widget.onExpired?.call();
        return;
      }
      setState(() => _remaining--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _label {
    final m = (_remaining ~/ 60).toString().padLeft(2, '0');
    final s = (_remaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) =>
      Text(_label, style: widget.style);
}