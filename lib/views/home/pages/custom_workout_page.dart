import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/custom_workout_repository.dart';
import '../../../widgets/exercises/exercise_avatar.dart';
import '../../workouts/workout_editor_page.dart';

class CustomWorkoutPage extends StatefulWidget {
  const CustomWorkoutPage({super.key});
  @override
  State<CustomWorkoutPage> createState() => _CustomWorkoutPageState();
}

class _CustomWorkoutPageState extends State<CustomWorkoutPage> {
  final repository = CustomWorkoutRepository();
  List<CustomWorkout> _workouts = [];
  bool _loading = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final workouts = await repository.load();
      if (mounted) {
        setState(() {
          _workouts = workouts;
          _loading = false;
          _error = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error =
              'Could not load saved workouts. Your saved data has not been replaced.';
        });
      }
    }
  }

  Future<void> _create() async {
    if (_busy) return;
    setState(() => _busy = true);
    final details = await configureWorkout(context);
    if (!mounted) return;
    if (details != null) {
      final now = DateTime.now().toUtc();
      final workout = CustomWorkout(
        id: '${now.microsecondsSinceEpoch}',
        name: details.$1,
        difficulty: details.$2,
        entries: const [],
        createdAt: now,
        updatedAt: now,
      );
      await _edit(workout, isNew: true);
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _edit(CustomWorkout workout, {bool isNew = false}) async {
    final saved = await Navigator.of(context).push<CustomWorkout>(
      MaterialPageRoute(
        builder: (_) => WorkoutEditorPage(workout: workout, isNew: isNew),
      ),
    );
    if (!mounted || saved == null) return;
    await _load();
  }

  Future<void> _delete(CustomWorkout workout) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete workout?'),
        content: Text('Delete "${workout.name}" and its exercise selections?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    setState(() => _busy = true);
    try {
      await repository.delete(workout.id);
      await _load();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not delete this workout. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF3F5F9),
    appBar: AppBar(
      title: const Text(
        'CUSTOM WORKOUT',
        style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
      ),
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  TextButton(onPressed: _load, child: const Text('Retry')),
                ],
              ),
            ),
          )
        : _workouts.isEmpty
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipOval(
                    child: Image.asset(
                      'assets/images/ui/plan_coach.jpg',
                      width: 140,
                      height: 140,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.fitness_center,
                        size: 100,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Design your own workout with original animated exercises.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _createButton(),
                ],
              ),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _workouts.length,
            itemBuilder: (context, index) {
              final workout = _workouts[index];
              return Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(14),
                  leading: SizedBox(
                    width: 60,
                    height: 68,
                    child: ExerciseAvatar(
                      exercise: workout.entries.first.exercise,
                    ),
                  ),
                  title: Text(
                    workout.name,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    '${workout.difficulty} • ${workout.entries.length} exercises',
                  ),
                  onTap: _busy ? null : () => _edit(workout),
                  trailing: IconButton(
                    tooltip: 'Delete ${workout.name}',
                    onPressed: _busy ? null : () => _delete(workout),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ),
              );
            },
          ),
    bottomNavigationBar: !_loading && _error == null && _workouts.isNotEmpty
        ? SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _createButton(),
            ),
          )
        : null,
  );

  Widget _createButton() => SizedBox(
    width: double.infinity,
    height: 56,
    child: FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      onPressed: _busy ? null : _create,
      icon: const Icon(Icons.add),
      label: const Text('Create workout'),
    ),
  );
}
