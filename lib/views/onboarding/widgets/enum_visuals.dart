import 'package:flutter/material.dart';

import '../../../data/models/user_profile.dart';

/// Maps model enums to icons so the data layer stays free of UI code.
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
      case FocusArea.back:
        return Icons.swap_vert_rounded;
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
}

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
}
