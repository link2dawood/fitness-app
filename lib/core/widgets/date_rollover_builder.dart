import 'dart:async';
import 'package:flutter/material.dart';

/// Rebuilds retained screens at local midnight and after a foreground transition.
class DateRolloverBuilder extends StatefulWidget {
  const DateRolloverBuilder({super.key, required this.builder, this.now});
  final WidgetBuilder builder;
  final DateTime Function()? now;
  @override
  State<DateRolloverBuilder> createState() => _DateRolloverBuilderState();
}

class _DateRolloverBuilderState extends State<DateRolloverBuilder>
    with WidgetsBindingObserver {
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _schedule();
  }

  void _schedule() {
    _timer?.cancel();
    final now = widget.now?.call() ?? DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    _timer = Timer(midnight.difference(now), () {
      if (!mounted) return;
      setState(() {});
      _schedule();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {});
      _schedule();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context);
}
