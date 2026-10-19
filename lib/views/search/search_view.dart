import 'package:flutter/material.dart';
import '../../data/models/exercise.dart';
import '../settings/feature_suggestions_sheet.dart';
import '../../data/models/training_search.dart';
import '../home/pages/training_collection_page.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key, this.initialQuery = ''});
  final String initialQuery;
  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  late final controller = TextEditingController(text: widget.initialQuery);
  ExerciseFocus? focus;
  ExerciseDifficulty? difficulty;
  ExerciseType? type;
  int? duration;
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget choices<T>(
    String title,
    List<T> values,
    T? selected,
    String Function(T) label,
    void Function(T?) change,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 8),
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final value in values)
            ChoiceChip(
              label: Text(label(value)),
              selected: selected == value,
              onSelected: (on) => setState(() => change(on ? value : null)),
            ),
        ],
      ),
    ],
  );
  @override
  Widget build(BuildContext context) {
    final results = TrainingSearch.results(
      query: controller.text,
      focus: focus,
      difficulty: difficulty,
      type: type,
      durationBand: duration,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Search workouts')),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search workouts, plans…',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        tooltip: 'Clear search',
                        onPressed: () => setState(controller.clear),
                        icon: const Icon(Icons.close),
                      ),
                    ),
                  ),
                  choices(
                    'Body Focus',
                    ExerciseFocus.values,
                    focus,
                    (v) => v.label,
                    (v) => focus = v,
                  ),
                  choices(
                    'Level',
                    ExerciseDifficulty.values,
                    difficulty,
                    (v) => v.label,
                    (v) => difficulty = v,
                  ),
                  choices(
                    'Workout Type',
                    ExerciseType.values,
                    type,
                    (v) => v.label,
                    (v) => type = v,
                  ),
                  choices(
                    'Duration',
                    [0, 1, 2, 3],
                    duration,
                    (v) => ['≤10 min', '11–20 min', '21–30 min', '>30 min'][v],
                    (v) => duration = v,
                  ),
                  TextButton(
                    onPressed: () => setState(() {
                      controller.clear();
                      focus = null;
                      difficulty = null;
                      type = null;
                      duration = null;
                    }),
                    child: const Text('Clear all'),
                  ),
                  Text(
                    '${results.length} workouts',
                    key: const ValueKey('workout-search-count'),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  TextButton.icon(
                    onPressed: () => showFeatureSuggestions(context),
                    icon: const Icon(Icons.feedback_outlined),
                    label: const Text('Tell us what you need'),
                  ),
                  if (results.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'No workouts match. Try changing your search or filters.',
                      ),
                    ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverList.builder(
              itemCount: results.length,
              itemBuilder: (_, i) => TrainingWorkoutTile(workout: results[i]),
            ),
          ),
        ],
      ),
    );
  }
}
