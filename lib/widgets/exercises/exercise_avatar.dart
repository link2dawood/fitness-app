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
      duration: widget.exercise.animationDuration,
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
    if (oldWidget.exercise.motion != widget.exercise.motion) {
      _controller.stop();
      _controller.duration = widget.exercise.animationDuration;
    }
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
  bool toesIn = false;
  bool toesOut = false;
  double heelLift = 0;
  bool doorway = false;
  double backCurve = 0;
  Rect? support;
  bool mirrored = false;
  bool wall = false;
  double wallX = .84;
  bool supportBack = false;
}

_Pose _mirrorPose(_Pose p) {
  p.mirrored = !p.mirrored;
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

_Pose _blendPose(_Pose a, _Pose b, double t) {
  final p = _Pose()
    ..side = true
    ..floor = true;
  p.head = _mix(a.head, b.head, t);
  p.neck = _mix(a.neck, b.neck, t);
  p.sl = _mix(a.sl, b.sl, t);
  p.sr = _mix(a.sr, b.sr, t);
  p.hl = _mix(a.hl, b.hl, t);
  p.hr = _mix(a.hr, b.hr, t);
  p.el = _mix(a.el, b.el, t);
  p.er = _mix(a.er, b.er, t);
  p.wl = _mix(a.wl, b.wl, t);
  p.wr = _mix(a.wr, b.wr, t);
  p.kl = _mix(a.kl, b.kl, t);
  p.kr = _mix(a.kr, b.kr, t);
  p.al = _mix(a.al, b.al, t);
  p.ar = _mix(a.ar, b.ar, t);
  return p;
}

_Pose _shiftPose(_Pose p, Offset delta) {
  p.head += delta;
  p.neck += delta;
  p.sl += delta;
  p.sr += delta;
  p.hl += delta;
  p.hr += delta;
  p.el += delta;
  p.er += delta;
  p.wl += delta;
  p.wr += delta;
  p.kl += delta;
  p.kr += delta;
  p.al += delta;
  p.ar += delta;
  return p;
}

_Pose _seatedPose() {
  final p = _Pose()..floor = true;
  p.hl = const Offset(.46, .70);
  p.hr = const Offset(.54, .70);
  p.sl = const Offset(.44, .42);
  p.sr = const Offset(.56, .42);
  p.neck = const Offset(.50, .38);
  p.head = const Offset(.50, .31);
  p.kl = const Offset(.29, .80);
  p.kr = const Offset(.71, .80);
  p.al = const Offset(.59, .84);
  p.ar = const Offset(.41, .84);
  p.wl = const Offset(.32, .74);
  p.wr = const Offset(.68, .74);
  p.el = _joint(p.sl, p.wl, .18, .17, 1);
  p.er = _joint(p.sr, p.wr, .18, .17, -1);
  return p;
}

_Pose _pose(ExerciseMotion motion, double progress) {
  final p = _Pose();
  final angle = progress * math.pi * 2;
  final wave = (1 - math.cos(angle)) / 2;
  switch (motion) {
    case ExerciseMotion.crossBodyShoulderStretch:
      final q = _pose(ExerciseMotion.shoulderStretch, progress);
      return _blendPose(q, _mirrorPose(q), wave);
    case ExerciseMotion.elbowRotations:
      p.wl = p.sl + const Offset(-.015, .01);
      p.wr = p.sr + const Offset(.015, .01);
      p.el = p.sl + Offset(-.11 * math.cos(angle), .11 * math.sin(angle));
      p.er = p.sr + Offset(.11 * math.cos(angle), .11 * math.sin(angle));
    case ExerciseMotion.alternatingSideBends:
      final lean = .11 * math.sin(angle);
      p.sl += Offset(lean, .015 * lean.abs());
      p.sr += Offset(lean, .015 * lean.abs());
      p.neck += Offset(lean * 1.3, .01);
      p.head += Offset(lean * 1.5, .01);
      if (lean >= 0) {
        p.wl = p.head + const Offset(.08, -.09);
        p.el = p.sl + const Offset(-.03, -.13);
        p.wr = p.hr + const Offset(.04, .14);
        p.er = _mix(p.sr, p.wr, .5);
      } else {
        p.wr = p.head + const Offset(-.08, -.09);
        p.er = p.sr + const Offset(.03, -.13);
        p.wl = p.hl + const Offset(-.04, .14);
        p.el = _mix(p.sl, p.wl, .5);
      }
    case ExerciseMotion.spinalRollDown:
      final q = _pose(ExerciseMotion.hipHinge, progress);
      q.neck += Offset(.02 * wave, .035 * wave);
      q.head += Offset(.025 * wave, .065 * wave);
      return q;
    case ExerciseMotion.standingHipRotationsLeft:
      return _pose(ExerciseMotion.singleHipRotation, progress);
    case ExerciseMotion.standingHipRotationsRight:
      return _mirrorPose(_pose(ExerciseMotion.singleHipRotation, progress));
    case ExerciseMotion.kneelingPushUps:
      return _pose(ExerciseMotion.kneePushUps, progress);
    case ExerciseMotion.birdDogTimed:
      return _pose(ExerciseMotion.birdDog, progress);
    case ExerciseMotion.reverseHipRaise:
      final q = _pose(ExerciseMotion.backBowPulls, 0);
      q.hl -= Offset(0, .035 * wave);
      q.hr -= Offset(0, .035 * wave);
      q.kl = Offset(.29, .80 - .065 * wave);
      q.kr = q.kl + const Offset(.02, -.015);
      q.al = q.kl + const Offset(.01, -.19);
      q.ar = q.kr + const Offset(.01, -.19);
      q.wl = const Offset(.80, .82);
      q.wr = const Offset(.82, .80);
      q.el = const Offset(.65, .83);
      q.er = const Offset(.67, .81);
      return q;
    case ExerciseMotion.supermanTimed:
      return _pose(ExerciseMotion.superman, progress);
    case ExerciseMotion.legScissors:
      final q = _pose(ExerciseMotion.legRaises, 0);
      q.al = q.hl + _polar(.36, -.20 - .95 * wave);
      q.ar = q.hr + _polar(.36, -.20 - .95 * (1 - wave));
      q.kl = _mix(q.hl, q.al, .5);
      q.kr = _mix(q.hr, q.ar, .5);
      return q;
    case ExerciseMotion.suitcaseCrunch:
      final q = _pose(ExerciseMotion.crunchKicks, progress);
      q.sl = Offset(.34 + .12 * wave, .68 - .16 * wave);
      q.sr = q.sl + const Offset(.02, -.02);
      q.neck = q.sl + const Offset(-.025, -.035);
      q.head = q.sl + const Offset(-.06, -.10);
      q.wl = Offset(.60, .64 - .08 * wave);
      q.wr = q.wl + const Offset(.02, -.02);
      q.el = _mix(q.sl, q.wl, .5);
      q.er = _mix(q.sr, q.wr, .5);
      return q;
    case ExerciseMotion.leftPivotStepLunge:
    case ExerciseMotion.rightPivotStepLunge:
      final q = _pose(ExerciseMotion.backwardLungeKickRight, wave * .25);
      q.wl = q.sl + const Offset(.10, .06);
      q.wr = q.wl + const Offset(.02, -.02);
      q.el = _joint(q.sl, q.wl, .15, .14, 1);
      q.er = _joint(q.sr, q.wr, .15, .14, -1);
      q.sl += Offset(-.025 * wave, 0);
      q.sr += Offset(.025 * wave, 0);
      return motion == ExerciseMotion.leftPivotStepLunge ? _mirrorPose(q) : q;
    case ExerciseMotion.prisonerSquat:
      final q = _pose(ExerciseMotion.squats, progress);
      q.wl = q.head + const Offset(-.045, .025);
      q.wr = q.head + const Offset(.045, .025);
      q.el = q.sl + const Offset(-.13, -.01);
      q.er = q.sr + const Offset(.13, -.01);
      return q;
    case ExerciseMotion.hipFlexorStretchLeft:
      return _pose(ExerciseMotion.kneelLungeLeft, progress);
    case ExerciseMotion.hipFlexorStretchRight:
      return _pose(ExerciseMotion.kneelLungeRight, progress);
    case ExerciseMotion.plankToDownwardDog:
      return _blendPose(
        _pose(ExerciseMotion.straightPlank, 0),
        _pose(ExerciseMotion.downDog, 0),
        wave,
      );

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
    case ExerciseMotion.clapsOverhead:
      return _pose(ExerciseMotion.armRaises, progress);
    case ExerciseMotion.crossArmCrunch:
    case ExerciseMotion.crossoverCrunch:
    case ExerciseMotion.crunchLegsRaised:
    case ExerciseMotion.crunchKicks:
    case ExerciseMotion.clappingCrunch:
      final q = _pose(ExerciseMotion.abdominalCrunch, progress);
      if (motion == ExerciseMotion.crossArmCrunch) {
        q.wl = q.sr + const Offset(.04, .06);
        q.wr = q.sl + const Offset(-.04, .06);
      } else if (motion == ExerciseMotion.crossoverCrunch) {
        q.wl = q.head + const Offset(.01, .02);
        q.wr = Offset(.64, .58 - .08 * math.sin(angle));
        q.sl += Offset(.025 * math.sin(angle), 0);
      } else if (motion == ExerciseMotion.crunchLegsRaised) {
        q.al = const Offset(.60, .38);
        q.ar = const Offset(.63, .36);
        q.kl = _mix(q.hl, q.al, .5);
        q.kr = _mix(q.hr, q.ar, .5);
      } else if (motion == ExerciseMotion.crunchKicks) {
        q.al = _mix(const Offset(.69, .57), const Offset(.94, .73), wave);
        q.ar = q.al + const Offset(.015, -.02);
        q.kl = _mix(const Offset(.50, .56), _mix(q.hl, q.al, .5), wave);
        q.kr = q.kl + const Offset(.015, -.02);
      } else {
        final lift = (1 + math.sin(angle)) / 2;
        q.al = q.hl + _polar(.36, -.15 - .85 * lift);
        q.ar = q.hr + _polar(.36, -.15 - .85 * (1 - lift));
        q.kl = _mix(q.hl, q.al, .5);
        q.kr = _mix(q.hr, q.ar, .5);
        q.wl = _mix(q.hl, q.al, .4) + const Offset(0, .04);
        q.wr = q.wl + const Offset(.01, -.015);
      }
      q.el = _joint(q.sl, q.wl, .14, .14, -1);
      q.er = _joint(q.sr, q.wr, .14, .14, -1);
      if (motion == ExerciseMotion.crossArmCrunch) {
        q.wl = q.sr + const Offset(.015, -.025);
        q.wr = q.sl + const Offset(.02, -.02);
        q.el = q.sl + const Offset(.13, -.03);
        q.er = q.sr + const Offset(.12, -.025);
      }
      return q;
    case ExerciseMotion.cobras:
    case ExerciseMotion.cobraStretch:
      p.floor = true;
      p.side = true;
      final lift = motion == ExerciseMotion.cobraStretch
          ? .80 + .04 * wave
          : wave;
      p.hl = const Offset(.46, .81);
      p.hr = p.hl + const Offset(.02, -.01);
      p.sl = Offset(.70 - .07 * lift, .80 - .21 * lift);
      p.sr = p.sl + const Offset(.02, -.01);
      final heading = (p.sl - p.hl).direction;
      p.neck = p.sl + _polar(.04, heading);
      p.head = p.sl + _polar(.10, heading);
      p.kl = const Offset(.29, .82);
      p.kr = const Offset(.31, .80);
      p.al = const Offset(.12, .84);
      p.ar = const Offset(.14, .82);
      p.wl = const Offset(.70, .84);
      p.wr = const Offset(.72, .82);
      p.el = _joint(p.sl, p.wl, .15, .15, 1);
      p.er = _joint(p.sr, p.wr, .15, .15, 1);
    case ExerciseMotion.sideHipRight:
    case ExerciseMotion.sideHipLeft:
      p.floor = true;
      p.side = true;
      p.hl = Offset(.50, .81 - .12 * wave);
      p.hr = p.hl + const Offset(.02, -.01);
      p.sl = const Offset(.29, .57);
      p.sr = p.sl + const Offset(.02, -.01);
      p.neck = const Offset(.26, .52);
      p.head = const Offset(.23, .46);
      p.el = const Offset(.29, .84);
      p.wl = const Offset(.15, .84);
      p.er = const Offset(.48, .54);
      p.wr = p.hr;
      p.kl = const Offset(.69, .83);
      p.kr = const Offset(.71, .81);
      p.al = const Offset(.81, .72);
      p.ar = const Offset(.83, .70);
      if (motion == ExerciseMotion.sideHipLeft) return _mirrorPose(p);
    case ExerciseMotion.curtsyLunge:
      final lower = math.sin(angle).abs();
      final side = math.sin(angle);
      p.hl += Offset(0, .12 * lower);
      p.hr += Offset(0, .12 * lower);
      p.sl += Offset(0, .12 * lower);
      p.sr += Offset(0, .12 * lower);
      p.neck += Offset(0, .12 * lower);
      p.head += Offset(0, .12 * lower);
      p.al = Offset(.42 + .23 * math.max(0, side), .86);
      p.ar = Offset(.58 - .23 * math.max(0, -side), .86);
      p.kl = _mix(_mix(p.hl, p.al, .5), Offset(.35, .75), lower);
      p.kr = _mix(_mix(p.hr, p.ar, .5), Offset(.65, .75), lower);
      p.wl = const Offset(.49, .39);
      p.wr = const Offset(.51, .39);
      p.el = _joint(p.sl, p.wl, .15, .14, 1);
      p.er = _joint(p.sr, p.wr, .15, .14, -1);
    case ExerciseMotion.chestPressPulse:
      p.wl = Offset(.49, .21 - .04 * wave);
      p.wr = Offset(.51, .21 - .04 * wave);
      p.el = Offset(.49, .36 - .04 * wave);
      p.er = Offset(.51, .36 - .04 * wave);
    case ExerciseMotion.calfRaises:
    case ExerciseMotion.calfSplayed:
    case ExerciseMotion.calfPigeon:
      p.heelLift = .035 * wave;
      p.toesIn = motion == ExerciseMotion.calfPigeon;
      p.toesOut = motion == ExerciseMotion.calfSplayed;
      p.head -= Offset(0, p.heelLift);
      p.neck -= Offset(0, p.heelLift);
      p.sl -= Offset(0, p.heelLift);
      p.sr -= Offset(0, p.heelLift);
      p.hl -= Offset(0, p.heelLift);
      p.hr -= Offset(0, p.heelLift);
      p.el -= Offset(0, p.heelLift);
      p.er -= Offset(0, p.heelLift);
      p.wl -= Offset(0, p.heelLift);
      p.wr -= Offset(0, p.heelLift);
      p.kl -= Offset(0, p.heelLift);
      p.kr -= Offset(0, p.heelLift);
      p.al -= Offset(0, p.heelLift);
      p.ar -= Offset(0, p.heelLift);
    case ExerciseMotion.crossTouchReach:
      final bend = wave;
      p.sl = Offset(.44 + .09 * bend, .30 + .25 * bend);
      p.sr = Offset(.56 + .09 * bend, .30 + .25 * bend);
      p.neck = Offset(.5 + .09 * bend, .265 + .25 * bend);
      p.head = Offset(.5 + .09 * bend, .19 + .25 * bend);
      p.al = const Offset(.30, .86);
      p.ar = const Offset(.70, .86);
      p.kl = _mix(p.hl, p.al, .5);
      p.kr = _mix(p.hr, p.ar, .5);
      p.wl = _mix(const Offset(.40, .08), p.ar, bend);
      p.wr = _mix(const Offset(.83, .33), const Offset(.72, .27), bend);
      p.el = _mix(p.sl, p.wl, .5);
      p.er = _mix(p.sr, p.wr, .5);
    case ExerciseMotion.catCow:
      final q = _pose(ExerciseMotion.birdDog, 0);
      q.backCurve = .07 * math.sin(angle);
      q.sl += Offset(0, .025 * math.sin(angle));
      q.sr += Offset(0, .025 * math.sin(angle));
      q.hl += Offset(0, -.025 * math.sin(angle));
      q.hr += Offset(0, -.025 * math.sin(angle));
      q.head += Offset(0, .06 * math.sin(angle));
      return q;
    case ExerciseMotion.childPose:
      p.floor = true;
      p.side = true;
      p.hl = const Offset(.37, .68);
      p.hr = const Offset(.39, .66);
      p.sl = const Offset(.60, .77);
      p.sr = const Offset(.62, .75);
      p.neck = const Offset(.65, .78);
      p.head = const Offset(.72, .79);
      p.kl = const Offset(.50, .84);
      p.kr = const Offset(.52, .82);
      p.al = const Offset(.29, .84);
      p.ar = const Offset(.31, .82);
      p.wl = const Offset(.90, .84);
      p.wr = const Offset(.92, .82);
      p.el = _mix(p.sl, p.wl, .5);
      p.er = _mix(p.sr, p.wr, .5);
    case ExerciseMotion.chestStretch:
      p.doorway = true;
      p.el = const Offset(.26, .30);
      p.er = const Offset(.74, .30);
      p.wl = const Offset(.26, .15);
      p.wr = const Offset(.74, .15);
      p.al = const Offset(.39, .86);
      p.ar = const Offset(.63, .84);
      p.kl = _mix(p.hl, p.al, .5);
      p.kr = _mix(p.hr, p.ar, .5);
    case ExerciseMotion.calfStretchLeft:
    case ExerciseMotion.calfStretchRight:
      final q = _pose(ExerciseMotion.wallPushUp, .12);
      q.al = const Offset(.31, .86);
      q.ar = const Offset(.68, .86);
      q.kl = _mix(q.hl, q.al, .5);
      q.kr = _joint(q.hr, q.ar, .20, .20, -1);
      if (motion == ExerciseMotion.calfStretchRight) return _mirrorPose(q);
      return q;
    case ExerciseMotion.crabKicks:
    case ExerciseMotion.crabKickUp:
      p.floor = true;
      p.side = true;
      p.sl = const Offset(.33, .59);
      p.sr = const Offset(.35, .57);
      p.hl = Offset(
        .56,
        .63 - (motion == ExerciseMotion.crabKickUp ? .04 * wave : 0),
      );
      p.hr = p.hl + const Offset(.02, -.02);
      p.neck = const Offset(.29, .54);
      p.head = const Offset(.25, .48);
      p.wl = const Offset(.25, .84);
      p.wr = const Offset(.28, .82);
      p.el = _mix(p.sl, p.wl, .5);
      p.er = _mix(p.sr, p.wr, .5);
      final left = math.max(0.0, math.sin(angle));
      final right = math.max(0.0, -math.sin(angle));
      p.al = _mix(const Offset(.82, .84), const Offset(.78, .35), left);
      p.ar = _mix(const Offset(.84, .82), const Offset(.80, .33), right);
      p.kl = _mix(const Offset(.76, .61), _mix(p.hl, p.al, .5), left);
      p.kr = _mix(const Offset(.78, .59), _mix(p.hr, p.ar, .5), right);
    case ExerciseMotion.crossKneePlank:
    case ExerciseMotion.crossbodyClimber:
      p.floor = true;
      p.side = true;
      p.sl = const Offset(.65, .53);
      p.sr = const Offset(.67, .51);
      p.hl = const Offset(.40, .59);
      p.hr = const Offset(.42, .57);
      p.neck = const Offset(.70, .51);
      p.head = const Offset(.77, .49);
      final forearm = motion == ExerciseMotion.crossKneePlank;
      p.wl = Offset(forearm ? .85 : .66, .84);
      p.wr = p.wl + const Offset(.02, -.02);
      p.el = forearm ? const Offset(.66, .84) : _mix(p.sl, p.wl, .5);
      p.er = forearm ? const Offset(.68, .82) : _mix(p.sr, p.wr, .5);
      final left = math.max(0.0, math.sin(angle));
      final right = math.max(0.0, -math.sin(angle));
      p.kl = _mix(const Offset(.26, .70), const Offset(.63, .72), left);
      p.kr = _mix(const Offset(.28, .68), const Offset(.65, .70), right);
      p.al = _mix(const Offset(.10, .84), const Offset(.47, .81), left);
      p.ar = _mix(const Offset(.12, .82), const Offset(.49, .79), right);
    case ExerciseMotion.shoulderRolls:
      final shift = _polar(.018, angle);
      p.sl += shift;
      p.sr += shift;
      p.el += shift;
      p.er += shift;
      p.wl += shift;
      p.wr += shift;
    case ExerciseMotion.claspBehind:
      // Side view, standing tall: hands clasped at the lower back, then the
      // straight arms lift gently away from the body to open the chest.
      p.side = true;
      p.hl = const Offset(.49, .55);
      p.hr = const Offset(.51, .545);
      p.kl = const Offset(.49, .705);
      p.kr = const Offset(.51, .70);
      p.al = const Offset(.48, .86);
      p.ar = const Offset(.50, .855);
      p.sl = Offset(.505 + .01 * wave, .30);
      p.sr = p.sl + const Offset(.02, -.006);
      p.neck = p.sl + const Offset(.012, -.037);
      p.head = p.neck + Offset(.012, -.072 - .004 * wave);
      p.wl = _mix(const Offset(.43, .575), const Offset(.37, .51), wave);
      p.wr = p.wl + const Offset(.012, -.008);
      p.el = _joint(p.sl, p.wl, .145, .14, 1);
      p.er = _joint(p.sr, p.wr, .145, .14, 1);
    case ExerciseMotion.chairBendLeft:
    case ExerciseMotion.chairBendRight:
      p.chair = true;
      p.hl = const Offset(.46, .63);
      p.hr = const Offset(.54, .63);
      final lean = .07 * (.6 + .4 * wave);
      p.sl = Offset(.44 - lean, .38);
      p.sr = Offset(.56 - lean, .38);
      p.neck = Offset(.50 - lean, .34);
      p.head = Offset(.50 - lean, .27);
      p.el = Offset(.50 - lean, .12);
      p.wl = Offset(.58 - lean, .32);
      p.er = Offset(.66 - lean, .24);
      p.wr = p.el;
      p.kl = const Offset(.43, .68);
      p.kr = const Offset(.57, .68);
      p.al = const Offset(.43, .86);
      p.ar = const Offset(.57, .86);
      if (motion == ExerciseMotion.chairBendRight) return _mirrorPose(p);
    case ExerciseMotion.dynamicChest:
      final q = _pose(ExerciseMotion.armScissors, progress);
      q.wl = _mix(const Offset(.15, .31), const Offset(.50, .35), wave);
      q.wr = _mix(const Offset(.85, .31), const Offset(.50, .35), wave);
      q.el = _mix(q.sl, q.wl, .5);
      q.er = _mix(q.sr, q.wr, .5);
      return q;
    case ExerciseMotion.dbLateral:
      final q = _pose(ExerciseMotion.sideArmRaise, progress);
      q.weights = true;
      return q;
    case ExerciseMotion.dbFront:
      final q = _pose(ExerciseMotion.forwardArmSwings, progress);
      q.weights = true;
      q.wl = q.sl + _polar(.28, math.pi / 2 - wave * math.pi / 2);
      q.wr = q.sr + _polar(.28, math.pi / 2 - wave * math.pi / 2);
      q.el = _mix(q.sl, q.wl, .5);
      q.er = _mix(q.sr, q.wr, .5);
      return q;
    case ExerciseMotion.dbPunch:
      final q = _pose(ExerciseMotion.punches, progress);
      q.weights = true;
      return q;
    case ExerciseMotion.dbShrug:
      final q = _pose(ExerciseMotion.shoulderRolls, progress);
      q.weights = true;
      q.sl = const Offset(.44, .30) - Offset(0, .035 * wave);
      q.sr = const Offset(.56, .30) - Offset(0, .035 * wave);
      q.el = q.sl + const Offset(-.02, .14);
      q.er = q.sr + const Offset(.02, .14);
      q.wl = q.sl + const Offset(-.04, .28);
      q.wr = q.sr + const Offset(.04, .28);
      return q;
    case ExerciseMotion.donkeyLeft:
    case ExerciseMotion.donkeyRight:
    case ExerciseMotion.donkeyPulseLeft:
    case ExerciseMotion.donkeyPulseRight:
      final q = _pose(ExerciseMotion.birdDog, 0);
      final pulse =
          motion == ExerciseMotion.donkeyPulseLeft ||
          motion == ExerciseMotion.donkeyPulseRight;
      final lift = pulse ? .80 + .20 * wave : wave;
      q.kr = _mix(const Offset(.40, .80), const Offset(.20, .56), lift);
      q.ar = q.kr + _polar(.19, math.pi + lift * math.pi / 2);
      if (motion == ExerciseMotion.donkeyLeft ||
          motion == ExerciseMotion.donkeyPulseLeft) {
        return _mirrorPose(q);
      }
      return q;
    case ExerciseMotion.diamondPushUp:
    case ExerciseMotion.declinePushUp:
    case ExerciseMotion.diagonalPlank:
      p.floor = true;
      p.side = true;
      final decline = motion == ExerciseMotion.declinePushUp;
      final diagonal = motion == ExerciseMotion.diagonalPlank;
      final lower = diagonal ? 0.0 : wave;
      p.sl = Offset(.66, .56 + .15 * lower);
      p.sr = p.sl + const Offset(.02, -.01);
      p.hl = Offset(.40, decline ? .59 : .66 + .07 * lower);
      p.hr = p.hl + const Offset(.02, -.01);
      p.neck = p.sl + const Offset(.04, 0);
      p.head = p.sl + const Offset(.11, 0);
      p.al = Offset(.12, decline ? .57 : .84);
      p.ar = p.al + const Offset(.02, -.015);
      p.kl = _mix(p.hl, p.al, .5);
      p.kr = _mix(p.hr, p.ar, .5);
      p.wl = const Offset(.69, .84);
      p.wr = const Offset(.71, .84);
      if (diagonal) {
        final left = math.max(0.0, math.sin(angle));
        final right = math.max(0.0, -math.sin(angle));
        p.wl = _mix(p.wl, const Offset(.94, .51), left);
        p.wr = _mix(p.wr, const Offset(.95, .49), right);
        p.al = _mix(p.al, const Offset(.06, .59), right);
        p.ar = _mix(p.ar, const Offset(.08, .57), left);
        p.kl = _mix(p.hl, p.al, .5);
        p.kr = _mix(p.hr, p.ar, .5);
      }
      p.el = _joint(p.sl, p.wl, .15, .15, 1);
      p.er = _joint(p.sr, p.wr, .15, .15, 1);
      if (decline) p.support = const Rect.fromLTWH(.06, .59, .20, .025);
    case ExerciseMotion.deadBug:
    case ExerciseMotion.kneesToChest:
      final q = _pose(ExerciseMotion.crunch9090, 0);
      if (motion == ExerciseMotion.kneesToChest) {
        q.kl = const Offset(.43, .61);
        q.kr = const Offset(.45, .59);
        q.al = const Offset(.63, .69);
        q.ar = const Offset(.65, .67);
        q.wl = q.kl + const Offset(.03, 0);
        q.wr = q.kr;
      } else {
        final left = (1 + math.sin(angle)) / 2;
        q.al = _mix(const Offset(.76, .55), const Offset(.94, .78), left);
        q.ar = _mix(const Offset(.78, .53), const Offset(.94, .76), 1 - left);
        q.kl = _mix(const Offset(.55, .53), _mix(q.hl, q.al, .5), left);
        q.kr = _mix(const Offset(.57, .51), _mix(q.hr, q.ar, .5), 1 - left);
        q.wl = q.sl + _polar(.28, -math.pi / 2 - left * math.pi / 2);
        q.wr = q.sr + _polar(.28, -math.pi / 2 - (1 - left) * math.pi / 2);
      }
      q.el = _mix(q.sl, q.wl, .5);
      q.er = _mix(q.sr, q.wr, .5);
      return q;
    case ExerciseMotion.doorCurlLeft:
    case ExerciseMotion.doorCurlRight:
      p.side = true;
      p.doorway = true;
      p.sl = Offset(.48 + .10 * wave, .32);
      p.sr = p.sl + const Offset(.02, -.01);
      p.hl = Offset(.40 + .07 * wave, .57);
      p.hr = p.hl + const Offset(.02, -.01);
      p.neck = p.sl + const Offset(.01, -.04);
      p.head = p.neck + const Offset(0, -.07);
      p.wl = const Offset(.74, .32);
      p.el = _joint(p.sl, p.wl, .15, .15, 1);
      p.wr = p.hr + const Offset(.02, -.03);
      p.er = _mix(p.sr, p.wr, .5);
      p.al = const Offset(.32, .86);
      p.ar = const Offset(.37, .85);
      p.kl = _mix(p.hl, p.al, .5);
      p.kr = _mix(p.hr, p.ar, .5);
      if (motion == ExerciseMotion.doorCurlRight) return _mirrorPose(p);
    case ExerciseMotion.dbTriceps:
      p.singleWeight = true;
      p.weights = true;
      p.el = const Offset(.45, .12);
      p.er = const Offset(.55, .12);
      p.wl = _mix(const Offset(.50, .27), const Offset(.50, .035), wave);
      p.wr = p.wl;
    case ExerciseMotion.dbUpright:
      p.weights = true;
      p.wl = Offset(.46, .59 - .25 * wave);
      p.wr = Offset(.54, .59 - .25 * wave);
      p.el = Offset(.42 - .14 * wave, .44 - .14 * wave);
      p.er = Offset(.58 + .14 * wave, .44 - .14 * wave);
    case ExerciseMotion.downDog:
      p.floor = true;
      p.side = true;
      p.hl = const Offset(.46, .39);
      p.hr = const Offset(.48, .37);
      p.sl = const Offset(.66, .62);
      p.sr = const Offset(.68, .60);
      p.neck = const Offset(.69, .66);
      p.head = const Offset(.73, .72);
      p.al = const Offset(.16, .84);
      p.ar = const Offset(.18, .82);
      p.kl = _mix(p.hl, p.al, .5);
      p.kr = _mix(p.hr, p.ar, .5);
      p.wl = const Offset(.83, .84);
      p.wr = const Offset(.85, .82);
      p.el = _mix(p.sl, p.wl, .5);
      p.er = _mix(p.sr, p.wr, .5);
    case ExerciseMotion.downDogWall:
      p.side = true;
      p.wall = true;
      p.hl = const Offset(.34, .54);
      p.hr = const Offset(.36, .52);
      p.sl = const Offset(.59, .54);
      p.sr = const Offset(.61, .52);
      p.neck = const Offset(.64, .55);
      p.head = const Offset(.71, .57);
      p.al = const Offset(.30, .86);
      p.ar = const Offset(.34, .84);
      p.kl = _mix(p.hl, p.al, .5);
      p.kr = _mix(p.hr, p.ar, .5);
      p.wl = const Offset(.82, .49);
      p.wr = const Offset(.82, .47);
      p.el = _mix(p.sl, p.wl, .5);
      p.er = _mix(p.sr, p.wr, .5);
    case ExerciseMotion.dbConcentrationLeft:
    case ExerciseMotion.dbConcentrationRight:
      p.weights = true;
      p.singleWeight = true;
      p.support = const Rect.fromLTWH(.30, .65, .40, .025);
      p.hl = const Offset(.46, .62);
      p.hr = const Offset(.54, .62);
      p.sl = const Offset(.44, .37);
      p.sr = const Offset(.56, .37);
      p.neck = const Offset(.50, .33);
      p.head = const Offset(.50, .26);
      p.kl = const Offset(.32, .70);
      p.kr = const Offset(.68, .70);
      p.al = const Offset(.25, .86);
      p.ar = const Offset(.75, .86);
      p.el = const Offset(.37, .59);
      p.wl = p.el + _polar(.15, math.pi / 2 - wave * math.pi * .80);
      p.er = const Offset(.68, .54);
      p.wr = p.kr;
      if (motion == ExerciseMotion.dbConcentrationRight) return _mirrorPose(p);
    case ExerciseMotion.dbKickbacks:
    case ExerciseMotion.dbRearDelt:
      final q = _pose(ExerciseMotion.bentOverRow, 0);
      if (motion == ExerciseMotion.dbKickbacks) {
        q.el = const Offset(.48, .40);
        q.er = const Offset(.50, .38);
        q.wl = q.el + _polar(.15, math.pi / 2 + wave * math.pi * .50);
        q.wr = q.wl + const Offset(.02, -.02);
      } else {
        q.wl = _mix(const Offset(.65, .66), const Offset(.39, .40), wave);
        q.wr = _mix(const Offset(.67, .64), const Offset(.73, .34), wave);
        q.el = _joint(q.sl, q.wl, .15, .15, -1);
        q.er = _joint(q.sr, q.wr, .15, .15, 1);
      }
      return q;
    case ExerciseMotion.dbWoodLeft:
    case ExerciseMotion.dbWoodRight:
      p.weights = true;
      p.singleWeight = true;
      p.wl = _mix(const Offset(.67, .56), const Offset(.28, .15), wave);
      p.wr = p.wl;
      p.el = _mix(p.sl, p.wl, .5);
      p.er = _mix(p.sr, p.wr, .5);
      p.sl += Offset(-.03 * wave, 0);
      p.sr += Offset(-.03 * wave, 0);
      if (motion == ExerciseMotion.dbWoodRight) return _mirrorPose(p);
    case ExerciseMotion.dbVUp:
    case ExerciseMotion.dbOtisLeft:
    case ExerciseMotion.dbOtisRight:
      final q = _pose(ExerciseMotion.abdominalCrunch, progress);
      q.weights = true;
      q.singleWeight = true;
      if (motion == ExerciseMotion.dbVUp) {
        q.al = q.hl + _polar(.39, -.12 - 1.15 * wave);
        q.ar = q.al + const Offset(.02, -.02);
        q.kl = _mix(q.hl, q.al, .5);
        q.kr = _mix(q.hr, q.ar, .5);
        q.wl = _mix(const Offset(.20, .57), const Offset(.63, .38), wave);
        q.wr = q.wl;
      } else {
        q.wl = q.sl + _polar(.27, -math.pi / 2);
        q.wr = q.hl + const Offset(.01, -.06);
      }
      q.el = _mix(q.sl, q.wl, .5);
      q.er = _joint(q.sr, q.wr, .15, .15, 1);
      if (motion == ExerciseMotion.dbOtisRight) return _mirrorPose(q);
      return q;
    case ExerciseMotion.dbLyingTriceps:
      p.floor = true;
      p.side = true;
      p.weights = true;
      p.support = const Rect.fromLTWH(.18, .68, .60, .025);
      p.sl = const Offset(.32, .64);
      p.sr = const Offset(.34, .62);
      p.hl = const Offset(.57, .64);
      p.hr = const Offset(.59, .62);
      p.neck = const Offset(.27, .64);
      p.head = const Offset(.20, .64);
      p.kl = const Offset(.76, .65);
      p.kr = const Offset(.78, .63);
      p.al = const Offset(.76, .86);
      p.ar = const Offset(.80, .84);
      p.el = const Offset(.35, .48);
      p.er = const Offset(.38, .46);
      p.wl = p.el + _polar(.15, -math.pi + wave * math.pi / 2);
      p.wr = p.wl + const Offset(.03, -.02);
    case ExerciseMotion.plankRotationLeft:
      p.floor = true;
      p.side = true;
      p.sl = const Offset(.64, .57);
      p.sr = p.sl + Offset(.02, -.07 * wave);
      p.hl = const Offset(.40, .65);
      p.hr = p.hl + Offset(.02, -.03 * wave);
      p.neck = const Offset(.69, .55);
      p.head = const Offset(.76, .53);
      p.al = const Offset(.13, .84);
      p.ar = const Offset(.16, .82);
      p.kl = _mix(p.hl, p.al, .5);
      p.kr = _mix(p.hr, p.ar, .5);
      p.el = const Offset(.65, .84);
      p.wl = const Offset(.82, .84);
      p.wr = _mix(const Offset(.84, .82), const Offset(.66, .25), wave);
      p.er = _mix(p.sr, p.wr, .5);
    case ExerciseMotion.froggyGlute:
    case ExerciseMotion.floorY:
    case ExerciseMotion.hyperextension:
      final q = _pose(ExerciseMotion.backBowPulls, 0);
      if (motion == ExerciseMotion.froggyGlute) {
        q.kl = Offset(.29, .80 - .06 * wave);
        q.kr = q.kl + const Offset(.02, -.02);
        q.al = q.kl + const Offset(0, -.19);
        q.ar = q.al + const Offset(.02, -.02);
        q.wl = const Offset(.78, .84);
        q.wr = const Offset(.80, .82);
        q.el = q.sl + const Offset(.06, .025);
        q.er = q.sr + const Offset(.06, .025);
      } else if (motion == ExerciseMotion.floorY) {
        q.wl = Offset(.94, .83 - .09 * wave);
        q.wr = Offset(.92, .75 - .09 * wave);
        q.el = _mix(q.sl, q.wl, .5);
        q.er = _mix(q.sr, q.wr, .5);
      } else {
        q.sl -= Offset(0, .11 * wave);
        q.sr -= Offset(0, .11 * wave);
        q.head -= Offset(0, .14 * wave);
        q.neck -= Offset(0, .12 * wave);
        q.wl = q.head + const Offset(-.025, .025);
        q.wr = q.wl + const Offset(.02, -.02);
        q.el = _joint(q.sl, q.wl, .14, .14, -1);
        q.er = _joint(q.sr, q.wr, .14, .14, -1);
      }
      return q;
    case ExerciseMotion.floorDips:
      final q = _pose(ExerciseMotion.crabKicks, 0);
      q.sl += Offset(0, .07 * wave);
      q.sr += Offset(0, .07 * wave);
      q.hl += Offset(0, .10 * wave);
      q.hr += Offset(0, .10 * wave);
      q.head += Offset(0, .07 * wave);
      q.neck += Offset(0, .07 * wave);
      q.el = _joint(q.sl, q.wl, .14, .14, -1);
      q.er = _joint(q.sr, q.wr, .14, .14, -1);
      return q;
    case ExerciseMotion.flutterKicks:
      final q = _pose(ExerciseMotion.abdominalCrunch, 0);
      q.al = q.hl + _polar(.39, -.16 - .13 * math.sin(angle));
      q.ar = q.hr + _polar(.39, -.16 + .13 * math.sin(angle));
      q.kl = _mix(q.hl, q.al, .5);
      q.kr = _mix(q.hr, q.ar, .5);
      q.wl = q.hl + const Offset(-.10, .03);
      q.wr = q.hr + const Offset(-.10, .03);
      q.el = _mix(q.sl, q.wl, .5);
      q.er = _mix(q.sr, q.wr, .5);
      return q;
    case ExerciseMotion.forwardBend:
    case ExerciseMotion.hipHinge:
    case ExerciseMotion.halfBendPush:
      p.side = true;
      final fold = motion == ExerciseMotion.forwardBend
          ? .85 + .04 * wave
          : motion == ExerciseMotion.halfBendPush
          ? .60
          : wave;
      final tilt = -math.pi / 2 + fold * math.pi * .58;
      p.hl = const Offset(.46, .55);
      p.hr = const Offset(.48, .53);
      p.sl = p.hl + _polar(.25, tilt);
      p.sr = p.sl + const Offset(.02, -.02);
      p.neck = p.sl + _polar(.04, tilt);
      p.head = p.sl + _polar(.11, tilt);
      p.wl = p.sl + const Offset(0, .28);
      p.wr = p.sr + const Offset(0, .28);
      p.el = _mix(p.sl, p.wl, .5);
      p.er = _mix(p.sr, p.wr, .5);
      p.al = const Offset(.43, .86);
      p.ar = const Offset(.48, .84);
      p.kl = const Offset(.50, .70);
      p.kr = const Offset(.54, .68);
      if (motion == ExerciseMotion.halfBendPush) {
        p.hl += const Offset(0, .07);
        p.hr += const Offset(0, .07);
        p.sl += const Offset(0, .07);
        p.sr += const Offset(0, .07);
        p.head += const Offset(0, .07);
        p.neck += const Offset(0, .07);
        p.kl = const Offset(.60, .73);
        p.kr = const Offset(.64, .71);
        p.wl = p.sl + Offset(.07 + .18 * wave, .02);
        p.wr = p.sr + Offset(.07 + .18 * wave, .02);
        p.el = _joint(p.sl, p.wl, .15, .15, 1);
        p.er = _joint(p.sr, p.wr, .15, .15, 1);
      }
    case ExerciseMotion.frogPress:
      final q = _pose(ExerciseMotion.abdominalCrunch, 0);
      q.al = _mix(const Offset(.56, .56), const Offset(.93, .66), wave);
      q.ar = q.al + const Offset(.015, -.025);
      q.kl = _mix(const Offset(.43, .60), _mix(q.hl, q.al, .5), wave);
      q.kr = _mix(const Offset(.63, .50), _mix(q.hr, q.ar, .5), wave);
      q.wl = const Offset(.45, .84);
      q.wr = const Offset(.47, .82);
      q.el = _mix(q.sl, q.wl, .5);
      q.er = _mix(q.sr, q.wr, .5);
      return q;
    case ExerciseMotion.frogPump:
      final q = _pose(ExerciseMotion.bridge, progress);
      q.kl = const Offset(.65, .66);
      q.kr = const Offset(.75, .60);
      q.al = const Offset(.79, .84);
      q.ar = const Offset(.80, .82);
      return q;
    case ExerciseMotion.floorSlides:
      final q = _pose(ExerciseMotion.abdominalCrunch, 0);
      q.el = q.sl + _polar(.14, math.pi + .65 * wave);
      q.er = q.sr + _polar(.14, math.pi + .65 * wave);
      q.wl = q.el + _polar(.14, -math.pi / 2 - .65 * wave);
      q.wr = q.wl + const Offset(.02, -.03);
      return q;
    case ExerciseMotion.spiderLunges:
      final q = _pose(ExerciseMotion.crossbodyClimber, progress);
      final left = math.max(0.0, math.sin(angle));
      final right = math.max(0.0, -math.sin(angle));
      q.al = _mix(const Offset(.10, .84), const Offset(.76, .84), left);
      q.ar = _mix(const Offset(.12, .82), const Offset(.78, .82), right);
      q.kl = _mix(const Offset(.26, .70), const Offset(.62, .62), left);
      q.kr = _mix(const Offset(.28, .68), const Offset(.64, .60), right);
      return q;
    case ExerciseMotion.flutterSquats:
      p.side = true;
      final squat = math.pow(math.sin(angle), 2).toDouble();
      p.hl = Offset(.45, .55 + .12 * squat);
      p.hr = p.hl + const Offset(.02, -.02);
      p.sl = p.hl + const Offset(.03, -.25);
      p.sr = p.sl + const Offset(.02, -.02);
      p.neck = p.sl + const Offset(.01, -.04);
      p.head = p.neck + const Offset(.01, -.07);
      p.al = const Offset(.47, .86);
      p.ar = const Offset(.52, .84);
      p.kl = _mix(_mix(p.hl, p.al, .5), const Offset(.64, .73), squat);
      p.kr = _mix(_mix(p.hr, p.ar, .5), const Offset(.66, .71), squat);
      final kick = math.pow(math.cos(angle), 8).toDouble();
      if (math.cos(angle) > 0) {
        p.al += Offset(.28 * kick, -.22 * kick);
        p.kl = _mix(p.kl, _mix(p.hl, p.al, .5), kick);
      } else {
        p.ar += Offset(.28 * kick, -.22 * kick);
        p.kr = _mix(p.kr, _mix(p.hr, p.ar, .5), kick);
      }
      p.wl = Offset(.59, .39 + .12 * squat);
      p.wr = p.wl + const Offset(.02, -.02);
      p.el = _joint(p.sl, p.wl, .15, .14, 1);
      p.er = _joint(p.sr, p.wr, .15, .14, 1);
    case ExerciseMotion.spineStretch:
      p.floor = true;
      p.side = true;
      p.hl = const Offset(.35, .81);
      p.hr = const Offset(.37, .79);
      p.sl = const Offset(.54, .62);
      p.sr = const Offset(.56, .60);
      p.neck = const Offset(.57, .59);
      p.head = const Offset(.63, .57);
      p.al = const Offset(.84, .84);
      p.ar = const Offset(.86, .82);
      p.kl = _mix(p.hl, p.al, .5);
      p.kr = _mix(p.hr, p.ar, .5);
      p.wl = const Offset(.80, .78);
      p.wr = const Offset(.82, .76);
      p.el = _mix(p.sl, p.wl, .5);
      p.er = _mix(p.sr, p.wr, .5);
    case ExerciseMotion.gluteKickBack:
    case ExerciseMotion.gluteKickLeft:
    case ExerciseMotion.gluteKickRight:
    case ExerciseMotion.gluteCrossLeft:
    case ExerciseMotion.gluteCrossRight:
    case ExerciseMotion.glutePulseLeft:
    case ExerciseMotion.glutePulseRight:
      final q = _pose(ExerciseMotion.birdDog, 0);
      final pulse =
          motion == ExerciseMotion.glutePulseLeft ||
          motion == ExerciseMotion.glutePulseRight;
      final cross =
          motion == ExerciseMotion.gluteCrossLeft ||
          motion == ExerciseMotion.gluteCrossRight;
      final cycle = motion == ExerciseMotion.gluteKickBack
          ? (1 - math.cos(angle * 2)) / 2
          : wave;
      final lift = pulse ? .80 + .20 * wave : cycle;
      q.ar = _mix(
        const Offset(.20, .82),
        Offset(.04, .54 + (cross ? .10 * math.sin(angle) : 0)),
        lift,
      );
      q.kr = _mix(const Offset(.40, .80), _mix(q.hr, q.ar, .5), lift);
      if (motion == ExerciseMotion.gluteKickBack && progress >= .5) {
        return _mirrorPose(q);
      }
      if (motion == ExerciseMotion.gluteKickLeft ||
          motion == ExerciseMotion.gluteCrossLeft ||
          motion == ExerciseMotion.glutePulseLeft) {
        return _mirrorPose(q);
      }
      return q;
    case ExerciseMotion.gluteStretchLeft:
    case ExerciseMotion.gluteStretchRight:
      final q = _pose(ExerciseMotion.kneesToChest, .25);
      q.kl = const Offset(.63, .53);
      q.al = const Offset(.48, .61);
      q.kr = const Offset(.47, .62);
      q.ar = const Offset(.67, .68);
      q.wl = const Offset(.52, .64);
      q.wr = const Offset(.54, .62);
      q.el = _joint(q.sl, q.wl, .14, .14, -1);
      q.er = _joint(q.sr, q.wr, .14, .14, -1);
      if (motion == ExerciseMotion.gluteStretchRight) return _mirrorPose(q);
      return q;
    case ExerciseMotion.highStepping:
    case ExerciseMotion.highKneeTwist:
      final left = math.max(0.0, math.sin(angle));
      final right = math.max(0.0, -math.sin(angle));
      p.kl = _mix(p.kl, const Offset(.36, .56), left);
      p.kr = _mix(p.kr, const Offset(.64, .56), right);
      p.al = _mix(p.al, const Offset(.34, .73), left);
      p.ar = _mix(p.ar, const Offset(.66, .73), right);
      if (motion == ExerciseMotion.highKneeTwist) {
        p.sl += Offset(.04 * math.sin(angle), .02 * left);
        p.sr += Offset(.04 * math.sin(angle), .02 * right);
        p.wl = p.sl + const Offset(-.26, .02);
        p.wr = p.sr + const Offset(.26, .02);
        p.el = _mix(p.sl, p.wl, .5);
        p.er = _mix(p.sr, p.wr, .5);
      } else {
        p.wl = Offset(.51 + .06 * right, .38 + .08 * left);
        p.wr = Offset(.49 - .06 * left, .38 + .08 * right);
        p.el = _joint(p.sl, p.wl, .15, .14, 1);
        p.er = _joint(p.sr, p.wr, .15, .14, -1);
      }
    case ExerciseMotion.hinduPushUp:
      return _blendPose(
        _pose(ExerciseMotion.downDog, 0),
        _pose(ExerciseMotion.cobras, .5),
        wave,
      );
    case ExerciseMotion.bridgeLegLeft:
    case ExerciseMotion.bridgeLegRight:
      final q = _pose(ExerciseMotion.bridge, .5);
      q.ar = q.hr + _polar(.36, -.25 - 1.05 * wave);
      q.kr = _mix(q.hr, q.ar, .5);
      if (motion == ExerciseMotion.bridgeLegLeft) return _mirrorPose(q);
      return q;
    case ExerciseMotion.heelTouch:
      final q = _pose(ExerciseMotion.abdominalCrunch, .2);
      final reach = math.sin(angle);
      q.sl += Offset(.03 * reach, 0);
      q.sr += Offset(.03 * reach, 0);
      q.wl = _mix(
        const Offset(.48, .77),
        const Offset(.79, .81),
        math.max(0, reach),
      );
      q.wr = _mix(
        const Offset(.50, .75),
        const Offset(.82, .79),
        math.max(0, -reach),
      );
      q.el = _mix(q.sl, q.wl, .5);
      q.er = _mix(q.sr, q.wr, .5);
      return q;
    case ExerciseMotion.hops:
      final jump = .075 * math.sin(angle).abs();
      p.head -= Offset(0, jump);
      p.neck -= Offset(0, jump);
      p.sl -= Offset(0, jump);
      p.sr -= Offset(0, jump);
      p.hl -= Offset(0, jump);
      p.hr -= Offset(0, jump);
      p.el -= Offset(0, jump);
      p.er -= Offset(0, jump);
      p.wl -= Offset(0, jump);
      p.wr -= Offset(0, jump);
      p.kl -= Offset(0, jump);
      p.kr -= Offset(0, jump);
      p.al -= Offset(0, jump);
      p.ar -= Offset(0, jump);
    case ExerciseMotion.hoverPushUp:
      final q = _pose(ExerciseMotion.diamondPushUp, progress);
      q.wl = const Offset(.64, .84);
      q.wr = const Offset(.74, .82);
      q.el = _joint(q.sl, q.wl, .15, .15, 1);
      q.er = _joint(q.sr, q.wr, .15, .15, -1);
      return q;
    case ExerciseMotion.heelsHeavens:
      final q = _pose(ExerciseMotion.crunchLegsRaised, 0);
      q.hl -= Offset(0, .08 * wave);
      q.hr -= Offset(0, .08 * wave);
      q.al = Offset(.59, .37 - .08 * wave);
      q.ar = Offset(.62, .35 - .08 * wave);
      q.kl = _mix(q.hl, q.al, .5);
      q.kr = _mix(q.hr, q.ar, .5);
      q.wl = const Offset(.49, .84);
      q.wr = const Offset(.51, .82);
      q.el = _mix(q.sl, q.wl, .5);
      q.er = _mix(q.sr, q.wr, .5);
      return q;
    case ExerciseMotion.inclinePushUp:
      p.floor = true;
      p.side = true;
      p.support = const Rect.fromLTWH(.66, .63, .24, .025);
      p.sl = Offset(.60 + .04 * wave, .39 + .12 * wave);
      p.sr = p.sl + const Offset(.02, -.01);
      p.hl = Offset(.38, .62 + .05 * wave);
      p.hr = p.hl + const Offset(.02, -.01);
      p.neck = p.sl + const Offset(.025, -.035);
      p.head = p.neck + const Offset(.035, -.06);
      p.al = const Offset(.12, .86);
      p.ar = const Offset(.15, .84);
      p.kl = _mix(p.hl, p.al, .5);
      p.kr = _mix(p.hr, p.ar, .5);
      p.wl = const Offset(.75, .61);
      p.wr = const Offset(.78, .59);
      p.el = _joint(p.sl, p.wl, .15, .15, 1);
      p.er = _joint(p.sr, p.wr, .15, .15, 1);
    case ExerciseMotion.inchworm:
      final folded = _shiftPose(
        _pose(ExerciseMotion.forwardBend, 0),
        const Offset(-.17, 0),
      );
      final plank = _pose(ExerciseMotion.diamondPushUp, 0);
      plank.al = folded.al;
      plank.ar = folded.ar;
      plank.kl = _mix(plank.hl, plank.al, .5);
      plank.kr = _mix(plank.hr, plank.ar, .5);
      return _blendPose(folded, plank, wave);
    case ExerciseMotion.inOuts:
      return _blendPose(
        _pose(ExerciseMotion.diamondPushUp, 0),
        _pose(ExerciseMotion.burpees, .2),
        wave,
      );
    case ExerciseMotion.jumpingJacks:
      final q = _pose(ExerciseMotion.armRaises, progress);
      final swing = wave * math.pi * .91;
      q.wl = q.sl + _polar(.26, math.pi / 2 + swing);
      q.wr = q.sr + _polar(.26, math.pi / 2 - swing);
      q.el = _mix(q.sl, q.wl, .5);
      q.er = _mix(q.sr, q.wr, .5);
      q.al = Offset(.46 - .22 * wave, .86);
      q.ar = Offset(.54 + .22 * wave, .86);
      q.kl = _mix(q.hl, q.al, .5);
      q.kr = _mix(q.hr, q.ar, .5);
      return _shiftPose(q, Offset(0, -.02 * math.sin(angle * 2).abs()));
    case ExerciseMotion.jumpSquats:
    case ExerciseMotion.jumpSquatsTimed:
      final squat = math.max(0.0, math.sin(angle));
      final jump = math.max(0.0, -math.sin(angle));
      p.hl += Offset(0, .13 * squat);
      p.hr += Offset(0, .13 * squat);
      p.sl += Offset(0, .13 * squat);
      p.sr += Offset(0, .13 * squat);
      p.head += Offset(0, .13 * squat);
      p.neck += Offset(0, .13 * squat);
      p.al = const Offset(.35, .86);
      p.ar = const Offset(.65, .86);
      p.kl = _mix(_mix(p.hl, p.al, .5), const Offset(.30, .73), squat);
      p.kr = _mix(_mix(p.hr, p.ar, .5), const Offset(.70, .73), squat);
      p.wl = _mix(
        const Offset(.40, .57),
        Offset(.49, .39 + .13 * squat),
        squat,
      );
      p.wr = _mix(
        const Offset(.60, .57),
        Offset(.51, .39 + .13 * squat),
        squat,
      );
      p.el = _joint(p.sl, p.wl, .15, .14, 1);
      p.er = _joint(p.sr, p.wr, .15, .14, -1);
      return _shiftPose(p, Offset(0, -.08 * jump));
    case ExerciseMotion.jumpPushUps:
    case ExerciseMotion.militaryPushUp:
      final q = _pose(ExerciseMotion.diamondPushUp, progress);
      if (motion == ExerciseMotion.jumpPushUps) {
        final jump =
            .04 * math.pow(math.max(0.0, math.cos(angle)), 6).toDouble();
        q.sl -= Offset(0, jump);
        q.sr -= Offset(0, jump);
        q.head -= Offset(0, jump);
        q.neck -= Offset(0, jump);
        q.el -= Offset(0, jump);
        q.er -= Offset(0, jump);
        q.wl -= Offset(0, jump);
        q.wr -= Offset(0, jump);
      } else {
        q.wl = const Offset(.67, .84);
        q.wr = const Offset(.69, .82);
        q.el = _joint(q.sl, q.wl, .15, .15, 1);
        q.er = _joint(q.sr, q.wr, .15, .15, 1);
      }
      return q;
    case ExerciseMotion.kneePushUps:
    case ExerciseMotion.kneePlank:
    case ExerciseMotion.modifiedLowHold:
      p.floor = true;
      p.side = true;
      final lower = motion == ExerciseMotion.modifiedLowHold
          ? .85
          : motion == ExerciseMotion.kneePlank
          ? 0.0
          : wave;
      p.sl = Offset(.65, .55 + .14 * lower);
      p.sr = p.sl + const Offset(.02, -.01);
      p.hl = Offset(.43, .69 + .04 * lower);
      p.hr = p.hl + const Offset(.02, -.01);
      p.neck = p.sl + const Offset(.04, 0);
      p.head = p.sl + const Offset(.11, 0);
      p.kl = const Offset(.30, .84);
      p.kr = const Offset(.32, .82);
      p.al = const Offset(.15, .70);
      p.ar = const Offset(.17, .68);
      p.wl = const Offset(.69, .84);
      p.wr = const Offset(.71, .82);
      p.el = _joint(p.sl, p.wl, .15, .15, 1);
      p.er = _joint(p.sr, p.wr, .15, .15, 1);
      if (motion == ExerciseMotion.kneePlank) {
        p.el = const Offset(.66, .84);
        p.er = const Offset(.68, .82);
        p.wl = const Offset(.83, .84);
        p.wr = const Offset(.85, .82);
      }
    case ExerciseMotion.kneelLungeLeft:
    case ExerciseMotion.kneelLungeRight:
      final q = _pose(ExerciseMotion.backwardLungeKickRight, .25);
      q.kr = const Offset(.32, .84);
      q.ar = const Offset(.14, .84);
      q.kl = const Offset(.62, .65);
      q.al = const Offset(.64, .86);
      q.wl = const Offset(.60, .62);
      q.wr = const Offset(.62, .60);
      q.el = _joint(q.sl, q.wl, .15, .15, 1);
      q.er = _joint(q.sr, q.wr, .15, .15, 1);
      q.floor = true;
      if (motion == ExerciseMotion.kneelLungeLeft) return _mirrorPose(q);
      return q;
    case ExerciseMotion.kneeChestLeft:
    case ExerciseMotion.kneeChestRight:
      final q = _pose(ExerciseMotion.kneesToChest, 0);
      q.kr = _mix(q.hr, const Offset(.94, .82), .5);
      q.ar = const Offset(.94, .82);
      q.wl = q.kl + const Offset(.03, .01);
      q.wr = q.wl + const Offset(.02, -.02);
      q.el = _joint(q.sl, q.wl, .14, .14, -1);
      q.er = _joint(q.sr, q.wr, .14, .14, -1);
      if (motion == ExerciseMotion.kneeChestRight) return _mirrorPose(q);
      return q;
    case ExerciseMotion.kneeCircle:
      p.head = const Offset(.50, .28);
      p.neck = const Offset(.50, .35);
      p.sl = const Offset(.44, .39);
      p.sr = const Offset(.56, .39);
      p.hl = const Offset(.46, .62);
      p.hr = const Offset(.54, .62);
      final circle = _polar(.02, angle);
      p.kl = const Offset(.47, .74) + circle;
      p.kr = const Offset(.53, .74) + circle;
      p.al = const Offset(.46, .86);
      p.ar = const Offset(.54, .86);
      p.wl = p.kl + const Offset(0, -.04);
      p.wr = p.kr + const Offset(0, -.04);
      p.el = _mix(p.sl, p.wl, .5);
      p.er = _mix(p.sr, p.wr, .5);
    case ExerciseMotion.kneeElbow:
      final q = _pose(ExerciseMotion.highKneeTwist, progress);
      q.wl = q.head + const Offset(-.05, .01);
      q.wr = q.head + const Offset(.05, .01);
      q.el = q.sl + Offset(-.13, .05 + .07 * math.max(0.0, math.sin(angle)));
      q.er = q.sr + Offset(.13, .05 + .07 * math.max(0.0, -math.sin(angle)));
      return q;
    case ExerciseMotion.kneelingSideLeft:
      return _pose(ExerciseMotion.sideHipLeft, .5);
    case ExerciseMotion.kneelingSideRight:
      return _pose(ExerciseMotion.sideHipRight, .5);
    case ExerciseMotion.legRaises:
      final q = _pose(ExerciseMotion.flutterKicks, 0);
      q.al = q.hl + _polar(.39, -.10 - 1.25 * wave);
      q.ar = q.al + const Offset(.02, -.02);
      q.kl = _mix(q.hl, q.al, .5);
      q.kr = _mix(q.hr, q.ar, .5);
      return q;
    case ExerciseMotion.longArmCrunch:
      final q = _pose(ExerciseMotion.abdominalCrunch, progress);
      q.wl = q.sl + _polar(.27, (q.sl - q.hl).direction);
      q.wr = q.wl + const Offset(.02, -.02);
      q.el = _mix(q.sl, q.wl, .5);
      q.er = _mix(q.sr, q.wr, .5);
      return q;
    case ExerciseMotion.lunges:
      return _pose(ExerciseMotion.backwardLunge, progress);
    case ExerciseMotion.lungeHopsLeft:
      final q = _pose(ExerciseMotion.backwardLungeKickRight, progress);
      final lift = math.max(0.0, -math.sin(angle));
      q.kr = _mix(q.kr, const Offset(.70, .55), lift);
      q.ar = _mix(q.ar, const Offset(.68, .73), lift);
      return _mirrorPose(_shiftPose(q, Offset(0, -.04 * lift)));
    case ExerciseMotion.lungeTwist:
      final q = _pose(ExerciseMotion.backwardLungeKickRight, .25);
      q.wl = _mix(const Offset(.78, .36), const Offset(.29, .40), wave);
      q.wr = q.wl + const Offset(.02, -.02);
      q.el = _mix(q.sl, q.wl, .5);
      q.er = _mix(q.sr, q.wr, .5);
      q.sl += Offset(-.03 * wave, 0);
      q.sr += Offset(.03 * wave, 0);
      return q;
    case ExerciseMotion.leaningRaises:
      final q = _pose(ExerciseMotion.wallPushUp, .1);
      q.wall = true;
      q.head -= Offset(0, .025 * wave);
      q.neck -= Offset(0, .025 * wave);
      q.sl -= Offset(0, .025 * wave);
      q.sr -= Offset(0, .025 * wave);
      q.hl -= Offset(0, .025 * wave);
      q.hr -= Offset(0, .025 * wave);
      q.al -= Offset(0, .025 * wave);
      q.ar -= Offset(0, .025 * wave);
      q.kl = _mix(q.hl, q.al, .5);
      q.kr = _mix(q.hr, q.ar, .5);
      q.el = _joint(q.sl, q.wl, .15, .15, 1);
      q.er = _joint(q.sr, q.wr, .15, .15, 1);
      q.heelLift = .025 * wave;
      return q;
    case ExerciseMotion.quadWallLeft:
      p.side = true;
      p.wall = true;
      p.wl = const Offset(.82, .32);
      p.el = _joint(p.sl, p.wl, .16, .16, 1);
      p.kl = const Offset(.43, .70);
      p.al = const Offset(.29, .56);
      p.wr = p.al;
      p.er = _mix(p.sr, p.wr, .5);
      p.kr = _mix(p.hr, p.ar, .5);
    case ExerciseMotion.lyingButterfly:
      return _pose(ExerciseMotion.frogPump, 0);
    case ExerciseMotion.lyingTwistLeft:
      return _pose(ExerciseMotion.bentLegTwist, .25);
    case ExerciseMotion.lyingTwistRight:
      return _pose(ExerciseMotion.bentLegTwist, .75);
    case ExerciseMotion.legCurlLeft:
    case ExerciseMotion.legCurlRight:
      p.side = true;
      p.kl = Offset(.42, .68 - .13 * wave);
      p.al = Offset(.59, .78 - .16 * wave);
      p.ar = const Offset(.59, .86);
      p.kr = _mix(p.hr, p.ar, .5);
      p.wl = p.al + const Offset(-.02, -.02);
      p.wr = p.wl + const Offset(.02, -.02);
      p.el = _mix(p.sl, p.wl, .5);
      p.er = _mix(p.sr, p.wr, .5);
      if (motion == ExerciseMotion.legCurlRight) return _mirrorPose(p);
    case ExerciseMotion.lyingSwingLeft:
    case ExerciseMotion.lyingSwingRight:
      final q = _pose(ExerciseMotion.bottomLegLiftRight, 0);
      q.al = const Offset(.89, .84);
      q.kl = _mix(q.hl, q.al, .5);
      q.ar = Offset(.90, .81 - .25 * wave);
      q.kr = _mix(q.hr, q.ar, .5);
      q.wl = const Offset(.04, .77);
      q.wr = const Offset(.06, .75);
      q.el = _mix(q.sl, q.wl, .5);
      q.er = _mix(q.sr, q.wr, .5);
      if (motion == ExerciseMotion.lyingSwingLeft) return _mirrorPose(q);
      return q;
    case ExerciseMotion.legSpreads:
      final q = _pose(ExerciseMotion.legRaises, .5);
      q.al = q.hl + _polar(.39, -1.10 - .35 * wave);
      q.ar = q.hr + _polar(.39, -1.10 + .35 * wave);
      q.kl = _mix(q.hl, q.al, .5);
      q.kr = _mix(q.hr, q.ar, .5);
      return q;
    case ExerciseMotion.lateralPlank:
      final q = _pose(ExerciseMotion.diamondPushUp, 0);
      q.wl += Offset(.025 * math.sin(angle), 0);
      q.wr += Offset(-.025 * math.sin(angle), 0);
      q.el = _mix(q.sl, q.wl, .5);
      q.er = _mix(q.sr, q.wr, .5);
      return _shiftPose(q, Offset(.05 * math.sin(angle), 0));
    case ExerciseMotion.lateralRaiseLeft:
      p.support = const Rect.fromLTWH(.13, .65, .20, .025);
      p.supportBack = true;
      p.wl = const Offset(.15, .36);
      p.el = _joint(p.sl, p.wl, .15, .15, -1);
      p.ar = Offset(.58 + .24 * wave, .86 - .08 * wave);
      p.kr = _mix(p.hr, p.ar, .5);
      p.wr = const Offset(.61, .56);
      p.er = _mix(p.sr, p.wr, .5);
    case ExerciseMotion.sideForwardLeft:
      final q = _pose(ExerciseMotion.bottomLegLiftRight, 0);
      q.kl = const Offset(.65, .78);
      q.al = const Offset(.55, .84);
      q.kr = Offset(.64, .65 - .08 * wave);
      q.ar = Offset(.76, .72 - .18 * wave);
      return _mirrorPose(q);
    case ExerciseMotion.lyingKneeHug:
      final q = _pose(ExerciseMotion.abdominalCrunch, 0);
      final left = (1 + math.sin(angle)) / 2;
      q.kl = _mix(const Offset(.72, .72), const Offset(.43, .59), left);
      q.kr = _mix(const Offset(.74, .70), const Offset(.45, .57), 1 - left);
      q.al = q.kl + const Offset(.17, .10);
      q.ar = q.kr + const Offset(.17, .10);
      q.wl = _mix(q.kr, q.kl, left) + const Offset(.03, .01);
      q.wr = q.wl + const Offset(.02, -.02);
      q.el = _joint(q.sl, q.wl, .14, .14, -1);
      q.er = _joint(q.sr, q.wr, .14, .14, -1);
      return q;
    case ExerciseMotion.legInOuts:
      final q = _pose(ExerciseMotion.crunchKicks, progress);
      q.sl = const Offset(.36, .61);
      q.sr = const Offset(.38, .59);
      q.neck = const Offset(.335, .58);
      q.head = const Offset(.29, .53);
      q.wl = const Offset(.29, .84);
      q.wr = const Offset(.31, .82);
      q.el = _joint(q.sl, q.wl, .14, .14, 1);
      q.er = _joint(q.sr, q.wr, .14, .14, 1);
      return q;
    case ExerciseMotion.lumbarCatCow:
      return _pose(ExerciseMotion.catCow, progress);
    case ExerciseMotion.mountainClimber:
      final q = _pose(ExerciseMotion.crossbodyClimber, progress);
      q.kl += Offset(-.035 * math.max(0.0, math.sin(angle)), 0);
      q.kr += Offset(.035 * math.max(0.0, -math.sin(angle)), 0);
      return q;
    case ExerciseMotion.modifiedBurpee:
    case ExerciseMotion.modifiedBurpeeTimed:
      final frames = [
        _pose(ExerciseMotion.burpees, 0),
        _pose(ExerciseMotion.burpees, .2),
        _pose(ExerciseMotion.burpees, .4),
        _pose(ExerciseMotion.burpees, .2),
        _pose(ExerciseMotion.burpees, 0),
      ];
      final scaled = progress.clamp(0.0, 1.0) * 4;
      final index = scaled.floor().clamp(0, 3);
      final t = scaled - index;
      return _blendPose(frames[index], frames[index + 1], t * t * (3 - 2 * t));
    case ExerciseMotion.militaryPress:
      final q = _pose(ExerciseMotion.arnoldDumbbellPress, progress);
      q.wl = Offset(.31, .29 - .22 * wave);
      q.wr = Offset(.69, .29 - .22 * wave);
      q.el = _joint(q.sl, q.wl, .15, .15, -1);
      q.er = _joint(q.sr, q.wr, .15, .15, 1);
      return q;
    case ExerciseMotion.climberThrust:
      return progress < .5
          ? _pose(ExerciseMotion.mountainClimber, progress * 2)
          : _pose(ExerciseMotion.inOuts, (progress - .5) * 2);
    case ExerciseMotion.climberTimed:
      return _pose(ExerciseMotion.mountainClimber, progress);
    case ExerciseMotion.oneLegPushUp:
      final q = _pose(ExerciseMotion.diamondPushUp, progress);
      q.ar = const Offset(.08, .58);
      q.kr = _mix(q.hr, q.ar, .5);
      return q;
    case ExerciseMotion.obliqueVLeft:
    case ExerciseMotion.obliqueVRight:
      final q = _pose(ExerciseMotion.abdominalCrunch, progress);
      q.al = q.hl + _polar(.38, -.10 - .90 * wave);
      q.ar = q.al + const Offset(.025, -.02);
      q.kl = _mix(q.hl, q.al, .5);
      q.kr = _mix(q.hr, q.ar, .5);
      q.wl = q.head + const Offset(.01, .02);
      q.el = q.sl + const Offset(.06, -.08);
      q.wr = const Offset(.26, .84);
      q.er = _mix(q.sr, q.wr, .5);
      if (motion == ExerciseMotion.obliqueVRight) return _mirrorPose(q);
      return q;
    case ExerciseMotion.overheadClockwise:
    case ExerciseMotion.overheadCounter:
      final rotation = motion == ExerciseMotion.overheadClockwise
          ? angle
          : -angle;
      p.wl = const Offset(.49, .07) + _polar(.02, rotation);
      p.wr = p.wl + const Offset(.02, 0);
      p.el = _mix(p.sl, p.wl, .5);
      p.er = _mix(p.sr, p.wr, .5);
    case ExerciseMotion.obliqueCrossLeft:
    case ExerciseMotion.obliqueCrossRight:
      final q = _pose(ExerciseMotion.abdominalCrunch, progress);
      q.kl = const Offset(.66, .56);
      q.al = const Offset(.56, .65);
      q.kr = const Offset(.70, .61);
      q.ar = const Offset(.82, .84);
      q.wl = q.head + const Offset(.015, .02);
      q.wr = q.kl + const Offset(-.02, .02);
      q.el = q.sl + const Offset(.05, -.07);
      q.er = _joint(q.sr, q.wr, .15, .15, -1);
      if (motion == ExerciseMotion.obliqueCrossRight) return _mirrorPose(q);
      return q;
    case ExerciseMotion.obliqueReach:
      return _pose(ExerciseMotion.heelTouch, progress);
    case ExerciseMotion.offsetPushUp:
      final q = _pose(ExerciseMotion.pushUps, progress);
      q.support = const Rect.fromLTWH(.59, .82, .12, .025);
      q.wl = const Offset(.65, .80);
      q.wr = const Offset(.76, .84);
      q.el = _joint(q.sl, q.wl, .15, .15, 1);
      q.er = _joint(q.sr, q.wr, .15, .15, -1);
      return q;
    case ExerciseMotion.plank:
      return _pose(ExerciseMotion.crossKneePlank, 0);
    case ExerciseMotion.pushUps:
      final q = _pose(ExerciseMotion.diamondPushUp, progress);
      q.wl = const Offset(.66, .84);
      q.wr = const Offset(.75, .82);
      q.el = _joint(q.sl, q.wl, .15, .15, 1);
      q.er = _joint(q.sr, q.wr, .15, .15, -1);
      return q;
    case ExerciseMotion.pushRotation:
      return progress < .5
          ? _pose(ExerciseMotion.pushUps, progress * 2)
          : _pose(ExerciseMotion.plankRotationLeft, (progress - .5) * 2);
    case ExerciseMotion.plieSquat:
      p.toesOut = true;
      p.hl += Offset(0, .12 * wave);
      p.hr += Offset(0, .12 * wave);
      p.sl += Offset(0, .12 * wave);
      p.sr += Offset(0, .12 * wave);
      p.neck += Offset(0, .12 * wave);
      p.head += Offset(0, .12 * wave);
      p.al = const Offset(.20, .86);
      p.ar = const Offset(.80, .86);
      p.kl = _mix(_mix(p.hl, p.al, .5), const Offset(.24, .72), wave);
      p.kr = _mix(_mix(p.hr, p.ar, .5), const Offset(.76, .72), wave);
      p.wl = Offset(.49, .39 + .12 * wave);
      p.wr = p.wl + const Offset(.02, 0);
      p.el = _joint(p.sl, p.wl, .15, .15, 1);
      p.er = _joint(p.sr, p.wr, .15, .15, -1);
    case ExerciseMotion.plankTaps:
    case ExerciseMotion.plankLegUp:
    case ExerciseMotion.plankReach:
    case ExerciseMotion.plankJacks:
      final q = _pose(
        motion == ExerciseMotion.plankReach
            ? ExerciseMotion.plank
            : ExerciseMotion.diamondPushUp,
        0,
      );
      final left = math.max(0.0, math.sin(angle));
      final right = math.max(0.0, -math.sin(angle));
      if (motion == ExerciseMotion.plankTaps) {
        q.wl = _mix(q.wl, q.sr, left);
        q.wr = _mix(q.wr, q.sl, right);
        q.el = _joint(q.sl, q.wl, .15, .15, 1);
        q.er = _joint(q.sr, q.wr, .15, .15, 1);
      } else if (motion == ExerciseMotion.plankLegUp) {
        q.al = _mix(q.al, const Offset(.07, .56), left);
        q.ar = _mix(q.ar, const Offset(.09, .54), right);
        q.kl = _mix(q.hl, q.al, .5);
        q.kr = _mix(q.hr, q.ar, .5);
      } else if (motion == ExerciseMotion.plankReach) {
        q.wl = _mix(q.wl, const Offset(.95, .51), left);
        q.wr = _mix(q.wr, const Offset(.96, .49), right);
        q.el = _mix(q.el, _mix(q.sl, q.wl, .5), left);
        q.er = _mix(q.er, _mix(q.sr, q.wr, .5), right);
      } else {
        q.al += Offset(-.035 * wave, -.07 * wave);
        q.ar += Offset(.12 * wave, 0);
        q.kl = _mix(q.hl, q.al, .5);
        q.kr = _mix(q.hr, q.ar, .5);
      }
      return q;
    case ExerciseMotion.proneTriceps:
      return _pose(ExerciseMotion.cobras, progress);
    case ExerciseMotion.pikePushUp:
      final q = _pose(ExerciseMotion.downDog, 0);
      q.sl += Offset(.025 * wave, .07 * wave);
      q.sr += Offset(.025 * wave, .07 * wave);
      q.neck += Offset(0, .07 * wave);
      q.head += Offset(0, .07 * wave);
      q.el = _joint(q.sl, q.wl, .15, .15, 1);
      q.er = _joint(q.sr, q.wr, .15, .15, 1);
      return q;
    case ExerciseMotion.clamRight:
    case ExerciseMotion.clamLeft:
      final q = _pose(ExerciseMotion.bottomLegLiftRight, 0);
      q.kl = const Offset(.67, .78);
      q.al = const Offset(.57, .84);
      q.kr = Offset(.68, .76 - .15 * wave);
      q.ar = const Offset(.59, .82);
      if (motion == ExerciseMotion.clamLeft) return _mirrorPose(q);
      return q;
    case ExerciseMotion.pistolLeft:
    case ExerciseMotion.pistolRight:
      p.side = true;
      p.support = const Rect.fromLTWH(.22, .66, .30, .025);
      p.supportBack = true;
      p.hl = Offset(.48, .54 + .10 * wave);
      p.hr = p.hl + const Offset(.02, -.02);
      p.sl = p.hl + Offset(.02 + .03 * wave, -.25);
      p.sr = p.sl + const Offset(.02, -.02);
      p.neck = p.sl + const Offset(.01, -.04);
      p.head = p.neck + const Offset(.01, -.07);
      p.al = const Offset(.65, .86);
      p.kl = _mix(_mix(p.hl, p.al, .5), const Offset(.69, .69), wave);
      p.ar = Offset(.85, .70 - .05 * wave);
      p.kr = _mix(p.hr, p.ar, .5);
      p.wl = Offset(.77, .42 + .10 * wave);
      p.wr = p.wl + const Offset(.02, -.02);
      p.el = _mix(p.sl, p.wl, .5);
      p.er = _mix(p.sr, p.wr, .5);
      if (motion == ExerciseMotion.pistolRight) return _mirrorPose(p);
    case ExerciseMotion.proneFlutter:
      final q = _pose(ExerciseMotion.backBowPulls, 0);
      q.al = Offset(.10, .82 - .07 * math.max(0.0, math.sin(angle)));
      q.ar = Offset(.12, .80 - .07 * math.max(0.0, -math.sin(angle)));
      q.kl = _mix(q.hl, q.al, .5);
      q.kr = _mix(q.hr, q.ar, .5);
      return q;
    case ExerciseMotion.plankHipDips:
      final q = _pose(ExerciseMotion.plank, 0);
      q.hl += Offset(.03 * math.sin(angle), .04 * wave);
      q.hr += Offset(-.03 * math.sin(angle), .04 * wave);
      q.kl = _mix(q.hl, q.al, .5);
      q.kr = _mix(q.hr, q.ar, .5);
      return q;
    case ExerciseMotion.pigeonLeft:
    case ExerciseMotion.pigeonRight:
      p.floor = true;
      p.side = true;
      p.hl = const Offset(.45, .72);
      p.hr = const Offset(.47, .70);
      p.sl = const Offset(.61, .60);
      p.sr = const Offset(.63, .58);
      p.neck = const Offset(.65, .56);
      p.head = const Offset(.72, .51);
      p.kl = const Offset(.62, .81);
      p.al = const Offset(.40, .84);
      p.ar = const Offset(.13, .84);
      p.kr = _mix(p.hr, p.ar, .5);
      p.wl = const Offset(.73, .84);
      p.wr = const Offset(.76, .82);
      p.el = _mix(p.sl, p.wl, .5);
      p.er = _mix(p.sr, p.wr, .5);
      if (motion == ExerciseMotion.pigeonLeft) return _mirrorPose(p);
    case ExerciseMotion.pushHold:
      return _pose(ExerciseMotion.pushUps, .5);
    case ExerciseMotion.quickFeet:
      final step = math.sin(angle * 3);
      p.hl += const Offset(0, .035);
      p.hr += const Offset(0, .035);
      p.sl += const Offset(0, .035);
      p.sr += const Offset(0, .035);
      p.head += const Offset(0, .035);
      p.neck += const Offset(0, .035);
      p.al = Offset(.39, .86 - .035 * math.max(0.0, step));
      p.ar = Offset(.61, .86 - .035 * math.max(0.0, -step));
      p.kl = Offset(.40, .73 - .02 * math.max(0.0, step));
      p.kr = Offset(.60, .73 - .02 * math.max(0.0, -step));
      p.wl = const Offset(.48, .37);
      p.wr = const Offset(.52, .37);
      p.el = _joint(p.sl, p.wl, .15, .15, 1);
      p.er = _joint(p.sr, p.wr, .15, .15, -1);
    case ExerciseMotion.quadStretch:
      final q = _pose(ExerciseMotion.quadWallLeft, 0);
      q.wall = false;
      q.wl = const Offset(.63, .53);
      q.el = _mix(q.sl, q.wl, .5);
      return q;
    case ExerciseMotion.reverseCrunch:
      final q = _pose(ExerciseMotion.crunch9090, 0);
      q.hl -= Offset(0, .08 * wave);
      q.hr -= Offset(0, .08 * wave);
      q.kl = Offset(.55 - .08 * wave, .55 - .04 * wave);
      q.kr = q.kl + const Offset(.02, -.02);
      q.al = Offset(.77 - .07 * wave, .56 - .07 * wave);
      q.ar = q.al + const Offset(.02, -.02);
      q.wl = const Offset(.48, .84);
      q.wr = const Offset(.50, .82);
      q.el = _mix(q.sl, q.wl, .5);
      q.er = _mix(q.sr, q.wr, .5);
      return q;
    case ExerciseMotion.russianTwist:
      final q = _pose(ExerciseMotion.legInOuts, 0);
      q.kl = const Offset(.70, .65);
      q.kr = const Offset(.72, .63);
      q.al = const Offset(.82, .82);
      q.ar = const Offset(.85, .80);
      q.wl = Offset(.52 + .14 * math.sin(angle), .65);
      q.wr = q.wl + const Offset(.02, -.02);
      q.el = _joint(q.sl, q.wl, .15, .15, 1);
      q.er = _joint(q.sr, q.wr, .15, .15, 1);
      q.sl += Offset(.025 * math.sin(angle), 0);
      q.sr += Offset(.025 * math.sin(angle), 0);
      return q;
    case ExerciseMotion.lungeHopsRight:
      return _mirrorPose(_pose(ExerciseMotion.lungeHopsLeft, progress));
    case ExerciseMotion.reverseFlutter:
      p.floor = true;
      p.side = true;
      p.support = const Rect.fromLTWH(.40, .65, .45, .025);
      p.hl = const Offset(.45, .62);
      p.hr = const Offset(.47, .60);
      p.sl = const Offset(.70, .61);
      p.sr = const Offset(.72, .59);
      p.neck = const Offset(.75, .59);
      p.head = const Offset(.82, .57);
      p.wl = const Offset(.76, .86);
      p.wr = const Offset(.79, .84);
      p.el = _mix(p.sl, p.wl, .5);
      p.er = _mix(p.sr, p.wr, .5);
      p.al = Offset(.10, .63 - .05 * math.max(0.0, math.sin(angle)));
      p.ar = Offset(.12, .61 - .05 * math.max(0.0, -math.sin(angle)));
      p.kl = _mix(p.hl, p.al, .5);
      p.kr = _mix(p.hr, p.ar, .5);
    case ExerciseMotion.reversePushUp:
      return _blendPose(
        _pose(ExerciseMotion.pushUps, .5),
        _pose(ExerciseMotion.downDog, 0),
        wave,
      );
    case ExerciseMotion.roundhouseSquat:
      final squat = math.max(0.0, math.sin(angle * 2));
      final kick = math.max(0.0, -math.sin(angle * 2));
      p.hl += Offset(0, .12 * squat);
      p.hr += Offset(0, .12 * squat);
      p.sl += Offset(0, .12 * squat);
      p.sr += Offset(0, .12 * squat);
      p.head += Offset(0, .12 * squat);
      p.neck += Offset(0, .12 * squat);
      p.al = const Offset(.36, .86);
      p.ar = const Offset(.64, .86);
      p.kl = _mix(_mix(p.hl, p.al, .5), const Offset(.28, .74), squat);
      p.kr = _mix(_mix(p.hr, p.ar, .5), const Offset(.72, .74), squat);
      if (progress < .5) {
        p.al = _mix(p.al, const Offset(.08, .58), kick);
        p.kl = _mix(p.kl, const Offset(.28, .58), kick);
      } else {
        p.ar = _mix(p.ar, const Offset(.92, .58), kick);
        p.kr = _mix(p.kr, const Offset(.72, .58), kick);
      }
      p.wl = Offset(.48, .38 + .10 * squat);
      p.wr = p.wl + const Offset(.04, 0);
      p.el = _joint(p.sl, p.wl, .15, .15, 1);
      p.er = _joint(p.sr, p.wr, .15, .15, -1);
    case ExerciseMotion.quadWallRight:
      return _mirrorPose(_pose(ExerciseMotion.quadWallLeft, 0));
    case ExerciseMotion.reverseCrunchRaised:
      return _pose(ExerciseMotion.heelsHeavens, progress);
    case ExerciseMotion.lateralRaiseRight:
      return _mirrorPose(_pose(ExerciseMotion.lateralRaiseLeft, progress));
    case ExerciseMotion.sideForwardRight:
      return _mirrorPose(_pose(ExerciseMotion.sideForwardLeft, progress));
    case ExerciseMotion.straightPlank:
      return _pose(ExerciseMotion.diamondPushUp, 0);
    case ExerciseMotion.sideLunges:
      return _pose(ExerciseMotion.adductorStretch, progress);
    case ExerciseMotion.sideLyingRight:
      return _pose(ExerciseMotion.lyingSwingRight, progress);
    case ExerciseMotion.sideLyingLeft:
      return _pose(ExerciseMotion.lyingSwingLeft, progress);
    case ExerciseMotion.squatKicks:
      return _pose(ExerciseMotion.flutterSquats, progress);
    case ExerciseMotion.standingBicycle:
      return _pose(ExerciseMotion.kneeElbow, progress);
    case ExerciseMotion.floorStretchLeft:
      return _pose(ExerciseMotion.lyingSwingLeft, 0);
    case ExerciseMotion.floorStretchRight:
      return _pose(ExerciseMotion.lyingSwingRight, 0);
    case ExerciseMotion.lumbarTwistLeft:
      return _pose(ExerciseMotion.bentLegTwist, .25);
    case ExerciseMotion.lumbarTwistRight:
      return _pose(ExerciseMotion.bentLegTwist, .75);
    case ExerciseMotion.sumoSquat:
      return _pose(ExerciseMotion.plieSquat, progress);
    case ExerciseMotion.sideCrunchLeft:
      return _pose(ExerciseMotion.armCurlsCrunchLeft, progress);
    case ExerciseMotion.sideCrunchRight:
      return _pose(ExerciseMotion.armCurlsCrunchRight, progress);
    case ExerciseMotion.reclinedOblique:
      final q = _pose(ExerciseMotion.altVUp, progress);
      q.wl = _mix(q.wl, q.ar, .45);
      q.wr = q.wl + const Offset(.02, -.02);
      q.el = _mix(q.sl, q.wl, .5);
      q.er = _mix(q.sr, q.wr, .5);
      q.sl += Offset(.025 * math.sin(angle), 0);
      q.sr += Offset(.025 * math.sin(angle), 0);
      return q;
    case ExerciseMotion.reclinedRhomboid:
      final q = _pose(ExerciseMotion.legInOuts, 0);
      q.kl = const Offset(.70, .65);
      q.kr = const Offset(.72, .63);
      q.al = const Offset(.82, .84);
      q.ar = const Offset(.84, .82);
      q.wl = _mix(const Offset(.63, .58), const Offset(.43, .49), wave);
      q.wr = q.wl + const Offset(.02, -.02);
      q.el = _joint(q.sl, q.wl, .15, .15, 1);
      q.er = _joint(q.sr, q.wr, .15, .15, 1);
      return q;
    case ExerciseMotion.rhomboidPull:
      p.el = Offset(.34 - .05 * wave, .41);
      p.er = Offset(.66 + .05 * wave, .41);
      p.wl = _mix(const Offset(.49, .32), const Offset(.26, .28), wave);
      p.wr = _mix(const Offset(.51, .32), const Offset(.74, .28), wave);
    case ExerciseMotion.snowAngels:
      final q = _pose(ExerciseMotion.backBowPulls, 0);
      q.wl = q.sl + _polar(.25, -math.pi * wave);
      q.wr = q.sr + _polar(.25, -math.pi * wave);
      q.el = _mix(q.sl, q.wl, .5);
      q.er = _mix(q.sr, q.wr, .5);
      return q;
    case ExerciseMotion.reverseFlys:
      final q = _pose(ExerciseMotion.bentOverRow, 0);
      q.wl = _mix(const Offset(.65, .65), const Offset(.37, .35), wave);
      q.wr = _mix(const Offset(.67, .63), const Offset(.88, .30), wave);
      q.el = _mix(q.sl, q.wl, .5);
      q.er = _mix(q.sr, q.wr, .5);
      return q;
    case ExerciseMotion.reversePlank:
      final q = _pose(ExerciseMotion.crabKicks, 0);
      q.hl = const Offset(.55, .69);
      q.hr = const Offset(.57, .67);
      q.al = const Offset(.90, .84);
      q.ar = const Offset(.92, .82);
      q.kl = _mix(q.hl, q.al, .5);
      q.kr = _mix(q.hr, q.ar, .5);
      return q;
    case ExerciseMotion.runnerLeft:
    case ExerciseMotion.runnerRight:
      final q = _pose(ExerciseMotion.spiderLunges, .25);
      q.sl += const Offset(0, .06);
      q.sr += const Offset(0, .06);
      q.head += const Offset(0, .07);
      q.neck += const Offset(0, .07);
      q.el = const Offset(.65, .84);
      q.wl = const Offset(.80, .84);
      q.er = const Offset(.67, .82);
      q.wr = const Offset(.82, .82);
      if (motion == ExerciseMotion.runnerLeft) return _mirrorPose(q);
      return q;
    case ExerciseMotion.sitUps:
    case ExerciseMotion.sitUpTwist:
      final q = _pose(ExerciseMotion.abdominalCrunch, 0);
      final curl = math.pi + .95 * wave;
      q.sl = q.hl + _polar(.25, curl);
      q.sr = q.sl + const Offset(.02, -.02);
      q.neck = q.hl + _polar(.29, curl);
      q.head = q.hl + _polar(.36, curl);
      q.wl = q.head + const Offset(.01, .02);
      q.wr = q.wl + const Offset(.02, -.02);
      q.el = q.sl + const Offset(.07, -.07);
      q.er = q.sr + const Offset(.09, -.07);
      if (motion == ExerciseMotion.sitUpTwist) {
        final turn = .05 * math.sin(angle);
        q.sl += Offset(turn, 0);
        q.sr += Offset(turn, 0);
        q.wl += Offset(turn, 0);
        q.wr += Offset(turn, 0);
        q.el += Offset(turn, 0);
        q.er += Offset(turn, 0);
      }
      return q;
    case ExerciseMotion.stepChair:
      p.side = true;
      p.support = const Rect.fromLTWH(.54, .66, .28, .025);
      final up = wave;
      p.hl = Offset(.45 + .12 * up, .55 - .16 * up);
      p.hr = p.hl + const Offset(.02, -.02);
      p.sl = p.hl + const Offset(.02, -.22);
      p.sr = p.sl + const Offset(.02, -.02);
      p.neck = p.sl + const Offset(.01, -.035);
      p.head = p.neck + const Offset(.01, -.06);
      p.al = const Offset(.65, .64);
      p.ar = _mix(const Offset(.35, .86), const Offset(.61, .64), up);
      p.kl = _joint(p.hl, p.al, .19, .20, -1);
      p.kr = _joint(p.hr, p.ar, .20, .20, 1);
      p.wl = p.sl + const Offset(.03, .25);
      p.wr = p.sr + const Offset(.03, .25);
      p.el = _mix(p.sl, p.wl, .5);
      p.er = _mix(p.sr, p.wr, .5);
    case ExerciseMotion.squats:
    case ExerciseMotion.squatReach:
    case ExerciseMotion.squatPulses:
      final depth = motion == ExerciseMotion.squatPulses
          ? .78 + .07 * math.sin(angle * 2)
          : wave;
      p.hl += Offset(0, .13 * depth);
      p.hr += Offset(0, .13 * depth);
      p.sl += Offset(0, .13 * depth);
      p.sr += Offset(0, .13 * depth);
      p.neck += Offset(0, .13 * depth);
      p.head += Offset(0, .13 * depth);
      p.al = const Offset(.34, .86);
      p.ar = const Offset(.66, .86);
      p.kl = _mix(_mix(p.hl, p.al, .5), const Offset(.29, .74), depth);
      p.kr = _mix(_mix(p.hr, p.ar, .5), const Offset(.71, .74), depth);
      p.wl = Offset(.49, .39 + .13 * depth);
      p.wr = p.wl + const Offset(.02, 0);
      if (motion == ExerciseMotion.squatReach) {
        p.wl = _mix(const Offset(.38, .08), const Offset(.49, .73), depth);
        p.wr = _mix(const Offset(.62, .08), const Offset(.51, .73), depth);
      }
      p.el = _joint(p.sl, p.wl, .15, .15, 1);
      p.er = _joint(p.sr, p.wr, .15, .15, -1);
      if (motion == ExerciseMotion.squatReach) {
        final reach = math.pow(1 - depth, 2).toDouble();
        p.el = _mix(p.el, _mix(p.sl, p.wl, .5), reach);
        p.er = _mix(p.er, _mix(p.sr, p.wr, .5), reach);
      }
    case ExerciseMotion.sidePlankRight:
    case ExerciseMotion.sidePlankLeft:
    case ExerciseMotion.sideBridgeLeft:
    case ExerciseMotion.sideBridgeRight:
    case ExerciseMotion.sideRaiseLeft:
    case ExerciseMotion.sideRaiseRight:
    case ExerciseMotion.sideKickLeft:
    case ExerciseMotion.sideKickRight:
      final q = _pose(ExerciseMotion.plankRotationLeft, .5);
      q.wr = q.hr;
      q.er = q.sr + const Offset(-.10, -.08);
      if (motion == ExerciseMotion.sideBridgeLeft ||
          motion == ExerciseMotion.sideBridgeRight) {
        q.hl += Offset(0, .10 * wave);
        q.hr += Offset(0, .10 * wave);
        q.wr = q.hr;
        q.kl = _mix(q.hl, q.al, .5);
        q.kr = _mix(q.hr, q.ar, .5);
      } else if (motion == ExerciseMotion.sideRaiseLeft ||
          motion == ExerciseMotion.sideRaiseRight) {
        q.ar = _mix(const Offset(.15, .82), const Offset(.10, .48), wave);
        q.kr = _mix(q.hr, q.ar, .5);
      } else if (motion == ExerciseMotion.sideKickLeft ||
          motion == ExerciseMotion.sideKickRight) {
        q.ar = _mix(const Offset(.15, .82), const Offset(.56, .64), wave);
        q.kr = _mix(const Offset(.29, .69), const Offset(.47, .57), wave);
      }
      q.er = _joint(q.sr, q.wr, .17, .17, -1);
      final left =
          motion == ExerciseMotion.sidePlankLeft ||
          motion == ExerciseMotion.sideBridgeLeft ||
          motion == ExerciseMotion.sideRaiseLeft ||
          motion == ExerciseMotion.sideKickLeft;
      return left ? _mirrorPose(q) : q;
    case ExerciseMotion.splitRight:
    case ExerciseMotion.splitLeft:
      final q = _pose(ExerciseMotion.backwardLungeKickRight, progress / 2);
      q.al = const Offset(.65, .86);
      q.ar = const Offset(.22, .86);
      q.kl = _joint(q.hl, q.al, .21, .21, -1);
      q.kr = _joint(q.hr, q.ar, .22, .22, 1);
      if (motion == ExerciseMotion.splitLeft) return _mirrorPose(q);
      return q;
    case ExerciseMotion.staggeredPush:
      final q = _pose(ExerciseMotion.pushUps, progress);
      q.wl = const Offset(.60, .84);
      q.wr = const Offset(.81, .82);
      q.el = _joint(q.sl, q.wl, .15, .15, 1);
      q.er = _joint(q.sr, q.wr, .15, .15, -1);
      return q;
    case ExerciseMotion.spidermanPush:
      final q = _pose(ExerciseMotion.pushUps, progress);
      q.kr = _mix(q.kr, const Offset(.70, .70), wave);
      q.ar = _mix(q.ar, const Offset(.52, .81), wave);
      return q;
    case ExerciseMotion.standingGlute:
    case ExerciseMotion.standingGluteLeft:
    case ExerciseMotion.standingGluteRight:
      p.side = true;
      p.sl = const Offset(.50, .30);
      p.sr = const Offset(.52, .29);
      p.hl = const Offset(.48, .55);
      p.hr = const Offset(.50, .54);
      p.head = const Offset(.52, .19);
      p.neck = const Offset(.515, .265);
      final lift = motion == ExerciseMotion.standingGlute
          ? (1 - math.cos(angle * 2)) / 2
          : wave;
      p.al = _mix(const Offset(.42, .86), const Offset(.23, .74), lift);
      p.kl = _mix(p.hl, p.al, .5);
      p.ar = const Offset(.57, .86);
      p.kr = _mix(p.hr, p.ar, .5);
      p.wl = const Offset(.48, .53);
      p.wr = const Offset(.55, .52);
      p.el = _joint(p.sl, p.wl, .15, .14, 1);
      p.er = _joint(p.sr, p.wr, .15, .14, -1);
      if (motion == ExerciseMotion.standingGluteRight ||
          (motion == ExerciseMotion.standingGlute && progress >= .5)) {
        return _mirrorPose(p);
      }
    case ExerciseMotion.sumoCalf:
    case ExerciseMotion.sumoCalfWall:
      final q = _pose(ExerciseMotion.plieSquat, .5);
      _shiftPose(q, Offset(0, -.025 * wave));
      q.heelLift = .025 * wave;
      if (motion == ExerciseMotion.sumoCalfWall) {
        q.wall = true;
        q.wl = const Offset(.82, .40);
        q.wr = const Offset(.82, .43);
        q.el = _joint(q.sl, q.wl, .18, .18, 1);
        q.er = _joint(q.sr, q.wr, .18, .18, 1);
      }
      return q;
    case ExerciseMotion.sumoLeg:
      final q = _pose(ExerciseMotion.plieSquat, progress);
      final lift = math.pow(math.max(0.0, math.cos(angle)), 4).toDouble();
      q.ar += Offset(.10 * lift, -.13 * lift);
      q.kr = _mix(q.hr, q.ar, .5);
      return q;
    case ExerciseMotion.singleCalfLeft:
    case ExerciseMotion.singleCalfRight:
    case ExerciseMotion.calfHopLeft:
    case ExerciseMotion.calfHopRight:
      final q = _pose(ExerciseMotion.calfRaises, progress);
      q.wall = true;
      q.side = true;
      q.kl = const Offset(.44, .70);
      q.al = const Offset(.30, .68);
      q.wl = const Offset(.82, .32);
      q.el = _joint(q.sl, q.wl, .18, .18, 1);
      q.wr = const Offset(.55, .53);
      q.er = _mix(q.sr, q.wr, .5);
      if (motion == ExerciseMotion.calfHopLeft ||
          motion == ExerciseMotion.calfHopRight) {
        q.wall = false;
        q.wl = const Offset(.48, .41);
        q.el = _joint(q.sl, q.wl, .15, .14, 1);
        _shiftPose(q, Offset(0, -.055 * math.sin(angle).abs()));
      }
      if (motion == ExerciseMotion.singleCalfLeft ||
          motion == ExerciseMotion.calfHopLeft) {
        return _mirrorPose(q);
      }
      return q;
    case ExerciseMotion.sideCircleLeft:
    case ExerciseMotion.sideCircleRight:
      final q = _pose(ExerciseMotion.lyingSwingRight, 0);
      q.ar =
          const Offset(.87, .66) +
          Offset(.03 * math.cos(angle), .05 * math.sin(angle));
      q.kr = _mix(q.hr, q.ar, .5);
      if (motion == ExerciseMotion.sideCircleLeft) return _mirrorPose(q);
      return q;
    case ExerciseMotion.scissors:
      final q = _pose(ExerciseMotion.legRaises, .5);
      q.al = Offset(.58 + .11 * math.sin(angle), .40);
      q.ar = Offset(.60 - .11 * math.sin(angle), .38);
      q.kl = _mix(q.hl, q.al, .5);
      q.kr = _mix(q.hr, q.ar, .5);
      return q;
    case ExerciseMotion.skater:
      final side = math.sin(angle);
      p.al = Offset(
        .43 + .10 * math.max(0.0, side),
        .86 - .08 * math.max(0.0, side),
      );
      p.ar = Offset(
        .57 - .10 * math.max(0.0, -side),
        .86 - .08 * math.max(0.0, -side),
      );
      p.kl = _mix(p.hl, p.al, .5) + const Offset(0, .035);
      p.kr = _mix(p.hr, p.ar, .5) + const Offset(0, .035);
      p.wl = Offset(.50 - .08 * side, .39);
      p.wr = Offset(.50 - .10 * side, .44);
      p.el = _joint(p.sl, p.wl, .15, .14, 1);
      p.er = _joint(p.sr, p.wr, .15, .14, -1);
      return _shiftPose(p, Offset(.12 * side, 0));
    case ExerciseMotion.sideHop:
      return _shiftPose(
        _pose(ExerciseMotion.hops, progress),
        Offset(.12 * math.sin(angle), 0),
      );
    case ExerciseMotion.superman:
    case ExerciseMotion.swimmerSuperman:
      final q = _pose(ExerciseMotion.backBowPulls, 0);
      final alternate = motion == ExerciseMotion.swimmerSuperman;
      final paired = (1 - math.cos(angle * 2)) / 2;
      final left = !alternate
          ? wave
          : progress < .5
          ? math.max(0.0, math.sin(angle * 2))
          : paired;
      final right = !alternate
          ? wave
          : progress < .5
          ? math.max(0.0, -math.sin(angle * 2))
          : paired;
      q.sl -= Offset(0, .08 * wave);
      q.sr -= Offset(0, .08 * wave);
      q.neck -= Offset(0, .09 * wave);
      q.head -= Offset(0, .10 * wave);
      q.al = Offset(.10, .84 - .12 * right);
      q.ar = Offset(.12, .82 - .12 * left);
      q.kl = _mix(q.hl, q.al, .5);
      q.kr = _mix(q.hr, q.ar, .5);
      q.wl = Offset(.94, .78 - .10 * left);
      q.wr = Offset(.92, .76 - .10 * right);
      q.el = _mix(q.sl, q.wl, .5);
      q.er = _mix(q.sr, q.wr, .5);
      return q;
    case ExerciseMotion.seatedShrugs:
      final q = _seatedPose();
      q.sl -= Offset(0, .035 * wave);
      q.sr -= Offset(0, .035 * wave);
      q.el = _joint(q.sl, q.wl, .18, .17, 1);
      q.er = _joint(q.sr, q.wr, .18, .17, -1);
      return q;
    case ExerciseMotion.shoulderStretch:
      p.wl = const Offset(.66, .35);
      p.el = const Offset(.52, .35);
      p.wr = const Offset(.51, .35);
      p.er = const Offset(.69, .40);
    case ExerciseMotion.singleHipRotation:
      p.kl =
          const Offset(.42, .58) +
          Offset(.08 * math.cos(angle), .025 * math.sin(angle));
      p.al = p.kl + const Offset(.01, .16);
      p.ar = const Offset(.59, .86);
      p.kr = _mix(p.hr, p.ar, .5);
      p.wl = const Offset(.46, .53);
      p.wr = const Offset(.55, .52);
      p.el = _joint(p.sl, p.wl, .15, .14, 1);
      p.er = _joint(p.sr, p.wr, .15, .14, -1);
    case ExerciseMotion.supinePush:
      final q = _pose(ExerciseMotion.abdominalCrunch, 0);
      q.sl -= Offset(0, .06 * wave);
      q.sr -= Offset(0, .06 * wave);
      q.neck -= Offset(0, .07 * wave);
      q.head -= Offset(0, .08 * wave);
      q.el = const Offset(.40, .84);
      q.er = const Offset(.42, .82);
      q.wl = const Offset(.40, .68);
      q.wr = const Offset(.42, .66);
      return q;
    case ExerciseMotion.standingSideBend:
      final lean = .09 * math.sin(angle);
      p.sl += Offset(lean, 0);
      p.sr += Offset(lean, 0);
      p.neck += Offset(lean, 0);
      p.head += Offset(lean * 1.4, .02 * lean.abs());
      p.wl = p.head + const Offset(-.05, .01);
      p.el = p.sl + const Offset(-.12, .04);
      p.wr = p.sr + const Offset(.02, .27);
      p.er = _mix(p.sr, p.wr, .5);
    case ExerciseMotion.shoulderGators:
      p.wl = const Offset(.45, .22);
      p.wr = const Offset(.55, .22);
      p.el = Offset(.30 + .15 * wave, .32);
      p.er = Offset(.70 - .15 * wave, .32);
    case ExerciseMotion.bicepsLeft:
    case ExerciseMotion.bicepsRight:
      p.side = true;
      p.wall = true;
      p.wl = const Offset(.82, .38);
      p.el = _mix(p.sl, p.wl, .5);
      p.wr = const Offset(.45, .55);
      p.er = _mix(p.sr, p.wr, .5);
      if (motion == ExerciseMotion.bicepsRight) return _mirrorPose(p);
    case ExerciseMotion.skipping:
      final q = _pose(ExerciseMotion.hops, (progress * 2) % 1);
      q.wl = const Offset(.35, .57) + _polar(.02, angle * 2);
      q.wr = const Offset(.65, .57) + _polar(.02, angle * 2);
      q.el = _joint(q.sl, q.wl, .15, .14, 1);
      q.er = _joint(q.sr, q.wr, .15, .14, -1);
      return q;
    case ExerciseMotion.starCrawl:
      final q = _pose(ExerciseMotion.mountainClimber, progress);
      q.wl += Offset(.05 * math.max(0.0, math.sin(angle)), 0);
      q.wr += Offset(-.05 * math.max(0.0, -math.sin(angle)), 0);
      q.el = _mix(q.sl, q.wl, .5);
      q.er = _mix(q.sr, q.wr, .5);
      return q;
    case ExerciseMotion.shoulderOutward:
      p.chair = true;
      p.hl = const Offset(.46, .63);
      p.hr = const Offset(.54, .63);
      p.sl = const Offset(.44, .38);
      p.sr = const Offset(.56, .38);
      p.neck = const Offset(.50, .33);
      p.head = const Offset(.50, .26);
      p.kl = const Offset(.43, .66);
      p.kr = const Offset(.57, .66);
      p.al = const Offset(.43, .86);
      p.ar = const Offset(.57, .86);
      p.el = const Offset(.40, .50);
      p.er = const Offset(.60, .50);
      p.wl = Offset(.40 - .10 * wave, .35);
      p.wr = Offset(.60 + .10 * wave, .35);
    case ExerciseMotion.seatedBendRight:
    case ExerciseMotion.seatedBendLeft:
      final q = _seatedPose();
      q.sl += const Offset(.08, 0);
      q.sr += const Offset(.08, 0);
      q.neck += const Offset(.10, .01);
      q.head += const Offset(.13, .03);
      q.wl = const Offset(.66, .20);
      q.el = const Offset(.50, .18);
      q.wr = const Offset(.75, .84);
      q.er = _mix(q.sr, q.wr, .5);
      if (motion == ExerciseMotion.seatedBendLeft) return _mirrorPose(q);
      return q;
    case ExerciseMotion.seatedTwistRight:
    case ExerciseMotion.seatedTwistLeft:
      final q = _seatedPose();
      q.side = true;
      q.sl += const Offset(.04, 0);
      q.sr -= const Offset(.03, 0);
      q.head += const Offset(.03, 0);
      q.wl = const Offset(.68, .75);
      q.wr = const Offset(.35, .79);
      q.el = _mix(q.sl, q.wl, .5);
      q.er = _mix(q.sr, q.wr, .5);
      if (motion == ExerciseMotion.seatedTwistLeft) return _mirrorPose(q);
      return q;
    case ExerciseMotion.straightBounds:
      final q = _pose(ExerciseMotion.highStepping, progress);
      q.side = true;
      final left = math.max(0.0, math.sin(angle));
      final right = math.max(0.0, -math.sin(angle));
      q.al = q.hl + _polar(.31, math.pi / 2 - .7 * left);
      q.ar = q.hr + _polar(.31, math.pi / 2 - .7 * right);
      q.kl = _mix(q.hl, q.al, .5);
      q.kr = _mix(q.hr, q.ar, .5);
      return _shiftPose(q, Offset(0, -.04 * math.sin(angle).abs()));
    case ExerciseMotion.standingKneeChest:
      final q = _pose(ExerciseMotion.legCurlLeft, .5);
      q.wl = q.kl + const Offset(0, -.02);
      q.wr = q.wl + const Offset(.02, -.02);
      q.el = _joint(q.sl, q.wl, .15, .14, 1);
      q.er = _joint(q.sr, q.wr, .15, .14, 1);
      return q;
    case ExerciseMotion.hamstringLeft:
    case ExerciseMotion.hamstringRight:
      final q = _pose(ExerciseMotion.spineStretch, 0);
      q.kr = const Offset(.35, .78);
      q.ar = const Offset(.40, .83);
      if (motion == ExerciseMotion.hamstringRight) return _mirrorPose(q);
      return q;
    case ExerciseMotion.seatedButterfly:
      final q = _seatedPose();
      q.sl += const Offset(0, .04);
      q.sr += const Offset(0, .04);
      q.neck += const Offset(0, .04);
      q.head += const Offset(0, .04);
      q.kl = const Offset(.25, .80);
      q.kr = const Offset(.75, .80);
      q.al = const Offset(.49, .84);
      q.ar = const Offset(.51, .84);
      q.wl = const Offset(.48, .79);
      q.wr = const Offset(.52, .79);
      q.el = _joint(q.sl, q.wl, .18, .17, 1);
      q.er = _joint(q.sr, q.wr, .18, .17, -1);
      return q;
    case ExerciseMotion.starJumps:
      final q = _pose(ExerciseMotion.jumpingJacks, progress);
      q.wl = q.sl + _polar(.26, math.pi / 2 + wave * math.pi * .65);
      q.wr = q.sr + _polar(.26, math.pi / 2 - wave * math.pi * .65);
      q.el = _mix(q.sl, q.wl, .5);
      q.er = _mix(q.sr, q.wr, .5);
      return _shiftPose(q, Offset(0, -.06 * wave));
    case ExerciseMotion.sideLungesTimed:
      return _pose(ExerciseMotion.sideLunges, progress);
    case ExerciseMotion.swimmerTimed:
      return _pose(ExerciseMotion.swimmerSuperman, progress);
    case ExerciseMotion.straightKneePlank:
      return _pose(ExerciseMotion.kneePushUps, 0);
    case ExerciseMotion.spidermanPlankTimed:
      return _pose(ExerciseMotion.spidermanPlank, progress);
    case ExerciseMotion.slowClimber:
      return _pose(ExerciseMotion.mountainClimber, progress);
    case ExerciseMotion.plankPike:
      return _blendPose(
        _pose(ExerciseMotion.diamondPushUp, 0),
        _pose(ExerciseMotion.downDog, 0),
        wave,
      );
    case ExerciseMotion.vCrunch:
      return _pose(ExerciseMotion.legInOuts, progress);
    case ExerciseMotion.squatJacks:
      final q = _pose(ExerciseMotion.squats, progress);
      q.al = Offset(.46 - .18 * wave, .86);
      q.ar = Offset(.54 + .18 * wave, .86);
      q.kl = _mix(_mix(q.hl, q.al, .5), const Offset(.28, .74), wave);
      q.kr = _mix(_mix(q.hr, q.ar, .5), const Offset(.72, .74), wave);
      q.wl = q.sl + _polar(.26, math.pi / 2 + (1 - wave) * math.pi);
      q.wr = q.sr + _polar(.26, math.pi / 2 - (1 - wave) * math.pi);
      q.el = _mix(q.sl, q.wl, .5);
      q.er = _mix(q.sr, q.wr, .5);
      return _shiftPose(q, Offset(0, -.025 * math.sin(angle).abs()));
    case ExerciseMotion.supineHamLeft:
    case ExerciseMotion.supineHamRight:
      final q = _pose(ExerciseMotion.kneeChestLeft, 0);
      q.al = const Offset(.60, .39);
      q.kl = _mix(q.hl, q.al, .5);
      q.wl = const Offset(.56, .60);
      q.wr = q.wl + const Offset(.02, -.02);
      q.el = _joint(q.sl, q.wl, .14, .14, -1);
      q.er = _joint(q.sr, q.wr, .14, .14, -1);
      if (motion == ExerciseMotion.supineHamRight) return _mirrorPose(q);
      return q;
    case ExerciseMotion.straightRaiseLeft:
    case ExerciseMotion.straightRaiseRight:
      final q = _pose(ExerciseMotion.abdominalCrunch, 0);
      q.al = q.hl + _polar(.38, -.05 - 1.2 * wave);
      q.kl = _mix(q.hl, q.al, .5);
      q.wl = const Offset(.48, .84);
      q.wr = const Offset(.50, .82);
      q.el = _mix(q.sl, q.wl, .5);
      q.er = _mix(q.sr, q.wr, .5);
      if (motion == ExerciseMotion.straightRaiseRight) return _mirrorPose(q);
      return q;
    case ExerciseMotion.spidermanPlank:
      final q = _pose(ExerciseMotion.mountainClimber, progress);
      q.kl += Offset(
        .02 * math.max(0.0, math.sin(angle)),
        -.02 * math.max(0.0, math.sin(angle)),
      );
      q.kr += Offset(
        .02 * math.max(0.0, -math.sin(angle)),
        -.02 * math.max(0.0, -math.sin(angle)),
      );
      return q;
    case ExerciseMotion.sideKickbackLeft:
    case ExerciseMotion.sideKickbackRight:
      final q = _pose(ExerciseMotion.bottomLegLiftRight, 0);
      q.kl = const Offset(.65, .78);
      q.al = const Offset(.55, .84);
      q.kr = _mix(const Offset(.66, .66), const Offset(.71, .75), wave);
      q.ar = _mix(const Offset(.78, .70), const Offset(.92, .80), wave);
      if (motion == ExerciseMotion.sideKickbackLeft) return _mirrorPose(q);
      return q;
    case ExerciseMotion.hipCircle:
      final shift = _polar(.035, angle);
      p.hl += shift;
      p.hr += shift;
      p.kl = _mix(p.hl, p.al, .5);
      p.kr = _mix(p.hr, p.ar, .5);
      p.wl = p.hl + const Offset(-.02, 0);
      p.wr = p.hr + const Offset(.02, 0);
      p.el = _joint(p.sl, p.wl, .15, .14, 1);
      p.er = _joint(p.sr, p.wr, .15, .14, -1);
    case ExerciseMotion.deadliftLeft:
    case ExerciseMotion.deadliftRight:
      p.side = true;
      p.hl = const Offset(.48, .55);
      p.hr = const Offset(.50, .53);
      final tilt = -math.pi / 2 + .9 * wave;
      p.sl = p.hl + _polar(.25, tilt);
      p.sr = p.sl + const Offset(.02, -.02);
      p.neck = p.sl + _polar(.04, tilt);
      p.head = p.sl + _polar(.11, tilt);
      p.al = p.hl + _polar(.33, math.pi / 2 + 1.2 * wave);
      p.kl = _mix(p.hl, p.al, .5);
      p.ar = const Offset(.56, .86);
      p.kr = const Offset(.56, .71);
      p.wl = p.sl + const Offset(0, .27);
      p.wr = p.sr + const Offset(0, .27);
      p.el = _mix(p.sl, p.wl, .5);
      p.er = _mix(p.sr, p.wr, .5);
      if (motion == ExerciseMotion.deadliftRight) return _mirrorPose(p);
    case ExerciseMotion.sideKneeLeft:
    case ExerciseMotion.sideKneeRight:
      final q = _pose(ExerciseMotion.sidePlankRight, 0);
      q.ar = _mix(const Offset(.15, .82), const Offset(.50, .61), wave);
      q.kr = _mix(q.kr, const Offset(.50, .55), wave);
      q.wr = q.head + const Offset(-.02, .02);
      q.er = q.sr + const Offset(-.06, -.08);
      if (motion == ExerciseMotion.sideKneeLeft) return _mirrorPose(q);
      return q;
    case ExerciseMotion.starfishCrunch:
      final q = _pose(ExerciseMotion.abdominalCrunch, progress);
      final left = (1 + math.sin(angle)) / 2;
      q.al = q.hl + _polar(.38, -.12 - 1.0 * left);
      q.ar = q.hr + _polar(.38, -.12 - 1.0 * (1 - left));
      q.kl = _mix(q.hl, q.al, .5);
      q.kr = _mix(q.hr, q.ar, .5);
      q.wl = _mix(q.sl + _polar(.25, (q.sl - q.hl).direction), q.ar, wave * .8);
      q.wr = _mix(q.sr + const Offset(.08, -.22), q.al, wave * .8);
      q.el = _mix(q.sl, q.wl, .5);
      q.er = _mix(q.sr, q.wr, .5);
      return q;
    case ExerciseMotion.singleDrops:
      final q = _pose(ExerciseMotion.legRaises, .5);
      final left = (1 + math.sin(angle)) / 2;
      q.al = q.hl + _polar(.38, -math.pi / 2 + 1.2 * left);
      q.ar = q.hr + _polar(.38, -math.pi / 2 + 1.2 * (1 - left));
      q.kl = _mix(q.hl, q.al, .5);
      q.kr = _mix(q.hr, q.ar, .5);
      return q;
    case ExerciseMotion.crossoverToes:
      final q = _pose(ExerciseMotion.crossTouchReach, (progress * 2) % 1);
      return progress >= .5 ? _mirrorPose(q) : q;
    case ExerciseMotion.standingObliqueLeft:
    case ExerciseMotion.standingObliqueRight:
      p.kl = _mix(p.kl, const Offset(.32, .58), wave);
      p.al = _mix(p.al, const Offset(.35, .74), wave);
      p.sl += Offset(-.04 * wave, .025 * wave);
      p.sr += Offset(-.04 * wave, .025 * wave);
      p.neck += Offset(-.04 * wave, .025 * wave);
      p.head += Offset(-.05 * wave, .025 * wave);
      p.wl = _mix(const Offset(.40, .12), const Offset(.39, .22), wave);
      p.el = p.sl + Offset(-.10, .05 + .08 * wave);
      p.wr = const Offset(.55, .53);
      p.er = _joint(p.sr, p.wr, .15, .14, -1);
      if (motion == ExerciseMotion.standingObliqueRight) return _mirrorPose(p);
    case ExerciseMotion.stepJacks:
      final t = (progress * 2) % 1;
      final q = _pose(ExerciseMotion.jumpingJacks, t);
      _shiftPose(q, Offset(0, .02 * math.sin(angle * 4).abs()));
      final step = (1 - math.cos(angle * 2)) / 2;
      q.al = Offset(.46 - (progress < .5 ? .24 * step : 0), .86);
      q.ar = Offset(.54 + (progress >= .5 ? .24 * step : 0), .86);
      q.kl = _mix(q.hl, q.al, .5);
      q.kr = _mix(q.hr, q.ar, .5);
      return q;
    case ExerciseMotion.renegadeLeft:
    case ExerciseMotion.renegadeRight:
      final q = _pose(ExerciseMotion.diamondPushUp, 0);
      q.weights = true;
      q.wl = _mix(q.wl, q.hl + const Offset(.04, -.08), wave);
      q.el = _joint(q.sl, q.wl, .15, .15, -1);
      if (motion == ExerciseMotion.renegadeRight) return _mirrorPose(q);
      return q;
    case ExerciseMotion.seatedCatCow:
      final q = _seatedPose();
      q.side = true;
      q.hl = const Offset(.48, .70);
      q.hr = const Offset(.50, .68);
      q.sl = Offset(.48 + .03 * math.sin(angle), .42 + .015 * math.cos(angle));
      q.sr = q.sl + const Offset(.02, -.02);
      q.neck = Offset(.50 + .03 * math.sin(angle), .38 + .02 * math.sin(angle));
      q.head = Offset(.50 + .05 * math.sin(angle), .31 + .04 * math.sin(angle));
      q.backCurve = .05 * math.sin(angle);
      q.el = _mix(q.sl, q.wl, .5);
      q.er = _mix(q.sr, q.wr, .5);
      return q;
    case ExerciseMotion.chairDips:
      p.side = true;
      p.support = const Rect.fromLTWH(.17, .60, .28, .025);
      p.supportBack = true;
      p.hl = Offset(.56, .65 + .10 * wave);
      p.hr = p.hl + const Offset(.02, -.02);
      p.sl = Offset(.50, .39 + .10 * wave);
      p.sr = p.sl + const Offset(.02, -.02);
      p.neck = p.sl + const Offset(0, -.04);
      p.head = p.neck + const Offset(0, -.08);
      p.wl = const Offset(.42, .60);
      p.wr = const Offset(.44, .58);
      p.el = _joint(p.sl, p.wl, .14, .14, -1);
      p.er = _joint(p.sr, p.wr, .14, .14, -1);
      p.kl = Offset(.75, .65 + .02 * wave);
      p.kr = p.kl + const Offset(.02, -.02);
      p.al = const Offset(.77, .86);
      p.ar = const Offset(.80, .84);
    case ExerciseMotion.toySoldiers:
    case ExerciseMotion.toySoldiersTimed:
      p.side = true;
      p.sl = const Offset(.50, .30);
      p.sr = const Offset(.52, .28);
      p.hl = const Offset(.48, .55);
      p.hr = const Offset(.50, .53);
      p.head = const Offset(.52, .19);
      p.neck = const Offset(.515, .265);
      final left = math.max(0.0, math.sin(angle));
      final right = math.max(0.0, -math.sin(angle));
      p.al = p.hl + _polar(.31, math.pi / 2 - 1.4 * left);
      p.ar = p.hr + _polar(.31, math.pi / 2 - 1.4 * right);
      p.kl = _mix(p.hl, p.al, .5);
      p.kr = _mix(p.hr, p.ar, .5);
      p.wl = _mix(
        p.sl + const Offset(-.02, .27),
        p.ar + const Offset(0, -.04),
        .75 * right,
      );
      p.wr = _mix(
        p.sr + const Offset(-.02, .27),
        p.al + const Offset(0, -.04),
        .75 * left,
      );
      p.el = _mix(p.sl, p.wl, .5);
      p.er = _mix(p.sr, p.wr, .5);
    case ExerciseMotion.torsoTwist:
    case ExerciseMotion.trunkRotation:
      final turn =
          (motion == ExerciseMotion.trunkRotation ? .15 : .12) *
          math.sin(angle);
      p.sl += Offset(.025 * math.sin(angle), .015 * math.sin(angle));
      p.sr += Offset(.025 * math.sin(angle), -.015 * math.sin(angle));
      p.head += Offset(.025 * math.sin(angle), 0);
      p.neck += Offset(.025 * math.sin(angle), 0);
      p.wl = Offset(.49 + turn, .39);
      p.wr = p.wl + const Offset(.02, 0);
      p.el = _joint(p.sl, p.wl, .15, .14, 1);
      p.er = _joint(p.sr, p.wr, .15, .14, -1);
    case ExerciseMotion.tricepsKickback:
      final q = _pose(ExerciseMotion.dbKickbacks, progress);
      q.weights = false;
      return q;
    case ExerciseMotion.tricepsStretchLeft:
    case ExerciseMotion.tricepsStretchRight:
      p.wl = p.head + const Offset(.03, .06);
      p.el = const Offset(.47, .07);
      p.wr = p.el;
      p.er = const Offset(.68, .17);
      if (motion == ExerciseMotion.tricepsStretchRight) return _mirrorPose(p);
    case ExerciseMotion.triangleLeft:
    case ExerciseMotion.triangleRight:
      final q = _pose(ExerciseMotion.crossTouchReach, .5);
      if (motion == ExerciseMotion.triangleRight) return _mirrorPose(q);
      return q;
    case ExerciseMotion.tPlankLeft:
    case ExerciseMotion.tPlankRight:
      final q = _pose(ExerciseMotion.plankRotationLeft, progress);
      q.wl = const Offset(.65, .84);
      q.el = _mix(q.sl, q.wl, .5);
      q.wr = _mix(const Offset(.72, .82), const Offset(.66, .25), wave);
      q.er = _mix(q.sr, q.wr, .5);
      if (motion == ExerciseMotion.tPlankLeft) return _mirrorPose(q);
      return q;
    case ExerciseMotion.twistingPiston:
      final q = _pose(ExerciseMotion.inOuts, (progress * 2) % 1);
      final tuck = (1 - math.cos(angle * 2)) / 2;
      final direction = progress < .5 ? 1.0 : -1.0;
      q.hl += Offset(.035 * tuck * direction, 0);
      q.hr += Offset(.035 * tuck * direction, 0);
      q.kl += Offset(.07 * tuck * direction, 0);
      q.kr += Offset(.07 * tuck * direction, 0);
      q.al += Offset(.06 * tuck * direction, 0);
      q.ar += Offset(.06 * tuck * direction, 0);
      return q;
    case ExerciseMotion.needleLeft:
    case ExerciseMotion.needleRight:
      final q = _pose(ExerciseMotion.birdDog, 0);
      q.sl += Offset(0, .12 * wave);
      q.sr += Offset(0, .12 * wave);
      q.neck += Offset(0, .20 * wave);
      q.head += Offset(0, .26 * wave);
      q.wl = _mix(q.wl, const Offset(.47, .84), wave);
      q.el = _joint(q.sl, q.wl, .15, .15, 1);
      q.er = _mix(q.sr, q.wr, .5);
      if (motion == ExerciseMotion.needleRight) return _mirrorPose(q);
      return q;
    case ExerciseMotion.upDownPlank:
      final high = _pose(ExerciseMotion.diamondPushUp, 0);
      final low = _pose(ExerciseMotion.diamondPushUp, 0);
      low.sl += const Offset(0, .10);
      low.sr += const Offset(0, .10);
      low.hl += const Offset(0, .04);
      low.hr += const Offset(0, .04);
      low.head += const Offset(0, .10);
      low.neck += const Offset(0, .10);
      low.el = const Offset(.65, .84);
      low.er = const Offset(.67, .82);
      low.wl = const Offset(.82, .84);
      low.wr = const Offset(.84, .82);
      final first = _blendPose(high, low, .5);
      first.el = const Offset(.65, .84);
      first.wl = const Offset(.82, .84);
      first.wr = const Offset(.71, .82);
      first.er = _mix(first.sr, first.wr, .5);
      final second = _blendPose(high, low, .5);
      second.er = const Offset(.67, .82);
      second.wr = const Offset(.84, .82);
      second.wl = const Offset(.69, .84);
      second.el = _mix(second.sl, second.wl, .5);
      final frames = [high, first, low, second, high];
      final scaled = progress.clamp(0.0, 1.0) * 4;
      final index = scaled.floor().clamp(0, 3);
      final t = scaled - index;
      return _blendPose(frames[index], frames[index + 1], t * t * (3 - 2 * t));
    case ExerciseMotion.vUp:
      final q = _pose(ExerciseMotion.dbVUp, progress);
      q.weights = false;
      q.er = _mix(q.sr, q.wr, .5);
      return q;
    case ExerciseMotion.vHold:
      final q = _pose(ExerciseMotion.legInOuts, 0);
      q.al = q.hl + _polar(.38, -.45);
      q.ar = q.al + const Offset(.02, -.02);
      q.kl = _mix(q.hl, q.al, .5);
      q.kr = _mix(q.hr, q.ar, .5);
      q.wl = const Offset(.65, .62);
      q.wr = const Offset(.67, .60);
      q.el = _mix(q.sl, q.wl, .5);
      q.er = _mix(q.sr, q.wr, .5);
      return q;
    case ExerciseMotion.widePushUps:
      final q = _pose(ExerciseMotion.pushUps, progress);
      q.wl = const Offset(.60, .84);
      q.wr = const Offset(.82, .82);
      q.el = _joint(q.sl, q.wl, .15, .15, 1);
      q.er = _joint(q.sr, q.wr, .15, .15, -1);
      return q;
    case ExerciseMotion.wallSit:
      final q = _pose(ExerciseMotion.backArches, 0);
      q.chair = false;
      q.wall = true;
      q.wallX = .36;
      q.wl = const Offset(.63, .61);
      q.wr = const Offset(.65, .59);
      q.el = _mix(q.sl, q.wl, .5);
      q.er = _mix(q.sr, q.wr, .5);
      return q;
    case ExerciseMotion.wallCalf:
      final q = _pose(ExerciseMotion.calfRaises, progress);
      q.wall = true;
      q.side = true;
      final lift = q.heelLift;
      q.sl = Offset(.50, .31 - lift);
      q.sr = Offset(.52, .30 - lift);
      q.hl = Offset(.48, .55 - lift);
      q.hr = Offset(.50, .54 - lift);
      q.neck = Offset(.515, .265 - lift);
      q.head = Offset(.52, .19 - lift);
      q.al = Offset(.45, .86 - lift);
      q.ar = Offset(.49, .84 - lift);
      q.kl = _mix(q.hl, q.al, .5);
      q.kr = _mix(q.hr, q.ar, .5);
      q.wl = const Offset(.82, .32);
      q.wr = const Offset(.82, .30);
      q.el = _joint(q.sl, q.wl, .17, .17, 1);
      q.er = _joint(q.sr, q.wr, .17, .17, 1);
      return q;
    case ExerciseMotion.wallResistCalfLeft:
    case ExerciseMotion.wallResistCalfRight:
      final q = _pose(ExerciseMotion.wallPushUp, .1);
      q.wall = true;
      final lift = .025 * wave;
      q.sl -= Offset(0, lift);
      q.sr -= Offset(0, lift);
      q.hl -= Offset(0, lift);
      q.hr -= Offset(0, lift);
      q.head -= Offset(0, lift);
      q.neck -= Offset(0, lift);
      q.kl = const Offset(.35, .68);
      q.al = const Offset(.23, .69);
      q.ar -= Offset(0, lift);
      q.kr = _mix(q.hr, q.ar, .5);
      q.el = _joint(q.sl, q.wl, .15, .15, 1);
      q.er = _joint(q.sr, q.wr, .15, .15, 1);
      q.heelLift = lift;
      if (motion == ExerciseMotion.wallResistCalfLeft) return _mirrorPose(q);
      return q;
    case ExerciseMotion.windshieldWipers:
      final q = _pose(ExerciseMotion.legRaises, .5);
      final sweep = math.sin(angle);
      q.al = Offset(.60 + .18 * sweep, .37 + .08 * sweep.abs());
      q.ar = q.al + const Offset(.025, -.02);
      q.kl = _mix(q.hl, q.al, .5);
      q.kr = _mix(q.hr, q.ar, .5);
      q.wl = const Offset(.17, .84);
      q.wr = const Offset(.48, .84);
      q.el = _mix(q.sl, q.wl, .5);
      q.er = _mix(q.sr, q.wr, .5);
      return q;
    case ExerciseMotion.wristsAnklesLeft:
    case ExerciseMotion.wristsAnklesRight:
      p.wl = const Offset(.49, .35) + _polar(.012, angle);
      p.wr = p.wl + const Offset(.02, 0);
      p.el = _joint(p.sl, p.wl, .15, .14, 1);
      p.er = _joint(p.sr, p.wr, .15, .14, -1);
      p.al += Offset(.015 * math.cos(angle), -.01 + .01 * math.sin(angle));
      p.kl = _mix(p.hl, p.al, .5);
      if (motion == ExerciseMotion.wristsAnklesRight) return _mirrorPose(p);
    case ExerciseMotion.wallStandingGluteLeft:
    case ExerciseMotion.wallStandingGluteRight:
      final q = _pose(ExerciseMotion.standingGluteLeft, progress);
      q.wall = true;
      q.wl = const Offset(.82, .32);
      q.wr = const Offset(.82, .30);
      q.el = _joint(q.sl, q.wl, .17, .17, 1);
      q.er = _joint(q.sr, q.wr, .17, .17, 1);
      if (motion == ExerciseMotion.wallStandingGluteLeft) return _mirrorPose(q);
      return q;
    case ExerciseMotion.walkingSquats:
      final q = _pose(ExerciseMotion.squats, .4);
      final step = math.sin(angle);
      q.al += Offset(.04 * step, -.025 * math.max(0.0, step));
      q.ar += Offset(-.04 * step, -.025 * math.max(0.0, -step));
      q.kl += Offset(.02 * step, -.01 * math.max(0.0, step));
      q.kr += Offset(-.02 * step, -.01 * math.max(0.0, -step));
      return _shiftPose(q, Offset(.08 * step, 0));
    case ExerciseMotion.wallGluteHoldLeft:
    case ExerciseMotion.wallGluteHoldRight:
      p.side = true;
      p.wall = true;
      p.hl = const Offset(.43, .58);
      p.hr = const Offset(.45, .56);
      p.sl = const Offset(.62, .45);
      p.sr = const Offset(.64, .43);
      p.neck = const Offset(.65, .42);
      p.head = const Offset(.71, .37);
      p.wl = const Offset(.82, .32);
      p.wr = const Offset(.82, .30);
      p.el = _joint(p.sl, p.wl, .15, .15, 1);
      p.er = _joint(p.sr, p.wr, .15, .15, 1);
      final hold = (wave * 1.5).clamp(0.0, 1.0);
      p.al = _mix(const Offset(.40, .84), const Offset(.12, .58), hold);
      p.kl = _mix(p.hl, p.al, .5);
      p.ar = const Offset(.49, .86);
      p.kr = _mix(p.hr, p.ar, .5);
      if (motion == ExerciseMotion.wallGluteHoldLeft) return _mirrorPose(p);
    case ExerciseMotion.walkDog:
      final q = _pose(ExerciseMotion.downDog, 0);
      final left = math.max(0.0, math.sin(angle));
      final right = math.max(0.0, -math.sin(angle));
      q.kl = _mix(q.kl, const Offset(.36, .67), left);
      q.kr = _mix(q.kr, const Offset(.38, .65), right);
      q.al += Offset(0, -.035 * left);
      q.ar += Offset(0, -.035 * right);
      return q;
    case ExerciseMotion.xManCrunch:
      final q = _pose(ExerciseMotion.abdominalCrunch, progress);
      q.al = q.hl + _polar(.38, -.03);
      q.ar = q.hr + _polar(.38, -.18);
      q.kl = _mix(q.hl, q.al, .5);
      q.kr = _mix(q.hr, q.ar, .5);
      q.wl = _mix(
        q.sl + _polar(.25, (q.sl - q.hl).direction),
        const Offset(.68, .66),
        wave,
      );
      q.wr = _mix(
        q.sr + _polar(.25, (q.sr - q.hr).direction),
        const Offset(.70, .64),
        wave,
      );
      q.el = _mix(q.sl, q.wl, .5);
      q.er = _mix(q.sr, q.wr, .5);
      return q;
    case ExerciseMotion.xBurpees:
      if (progress < .6) return _pose(ExerciseMotion.burpees, progress);
      final star = _pose(ExerciseMotion.starJumps, .5);
      if (progress < .8) {
        return _blendPose(
          _pose(ExerciseMotion.burpees, .6),
          star,
          (progress - .6) * 5,
        );
      }
      return _blendPose(
        star,
        _pose(ExerciseMotion.burpees, 1),
        (progress - .8) * 5,
      );
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
    if (p.wall ||
        motion == ExerciseMotion.wallPushUp ||
        motion == ExerciseMotion.calfStretchLeft ||
        motion == ExerciseMotion.calfStretchRight) {
      canvas.save();
      if (p.mirrored || motion == ExerciseMotion.calfStretchRight) {
        canvas.translate(1, 0);
        canvas.scale(-1, 1);
      }
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(p.wallX, .13, .035, .74),
          const Radius.circular(.01),
        ),
        Paint()..color = const Color(0xFFCCD7C4),
      );
      for (var y = .2; y < .86; y += .12) {
        canvas.drawLine(
          Offset(p.wallX + .005, y),
          Offset(p.wallX + .035, y),
          Paint()
            ..color = Colors.white
            ..strokeWidth = .005,
        );
      }
      canvas.restore();
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
          ankle +
          Offset(
            p.side
                ? .035
                : (ankle.dx < .5 ? -1 : 1) *
                      (p.toesIn
                          ? -.025
                          : p.toesOut
                          ? .045
                          : .025),
            .012 + p.heelLift,
          );
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

    if (p.support != null) {
      canvas.save();
      if (p.mirrored) {
        canvas.translate(1, 0);
        canvas.scale(-1, 1);
      }
      final rect = p.support!;
      if (p.supportBack) {
        line(
          rect.topLeft,
          Offset(rect.left, .35),
          const Color(0xFF87938B),
          .022,
        );
      }
      line(rect.topLeft, rect.topRight, const Color(0xFF87938B), rect.height);
      line(
        rect.topLeft + const Offset(.025, .01),
        Offset(rect.left + .025, .87),
        const Color(0xFF87938B),
        .018,
      );
      line(
        rect.topRight + const Offset(-.025, .01),
        Offset(rect.right - .025, .87),
        const Color(0xFF87938B),
        .018,
      );
      canvas.restore();
    }
    if (p.doorway) {
      for (final x in [.23, .77]) {
        line(Offset(x, .10), Offset(x, .87), const Color(0xFFCCD7C4), .025);
      }
      line(
        const Offset(.23, .10),
        const Offset(.77, .10),
        const Color(0xFFCCD7C4),
        .025,
      );
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
      if (p.backCurve == 0) {
        line(
          _mix(p.sl, p.sr, .5),
          _mix(p.hl, p.hr, .5),
          AppColors.primary,
          .07,
        );
      } else {
        final shoulder = _mix(p.sl, p.sr, .5);
        final hip = _mix(p.hl, p.hr, .5);
        final middle = _mix(shoulder, hip, .5) + Offset(0, p.backCurve);
        canvas.drawPath(
          Path()
            ..moveTo(shoulder.dx, shoulder.dy)
            ..quadraticBezierTo(middle.dx, middle.dy, hip.dx, hip.dy),
          Paint()
            ..color = AppColors.primary
            ..style = PaintingStyle.stroke
            ..strokeWidth = .07
            ..strokeCap = StrokeCap.round,
        );
      }
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
