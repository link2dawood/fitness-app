import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/exercise.dart';
import '../../../data/models/training_recommendations.dart';
import '../../../data/models/training_calendar.dart';
import '../../../data/models/training_workout.dart';
import '../../../data/repositories/training_history_repository.dart';
import '../../../viewmodels/home_viewmodel.dart';
import '../../search/search_view.dart';
import '../../workouts/training_goal_sheet.dart';
import '../../workouts/training_history_sheet.dart';
import '../../settings/feature_suggestions_sheet.dart';
import 'training_collection_page.dart';
import '../../../widgets/training_feature_cards.dart';
import '../../workouts/training_workout_page.dart';
import '../../workouts/challenge_day_page.dart';

class TrainingPage extends StatefulWidget {
  const TrainingPage({super.key});
  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  String area = 'Abs';
  String goal = 'Burn Fat';
  static const areas = [
    'Abs',
    'Arm',
    'Forearm',
    'Chest',
    'Leg',
    'Butt',
    'Shoulder & Back',
  ];
  void _streak() {
    final count = TrainingHistoryRepository.instance.streak(DateTime.now());
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                color: AppColors.primary,
                size: 52,
              ),
              Text(
                '$count Day Streak!',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                count == 0
                    ? 'Complete your first workout to begin a streak.'
                    : 'Complete a workout today to keep your streak going.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('KEEP GOING'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title, {String? route}) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 12),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
        ),
        if (route != null)
          IconButton(
            tooltip: 'See all $title',
            onPressed: () => Navigator.pushNamed(
              context,
              route,
              arguments: context.read<HomeViewModel>().profile,
            ),
            icon: const Icon(Icons.arrow_forward),
          ),
      ],
    ),
  );
  Widget _routines(Iterable<TrainingWorkout> workouts) => Column(
    children: [
      for (final workout in workouts) TrainingWorkoutTile(workout: workout),
    ],
  );
  void _search([String? query]) => Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => SearchView(initialQuery: query ?? ''),
    ),
  );
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final history = TrainingHistoryRepository.instance;
    final now = DateTime.now();
    final firstDay = vm.profile?.firstDayOfWeek ?? 'SUNDAY';
    final sunday = firstDay == 'SUNDAY';
    final today = TrainingHistoryRepository.day(now);
    final dates = TrainingCalendar.week(now, firstDay);
    final completed = history.entries
        .map((e) => TrainingHistoryRepository.day(e.finishedAt))
        .toSet();
    final recommended = TrainingRecommendations.forProfile(vm.profile);
    final challenges = trainingWorkouts
        .where(
          (w) => w.title.toLowerCase().contains(
            RegExp('challenge|calisthenics|ripped'),
          ),
        )
        .take(3);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'HOME WORKOUT',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Training streak',
                        onPressed: vm.isLoading || vm.historyError != null
                            ? null
                            : _streak,
                        icon: const Icon(
                          Icons.local_fire_department_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Pro plans',
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.pro),
                        icon: const Icon(Icons.workspace_premium),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _search,
                icon: const Icon(Icons.search),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Search workouts, plans…'),
                ),
              ),
              if (vm.historyError != null) ...[
                Text(vm.historyError!),
                TextButton(
                  onPressed: vm.load,
                  child: const Text('Retry history'),
                ),
              ],
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Wrap(
                              spacing: 16,
                              runSpacing: 8,
                              children: [
                                const Text(
                                  'Weekly Goal',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  vm.isLoading
                                      ? 'Loading…'
                                      : vm.historyError != null
                                      ? 'History unavailable'
                                      : '${history.weeklyDays(now, sundayFirst: sunday)}/${vm.profile?.workoutDaysPerWeek ?? 4}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            tooltip: 'Edit weekly goal',
                            onPressed: vm.isLoading
                                ? null
                                : () => editTrainingGoal(context, vm),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final date in dates)
                            Expanded(
                              child: InkWell(
                                onTap: vm.isLoading || vm.historyError != null
                                    ? null
                                    : () => showTrainingHistory(
                                        context,
                                        date,
                                        firstDay: firstDay,
                                      ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Column(
                                    children: [
                                      FittedBox(
                                        child: Text(
                                          [
                                            'Mon',
                                            'Tue',
                                            'Wed',
                                            'Thu',
                                            'Fri',
                                            'Sat',
                                            'Sun',
                                          ][date.weekday - 1],
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: date == today
                                              ? AppColors.primary
                                              : null,
                                        ),
                                        child: Text(
                                          '${date.day}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: date == today
                                                ? Colors.white
                                                : AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        completed.contains(date)
                                            ? Icons.check_circle
                                            : Icons.circle_outlined,
                                        size: 12,
                                        color: completed.contains(date)
                                            ? AppColors.primary
                                            : Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: vm.isLoading || vm.historyError != null
                              ? null
                              : () => showTrainingHistory(
                                  context,
                                  today,
                                  firstDay: firstDay,
                                ),
                          icon: const Icon(Icons.history),
                          label: const Text('Workout history'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _section('Challenge', route: AppRoutes.challenge),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 14),
                          child: SizedBox(
                            width: (MediaQuery.sizeOf(context).width - 56)
                                .clamp(240.0, 320.0),
                            child: const ReferenceChallengeCard(),
                          ),
                        ),
                        if (recommended.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 14),
                            child: SizedBox(
                              width: (MediaQuery.sizeOf(context).width - 56)
                                  .clamp(240.0, 320.0),
                              child: TrainingChallengeCard(
                                workout: recommended.first,
                                customized: true,
                              ),
                            ),
                          ),
                        for (final (index, workout) in challenges.indexed)
                          Padding(
                            padding: const EdgeInsets.only(right: 14),
                            child: SizedBox(
                              width: (MediaQuery.sizeOf(context).width - 56)
                                  .clamp(240.0, 320.0),
                              child: TrainingChallengeCard(
                                workout: workout,
                                color: [
                                  const Color(0xFF00ACC1),
                                  const Color(0xFF7E22CE),
                                  trainingCardBlue,
                                ][index % 3],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              _section('Body Focus'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final value in areas)
                    ChoiceChip(
                      label: Text(value),
                      selected: area == value,
                      onSelected: (_) => setState(() => area = value),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              _routines(
                trainingWorkouts.where(
                  (w) =>
                      w.title.startsWith('$area ') &&
                      [
                        'Beginner',
                        'Intermediate',
                        'Advanced',
                      ].any((level) => w.title == '$area $level'),
                ),
              ),
              _section('Workout Types'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final label in [
                    'Build Muscle',
                    'Stretch',
                    'Burn Fat',
                    'Keep Fit',
                    'Beginner',
                    'With Equipment',
                    'Warm-Up',
                  ])
                    ActionChip(
                      label: Text(label),
                      onPressed: () => _search(label),
                    ),
                ],
              ),
              _section('Custom Workout'),
              TrainingCustomCard(
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.customWorkout),
              ),
              _section('Recommended'),
              if (vm.isLoading)
                const CircularProgressIndicator()
              else if (recommended.isEmpty)
                const Text(
                  'Complete your fitness profile to see personalized workouts.',
                ),
              if (recommended.isNotEmpty)
                TrainingPhotoCard(
                  title: recommended.first.title.toUpperCase(),
                  image: recommended.first.image,
                  subtitle:
                      '${recommended.first.summary}\nPersonalized for your training profile',
                  recommended: true,
                  actionLabel: 'VIEW WORKOUT',
                  onTap: () => openTrainingWorkout(context, recommended.first),
                )
              else
                TrainingPhotoCard(
                  title: 'Find your next workout',
                  image: 'assets/images/ui/recommended_height.jpg',
                  subtitle: 'Browse animated workout routines',
                  actionLabel: 'EXPLORE',
                  onTap: _search,
                ),
              _section('Just For You', route: AppRoutes.justForYou),
              _routines(recommended.skip(1).take(2)),
              _section('Stretch & Warm Up', route: AppRoutes.stretchWarmUp),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final (index, workout)
                        in trainingWorkouts
                            .where((w) => w.type != ExerciseType.training)
                            .take(4)
                            .indexed)
                      Padding(
                        padding: const EdgeInsets.only(right: 14),
                        child: SizedBox(
                          width: MediaQuery.textScalerOf(context).scale(16) > 22
                              ? (MediaQuery.sizeOf(context).width - 48).clamp(
                                  240.0,
                                  320.0,
                                )
                              : 190,
                          child: TrainingPhotoCard(
                            title: workout.title,
                            image: index.isEven
                                ? 'assets/images/workouts/stretch_warmup.jpg'
                                : 'assets/images/workouts/stretch_sleepy.jpg',
                            subtitle: workout.summary,
                            onTap: () => openTrainingWorkout(context, workout),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              _section('Popular Goals'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final value in ['Burn Fat', 'Build Muscle', 'Keep Fit'])
                    ChoiceChip(
                      label: Text(value),
                      selected: goal == value,
                      onSelected: (_) => setState(() => goal = value),
                    ),
                ],
              ),
              _routines(goalWorkouts(goal).take(3)),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    goal == 'Burn Fat'
                        ? AppRoutes.burnFatMore
                        : goal == 'Build Muscle'
                        ? AppRoutes.buildMuscleMore
                        : AppRoutes.keepFitMore,
                  ),
                  child: Text('More $goal workouts'),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => showFeatureSuggestions(context),
                  icon: const Icon(Icons.feedback_outlined),
                  label: const Text('Tell us what you need'),
                ),
              ),
              const SizedBox(height: 16),
              TrainingPhotoCard(
                title: 'Explore more\nworkouts',
                image: 'assets/images/workouts/hiit_fat_burning.jpg',
                subtitle: 'Discover more ways to train',
                collage: true,
                actionLabel: 'Go',
                onTap: () => vm.setTab(1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
