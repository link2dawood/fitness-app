import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/exercise.dart';

class ExerciseFocusIllustration extends StatelessWidget {
  const ExerciseFocusIllustration({super.key, required this.focus});
  final ExerciseFocus focus;
  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _FocusPainter(focus));
}

/// Original schematic body icons, highlighting the selected muscle group.
class _FocusPainter extends CustomPainter {
  const _FocusPainter(this.focus);
  final ExerciseFocus focus;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 40, size.height / 60);
    final base = Paint()..color = const Color(0xFFD0D4D0);
    final accent = Paint()..color = AppColors.primary;
    canvas.drawCircle(const Offset(20, 6), 5, base);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(11, 13, 18, 25),
        const Radius.circular(4),
      ),
      base,
    );
    void limb(Offset a, Offset b, Paint paint) => canvas.drawLine(
      a,
      b,
      Paint()
        ..color = paint.color
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
    limb(const Offset(10, 17), const Offset(4, 36), base);
    limb(const Offset(30, 17), const Offset(36, 36), base);
    limb(const Offset(15, 39), const Offset(13, 56), base);
    limb(const Offset(25, 39), const Offset(27, 56), base);
    switch (focus) {
      case ExerciseFocus.abs:
        canvas.drawRect(const Rect.fromLTWH(15, 25, 10, 12), accent);
      case ExerciseFocus.chest:
        canvas.drawRect(const Rect.fromLTWH(12, 15, 16, 9), accent);
      case ExerciseFocus.back:
        canvas.drawPath(
          Path()
            ..moveTo(12, 15)
            ..lineTo(28, 15)
            ..lineTo(20, 35)
            ..close(),
          accent,
        );
      case ExerciseFocus.arm:
        limb(const Offset(9, 21), const Offset(6, 30), accent);
        limb(const Offset(31, 21), const Offset(34, 30), accent);
      case ExerciseFocus.leg:
        limb(const Offset(15, 40), const Offset(13, 53), accent);
        limb(const Offset(25, 40), const Offset(27, 53), accent);
      case ExerciseFocus.glutes:
        canvas.drawOval(const Rect.fromLTWH(11, 32, 18, 10), accent);
      case ExerciseFocus.shoulder:
        canvas.drawCircle(const Offset(10, 16), 4, accent);
        canvas.drawCircle(const Offset(30, 16), 4, accent);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_FocusPainter oldDelegate) => focus != oldDelegate.focus;
}
