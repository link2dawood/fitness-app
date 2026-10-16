import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/exercise.dart';

/// Original, code-drawn avatar. No third-party artwork or motion files are used.
class ExerciseAvatar extends StatefulWidget {
  const ExerciseAvatar({
    super.key,
    required this.exercise,
    this.animate = true,
    this.pose,
  });
  final ExerciseDefinition exercise;
  final bool animate;

  /// A fixed point in the loop, used for previews and reduced-motion rendering.
  final double? pose;
  @override
  State<ExerciseAvatar> createState() => _ExerciseAvatarState();
}

class _ExerciseAvatarState extends State<ExerciseAvatar>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _controller;
  bool _foreground = true;
  bool _reduceMotion = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
  }

  void _update() {
    if (widget.animate &&
        widget.pose == null &&
        !_reduceMotion &&
        _foreground) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      _controller.stop();
      _controller.value = widget.pose ?? 0.25;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    _update();
  }

  @override
  void didUpdateWidget(covariant ExerciseAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _update();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _update();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: '${widget.exercise.name} animated demonstration',
    image: true,
    child: RepaintBoundary(
      child: CustomPaint(
        painter: _AvatarPainter(widget.exercise.motion, _controller),
        size: Size.infinite,
      ),
    ),
  );
}

Offset _polar(double radius, double angle) =>
    Offset(radius * math.cos(angle), radius * math.sin(angle));
Offset _mix(Offset a, Offset b, double amount) => Offset.lerp(a, b, amount)!;

/// A two-segment limb with fixed bone lengths and a controlled bend direction.
Offset _joint(
  Offset start,
  Offset end,
  double upper,
  double lower,
  double bend,
) {
  final delta = end - start;
  final distance = delta.distance.clamp(0.0001, upper + lower);
  final direction = delta / math.max(delta.distance, 0.0001);
  final along =
      ((upper * upper - lower * lower + distance * distance) / (2 * distance))
          .clamp(0.0, upper);
  final height = math.sqrt(math.max(0.0, upper * upper - along * along));
  return start +
      direction * along +
      Offset(-direction.dy, direction.dx) * height * bend;
}

class _Pose {
  Offset head = const Offset(.5, .19);
  Offset neck = const Offset(.5, .265);
  Offset sl = const Offset(.44, .30), sr = const Offset(.56, .30);
  Offset hl = const Offset(.46, .55), hr = const Offset(.54, .55);
  Offset el = const Offset(.42, .44), er = const Offset(.58, .44);
  Offset wl = const Offset(.40, .57), wr = const Offset(.60, .57);
  Offset kl = const Offset(.44, .70), kr = const Offset(.56, .70);
  Offset al = const Offset(.42, .86), ar = const Offset(.58, .86);
  bool side = false;
  bool floor = false;
}

_Pose _pose(ExerciseMotion motion, double progress) {
  final p = _Pose();
  final angle = progress * math.pi * 2;
  final wave = (1 - math.cos(angle)) / 2;
  switch (motion) {
    case ExerciseMotion.wallPushUp:
      p.side = true;
      p.sl = Offset(.54 + .12 * wave, .31 + .025 * wave);
      p.sr = p.sl + const Offset(.016, -.01);
      p.hl = Offset(.43 + .055 * wave, .57);
      p.hr = p.hl + const Offset(.016, -.01);
      p.neck = p.sl + const Offset(.015, -.045);
      p.head = p.neck + const Offset(.014, -.065);
      p.al = const Offset(.31, .86);
      p.ar = const Offset(.34, .85);
      p.kl = _mix(p.hl, p.al, .52);
      p.kr = _mix(p.hr, p.ar, .52);
      p.wl = const Offset(.82, .31);
      p.wr = const Offset(.82, .285);
      p.el = _joint(p.sl, p.wl, .15, .15, 1);
      p.er = _joint(p.sr, p.wr, .15, .15, 1);
    case ExerciseMotion.punches:
      p.side = true;
      p.sl = const Offset(.45, .31);
      p.sr = const Offset(.49, .30);
      p.hl = const Offset(.46, .55);
      p.hr = const Offset(.5, .55);
      p.al = const Offset(.34, .86);
      p.ar = const Offset(.65, .86);
      p.kl = const Offset(.36, .70);
      p.kr = const Offset(.58, .70);
      p.head = const Offset(.48, .19);
      p.neck = const Offset(.47, .265);
      final left = math.pow(math.max(0.0, math.sin(angle)), 2).toDouble();
      final right = math.pow(math.max(0.0, -math.sin(angle)), 2).toDouble();
      p.wl = _mix(const Offset(.54, .29), const Offset(.76, .31), left);
      p.wr = _mix(const Offset(.55, .28), const Offset(.79, .30), right);
      p.el = _joint(p.sl, p.wl, .17, .16, 1);
      p.er = _joint(p.sr, p.wr, .17, .16, 1);
    case ExerciseMotion.sideArmRaise:
    case ExerciseMotion.armRaises:
      final swing =
          wave *
          (motion == ExerciseMotion.armRaises ? math.pi * .91 : math.pi * .48);
      p.el = p.sl + _polar(.145, math.pi / 2 + swing);
      p.wl = p.sl + _polar(.285, math.pi / 2 + swing);
      p.er = p.sr + _polar(.145, math.pi / 2 - swing);
      p.wr = p.sr + _polar(.285, math.pi / 2 - swing);
    case ExerciseMotion.forwardArmSwings:
      p.side = true;
      p.sl = const Offset(.5, .31);
      p.sr = const Offset(.53, .30);
      p.hl = const Offset(.48, .55);
      p.hr = const Offset(.52, .55);
      p.head = const Offset(.52, .19);
      p.neck = const Offset(.515, .265);
      final swing = math.pi * .64 - wave * math.pi * .67;
      p.el = p.sl + _polar(.145, swing);
      p.wl = p.sl + _polar(.285, swing);
      p.er = p.sr + _polar(.145, swing);
      p.wr = p.sr + _polar(.285, swing);
    case ExerciseMotion.elbowsBack:
      p.side = true;
      p.sl = const Offset(.5, .31);
      p.sr = const Offset(.52, .30);
      p.head = const Offset(.51, .19);
      p.neck = const Offset(.51, .265);
      p.el = Offset(.60 - .20 * wave, .43);
      p.er = p.el + const Offset(.02, -.015);
      p.wl = Offset(.66 - .18 * wave, .33);
      p.wr = p.wl + const Offset(.02, -.015);
    case ExerciseMotion.crunch9090:
    case ExerciseMotion.abdominalCrunch:
      p.floor = true;
      p.side = true;
      p.hl = const Offset(.55, .81);
      p.hr = const Offset(.565, .795);
      final curl = math.pi - .04 + .60 * wave;
      p.sl = p.hl + _polar(.25, curl);
      p.sr = p.sl + const Offset(.015, -.012);
      p.neck = p.hl + _polar(.29, curl);
      p.head = p.hl + _polar(.36, curl);
      p.wl = Offset(.48, .67 - .07 * wave);
      p.wr = p.wl + const Offset(.015, -.02);
      p.el = _joint(p.sl, p.wl, .14, .13, -1);
      p.er = _joint(p.sr, p.wr, .14, .13, -1);
      if (motion == ExerciseMotion.crunch9090) {
        p.kl = const Offset(.55, .51);
        p.kr = const Offset(.57, .49);
        p.al = const Offset(.81, .51);
        p.ar = const Offset(.83, .49);
      } else {
        p.kl = const Offset(.70, .57);
        p.kr = const Offset(.72, .555);
        p.al = const Offset(.82, .84);
        p.ar = const Offset(.85, .825);
      }
    case ExerciseMotion.armCircles:
    case ExerciseMotion.armCirclesReverse:
      final rotation = motion == ExerciseMotion.armCircles ? angle : -angle;
      p.wl = const Offset(.18, .32) + _polar(.04, rotation);
      p.wr = const Offset(.82, .32) + _polar(.04, rotation + math.pi);
      p.el = _mix(p.sl, p.wl, .51);
      p.er = _mix(p.sr, p.wr, .51);
    case ExerciseMotion.adductorStretch:
      final shift = .12 * math.sin(angle);
      p.hl = Offset(.46 + shift, .59);
      p.hr = Offset(.54 + shift, .59);
      p.sl = Offset(.44 + shift, .35);
      p.sr = Offset(.56 + shift, .35);
      p.neck = Offset(.5 + shift, .31);
      p.head = Offset(.5 + shift, .235);
      p.al = const Offset(.19, .86);
      p.ar = const Offset(.81, .86);
      p.kl = _joint(p.hl, p.al, .21, .22, 1);
      p.kr = _joint(p.hr, p.ar, .21, .22, -1);
      p.wl = Offset(.44 + shift, .55);
      p.wr = Offset(.56 + shift, .55);
      p.el = _joint(p.sl, p.wl, .15, .14, 1);
      p.er = _joint(p.sr, p.wr, .15, .14, -1);
  }
  return p;
}

class _AvatarPainter extends CustomPainter {
  _AvatarPainter(this.motion, this.animation) : super(repaint: animation);
  final ExerciseMotion motion;
  final Animation<double> animation;
  static const skin = Color(0xFFE7B38B);
  static const darkSkin = Color(0xFFC88E6C);
  static const shorts = Color(0xFF253541);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final edge = math.min(size.width, size.height);
    canvas.save();
    canvas.translate((size.width - edge) / 2, (size.height - edge) / 2);
    canvas.scale(edge);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, 1, 1),
        const Radius.circular(.08),
      ),
      Paint()..color = const Color(0xFFF6FAF2),
    );
    final p = _pose(motion, animation.value);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(p.floor ? .51 : .5, .90),
        width: p.floor ? .75 : .5,
        height: .035,
      ),
      Paint()..color = const Color(0xFFE0E8DA),
    );
    if (p.floor) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(.1, .86, .81, .022),
          const Radius.circular(.01),
        ),
        Paint()..color = AppColors.primary.withValues(alpha: .35),
      );
    }
    if (motion == ExerciseMotion.wallPushUp) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(.84, .13, .035, .74),
          const Radius.circular(.01),
        ),
        Paint()..color = const Color(0xFFCCD7C4),
      );
      for (var y = .2; y < .86; y += .12) {
        canvas.drawLine(
          Offset(.845, y),
          Offset(.875, y),
          Paint()
            ..color = Colors.white
            ..strokeWidth = .005,
        );
      }
    }
    void line(Offset a, Offset b, Color color, double width) => canvas.drawLine(
      a,
      b,
      Paint()
        ..color = color
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round,
    );
    void leg(Offset hip, Offset knee, Offset ankle, bool far) {
      final color = far ? darkSkin : skin;
      line(hip, knee, color, .045);
      line(knee, ankle, color, .035);
      line(hip, _mix(hip, knee, .49), shorts, .068);
      final toe =
          ankle + Offset(p.side ? .035 : (ankle.dx < .5 ? -.025 : .025), .012);
      line(ankle, toe, const Color(0xFF24323D), .031);
      line(
        ankle + const Offset(0, .025),
        toe + const Offset(0, .016),
        Colors.white,
        .008,
      );
    }

    void arm(Offset shoulder, Offset elbow, Offset wrist, bool far) {
      final color = far ? darkSkin : skin;
      line(shoulder, elbow, color, .035);
      line(elbow, wrist, color, .029);
      canvas.drawCircle(wrist, .019, Paint()..color = color);
    }

    leg(p.hr, p.kr, p.ar, true);
    arm(p.sr, p.er, p.wr, true);
    leg(p.hl, p.kl, p.al, false);
    final torso = Path()
      ..moveTo(p.sl.dx - .012, p.sl.dy)
      ..quadraticBezierTo(p.neck.dx, p.neck.dy + .018, p.sr.dx + .012, p.sr.dy)
      ..lineTo(p.hr.dx + .025, p.hr.dy)
      ..lineTo(p.hl.dx - .025, p.hl.dy)
      ..close();
    canvas.drawPath(torso, Paint()..color = AppColors.primary);
    if (p.side) {
      line(_mix(p.sl, p.sr, .5), _mix(p.hl, p.hr, .5), AppColors.primary, .07);
    }
    line(
      _mix(p.sl, p.hl, .2),
      _mix(p.sl, p.hl, .8),
      const Color(0xFF64A62F),
      .012,
    );
    line(p.neck, p.head, skin, .033);
    arm(p.sl, p.el, p.wl, false);
    canvas.save();
    if (p.floor) {
      canvas.translate(p.head.dx, p.head.dy);
      canvas.rotate((p.head - p.neck).direction + math.pi / 2);
      canvas.translate(-p.head.dx, -p.head.dy);
    }
    canvas.drawOval(
      Rect.fromCenter(center: p.head, width: .086, height: .105),
      Paint()..color = skin,
    );
    final hair = Path()
      ..moveTo(p.head.dx - .045, p.head.dy)
      ..quadraticBezierTo(
        p.head.dx - .05,
        p.head.dy - .073,
        p.head.dx + .035,
        p.head.dy - .052,
      )
      ..lineTo(p.head.dx + .046, p.head.dy - .012)
      ..quadraticBezierTo(
        p.head.dx,
        p.head.dy - .035,
        p.head.dx - .045,
        p.head.dy,
      )
      ..close();
    canvas.drawPath(hair, Paint()..color = const Color(0xFF293944));
    if (p.side) {
      canvas.drawCircle(
        p.head + const Offset(.026, -.002),
        .004,
        Paint()..color = const Color(0xFF293944),
      );
      canvas.drawCircle(
        p.head + const Offset(.043, .012),
        .009,
        Paint()..color = skin,
      );
    } else {
      for (final x in [-.016, .016]) {
        canvas.drawCircle(
          p.head + Offset(x, .003),
          .0035,
          Paint()..color = const Color(0xFF293944),
        );
      }
    }
    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AvatarPainter oldDelegate) =>
      oldDelegate.motion != motion || oldDelegate.animation != animation;
}
