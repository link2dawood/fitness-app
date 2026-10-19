import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/training_calendar.dart';
import '../../data/repositories/training_history_repository.dart';

Future<void> showTrainingHistory(
  BuildContext context,
  DateTime date, {
  required String firstDay,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (_) => TrainingHistorySheet(date: date, firstDay: firstDay),
);

class TrainingHistorySheet extends StatefulWidget {
  const TrainingHistorySheet({
    super.key,
    required this.date,
    required this.firstDay,
  });
  final DateTime date;
  final String firstDay;
  @override
  State<TrainingHistorySheet> createState() => _TrainingHistorySheetState();
}

class _TrainingHistorySheetState extends State<TrainingHistorySheet> {
  late DateTime selected = TrainingHistoryRepository.day(widget.date);
  late DateTime month = DateTime(selected.year, selected.month);
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
  Widget build(BuildContext context) => SizedBox(
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
                        TrainingHistoryRepository.day(e.finishedAt) == selected,
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
