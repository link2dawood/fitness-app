import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../data/models/exercise.dart';
import 'exercise_avatar.dart';

const challengeAvatarFrames = <String, (int, int, bool)>{
  'jumping_jacks': (1, 0, false),
  'oblique_crossover_crunch_left': (1, 8, false),
  'oblique_crossover_crunch_right': (1, 8, true),
  'inchworms': (2, 0, false),
  'single_leg_drops': (2, 8, false),
  'challenge_body_saw': (3, 0, false),
  'bicycle_crunches': (3, 8, false),
  'side_crunches_left': (4, 0, false),
  'side_crunches_right': (4, 0, true),
  'bent_knee_side_hip_raises_left': (4, 8, false),
  'bent_knee_side_hip_raises_right': (4, 8, true),
  'cat_cow_pose': (5, 0, false),
  'lying_twist_stretch_left': (5, 8, false),
  'lying_twist_stretch_right': (5, 8, true),
};

class ChallengeAvatar extends StatefulWidget {
  const ChallengeAvatar({
    super.key,
    required this.exercise,
    this.animate = true,
  });
  final ExerciseDefinition exercise;
  final bool animate;
  @override
  State<ChallengeAvatar> createState() => _ChallengeAvatarState();
}

class _ChallengeAvatarState extends State<ChallengeAvatar>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  );
  ImageStream? stream;
  ImageStreamListener? listener;
  ui.Image? atlas;
  ImageInfo? imageInfo;
  bool foreground = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    load();
    play();
  }

  @override
  void didUpdateWidget(ChallengeAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exercise.id != widget.exercise.id) load();
    play();
  }

  void load() {
    final record = challengeAvatarFrames[widget.exercise.id];
    if (stream != null && listener != null) stream!.removeListener(listener!);
    imageInfo?.dispose();
    imageInfo = null;
    atlas = null;
    if (record == null) return;
    stream = AssetImage(
      'assets/images/challenge_avatars/atlas_${record.$1}.png',
    ).resolve(createLocalImageConfiguration(context));
    listener = ImageStreamListener(
      (image, _) {
        if (mounted) {
          setState(() {
            imageInfo?.dispose();
            imageInfo = image;
            atlas = image.image;
          });
        } else {
          image.dispose();
        }
      },
      onError: (Object _, StackTrace? _) {
        if (mounted) setState(() => atlas = null);
      },
    );
    stream!.addListener(listener!);
  }

  void play() {
    final enabled =
        foreground &&
        widget.animate &&
        !MediaQuery.disableAnimationsOf(context) &&
        TickerMode.valuesOf(context).enabled;
    if (enabled && !controller.isAnimating) controller.repeat();
    if (!enabled) controller.stop();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    foreground = state == AppLifecycleState.resumed;
    play();
  }

  @override
  void dispose() {
    if (stream != null && listener != null) stream!.removeListener(listener!);
    imageInfo?.dispose();
    controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final record = challengeAvatarFrames[widget.exercise.id];
    if (record == null || atlas == null) {
      return ExerciseAvatar(exercise: widget.exercise, animate: widget.animate);
    }
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: AnimatedBuilder(
          animation: controller,
          builder: (_, _) => CustomPaint(
            painter: _AtlasPainter(
              atlas!,
              record.$2 + (controller.value * 8).floor().clamp(0, 7),
              record.$3,
            ),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}

class _AtlasPainter extends CustomPainter {
  const _AtlasPainter(this.image, this.frame, this.mirror);
  final ui.Image image;
  final int frame;
  final bool mirror;
  @override
  void paint(Canvas canvas, Size size) {
    final width = image.width / 4, height = image.height / 4;
    final source = Rect.fromLTWH(
      (frame % 4) * width + 3,
      (frame ~/ 4) * height + 3,
      width - 6,
      height - 6,
    );
    final fitted = applyBoxFit(BoxFit.contain, source.size, size);
    final destination = Alignment.center.inscribe(
      fitted.destination,
      Offset.zero & size,
    );
    canvas.drawColor(const Color(0xFFE5E5E5), BlendMode.srcOver);
    canvas.save();
    if (mirror) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }
    canvas.drawImageRect(
      image,
      source,
      destination,
      Paint()..filterQuality = FilterQuality.high,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_AtlasPainter oldDelegate) =>
      oldDelegate.image != image ||
      oldDelegate.frame != frame ||
      oldDelegate.mirror != mirror;
}
