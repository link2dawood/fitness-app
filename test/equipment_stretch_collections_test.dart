import 'package:fitness_pro/data/models/exercise.dart';
import 'package:fitness_pro/data/models/training_workout.dart';
import 'package:fitness_pro/data/models/workout_type_collections.dart';
import 'package:fitness_pro/widgets/exercises/exercise_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Equipment, Stretch and Low Impact follow the reference order', () {
    expect(workoutTypeCollectionIds['with_equipment'], [
      'get_ripped_with_dumbbell',
      'build_wider_shoulders_intermediate',
      'build_wider_shoulders_advanced',
      'defined_arms_with_dumbbells',
      'dumbbell_abs_shaper',
      'beginner_abs_shred',
      'beginner_back_builder',
      'easy_arm_workout_with_dumbbells',
      'man_boobs_hiit_beginner',
      'man_boobs_hiit_intermediate',
      'man_boobs_hiit_advanced',
      'killer_chest_workout',
      'elite_abs_builder',
      'bigger_chest_builder',
      'beginner_chest_sculpt',
      'build_wider_shoulders',
      'intense_v_taper_challenge',
      'dumbbell_back_strength',
      'ultimate_full_body_builder',
      'peak_full_body_strength',
      'full_body_muscle_growth',
      'full_body_power_progression',
      'full_body_dumbbell_basics',
      'full_body_strength_starter',
      'elite_dumbbell_arms',
      'bigger_arms_challenge',
      'arm_mass_builder',
      'strong_arms_basics',
      'ultimate_lower_body_pump',
      'lower_body_muscle_gain',
      'glutes_legs_strength_starter',
    ]);
    expect(workoutTypeCollectionIds['stretch'], [
      'full_body_stretching',
      'lower_back_pain_relief',
      'sleepy_time_stretching',
      'neck_shoulder_tension_relief',
      'lower_body_stretching',
      'upper_body_stretching',
      'back_stretching',
      'shoulder_tension_relief',
      'knee_pain_relief',
    ]);
    expect(workoutTypeCollectionIds['low_impact'], [
      '3_exercises_lose_belly_fat',
      '12_min_classic',
      'stay_in_shape_at_home',
      '6_min_tabata',
    ]);
    for (final w in workoutTypeCollection('low_impact')) {
      expect(
        w.exercises.any(
          (e) =>
              RegExp('jump|hop|burpee', caseSensitive: false).hasMatch(e.name),
        ),
        isFalse,
      );
    }
    final circuit = trainingWorkouts.singleWhere(
      (w) => w.id == '3_exercises_lose_belly_fat',
    );
    expect(circuit.exercises, hasLength(9));
    expect(circuit.exerciseIds.toSet(), hasLength(3));
    expect(circuit.planVersion, 2);
    expect(circuit.progressStorageKey, endsWith('_v2'));
    expect(circuit.estimatedMinutes, 9);
  });

  test(
    'New routines have real positive targets, computed durations and equipment',
    () {
      for (final (id, count, minutes) in [
        ('killer_chest_workout', 25, 29),
        ('elite_abs_builder', 23, 28),
        ('bigger_chest_builder', 24, 28),
        ('intense_v_taper_challenge', 24, 30),
        ('dumbbell_back_strength', 22, 23),
        ('ultimate_full_body_builder', 25, 31),
        ('peak_full_body_strength', 24, 28),
        ('full_body_power_progression', 26, 28),
        ('full_body_dumbbell_basics', 24, 24),
        ('full_body_strength_starter', 24, 23),
        ('elite_dumbbell_arms', 27, 33),
        ('bigger_arms_challenge', 23, 28),
        ('arm_mass_builder', 23, 25),
        ('strong_arms_basics', 21, 22),
        ('ultimate_lower_body_pump', 24, 29),
        ('lower_body_muscle_gain', 25, 27),
        ('glutes_legs_strength_starter', 23, 23),
        ('lower_back_pain_relief', 18, 15),
        ('knee_pain_relief', 16, 14),
        ('12_min_classic', 13, 12),
        ('stay_in_shape_at_home', 22, 20),
      ]) {
        final w = trainingWorkouts.singleWhere((w) => w.id == id);
        expect(w.exercises, hasLength(count));
        expect(w.targets, hasLength(count));
        expect(w.targets!.every((target) => target > 0), isTrue);
        expect(w.estimatedMinutes, minutes);
        if (workoutTypeCollectionIds['with_equipment']!.contains(id)) {
          expect(w.equipment, contains(ExerciseEquipment.dumbbell));
        }
      }
      final distinct = ['killer_chest_workout', 'killer_chest_routine']
          .map(
            (id) => trainingWorkouts
                .singleWhere((w) => w.id == id)
                .progressStorageKey,
          )
          .toSet();
      expect(distinct, hasLength(2));
    },
  );

  testWidgets(
    'New weighted movements render their animation poses without errors',
    (tester) async {
      for (final id in [
        'dumbbell_squat',
        'dumbbell_reverse_lunge',
        'dumbbell_deadlift_left',
        'dumbbell_deadlift_right',
        'dumbbell_floor_press',
      ]) {
        final exercise = exerciseById(id);
        expect(exercise.equipment, contains(ExerciseEquipment.dumbbell));
        for (final pose in [0.0, .25, .5, .75]) {
          await tester.pumpWidget(
            MaterialApp(
              home: SizedBox(
                width: 240,
                height: 240,
                child: ExerciseAvatar(
                  exercise: exercise,
                  animate: false,
                  pose: pose,
                ),
              ),
            ),
          );
          await tester.pump();
          expect(tester.takeException(), isNull);
        }
      }
      await tester.pumpWidget(const SizedBox());
    },
  );
}
