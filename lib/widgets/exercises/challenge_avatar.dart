import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../data/models/exercise.dart';
import 'exercise_avatar.dart';

const challengeAvatarFrames = <String, (int, int, bool)>{
  'mountain_climber_timed': (14, 0, false),
  'squats': (15, 0, false),
  'high_stepping': (16, 0, false),
  'reverse_crunches': (17, 0, false),
  'push_ups': (18, 0, false),
  'plank': (19, 0, false),
  'cobra_stretch': (20, 0, false),
  'cross_body_shoulder_stretch': (6, 0, false),
  'elbow_rotations': (6, 8, false),
  'alternating_side_bends': (7, 0, false),
  'spinal_roll_down': (7, 8, false),
  'standing_hip_rotations_left': (8, 0, false),
  'standing_hip_rotations_right': (8, 0, true),
  'kneeling_push_ups': (8, 8, false),
  'bird_dog_timed': (9, 0, false),
  'reverse_hip_raise': (9, 8, false),
  'superman_timed': (10, 0, false),
  'leg_scissors': (10, 8, false),
  'suitcase_crunch': (11, 0, false),
  'left_pivot_step_lunge': (11, 8, false),
  'right_pivot_step_lunge': (11, 8, true),
  'prisoner_squat': (12, 0, false),
  'hip_flexor_stretch_left': (12, 8, false),
  'hip_flexor_stretch_right': (12, 8, true),
  'straight_arm_plank_to_downward_dog': (13, 0, false),
  'childs_pose': (13, 8, false),

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

// User-supplied reference footage: 32 frames in an 8 x 4 atlas.
const referenceAvatarDurations = <String, int>{
  'mountain_climber_timed': 3600,
  'squats': 3600,
  'high_stepping': 1650,
  'reverse_crunches': 2600,
  'push_ups': 2350,
  'plank': 2600,
  'cobra_stretch': 2000,
};

// Select consistent return poses and exclude generated cells that switch legs.
const challengeAvatarFrameOrder = <String, List<int>>{
  'cross_body_shoulder_stretch': [0, 1, 2, 3, 2, 1, 0, 0],
  'alternating_side_bends': [0, 1, 2, 1, 0, 6, 7, 6],
  'spinal_roll_down': [0, 1, 2, 3, 3, 2, 1, 0],
  'standing_hip_rotations_left': [0, 1, 2, 2, 2, 5, 6, 7],
  'standing_hip_rotations_right': [0, 1, 2, 2, 2, 5, 6, 7],
  'bird_dog_timed': [0, 1, 2, 3, 2, 1, 0, 0],
};

int challengeAvatarFrameFor(String exerciseId, double progress) {
  if (referenceAvatarDurations.containsKey(exerciseId)) {
    return (progress * 32).floor().clamp(0, 31);
  }
  final step = (progress * 8).floor().clamp(0, 7);
  return challengeAvatarFrames[exerciseId]!.$2 +
      (challengeAvatarFrameOrder[exerciseId]?[step] ?? step);
}

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
    controller.duration = Duration(
      milliseconds: referenceAvatarDurations[widget.exercise.id] ?? 2800,
    );
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
              challengeAvatarFrameFor(widget.exercise.id, controller.value),
              record.$3,
              referenceAvatarDurations.containsKey(widget.exercise.id) ? 8 : 4,
            ),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}

class _AtlasPainter extends CustomPainter {
  const _AtlasPainter(this.image, this.frame, this.mirror, this.columns);
  final ui.Image image;
  final int frame;
  final bool mirror;
  final int columns;
  @override
  void paint(Canvas canvas, Size size) {
    final width = image.width / columns, height = image.height / 4;
    final source = Rect.fromLTWH(
      (frame % columns) * width + 3,
      (frame ~/ columns) * height + 3,
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
      oldDelegate.columns != columns ||
      oldDelegate.mirror != mirror;
}
