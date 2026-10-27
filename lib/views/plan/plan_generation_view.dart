import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../data/models/user_profile.dart';

class PlanGenerationView extends StatefulWidget {
  const PlanGenerationView({super.key, this.profile});

  final UserProfile? profile;

  @override
  State<PlanGenerationView> createState() => _PlanGenerationViewState();
}

class _PlanGenerationViewState extends State<PlanGenerationView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  double _currentProgress = 0.0;
  int _completedSteps = 0;
  Timer? _delayTimer;
  Completer<bool>? _delay;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _progressAnimation = const AlwaysStoppedAnimation<double>(0);
    _controller.addListener(() {
      if (mounted) setState(() => _currentProgress = _progressAnimation.value);
    });

    // Start the 4-step loading flow
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runLoadingSteps();
    });
  }

  Future<bool> _wait(Duration duration) {
    if (!mounted) return Future.value(false);
    final pending = Completer<bool>();
    _delay = pending;
    _delayTimer = Timer(duration, () {
      _delay = null;
      pending.complete(mounted);
    });
    return pending.future;
  }

  Future<void> _runLoadingSteps() async {
    if (!await _wait(const Duration(milliseconds: 400))) return;
    for (var step = 1; step <= 4; step++) {
      if (!await _animateTo(step / 4) || !mounted) return;
      setState(() => _completedSteps = step);
      if (!await _wait(Duration(milliseconds: step == 4 ? 700 : 500))) return;
    }
    if (mounted) {
      Navigator.of(
        context,
      ).pushReplacementNamed(AppRoutes.planReady, arguments: widget.profile);
    }
  }

  Future<bool> _animateTo(double target) async {
    if (!mounted) return false;
    _progressAnimation = Tween<double>(begin: _currentProgress, end: target)
        .animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
        );
    _controller.reset();
    try {
      await _controller.forward().orCancel;
      return mounted;
    } on TickerCanceled {
      return false;
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _delay?.complete(false);
    _controller.dispose();
    super.dispose();
  }

  String _formatBodyMetrics() {
    if (widget.profile == null) return 'Not selected';
    final heightCm = widget.profile!.heightCm;
    final weightKg = widget.profile?.weightKg ?? 75;

    final totalInches = (heightCm / 2.54).round();
    final ft = totalInches ~/ 12;
    final inches = totalInches % 12;
    final lbs = (weightKg * 2.20462).toStringAsFixed(1);

    return '${ft}ft ${inches}in, ${lbs}lb';
  }

  @override
  Widget build(BuildContext context) {
    final bodyMetricsText = _formatBodyMetrics();
    final fitnessLevelText = widget.profile?.level?.label ?? 'Not selected';
    final targetedWorkoutText =
        widget.profile != null && widget.profile!.focusAreas.isNotEmpty
        ? widget.profile!.focusAreas.map((e) => e.label).join(', ')
        : 'Not selected';
    final percentage = (_currentProgress * 100).round();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 36),

                // ── Header Title & Subtitle ────────────────────────────────────
                const Text(
                  'REVIEWING YOUR\nPREFERENCES',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                    height: 1.25,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Preparing workout suggestions from the catalog...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                ),

                const SizedBox(height: 28),

                // ── Circular Progress Ring ─────────────────────────────────────
                Center(
                  child: SizedBox(
                    width: 220,
                    height: 220,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(220, 220),
                          painter: _CircleProgressPainter(
                            progress: _currentProgress,
                            progressColor: const Color(0xFF0062FF),
                            backgroundColor: const Color(0xFFF1F3F7),
                            strokeWidth: 18,
                          ),
                        ),
                        Text(
                          '$percentage%',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ── Checklist of 4 steps ───────────────────────────────────────
                _StepCheckRow(
                  isCompleted: _completedSteps >= 1,
                  isVisible: true,
                  prefixText: 'Body measurements: ',
                  highlightText: bodyMetricsText,
                ),
                const SizedBox(height: 14),

                _StepCheckRow(
                  isCompleted: _completedSteps >= 2,
                  isVisible: _completedSteps >= 1,
                  prefixText: 'Fitness level: ',
                  highlightText: fitnessLevelText,
                ),
                const SizedBox(height: 14),

                _StepCheckRow(
                  isCompleted: _completedSteps >= 3,
                  isVisible: _completedSteps >= 2,
                  prefixText: 'Focus areas: ',
                  highlightText: targetedWorkoutText,
                ),
                const SizedBox(height: 14),

                _StepCheckRow(
                  isCompleted: _completedSteps >= 4,
                  isVisible: _completedSteps >= 3,
                  prefixText: 'Your preferences are ready!',
                  highlightText: '',
                  isBoldPrefix: true,
                ),

                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepCheckRow extends StatelessWidget {
  const _StepCheckRow({
    required this.isCompleted,
    required this.isVisible,
    required this.prefixText,
    required this.highlightText,
    this.isBoldPrefix = false,
  });

  final bool isCompleted;
  final bool isVisible;
  final String prefixText;
  final String highlightText;
  final bool isBoldPrefix;

  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      return const SizedBox(height: 26);
    }

    const activeBlue = Color(0xFF0062FF);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isCompleted ? 1.0 : 0.45,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedScale(
            duration: const Duration(milliseconds: 300),
            scale: isCompleted ? 1.0 : 0.0,
            curve: Curves.easeOutBack,
            child: const Icon(Icons.check_rounded, color: activeBlue, size: 20),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: prefixText,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isBoldPrefix
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isCompleted
                          ? const Color(0xFF111827)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                  if (highlightText.isNotEmpty)
                    TextSpan(
                      text: highlightText,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: activeBlue,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleProgressPainter extends CustomPainter {
  const _CircleProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    if (progress <= 0) return;

    // Progress Arc starting from top (-90 degrees)
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
