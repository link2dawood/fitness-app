import 'package:flutter/material.dart';

/// Data model for a single workout entry shown in the results list.
class WorkoutEntry {
  const WorkoutEntry({
    required this.title,
    required this.durationMins,
    required this.exerciseCount,
    required this.imagePath,
  });

  final String title;
  final int durationMins;
  final int exerciseCount;
  final String imagePath;
}

/// Map of body-focus label → list of workouts (from WorkOut_Report.md).
const Map<String, List<WorkoutEntry>> _bodyFocusWorkouts = {
  'Back': [
    WorkoutEntry(
      title: 'Shoulder & Back Beginner',
      durationMins: 15,
      exerciseCount: 17,
      imagePath: 'assets/images/workout_back_sb.jpg',
    ),
    WorkoutEntry(
      title: 'Shoulder & Back Intermediate',
      durationMins: 19,
      exerciseCount: 17,
      imagePath: 'assets/images/workout_back_sb.jpg',
    ),
    WorkoutEntry(
      title: 'Shoulder & Back Advanced',
      durationMins: 21,
      exerciseCount: 17,
      imagePath: 'assets/images/workout_back_sb.jpg',
    ),
    WorkoutEntry(
      title: 'Beginner Back Builder',
      durationMins: 16,
      exerciseCount: 12,
      imagePath: 'assets/images/workout_back_builder.jpg',
    ),
  ],
};

/// Screen that displays workouts for a selected body focus area.
/// Navigated to from [SearchView] when the user taps a body focus badge.
class BodyFocusResultsView extends StatelessWidget {
  const BodyFocusResultsView({super.key, required this.focusLabel});

  /// The body focus label, e.g. "Back", "Arm", "Chest".
  final String focusLabel;

  List<WorkoutEntry> get _workouts =>
      _bodyFocusWorkouts[focusLabel] ?? const [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF111827),
                      size: 24,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Text(
                    focusLabel,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),

            // Workout List
            Expanded(
              child: _workouts.isEmpty
                  ? _buildEmpty()
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: _workouts.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) =>
                          _WorkoutCard(entry: _workouts[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.fitness_center_rounded,
            size: 56,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No workouts yet for $focusLabel',
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF9CA3AF),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({required this.entry});

  final WorkoutEntry entry;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening: ${entry.title}'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6FA),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: Image.asset(
                entry.imagePath,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${entry.durationMins} mins · ${entry.exerciseCount} exercises',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Chevron
            const Padding(
              padding: EdgeInsets.only(right: 14),
              child: Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFCBD5E1),
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
