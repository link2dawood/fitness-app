import 'package:flutter/material.dart';

class BmiScaleGeometry {
  static const minimum = 15.0;
  static const maximum = 40.0;
  static const labels = [15.0, 16.0, 18.5, 25.0, 30.0, 35.0, 40.0];
  static double fraction(double value) =>
      (value.clamp(minimum, maximum) - minimum) / (maximum - minimum);
}

/// Labels, segment edges and pointer share one linear numeric mapping.
class BmiScaleBar extends StatelessWidget {
  const BmiScaleBar({super.key, required this.bmi});
  final double bmi;
  @override
  Widget build(BuildContext context) => Semantics(
    label:
        'BMI ${bmi.toStringAsFixed(1)}. Scale 15 to 40. Markers: 15, 16, 18.5, 25, 30, 35, 40.',
    excludeSemantics: true,
    child: LayoutBuilder(
      builder: (context, box) {
        final style = DefaultTextStyle.of(
          context,
        ).style.merge(const TextStyle(fontSize: 10, color: Color(0xFF6B7280)));
        final painters = [
          for (final value in BmiScaleGeometry.labels)
            TextPainter(
              text: TextSpan(
                text: value == 18.5 ? '18.5' : value.toInt().toString(),
                style: style,
              ),
              textDirection: TextDirection.ltr,
              textScaler: MediaQuery.textScalerOf(context),
            )..layout(),
        ];
        final widest = painters
            .map((p) => p.width)
            .reduce((a, b) => a > b ? a : b);
        final height = painters
            .map((p) => p.height)
            .reduce((a, b) => a > b ? a : b);
        final edge = widest / 2;
        final width = (box.maxWidth - 2 * edge).clamp(0.0, double.infinity);
        final laneEnds = <double>[];
        final labels = <Widget>[];
        for (var i = 0; i < painters.length; i++) {
          final value = BmiScaleGeometry.labels[i];
          final left =
              edge +
              BmiScaleGeometry.fraction(value) * width -
              painters[i].width / 2;
          var lane = 0;
          while (lane < laneEnds.length && left < laneEnds[lane] + 4) {
            lane++;
          }
          if (lane == laneEnds.length) laneEnds.add(0);
          laneEnds[lane] = left + painters[i].width;
          labels.add(
            Positioned(
              left: left,
              top: 34 + lane * (height + 4),
              child: Text(
                value == 18.5 ? '18.5' : value.toInt().toString(),
                key: ValueKey('bmi-label-$value'),
                style: style,
                textDirection: TextDirection.ltr,
              ),
            ),
          );
        }
        for (final painter in painters) {
          painter.dispose();
        }
        return SizedBox(
          height: 34 + laneEnds.length * (height + 4),
          child: Stack(
            children: [
              Positioned(
                left: edge,
                right: edge,
                top: 0,
                height: 28,
                child: CustomPaint(
                  key: const ValueKey('bmi-scale-track'),
                  painter: _BmiPainter(bmi),
                ),
              ),
              ...labels,
            ],
          ),
        );
      },
    ),
  );
}

class _BmiPainter extends CustomPainter {
  const _BmiPainter(this.bmi);
  final double bmi;
  @override
  void paint(Canvas canvas, Size size) {
    const values = [15.0, 16.0, 18.5, 21.5, 25.0, 30.0, 35.0, 40.0];
    const colors = [
      Color(0xFF6366F1),
      Color(0xFF3B82F6),
      Color(0xFF22C55E),
      Color(0xFF84CC16),
      Color(0xFFF59E0B),
      Color(0xFFF97316),
      Color(0xFFEF4444),
    ];
    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 14, size.width, 12),
        const Radius.circular(6),
      ),
    );
    for (var i = 0; i < colors.length; i++) {
      final left = BmiScaleGeometry.fraction(values[i]) * size.width;
      final right = BmiScaleGeometry.fraction(values[i + 1]) * size.width;
      canvas.drawRect(
        Rect.fromLTRB(left, 14, right, 26),
        Paint()..color = colors[i],
      );
    }
    canvas.restore();
    final x = BmiScaleGeometry.fraction(bmi) * size.width;
    canvas.drawPath(
      Path()
        ..moveTo(x, 13)
        ..lineTo(x - 5, 4)
        ..lineTo(x + 5, 4)
        ..close(),
      Paint()..color = const Color(0xFF374151),
    );
  }

  @override
  bool shouldRepaint(_BmiPainter oldDelegate) => oldDelegate.bmi != bmi;
}
