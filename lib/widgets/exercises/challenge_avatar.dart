import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../data/models/exercise.dart';
import 'exercise_avatar.dart';

const challengeAvatarFrames = <String, (int, int, bool)>{
  'back_arches': (30, 0, false),
  'calf_raises': (30, 8, false),
  'chest_press_pulse': (31, 0, false),
  'clapping_crunches': (31, 8, false),
  'crab_kicks': (32, 0, false),
  'cross_arm_crunches': (32, 8, false),
  'cross_touch_and_reach': (33, 0, false),
  'crossover_crunch': (33, 8, false),
  'curtsy_lunges': (34, 0, false),
  'dumbbell_kickbacks': (34, 8, false),
  'dumbbell_lying_triceps_extension': (35, 0, false),
  'dumbbell_punch': (35, 8, false),
  'dumbbell_rear_delt_row': (36, 0, false),
  'dumbbell_shrug': (36, 8, false),
  'dumbbell_single_arm_otis_up_left': (37, 0, false),
  'dumbbell_woodchop_left': (37, 8, false),
  'glute_kick_back_right': (38, 0, false),
  'glute_kickback_crossover_left': (38, 8, false),
  'glute_kickback_pulse_left': (39, 0, false),
  'hindu_push_ups': (39, 8, false),
  'hip_bridge_leg_lift_left': (40, 0, false),
  'plank_hip_dips': (40, 8, false),
  'quick_feet': (41, 0, false),
  'reclined_oblique_twist': (41, 8, false),
  'reverse_crunches_leg_raised': (42, 0, false),
  'reverse_plank': (42, 8, false),
  'russian_twist': (43, 0, false),
  'sit_ups': (43, 8, false),
  'side_lying_kickback_left': (44, 0, false),
  'side_plank_knee_crunch_left': (44, 8, false),
  'spiderman_plank': (45, 0, false),
  'standing_hip_circle': (45, 8, false),
  'straight_arm_knee_plank': (46, 0, false),
  'leg_raises': (46, 8, false),
  'side_plank_left': (47, 0, false),
  'dead_bug': (47, 8, false),
  'dumbbell_woodchop_right': (37, 8, true),
  'glute_kickback_crossover_right': (38, 8, true),
  'glute_kickback_pulse_right': (39, 0, true),
  'side_lying_kickback_right': (44, 0, true),
  'side_plank_knee_crunch_right': (44, 8, true),
  'side_plank_right': (47, 0, true),
  'hip_bridge_leg_lift_right': (40, 0, true),
  'glute_kick_back_left': (38, 0, true),
  'spiderman_plank_timed': (45, 0, false),
  'cobras': (20, 0, false),

  'right_lunge_knee_hops': (27, 0, false),
  'reverse_flutter_kicks': (27, 8, false),
  'roundhouse_squat_kicks': (28, 0, false),
  'right_side_lying_forward_leg_lift': (28, 8, false),
  'runners_lunge_left': (29, 0, false),
  'runners_lunge_right': (29, 0, true),
  'straight_arm_plank': (29, 8, false),
  'knee_to_elbow_crunches': (21, 0, false),
  'plie_squats': (21, 8, false),
  'squat_kicks': (22, 0, false),
  'incline_push_ups': (22, 8, false),
  'triceps_dips': (23, 0, false),
  'back_bow_pulls': (23, 8, false),
  'straight_arm_plank_to_pike': (24, 0, false),
  'leg_in_and_outs': (24, 8, false),
  'abdominal_crunches': (25, 0, false),
  'clasp_hands_behind_back': (25, 8, false),
  'right_quad_stretch_wall': (26, 0, false),
  'left_quad_stretch_wall': (26, 0, true),
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
  'cobras': 2000,
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
  'roundhouse_squat_kicks': [0, 1, 2, 3, 3, 2, 1, 0],
  'crab_kicks': [0, 1, 2, 4, 4, 5, 6, 7],
  'dumbbell_punch': [0, 1, 2, 2, 3, 5, 6, 7],
  'quick_feet': [0, 1, 0, 6, 7, 6, 0, 1],
  'back_bow_pulls': [0, 1, 2, 3, 4, 2, 1, 0],
  'straight_arm_plank_to_pike': [0, 1, 2, 3, 3, 2, 1, 0],
  'abdominal_crunches': [0, 1, 2, 2, 1, 1, 0, 0],
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
