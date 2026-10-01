enum Gender {
  male('Male'),
  female('Female'),
  other('Other');

  const Gender(this.label);
  final String label;
}

enum FocusArea {
  fullBody('Full body'),
  arms('Arms'),
  chest('Chest'),
  abs('Abs'),
  legs('Legs');

  const FocusArea(this.label);
  final String label;
}

enum FitnessGoal {
  loseWeight('Lose weight', 'Burn fat and feel lighter'),
  buildMuscle('Build muscle', 'Gain strength and size'),
  keepFit('Stay fit', 'Maintain your current shape'),
  endurance('Boost endurance', 'Train longer without fatigue');

  const FitnessGoal(this.label, this.description);
  final String label;
  final String description;
}

enum Motivation {
  confidence('Feel confident', 'Look and feel your best'),
  stress('Reduce stress', 'Clear your mind after a long day'),
  health('Improve health', 'Build habits that last'),
  energy('Boost energy', 'Feel active throughout the day');

  const Motivation(this.label, this.description);
  final String label;
  final String description;
}

enum FitnessLevel {
  beginner('Beginner', 'Up to 5 push-ups in a row'),
  intermediate('Intermediate', '6 to 15 push-ups in a row'),
  advanced('Advanced', '16 or more push-ups in a row');

  const FitnessLevel(this.label, this.description);
  final String label;
  final String description;
}

enum ActivityLevel {
  sedentary('Sedentary', '👩‍💻'),
  lightlyActive('Lightly active', '🚶'),
  moderatelyActive('Moderately active', '🏃'),
  veryActive('Very active', '🥰');

  const ActivityLevel(this.label, this.emoji);
  final String label;
  final String emoji;
}

class UserProfile {
  const UserProfile({
    this.gender,
    this.focusAreas = const {},
    this.goal,
    this.motivation,
    this.level,
    this.activityLevel,
    this.age = 25,
    this.heightCm = 170,
    this.weightKg = 70,
    this.workoutDaysPerWeek = 4,
    this.firstDayOfWeek = 'SUNDAY',
  });

  final Gender? gender;
  final Set<FocusArea> focusAreas;
  final FitnessGoal? goal;
  final Motivation? motivation;
  final FitnessLevel? level;
  final ActivityLevel? activityLevel;
  final int age;
  final int heightCm;
  final int weightKg;
  final int workoutDaysPerWeek;
  final String firstDayOfWeek;

  /// Body Mass Index calculated from height and weight.
  double get bmi {
    final meters = heightCm / 100;
    return weightKg / (meters * meters);
  }

  UserProfile copyWith({
    Gender? gender,
    Set<FocusArea>? focusAreas,
    FitnessGoal? goal,
    Motivation? motivation,
    FitnessLevel? level,
    ActivityLevel? activityLevel,
    int? age,
    int? heightCm,
    int? weightKg,
    int? workoutDaysPerWeek,
    String? firstDayOfWeek,
  }) {
    return UserProfile(
      gender: gender ?? this.gender,
      focusAreas: focusAreas ?? this.focusAreas,
      goal: goal ?? this.goal,
      motivation: motivation ?? this.motivation,
      level: level ?? this.level,
      activityLevel: activityLevel ?? this.activityLevel,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      workoutDaysPerWeek: workoutDaysPerWeek ?? this.workoutDaysPerWeek,
      firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
    );
  }

  Map<String, dynamic> toJson() => {
        'gender': gender?.name,
        'focusAreas': focusAreas.map((e) => e.name).toList(),
        'goal': goal?.name,
        'motivation': motivation?.name,
        'level': level?.name,
        'activityLevel': activityLevel?.name,
        'age': age,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'workoutDaysPerWeek': workoutDaysPerWeek,
        'firstDayOfWeek': firstDayOfWeek,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    T? parse<T extends Enum>(List<T> values, String? name) {
      if (name == null) return null;
      for (final v in values) {
        if (v.name == name) return v;
      }
      return null;
    }

    final areas = (json['focusAreas'] as List<dynamic>? ?? [])
        .map((e) => parse(FocusArea.values, e as String?))
        .whereType<FocusArea>()
        .toSet();

    return UserProfile(
      gender: parse(Gender.values, json['gender'] as String?),
      focusAreas: areas,
      goal: parse(FitnessGoal.values, json['goal'] as String?),
      motivation: parse(Motivation.values, json['motivation'] as String?),
      level: parse(FitnessLevel.values, json['level'] as String?),
      activityLevel: parse(ActivityLevel.values, json['activityLevel'] as String?),
      age: json['age'] as int? ?? 25,
      heightCm: json['heightCm'] as int? ?? 170,
      weightKg: json['weightKg'] as int? ?? 70,
      workoutDaysPerWeek: json['workoutDaysPerWeek'] as int? ?? 4,
      firstDayOfWeek: json['firstDayOfWeek'] as String? ?? 'SUNDAY',
    );
  }
}
