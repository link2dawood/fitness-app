import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/date_rollover_builder.dart';
import '../../data/models/training_calendar.dart';
import '../../data/repositories/training_history_repository.dart';
import '../../data/repositories/onboarding_repository.dart';

Future<void> showPersistedTrainingHistory(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const PersistedTrainingHistorySheet(),
    );

/// Refresh storage before displaying entries, including when opened outside Home.
class PersistedTrainingHistorySheet extends StatefulWidget {
  const PersistedTrainingHistorySheet({super.key});
  @override
  State<PersistedTrainingHistorySheet> createState() =>
      _PersistedTrainingHistorySheetState();
}

class _PersistedTrainingHistorySheetState
    extends State<PersistedTrainingHistorySheet> {
  late Future<String> loading = load();
  Future<String> load() async {
    await TrainingHistoryRepository.instance.load();
    final profile = await OnboardingRepository().loadProfile();
    return profile?.firstDayOfWeek ?? 'SUNDAY';
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<String>(
    future: loading,
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        return TrainingHistorySheet(
          date: DateTime.now(),
          firstDay: snapshot.data!,
        );
      }
      return SizedBox(
        height: MediaQuery.sizeOf(context).height * .6,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      tooltip: 'Close history',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ),
                  Center(
                    child: snapshot.hasError
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Workout history could not be loaded. Your saved records have not been changed.',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              FilledButton(
                                onPressed: () => setState(() {
                                  loading = load();
                                }),
                                child: const Text('Retry'),
                              ),
                            ],
                          )
                        : const CircularProgressIndicator(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

Future<void> showTrainingHistory(
  BuildContext context,
  DateTime date, {
  required String firstDay,
  DateTime Function()? now,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (_) =>
      TrainingHistorySheet(date: date, firstDay: firstDay, now: now),
);

class TrainingHistorySheet extends StatefulWidget {
  const TrainingHistorySheet({
    super.key,
    required this.date,
    required this.firstDay,
    this.now,
  });
  final DateTime date;
  final String firstDay;
  final DateTime Function()? now;
  @override
  State<TrainingHistorySheet> createState() => _TrainingHistorySheetState();
}

class _TrainingHistorySheetState extends State<TrainingHistorySheet> {
  late DateTime selected = TrainingHistoryRepository.day(widget.date);
  late DateTime month = DateTime(selected.year, selected.month);
  late DateTime lastToday = TrainingHistoryRepository.day(
    widget.now?.call() ?? DateTime.now(),
  );
  Widget dayCell(DateTime date, Set<DateTime> days) => Semantics(
    button: true,
    selected: date == selected,
    label:
        '${date.year}/${date.month}/${date.day}${days.contains(date) ? ', workout completed' : ''}',
    child: InkWell(
      key: ValueKey('history-day-${date.year}-${date.month}-${date.day}'),
      onTap: () => setState(() => selected = date),
      child: Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        decoration: BoxDecoration(
          color: date == selected
              ? AppColors.primary.withValues(alpha: .18)
              : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            FittedBox(fit: BoxFit.scaleDown, child: Text('${date.day}')),
            const SizedBox(height: 4),
            Icon(
              days.contains(date) ? Icons.check_circle : Icons.circle_outlined,
              size: 10,
              color: days.contains(date) ? AppColors.primary : Colors.grey,
            ),
          ],
        ),
      ),
    ),
  );
  @override
  Widget build(BuildContext context) =>
      DateRolloverBuilder(now: widget.now, builder: _buildCalendar);

  Widget _buildCalendar(BuildContext context) {
    final today = TrainingHistoryRepository.day(
      widget.now?.call() ?? DateTime.now(),
    );
    if (today != lastToday) {
      if (selected == lastToday &&
          month.year == lastToday.year &&
          month.month == lastToday.month) {
        selected = today;
        month = DateTime(today.year, today.month);
      }
      lastToday = today;
    }
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * .88,
      child: SafeArea(
        child: AnimatedBuilder(
          animation: TrainingHistoryRepository.instance,
          builder: (context, _) {
            final history = TrainingHistoryRepository.instance;
            final days = history.entries
                .map((e) => TrainingHistoryRepository.day(e.finishedAt))
                .toSet();
            final entries =
                history.entries
                    .where(
                      (e) =>
                          TrainingHistoryRepository.day(e.finishedAt) ==
                          selected,
                    )
                    .toList()
                  ..sort((a, b) => b.finishedAt.compareTo(a.finishedAt));
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'History • ${selected.year}/${selected.month}/${selected.day}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close history',
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Previous month',
                        onPressed: () => setState(
                          () => month = DateTime(month.year, month.month - 1),
                        ),
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Expanded(
                        child: Text(
                          '${month.year}/${month.month.toString().padLeft(2, '0')}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Next month',
                        onPressed: () => setState(
                          () => month = DateTime(month.year, month.month + 1),
                        ),
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                  Row(
                    key: const ValueKey('history-weekdays'),
                    children: [
                      for (final day in TrainingCalendar.weekdays(
                        widget.firstDay,
                      ))
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              [
                                'Mon',
                                'Tue',
                                'Wed',
                                'Thu',
                                'Fri',
                                'Sat',
                                'Sun',
                              ][day - 1],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, box) => Wrap(
                      children: [
                        for (final date in TrainingCalendar.month(
                          month,
                          widget.firstDay,
                        ))
                          SizedBox(
                            width: box.maxWidth / 7,
                            child: date == null
                                ? const SizedBox(height: 48)
                                : dayCell(date, days),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${entries.length} completed workout${entries.length == 1 ? '' : 's'}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  if (entries.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text('No completed workouts on this day.'),
                    ),
                  for (final entry in entries)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.check_circle,
                        color: AppColors.primary,
                      ),
                      title: Text(entry.title),
                      subtitle: Text(
                        '${entry.seconds ~/ 60} min ${entry.seconds % 60} sec • ${entry.finishedAt.hour.toString().padLeft(2, '0')}:${entry.finishedAt.minute.toString().padLeft(2, '0')}',
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
