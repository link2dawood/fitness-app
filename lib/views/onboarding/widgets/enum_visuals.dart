import 'package:flutter/material.dart';

import '../../../data/models/user_profile.dart';

/// Maps model enums to icons & colors so the data layer stays free of UI code.

extension GenderVisual on Gender {
  IconData get icon {
    switch (this) {
      case Gender.male:
        return Icons.male_rounded;
      case Gender.female:
        return Icons.female_rounded;
      case Gender.other:
        return Icons.transgender_rounded;
    }
  }
}

extension FocusAreaVisual on FocusArea {
  IconData get icon {
    switch (this) {
      case FocusArea.fullBody:
        return Icons.accessibility_new_rounded;
      case FocusArea.arms:
        return Icons.fitness_center_rounded;
      case FocusArea.chest:
        return Icons.shield_outlined;
      case FocusArea.abs:
        return Icons.grid_view_rounded;
      case FocusArea.legs:
        return Icons.directions_run_rounded;
    }
  }
}

extension FitnessGoalVisual on FitnessGoal {
  IconData get icon {
    switch (this) {
      case FitnessGoal.loseWeight:
        return Icons.local_fire_department_rounded;
      case FitnessGoal.buildMuscle:
        return Icons.fitness_center_rounded;
      case FitnessGoal.keepFit:
        return Icons.favorite_rounded;
      case FitnessGoal.endurance:
        return Icons.bolt_rounded;
    }
  }
}

// ── Step 4: Motivation ────────────────────────────────────────────────────────

extension MotivationVisual on Motivation {
  IconData get icon {
    switch (this) {
      case Motivation.confidence:
        return Icons.emoji_emotions_rounded;
      case Motivation.stress:
        return Icons.spa_rounded;
      case Motivation.health:
        return Icons.monitor_heart_rounded;
      case Motivation.energy:
        return Icons.wb_sunny_rounded;
    }
  }

  Color get iconColor {
    switch (this) {
      case Motivation.confidence:
        return const Color(0xFFFF9800); // amber — self-confidence
      case Motivation.stress:
        return const Color(0xFF9C27B0); // purple — calm & spa
      case Motivation.health:
        return const Color(0xFFE91E63); // pink-red — heart health
      case Motivation.energy:
        return const Color(0xFFFF5722); // deep orange — sun/energy
    }
  }
}

// ── Step 5: Fitness Level ─────────────────────────────────────────────────────

extension FitnessLevelVisual on FitnessLevel {
  IconData get icon {
    switch (this) {
      case FitnessLevel.beginner:
        return Icons.signal_cellular_alt_1_bar_rounded;
      case FitnessLevel.intermediate:
        return Icons.signal_cellular_alt_2_bar_rounded;
      case FitnessLevel.advanced:
        return Icons.signal_cellular_alt_rounded;
    }
  }

  Color get iconColor {
    switch (this) {
      case FitnessLevel.beginner:
        return const Color(0xFF4CAF50); // green — just starting
      case FitnessLevel.intermediate:
        return const Color(0xFF2196F3); // blue — in progress
      case FitnessLevel.advanced:
        return const Color(0xFFFF5722); // deep orange — peak performance
    }
  }
}

// ── Step 6: Activity Level ────────────────────────────────────────────────────

extension ActivityLevelVisual on ActivityLevel {
  IconData get icon {
    switch (this) {
      case ActivityLevel.sedentary:
        return Icons.laptop_chromebook_rounded;
      case ActivityLevel.lightlyActive:
        return Icons.directions_walk_rounded;
      case ActivityLevel.moderatelyActive:
        return Icons.directions_run_rounded;
      case ActivityLevel.veryActive:
        return Icons.fitness_center_rounded;
    }
  }

  Color get iconColor {
    switch (this) {
      case ActivityLevel.sedentary:
        return const Color(0xFF9C27B0); // purple — desk/rest
      case ActivityLevel.lightlyActive:
        return const Color(0xFF00BCD4); // cyan — light walk
      case ActivityLevel.moderatelyActive:
        return const Color(0xFF2196F3); // blue — jogging
      case ActivityLevel.veryActive:
        return const Color(0xFFFF5722); // deep orange — intense training
    }
  }
}
