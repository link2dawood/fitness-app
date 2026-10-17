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
  bool weights = false;
  bool singleWeight = false;
  bool bench = false;
  bool chair = false;
}

_Pose _mirrorPose(_Pose p) {
  Offset flip(Offset a) => Offset(1 - a.dx, a.dy);
  p.head = flip(p.head);
  p.neck = flip(p.neck);
  p.sl = flip(p.sl);
  p.sr = flip(p.sr);
  p.hl = flip(p.hl);
  p.hr = flip(p.hr);
  p.el = flip(p.el);
  p.er = flip(p.er);
  p.wl = flip(p.wl);
  p.wr = flip(p.wr);
  p.kl = flip(p.kl);
  p.kr = flip(p.kr);
  p.al = flip(p.al);
  p.ar = flip(p.ar);
  return p;
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
    case ExerciseMotion.armCirclesClockwise:
    case ExerciseMotion.armCircles:
    case ExerciseMotion.armCirclesReverse:
      final rotation = motion != ExerciseMotion.armCirclesReverse
          ? angle
          : -angle;
      p.wl = const Offset(.18, .32) + _polar(.04, rotation);
      p.wr = const Offset(.82, .32) + _polar(.04, rotation + math.pi);
      p.el = _mix(p.sl, p.wl, .51);
      p.er = _mix(p.sr, p.wr, .51);
    case ExerciseMotion.armScissors:
    case ExerciseMotion.armSwingsLateralSteps:
      p.wl = _mix(const Offset(.16, .32), const Offset(.67, .39), wave);
      p.wr = _mix(const Offset(.84, .32), const Offset(.33, .35), wave);
      p.el = _joint(p.sl, p.wl, .15, .15, 1);
      p.er = _joint(p.sr, p.wr, .15, .15, -1);
      if (motion == ExerciseMotion.armSwingsLateralSteps) {
        final shift = .075 * math.sin(angle);
        p.al += Offset(shift, 0);
        p.ar += Offset(-shift, 0);
        p.kl = _mix(p.hl, p.al, .5);
        p.kr = _mix(p.hr, p.ar, .5);
      }
    case ExerciseMotion.alternatingHooks:
      p.el = Offset(.28 + .28 * wave, .36);
      p.er = Offset(.44 + .28 * wave, .36);
      p.wl = Offset(.33 + .30 * wave, .27);
      p.wr = Offset(.37 + .30 * wave, .29);
    case ExerciseMotion.arnoldDumbbellPress:
    case ExerciseMotion.alternatingDumbbellPress:
    case ExerciseMotion.alternateHammerCurl:
      p.weights = true;
      final alternate = motion != ExerciseMotion.arnoldDumbbellPress;
      final left = alternate ? (1 + math.sin(angle)) / 2 : wave;
      final right = alternate ? 1 - left : wave;
      if (motion == ExerciseMotion.alternateHammerCurl) {
        p.el = const Offset(.40, .44);
        p.er = const Offset(.60, .44);
        p.wl = p.el + _polar(.14, math.pi / 2 + left * math.pi * .85);
        p.wr = p.er + _polar(.14, math.pi / 2 - right * math.pi * .85);
      } else {
        final spread = motion == ExerciseMotion.arnoldDumbbellPress
            ? .06 * (1 - wave)
            : 0.0;
        p.wl = Offset(.31 + spread, .29 - .22 * left);
        p.wr = Offset(.69 - spread, .29 - .22 * right);
        p.el = _joint(p.sl, p.wl, .15, .15, -1);
        p.er = _joint(p.sr, p.wr, .15, .15, 1);
      }
    case ExerciseMotion.altVUp:
    case ExerciseMotion.bicycleCrunches:
    case ExerciseMotion.armCurlsCrunchLeft:
    case ExerciseMotion.armCurlsCrunchRight:
    case ExerciseMotion.buttBridge:
    case ExerciseMotion.buttBridgeTimed:
    case ExerciseMotion.bridge:
    case ExerciseMotion.anteriorShoulderStretch:
      p.floor = true;
      p.side = true;
      p.hl = Offset(.54, .80);
      p.hr = p.hl + const Offset(.015, -.015);
      final stretch = motion == ExerciseMotion.anteriorShoulderStretch;
      final bridge =
          motion == ExerciseMotion.bridge ||
          motion == ExerciseMotion.buttBridge ||
          motion == ExerciseMotion.buttBridgeTimed;
      final sideCurl =
          motion == ExerciseMotion.armCurlsCrunchLeft ||
          motion == ExerciseMotion.armCurlsCrunchRight;
      if (bridge) {
        p.hl -= Offset(0, .15 * wave);
        p.hr -= Offset(0, .15 * wave);
        p.sl = const Offset(.30, .81);
      } else {
        final curl = stretch
            ? 3.9
            : math.pi + .12 + (sideCurl ? .45 : .65) * wave;
        p.sl = p.hl + _polar(.24, curl);
      }
      p.sr = p.sl + const Offset(.015, -.015);
      final heading = (p.sl - p.hl).direction;
      p.neck = p.sl + _polar(.035, heading);
      p.head = p.sl + _polar(.10, heading);
      p.kl = const Offset(.68, .60);
      p.kr = const Offset(.70, .58);
      p.al = const Offset(.82, .84);
      p.ar = const Offset(.84, .82);
      if (motion == ExerciseMotion.altVUp ||
          motion == ExerciseMotion.bicycleCrunches) {
        final left = (1 + math.sin(angle)) / 2;
        if (motion == ExerciseMotion.altVUp) {
          p.al = p.hl + _polar(.39, -.10 - 1.1 * left);
          p.ar = p.hr + _polar(.39, -.10 - 1.1 * (1 - left));
          p.kl = _mix(p.hl, p.al, .5);
          p.kr = _mix(p.hr, p.ar, .5);
        } else {
          p.kl = p.hl + _polar(.21, -.15 - 1.8 * left);
          p.kr = p.hr + _polar(.21, -.15 - 1.8 * (1 - left));
          p.al = p.kl + _polar(.21, -.2 + 1.8 * left);
          p.ar = p.kr + _polar(.21, -.2 + 1.8 * (1 - left));
        }
      }
      p.wl = stretch
          ? const Offset(.23, .84)
          : bridge
          ? const Offset(.48, .84)
          : Offset(.50 + .12 * wave, .65 - .10 * wave);
      p.wr = p.wl + const Offset(.015, -.02);
      p.el = _joint(p.sl, p.wl, .14, .14, -1);
      p.er = _joint(p.sr, p.wr, .14, .14, -1);
      if (sideCurl) {
        p.kr = p.kl + const Offset(.025, -.02);
        p.ar = p.al + const Offset(.025, -.02);
        if (motion == ExerciseMotion.armCurlsCrunchRight) {
          Offset mirror(Offset a) => Offset(1 - a.dx, a.dy);
          p.head = mirror(p.head);
          p.neck = mirror(p.neck);
          p.sl = mirror(p.sl);
          p.sr = mirror(p.sr);
          p.hl = mirror(p.hl);
          p.hr = mirror(p.hr);
          p.el = mirror(p.el);
          p.er = mirror(p.er);
          p.wl = mirror(p.wl);
          p.wr = mirror(p.wr);
          p.kl = mirror(p.kl);
          p.kr = mirror(p.kr);
          p.al = mirror(p.al);
          p.ar = mirror(p.ar);
        }
      }
    case ExerciseMotion.birdDogLeft:
    case ExerciseMotion.birdDogRight:
    case ExerciseMotion.birdDog:
      p.floor = true;
      p.side = true;
      p.sl = const Offset(.63, .55);
      p.sr = const Offset(.65, .53);
      p.hl = const Offset(.38, .56);
      p.hr = const Offset(.40, .54);
      p.neck = const Offset(.69, .53);
      p.head = const Offset(.76, .52);
      final left = motion == ExerciseMotion.birdDogLeft
          ? 0.0
          : motion == ExerciseMotion.birdDogRight
          ? wave
          : math.max(0.0, math.sin(angle));
      final right = motion == ExerciseMotion.birdDogRight
          ? 0.0
          : motion == ExerciseMotion.birdDogLeft
          ? wave
          : math.max(0.0, -math.sin(angle));
      p.wl = _mix(const Offset(.65, .84), const Offset(.94, .52), left);
      p.wr = _mix(const Offset(.67, .82), const Offset(.94, .50), right);
      p.el = _mix(p.sl, p.wl, .5);
      p.er = _mix(p.sr, p.wr, .5);
      p.kl = _mix(const Offset(.38, .82), const Offset(.20, .55), right);
      p.kr = _mix(const Offset(.40, .80), const Offset(.22, .53), left);
      p.al = _mix(const Offset(.18, .84), const Offset(.04, .55), right);
      p.ar = _mix(const Offset(.20, .82), const Offset(.06, .53), left);
    case ExerciseMotion.backwardLungeKickRight:
      p.side = true;
      final lunge = math.max(0.0, math.sin(angle));
      final kick = math.max(0.0, -math.sin(angle));
      p.sl += Offset(0, .10 * lunge);
      p.sr += Offset(0, .10 * lunge);
      p.hl += Offset(0, .10 * lunge);
      p.hr += Offset(0, .10 * lunge);
      p.head += Offset(0, .10 * lunge);
      p.neck += Offset(0, .10 * lunge);
      p.al = const Offset(.50, .86);
      p.ar = Offset(.56 - .32 * lunge + .30 * kick, .86 - .32 * kick);
      p.kl = _mix(
        _mix(p.hl, p.al, .5),
        _joint(p.hl, p.al, .20, .20, -1),
        lunge,
      );
      p.kr = _mix(_mix(p.hr, p.ar, .5), _joint(p.hr, p.ar, .22, .22, 1), lunge);
      p.wl = const Offset(.60, .35);
      p.wr = const Offset(.64, .35);
      p.el = _joint(p.sl, p.wl, .15, .14, 1);
      p.er = _joint(p.sr, p.wr, .15, .14, 1);
    case ExerciseMotion.burpees:
      p.side = true;
      p.floor = true;
      // Smooth keyframes: stand, crouch, plank, crouch, jump, stand.
      final keys = [
        [.50, .30, .48, .55, .44, .70, .42, .86, .40, .57],
        [.57, .53, .40, .64, .61, .72, .47, .86, .65, .84],
        [.65, .57, .39, .63, .25, .72, .12, .84, .68, .84],
        [.57, .53, .40, .64, .61, .72, .47, .86, .65, .84],
        [.50, .19, .48, .44, .44, .59, .42, .74, .48, .03],
        [.50, .30, .48, .55, .44, .70, .42, .86, .40, .57],
      ];
      final scaled = progress.clamp(0.0, 1.0) * 5;
      final index = scaled.floor().clamp(0, 4);
      final t = scaled - index;
      Offset point(int n) => _mix(
        Offset(keys[index][n], keys[index][n + 1]),
        Offset(keys[index + 1][n], keys[index + 1][n + 1]),
        t * t * (3 - 2 * t),
      );
      p.sl = point(0);
      p.sr = p.sl + const Offset(.02, -.01);
      p.hl = point(2);
      p.hr = p.hl + const Offset(.02, -.01);
      p.kl = point(4);
      p.kr = p.kl + const Offset(.04, -.01);
      p.al = point(6);
      p.ar = p.al + const Offset(.04, -.01);
      p.wl = point(8);
      p.wr = p.wl + const Offset(.03, -.01);
      p.neck = p.sl + _polar(.04, (p.sl - p.hl).direction);
      p.head = p.sl + _polar(.11, (p.sl - p.hl).direction);
      p.el = _joint(p.sl, p.wl, .15, .15, 1);
      p.er = _joint(p.sr, p.wr, .15, .15, 1);
    case ExerciseMotion.backwardLungeKickLeft:
      return _mirrorPose(
        _pose(ExerciseMotion.backwardLungeKickRight, progress),
      );
    case ExerciseMotion.backwardLunge:
    case ExerciseMotion.backwardLungeTimed:
      final lunge = _pose(
        ExerciseMotion.backwardLungeKickRight,
        ((progress * 2) % 1) / 2,
      );
      return progress < .5 ? lunge : _mirrorPose(lunge);
    case ExerciseMotion.backwardArmSwings:
      p.side = true;
      p.sl = const Offset(.5, .31);
      p.sr = const Offset(.53, .30);
      p.wl = p.sl + _polar(.28, -angle + math.pi / 2);
      p.wr = p.sr + _polar(.28, -angle + math.pi / 2);
      p.el = _mix(p.sl, p.wl, .5);
      p.er = _mix(p.sr, p.wr, .5);
    case ExerciseMotion.buttKicks:
      p.side = true;
      final left = math.max(0.0, math.sin(angle));
      final right = math.max(0.0, -math.sin(angle));
      p.kl = const Offset(.47, .70);
      p.kr = const Offset(.54, .70);
      p.al = p.kl + _polar(.17, math.pi / 2 + 2.3 * left);
      p.ar = p.kr + _polar(.17, math.pi / 2 + 2.3 * right);
      p.wl = const Offset(.58, .39);
      p.wr = const Offset(.61, .37);
      p.el = _joint(p.sl, p.wl, .15, .14, 1);
      p.er = _joint(p.sr, p.wr, .15, .14, 1);
    case ExerciseMotion.bulgarianSplitSquatLeft:
    case ExerciseMotion.bulgarianSplitSquatRight:
      p.side = true;
      p.bench = true;
      p.hl = Offset(.48, .54 + .12 * wave);
      p.hr = p.hl + const Offset(.02, -.01);
      p.sl = p.hl + const Offset(.02, -.25);
      p.sr = p.sl + const Offset(.02, -.01);
      p.neck = p.sl + const Offset(0, -.04);
      p.head = p.neck + const Offset(0, -.07);
      p.al = const Offset(.68, .86);
      p.ar = const Offset(.26, .65);
      p.kl = _joint(p.hl, p.al, .21, .21, -1);
      p.kr = _joint(p.hr, p.ar, .20, .20, -1);
      p.wl = p.sl + const Offset(.02, .27);
      p.wr = p.sr + const Offset(-.02, .27);
      p.el = _mix(p.sl, p.wl, .5);
      p.er = _mix(p.sr, p.wr, .5);
      if (motion == ExerciseMotion.bulgarianSplitSquatRight) {
        return _mirrorPose(p);
      }
    case ExerciseMotion.boxPushUps:
      p.floor = true;
      p.side = true;
      p.hl = const Offset(.38, .56);
      p.hr = p.hl + const Offset(.02, -.01);
      p.sl = Offset(.64, .56 + .14 * wave);
      p.sr = p.sl + const Offset(.02, -.01);
      p.neck = p.sl + const Offset(.04, 0);
      p.head = p.sl + const Offset(.11, 0);
      p.kl = const Offset(.38, .83);
      p.kr = const Offset(.40, .81);
      p.al = const Offset(.18, .84);
      p.ar = const Offset(.20, .82);
      p.wl = const Offset(.68, .84);
      p.wr = const Offset(.70, .82);
      p.el = _joint(p.sl, p.wl, .15, .15, 1);
      p.er = _joint(p.sr, p.wr, .15, .15, 1);
    case ExerciseMotion.bottomLegLiftLeft:
    case ExerciseMotion.bottomLegLiftRight:
      p.floor = true;
      p.side = true;
      p.hl = const Offset(.48, .76);
      p.hr = const Offset(.50, .74);
      p.sl = const Offset(.26, .71);
      p.sr = const Offset(.28, .69);
      p.neck = const Offset(.22, .69);
      p.head = const Offset(.15, .67);
      p.al = Offset(.88, .80 - .14 * wave);
      p.kl = _mix(p.hl, p.al, .5);
      p.kr = const Offset(.65, .60);
      p.ar = const Offset(.59, .84);
      p.wl = const Offset(.16, .64);
      p.el = const Offset(.22, .84);
      p.wr = const Offset(.40, .84);
      p.er = _joint(p.sr, p.wr, .15, .15, 1);
      if (motion == ExerciseMotion.bottomLegLiftLeft) return _mirrorPose(p);
    case ExerciseMotion.bentLegTwist:
      p.floor = true;
      p.side = true;
      p.head = const Offset(.18, .75);
      p.neck = const Offset(.25, .76);
      p.sl = const Offset(.29, .77);
      p.sr = const Offset(.31, .75);
      p.hl = const Offset(.54, .79);
      p.hr = const Offset(.56, .77);
      p.wl = const Offset(.31, .47);
      p.wr = const Offset(.31, .89);
      p.el = _mix(p.sl, p.wl, .5);
      p.er = _mix(p.sr, p.wr, .5);
      final twist = math.sin(angle);
      p.kl = Offset(.63 + .08 * twist, .57 + .10 * twist);
      p.kr = p.kl + const Offset(.025, -.02);
      p.al = Offset(.83, .72 + .09 * twist);
      p.ar = p.al + const Offset(.025, -.02);
    case ExerciseMotion.bentOverRow:
    case ExerciseMotion.bentOverDumbbellRowsLeft:
    case ExerciseMotion.bentOverDumbbellRowsRight:
      p.side = true;
      p.weights = true;
      final supported = motion != ExerciseMotion.bentOverRow;
      p.singleWeight = supported;
      p.bench = supported;
      p.hl = const Offset(.42, .52);
      p.hr = const Offset(.44, .50);
      p.sl = const Offset(.65, .37);
      p.sr = const Offset(.67, .35);
      p.neck = const Offset(.69, .34);
      p.head = const Offset(.75, .31);
      p.al = const Offset(.30, .86);
      p.ar = supported ? const Offset(.62, .65) : const Offset(.54, .86);
      p.kl = const Offset(.38, .69);
      p.kr = supported ? const Offset(.46, .65) : const Offset(.52, .69);
      p.wl = _mix(const Offset(.65, .66), const Offset(.48, .46), wave);
      p.el = _joint(p.sl, p.wl, .15, .15, 1);
      p.wr = supported
          ? const Offset(.72, .65)
          : p.wl + const Offset(.03, -.02);
      p.er = _joint(p.sr, p.wr, .15, .15, 1);
      if (motion == ExerciseMotion.bentOverDumbbellRowsRight) {
        return _mirrorPose(p);
      }
    case ExerciseMotion.backBowPulls:
    case ExerciseMotion.bowPose:
      p.floor = true;
      p.side = true;
      final bow = motion == ExerciseMotion.bowPose;
      final lift = bow ? .75 + .1 * wave : wave;
      p.hl = const Offset(.47, .80);
      p.hr = p.hl + const Offset(.02, -.015);
      p.sl = Offset(.71, .80 - .12 * lift);
      p.sr = p.sl + const Offset(.02, -.015);
      p.neck = p.sl + const Offset(.035, -.015);
      p.head = p.sl + const Offset(.10, -.04);
      p.kl = Offset(.29, .80 - .04 * lift);
      p.kr = p.kl + const Offset(.02, -.015);
      p.al = bow ? Offset(.30, .56 - .06 * lift) : const Offset(.10, .83);
      p.ar = p.al + const Offset(.02, -.015);
      p.wl = bow
          ? p.al
          : _mix(const Offset(.93, .78), const Offset(.56, .67), wave);
      p.wr = p.wl + const Offset(.02, -.015);
      p.el = bow
          ? _joint(p.sl, p.wl, .20, .20, -1)
          : _mix(p.sl, p.wl, .5) + Offset(0, -.10 * wave);
      p.er = bow
          ? _joint(p.sr, p.wr, .20, .20, -1)
          : _mix(p.sr, p.wr, .5) + Offset(0, -.10 * wave);
    case ExerciseMotion.backArches:
      p.side = true;
      p.chair = true;
      p.hl = const Offset(.44, .63);
      p.hr = const Offset(.46, .61);
      p.sl = Offset(.44 - .07 * wave, .38);
      p.sr = p.sl + const Offset(.02, -.01);
      p.neck = p.sl + const Offset(-.01, -.04);
      p.head = p.neck + Offset(-.03 * wave, -.07);
      p.kl = const Offset(.65, .64);
      p.kr = const Offset(.67, .62);
      p.al = const Offset(.65, .86);
      p.ar = const Offset(.69, .84);
      p.wl = Offset(.70 - .05 * wave, .39);
      p.wr = p.wl + const Offset(.02, -.02);
      p.el = _mix(p.sl, p.wl, .5);
      p.er = _mix(p.sr, p.wr, .5);
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

    if (p.bench || p.chair) {
      final mirrored =
          motion == ExerciseMotion.bulgarianSplitSquatRight ||
          motion == ExerciseMotion.bentOverDumbbellRowsRight;
      canvas.save();
      if (mirrored) {
        canvas.translate(1, 0);
        canvas.scale(-1, 1);
      }
      final split =
          motion == ExerciseMotion.bulgarianSplitSquatLeft ||
          motion == ExerciseMotion.bulgarianSplitSquatRight;
      final x = p.chair
          ? .34
          : split
          ? .12
          : .43;
      final width = p.chair
          ? .22
          : split
          ? .23
          : .38;
      line(
        Offset(x, .66),
        Offset(x + width, .66),
        const Color(0xFF87938B),
        .028,
      );
      line(
        Offset(x + .025, .67),
        Offset(x + .025, .86),
        const Color(0xFF87938B),
        .018,
      );
      line(
        Offset(x + width - .025, .67),
        Offset(x + width - .025, .86),
        const Color(0xFF87938B),
        .018,
      );
      if (p.chair) {
        line(Offset(x, .66), Offset(x, .35), const Color(0xFF87938B), .025);
      }
      canvas.restore();
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
    if (p.weights) {
      for (final wrist in [p.wl, if (!p.singleWeight) p.wr]) {
        line(
          wrist + const Offset(-.032, 0),
          wrist + const Offset(.032, 0),
          const Color(0xFF687984),
          .014,
        );
        for (final dx in [-.036, .036]) {
          line(
            wrist + Offset(dx, -.025),
            wrist + Offset(dx, .025),
            shorts,
            .022,
          );
        }
      }
    }
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
