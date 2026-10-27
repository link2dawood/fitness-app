import '../../core/settings/settings_record.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/exercise.dart';

class WorkoutEntry {
  const WorkoutEntry({
    required this.id,
    required this.exerciseId,
    required this.target,
    this.restSeconds = 30,
  });
  final String id;
  final String exerciseId;
  final int target;
  final int restSeconds;
  ExerciseDefinition get exercise => exerciseById(exerciseId);
  WorkoutEntry copyWith({int? target, int? restSeconds}) => WorkoutEntry(
    id: id,
    exerciseId: exerciseId,
    target: target ?? this.target,
    restSeconds: restSeconds ?? this.restSeconds,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'exerciseId': exerciseId,
    'target': target,
    'restSeconds': restSeconds,
  };
  factory WorkoutEntry.fromJson(Map<String, dynamic> json) {
    final entry = WorkoutEntry(
      id: json['id'] as String,
      exerciseId: json['exerciseId'] as String,
      target: json['target'] as int,
      restSeconds: json['restSeconds'] as int,
    );
    if (entry.id.isEmpty ||
        entry.target < 1 ||
        entry.target > (entry.exercise.timed ? 3600 : 999) ||
        entry.restSeconds < 0 ||
        entry.restSeconds > 600) {
      throw const FormatException('Invalid workout exercise');
    }
    return entry;
  }
}

class CustomWorkout {
  const CustomWorkout({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.entries,
    required this.createdAt,
    required this.updatedAt,
  });
  final String id;
  final String name;
  final String difficulty;
  final List<WorkoutEntry> entries;
  final DateTime createdAt;
  final DateTime updatedAt;
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'difficulty': difficulty,
    'entries': entries.map((entry) => entry.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
  factory CustomWorkout.fromJson(Map<String, dynamic> json) {
    final workout = CustomWorkout(
      id: json['id'] as String,
      name: json['name'] as String,
      difficulty: json['difficulty'] as String,
      entries: (json['entries'] as List)
          .map(
            (entry) =>
                WorkoutEntry.fromJson(Map<String, dynamic>.from(entry as Map)),
          )
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
    if (workout.id.isEmpty ||
        workout.name.trim().isEmpty ||
        workout.entries.isEmpty ||
        ![
          'Beginner',
          'Intermediate',
          'Advanced',
        ].contains(workout.difficulty) ||
        workout.entries.map((entry) => entry.id).toSet().length !=
            workout.entries.length) {
      throw const FormatException('Invalid saved workout');
    }
    return workout;
  }
}

class CustomWorkoutRepository {
  static const key = 'custom_workouts_v1';
  Future<List<CustomWorkout>> load() async {
    final raw = (await SharedPreferences.getInstance()).getString(key);
    if (raw == null) return [];
    final json = jsonDecode(raw) as Map<String, dynamic>;
    if (json['version'] != 1) {
      throw const FormatException('Unsupported workout data version');
    }
    return (json['workouts'] as List)
        .map(
          (entry) =>
              CustomWorkout.fromJson(Map<String, dynamic>.from(entry as Map)),
        )
        .toList();
  }

  Future<void> _write(List<CustomWorkout> workouts) async {
    final raw = jsonEncode({
      'version': 1,
      'workouts': workouts.map((workout) => workout.toJson()).toList(),
    });
    if (!await (await SharedPreferences.getInstance()).setString(key, raw)) {
      throw StateError('Could not save workouts');
    }
  }

  Future<void> save(CustomWorkout workout) async {
    CustomWorkout.fromJson(workout.toJson());
    final workouts = await load();
    final index = workouts.indexWhere((entry) => entry.id == workout.id);
    if (index < 0) {
      workouts.add(workout);
    } else {
      workouts[index] = workout;
    }
    await _write(workouts);
  }

  Future<void> delete(String id) async {
    final workouts = await load();
    await _write(workouts.where((workout) => workout.id != id).toList());
  }

  Future<int> defaultRest() async {
    final prefs = await SettingsRecord.load('settings_');
    return prefs.restFor(30);
  }
}
