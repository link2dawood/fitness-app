import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _rateButtonBlue = Color(0xFF0055FF);
const _starGold = Color(0xFFFFC107);
const _starGoldStroke = Color(0xFFFFBC00);
const _bubbleBg = Color(0xFFEEF2FF);
const _bubbleText = Color(0xFF1D58F2);

Future<int?> showRateCollectionDialog(
  BuildContext context, {
  int initialRating = 5,
}) {
  return showDialog<int>(
    context: context,
    barrierDismissible: true,
    builder: (_) => RateCollectionDialog(initialRating: initialRating),
  );
}

class RateCollectionDialog extends StatefulWidget {
  const RateCollectionDialog({
    super.key,
    this.initialRating = 5,
    this.onSubmitted,
  }) : assert(initialRating >= 1 && initialRating <= 5);

  final int initialRating;
  final ValueChanged<int>? onSubmitted;

  static const String ratingValueKey = 'app_rating_value';
  static const String ratingPromptShownKey = 'app_rating_prompt_shown';

  @override
  State<RateCollectionDialog> createState() => _RateCollectionDialogState();
}

class _RateCollectionDialogState extends State<RateCollectionDialog> {
  late int _rating = widget.initialRating;
  bool _submitting = false;

  String get _title => _rating >= 4 ? 'We like you too!' : 'Oh, no!';

  String get _subtitle => _rating == 5
      ? 'Thanks for your feedback.'
      : 'Please share your feedback so we can\nimprove.';

  String get _buttonLabel => _rating == 5 ? 'Rate On Google Play' : 'Rate';

  void _selectRating(int value) {
    if (_submitting || _rating == value) return;
    HapticFeedback.selectionClick();
    setState(() => _rating = value);
  }

  Future<void> _submit() async {
    if (_submitting) return;
    HapticFeedback.lightImpact();
    setState(() => _submitting = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(RateCollectionDialog.ratingValueKey, _rating);
      await prefs.setBool(RateCollectionDialog.ratingPromptShownKey, true);
    } catch (_) {
      // Non-blocking if local storage fails.
    }
    if (!mounted) return;
    final selected = _rating;
    widget.onSubmitted?.call(selected);
    final messenger = ScaffoldMessenger.maybeOf(context);
    Navigator.of(context).pop(selected);
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            selected == 5
                ? 'Thanks for your 5-star feedback!'
                : 'Thanks for sharing your feedback!',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 136,
                width: 220,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: CustomPaint(
                    key: ValueKey<int>(_rating),
                    size: const Size(220, 136),
                    painter: RateEmojiPainter(rating: _rating),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                _title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                  letterSpacing: 0.1,
                ),
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 44),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    _subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF374151),
                      height: 1.35,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _bubbleBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '5 stars means a lot!',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _bubbleText,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 22),
                        child: CustomPaint(
                          size: Size(12, 7),
                          painter: _BubblePointerPainter(color: _bubbleBg),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (var star = 1; star <= 5; star++)
                    Expanded(
                      child: Center(
                        child: Semantics(
                          button: true,
                          selected: _rating == star,
                          label: '$star ${star == 1 ? 'star' : 'stars'}',
                          child: InkWell(
                            key: ValueKey<String>('rate-star-$star'),
                            customBorder: const CircleBorder(),
                            onTap: () => _selectRating(star),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: SizedBox(
                                width: 48,
                                height: 48,
                                child: CustomPaint(
                                  painter: _RateStarPainter(
                                    filled: star <= _rating,
                                    isFifthStar: star == 5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const ValueKey<String>('rate-submit-button'),
                  onPressed: _submitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: _rateButtonBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 54),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  child: Text(_buttonLabel, textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BubblePointerPainter extends CustomPainter {
  const _BubblePointerPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _BubblePointerPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _RateStarPainter extends CustomPainter {
  const _RateStarPainter({required this.filled, required this.isFifthStar});

  final bool filled;
  final bool isFifthStar;

  Path _roundedStarPath(Offset center, double outerRadius, double innerRadius) {
    const points = 5;
    final vertices = <Offset>[];
    for (var i = 0; i < points * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = -math.pi / 2 + i * math.pi / points;
      vertices.add(
        Offset(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        ),
      );
    }

    final path = Path();
    const cornerFraction = 0.25;
    for (var i = 0; i < vertices.length; i++) {
      final prev = vertices[(i - 1 + vertices.length) % vertices.length];
      final curr = vertices[i];
      final next = vertices[(i + 1) % vertices.length];

      final p1 = Offset.lerp(curr, prev, cornerFraction)!;
      final p2 = Offset.lerp(curr, next, cornerFraction)!;

      if (i == 0) {
        path.moveTo(p1.dx, p1.dy);
      } else {
        path.lineTo(p1.dx, p1.dy);
      }
      path.quadraticBezierTo(curr.dx, curr.dy, p2.dx, p2.dy);
    }
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 2);

    if (isFifthStar) {
      // Soft circular halo behind the 5th star
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFF3C4).withValues(alpha: 0.7),
            const Color(0xFFFFFBEB).withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: 24));
      canvas.drawCircle(center, 24, glowPaint);
    }

    final starPath = _roundedStarPath(center, 18.5, 9.5);

    if (filled) {
      final fillPaint = Paint()
        ..color = _starGold
        ..style = PaintingStyle.fill;
      canvas.drawPath(starPath, fillPaint);
    } else {
      final fillPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawPath(starPath, fillPaint);

      final strokePaint = Paint()
        ..color = _starGoldStroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(starPath, strokePaint);
    }

    if (isFifthStar) {
      // Cute face inside the 5th star
      final faceColor = filled ? Colors.white : _starGoldStroke;
      final eyePaint = Paint()
        ..color = faceColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center.translate(-3.6, -1.2), 1.3, eyePaint);
      canvas.drawCircle(center.translate(3.6, -1.2), 1.3, eyePaint);

      final smilePaint = Paint()
        ..color = faceColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round;

      final smileRect = Rect.fromCenter(
        center: center.translate(0, 1.8),
        width: 6.4,
        height: 4.4,
      );
      canvas.drawArc(smileRect, 0.15 * math.pi, 0.7 * math.pi, false, smilePaint);

      // 3 shine rays on top-right of the 5th star
      final rayPaint = Paint()
        ..color = _starGoldStroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;

      final rayOrigin = center.translate(10, -11);
      for (final angleDeg in [-75.0, -42.0, -10.0]) {
        final rad = angleDeg * math.pi / 180.0;
        final p1 = Offset(
          rayOrigin.dx + 6.0 * math.cos(rad),
          rayOrigin.dy + 6.0 * math.sin(rad),
        );
        final p2 = Offset(
          rayOrigin.dx + 10.5 * math.cos(rad),
          rayOrigin.dy + 10.5 * math.sin(rad),
        );
        canvas.drawLine(p1, p2, rayPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RateStarPainter oldDelegate) =>
      oldDelegate.filled != filled || oldDelegate.isFifthStar != isFifthStar;
}

class RateEmojiPainter extends CustomPainter {
  const RateEmojiPainter({required this.rating});

  final int rating;

  void _drawHeart(
    Canvas canvas,
    Offset center,
    double size,
    Color color, {
    double rotation = 0,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    if (rotation != 0) {
      canvas.rotate(rotation);
    }
    final w = size;
    final h = size;
    final path = Path()
      ..moveTo(0, h * 0.35)
      ..cubicTo(-w * 0.55, -h * 0.1, -w * 0.55, -h * 0.5, -w * 0.25, -h * 0.5)
      ..cubicTo(-w * 0.08, -h * 0.5, 0, -h * 0.32, 0, -h * 0.2)
      ..cubicTo(0, -h * 0.32, w * 0.08, -h * 0.5, w * 0.25, -h * 0.5)
      ..cubicTo(w * 0.55, -h * 0.5, w * 0.55, -h * 0.1, 0, h * 0.35)
      ..close();

    canvas.drawPath(path, Paint()..color = color);
    canvas.restore();
  }

  void _drawSparkle(Canvas canvas, Offset center, double radius, Color color) {
    final path = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..quadraticBezierTo(
        center.dx,
        center.dy,
        center.dx + radius,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx,
        center.dy,
        center.dx,
        center.dy + radius,
      )
      ..quadraticBezierTo(
        center.dx,
        center.dy,
        center.dx - radius,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx,
        center.dy,
        center.dx,
        center.dy - radius,
      )
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + 8;

    // Draw blob body (cute rounded mochi/gumdrop shape)
    final bodyPath = Path()
      ..moveTo(cx, cy - 42)
      ..cubicTo(cx + 34, cy - 42, cx + 46, cy - 12, cx + 44, cy + 18)
      ..cubicTo(cx + 43, cy + 34, cx + 26, cy + 38, cx, cy + 38)
      ..cubicTo(cx - 26, cy + 38, cx - 43, cy + 34, cx - 44, cy + 18)
      ..cubicTo(cx - 46, cy - 12, cx - 34, cy - 42, cx, cy - 42)
      ..close();

    final bodyRect = Rect.fromCenter(center: Offset(cx, cy), width: 92, height: 84);
    final bodyPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.25, -0.35),
        radius: 0.95,
        colors: const [
          Color(0xFFFFF59D),
          Color(0xFFFFD54F),
          Color(0xFFFFB300),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(bodyRect);

    canvas.drawShadow(bodyPath, const Color(0x40FFA000), 8, true);
    canvas.drawPath(bodyPath, bodyPaint);

    // Rosy cheeks
    final cheekPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFF7043).withValues(alpha: 0.42),
          const Color(0xFFFF7043).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx - 22, cy + 4), radius: 14));
    canvas.drawCircle(Offset(cx - 22, cy + 4), 14, cheekPaint);

    final rightCheekPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFF7043).withValues(alpha: 0.42),
          const Color(0xFFFF7043).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx + 22, cy + 4), radius: 14));
    canvas.drawCircle(Offset(cx + 22, cy + 4), 14, rightCheekPaint);

    const featureBrown = Color(0xFF3E2723);
    final strokePaint = Paint()
      ..color = featureBrown
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillBrown = Paint()
      ..color = featureBrown
      ..style = PaintingStyle.fill;

    switch (rating) {
      case 5:
        // Left winking eye (>)
        final winkPath = Path()
          ..moveTo(cx - 21, cy - 10)
          ..lineTo(cx - 12, cy - 6)
          ..lineTo(cx - 20, cy - 2);
        canvas.drawPath(winkPath, strokePaint);

        // Right eye + raised brow
        canvas.drawArc(
          Rect.fromCenter(center: Offset(cx + 7, cy - 16), width: 10, height: 6),
          math.pi * 1.1,
          math.pi * 0.8,
          false,
          strokePaint..strokeWidth = 2.4,
        );
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx + 7, cy - 9), width: 6.5, height: 8.5),
          fillBrown,
        );

        // Kissing lips (3 shape)
        final kissPath = Path()
          ..moveTo(cx + 3, cy - 1)
          ..quadraticBezierTo(cx + 9, cy + 1, cx + 4, cy + 5)
          ..quadraticBezierTo(cx + 10, cy + 7, cx + 4, cy + 11);
        canvas.drawPath(kissPath, strokePaint..strokeWidth = 2.6);

        // Large heart on cheek
        _drawHeart(
          canvas,
          Offset(cx + 25, cy - 8),
          32,
          const Color(0xFFFF3B6B),
          rotation: -0.18,
        );

        // Surrounding floating hearts & sparkle
        _drawHeart(canvas, Offset(cx - 28, cy - 50), 12, const Color(0xFFFF94B2), rotation: -0.2);
        _drawHeart(canvas, Offset(cx + 46, cy - 52), 18, const Color(0xFFFF4769), rotation: 0.15);
        _drawHeart(canvas, Offset(cx + 35, cy - 33), 11, const Color(0xFFFF94B2), rotation: -0.1);
        _drawHeart(canvas, Offset(cx - 56, cy - 4), 18, const Color(0xFFFF4769), rotation: -0.12);
        _drawHeart(canvas, Offset(cx - 35, cy + 28), 11, const Color(0xFFFF94B2), rotation: 0.1);
        _drawHeart(canvas, Offset(cx + 28, cy + 36), 11, const Color(0xFFFF94B2), rotation: 0.2);
        _drawSparkle(canvas, Offset(cx + 54, cy - 1), 8, const Color(0xFFFF5C7C));

      case 4:
        // Happy smiling eyes (^ ^)
        strokePaint.strokeWidth = 3.6;
        canvas.drawArc(
          Rect.fromCenter(center: Offset(cx - 14, cy - 6), width: 13, height: 10),
          math.pi * 1.1,
          math.pi * 0.8,
          false,
          strokePaint,
        );
        canvas.drawArc(
          Rect.fromCenter(center: Offset(cx + 14, cy - 6), width: 13, height: 10),
          math.pi * 1.1,
          math.pi * 0.8,
          false,
          strokePaint,
        );
        // Happy smile
        canvas.drawArc(
          Rect.fromCenter(center: Offset(cx, cy + 2), width: 26, height: 18),
          math.pi * 0.15,
          math.pi * 0.7,
          false,
          strokePaint,
        );

      case 3:
        // Surprised oval eyes
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx - 15, cy - 8), width: 7, height: 10.5),
          fillBrown,
        );
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx + 14, cy - 7), width: 8, height: 11.5),
          fillBrown,
        );
        // Open surprised mouth
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx, cy + 12), width: 13, height: 11),
          Paint()..color = const Color(0xFFD84315),
        );

      case 2:
        // Sad downward closed eyes
        strokePaint.strokeWidth = 3.4;
        canvas.drawArc(
          Rect.fromCenter(center: Offset(cx - 15, cy - 4), width: 13, height: 7),
          math.pi * 0.15,
          math.pi * 0.7,
          false,
          strokePaint,
        );
        canvas.drawArc(
          Rect.fromCenter(center: Offset(cx + 11, cy - 6), width: 13, height: 7),
          math.pi * 0.15,
          math.pi * 0.7,
          false,
          strokePaint,
        );
        // Sad frown mouth
        canvas.drawArc(
          Rect.fromCenter(center: Offset(cx - 2, cy + 18), width: 22, height: 12),
          math.pi * 1.15,
          math.pi * 0.7,
          false,
          strokePaint,
        );
        // White/ice-blue teardrop on right cheek
        final tearPath = Path()
          ..moveTo(cx + 17, cy - 1)
          ..quadraticBezierTo(cx + 24, cy + 8, cx + 20, cy + 14)
          ..quadraticBezierTo(cx + 16, cy + 18, cx + 13, cy + 13)
          ..quadraticBezierTo(cx + 11, cy + 8, cx + 17, cy - 1)
          ..close();
        canvas.drawPath(tearPath, Paint()..color = const Color(0xFFF0F9FF));

      case 1:
      default:
        // Distressed angled eyes
        canvas.save();
        canvas.translate(cx - 13, cy - 10);
        canvas.rotate(-0.35);
        canvas.drawOval(
          Rect.fromCenter(center: Offset.zero, width: 9.5, height: 6.5),
          fillBrown,
        );
        canvas.restore();

        canvas.save();
        canvas.translate(cx + 7, cy - 6);
        canvas.rotate(0.35);
        canvas.drawOval(
          Rect.fromCenter(center: Offset.zero, width: 9.5, height: 6.5),
          fillBrown,
        );
        canvas.restore();

        // Open distressed oval mouth
        canvas.save();
        canvas.translate(cx - 10, cy + 8);
        canvas.rotate(0.18);
        canvas.drawOval(
          Rect.fromCenter(center: Offset.zero, width: 13, height: 17),
          Paint()..color = const Color(0xFFD84315),
        );
        canvas.restore();

        // Sweat drop on right side
        final sweatPath = Path()
          ..moveTo(cx + 27, cy + 1)
          ..quadraticBezierTo(cx + 32, cy + 10, cx + 29, cy + 16)
          ..quadraticBezierTo(cx + 26, cy + 20, cx + 23, cy + 16)
          ..quadraticBezierTo(cx + 21, cy + 10, cx + 27, cy + 1)
          ..close();
        canvas.drawPath(sweatPath, Paint()..color = const Color(0xFFF0F9FF));
    }
  }

  @override
  bool shouldRepaint(covariant RateEmojiPainter oldDelegate) =>
      oldDelegate.rating != rating;
}

