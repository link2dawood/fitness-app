import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../data/models/exercise.dart';
import '../../data/models/training_search.dart';
import '../home/pages/training_collection_page.dart';
import '../settings/feature_suggestions_sheet.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key, this.initialQuery = ''});
  final String initialQuery;

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  late final TextEditingController controller = TextEditingController(
    text: widget.initialQuery,
  );
  final FocusNode _focusNode = FocusNode();

  String? _selectedBodyFocus;
  String? _selectedWorkoutType;
  String? _selectedLevel;
  int? _selectedDurationBand;

  static const List<({String label, String asset, ExerciseFocus? focus})>
  _bodyFocusItems = [
    (
      label: 'Abs',
      asset: 'assets/images/body/abs.png',
      focus: ExerciseFocus.abs,
    ),
    (
      label: 'Full Body',
      asset: 'assets/images/body/fullbody.png',
      focus: null,
    ),
    (
      label: 'Arm',
      asset: 'assets/images/body/arm.png',
      focus: ExerciseFocus.arm,
    ),
    (
      label: 'Butt & Leg',
      asset: 'assets/images/body/leg.png',
      focus: ExerciseFocus.leg,
    ),
    (
      label: 'Chest',
      asset: 'assets/images/body/chest.png',
      focus: ExerciseFocus.chest,
    ),
    (
      label: 'Back',
      asset: 'assets/images/body/back.png',
      focus: ExerciseFocus.back,
    ),
    (
      label: 'Shoulder',
      asset: 'assets/images/body/shoulder.png',
      focus: ExerciseFocus.shoulder,
    ),
  ];

  // Ordered by 2-row columns to match the reference horizontal grid:
  // Col 1: Fat Burning / Warm-Up
  // Col 2: Build Muscle / With Equipment
  // Col 3: HIIT / Stretch
  // Col 4: Low Impact
  static const List<({String id, String displayLabel, String queryToken})>
  _workoutTypes = [
    (id: 'fat_burning', displayLabel: 'Fat\nBurning', queryToken: 'Burn Fat'),
    (id: 'warm_up', displayLabel: 'Warm-Up', queryToken: 'Warm-Up'),
    (
      id: 'build_muscle',
      displayLabel: 'Build\nMuscle',
      queryToken: 'Build Muscle',
    ),
    (
      id: 'with_equipment',
      displayLabel: 'With\nEquipment',
      queryToken: 'With Equipment',
    ),
    (id: 'hiit', displayLabel: 'HIIT', queryToken: 'HIIT'),
    (id: 'stretch', displayLabel: 'Stretch', queryToken: 'Stretch'),
    (id: 'low_impact', displayLabel: 'Low\nImpact', queryToken: 'Keep Fit'),
  ];

  static const List<
    ({
      String label,
      Color bgColor,
      Color textColor,
      ExerciseDifficulty difficulty,
    })
  >
  _levels = [
    (
      label: 'Beginner',
      bgColor: Color(0xFFEAF2FF),
      textColor: Color(0xFF1E65F3),
      difficulty: ExerciseDifficulty.easy,
    ),
    (
      label: 'Intermediate',
      bgColor: Color(0xFFFFF3E6),
      textColor: Color(0xFFE07A1A),
      difficulty: ExerciseDifficulty.medium,
    ),
    (
      label: 'Advanced',
      bgColor: Color(0xFFFDECEF),
      textColor: Color(0xFFD94362),
      difficulty: ExerciseDifficulty.hard,
    ),
  ];

  static const List<({String range, int band})> _durations = [
    (range: '≤10', band: 0),
    (range: '11-20', band: 1),
    (range: '21-30', band: 2),
    (range: '>30', band: 3),
  ];

  @override
  void dispose() {
    controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  ExerciseFocus? get _activeFocus {
    if (_selectedBodyFocus == null) return null;
    for (final item in _bodyFocusItems) {
      if (item.label == _selectedBodyFocus) return item.focus;
    }
    return null;
  }

  ExerciseDifficulty? get _activeDifficulty {
    if (_selectedLevel == null) return null;
    for (final item in _levels) {
      if (item.label == _selectedLevel) return item.difficulty;
    }
    return null;
  }

  String get _effectiveQuery {
    final parts = <String>[];
    final base = controller.text.trim();
    if (base.isNotEmpty) parts.add(base);
    if (_selectedBodyFocus == 'Full Body') parts.add('Full Body');
    if (_selectedWorkoutType != null) {
      parts.add(
        _workoutTypes
            .firstWhere((t) => t.id == _selectedWorkoutType)
            .queryToken,
      );
    }
    return parts.join(' ');
  }

  bool get _hasActiveSearchOrFilter =>
      controller.text.trim().isNotEmpty ||
      _selectedBodyFocus != null ||
      _selectedWorkoutType != null ||
      _selectedLevel != null ||
      _selectedDurationBand != null;

  @override
  Widget build(BuildContext context) {
    final results = TrainingSearch.results(
      query: _effectiveQuery,
      focus: _activeFocus,
      difficulty: _activeDifficulty,
      durationBand: _selectedDurationBand,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Search Bar & Cancel Button ────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F3F7),
                        borderRadius: BorderRadius.circular(23),
                      ),
                      child: TextField(
                        controller: controller,
                        focusNode: _focusNode,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF111827),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search workouts, plans...',
                          hintStyle: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF9CA3AF),
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: Color(0xFF9CA3AF),
                            size: 22,
                          ),
                          suffixIcon: controller.text.isNotEmpty
                              ? IconButton(
                                  tooltip: 'Clear search',
                                  onPressed: () => setState(controller.clear),
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    color: Color(0xFF6B7280),
                                    size: 20,
                                  ),
                                )
                              : IconButton(
                                  tooltip: 'Clear search',
                                  onPressed: () => setState(controller.clear),
                                  icon: const SizedBox.shrink(),
                                ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0055FF),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Scrollable Body ───────────────────────────────────────────
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),

                        // 1. Body Focus
                        _buildSectionHeader('Body Focus'),
                        const SizedBox(height: 14),
                        _buildBodyFocusList(),

                        const SizedBox(height: 26),

                        // 2. Workout Type
                        _buildSectionHeader('Workout Type'),
                        const SizedBox(height: 14),
                        _buildWorkoutTypeGrid(),

                        const SizedBox(height: 26),

                        // 3. Level
                        _buildSectionHeader('Level'),
                        const SizedBox(height: 14),
                        _buildLevelRow(),

                        const SizedBox(height: 26),

                        // 4. Duration
                        _buildSectionHeader('Duration'),
                        const SizedBox(height: 14),
                        _buildDurationRow(),

                        const SizedBox(height: 30),

                        // 5. Can't find what you want? / Tell us what you need
                        _buildRequestSection(),

                        const SizedBox(height: 24),

                        // 6. Search / Filter Results Summary
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${results.length} workouts',
                                  key: const ValueKey('workout-search-count'),
                                  style: TextStyle(
                                    fontSize: _hasActiveSearchOrFilter ? 16 : 13,
                                    fontWeight: FontWeight.w800,
                                    color: _hasActiveSearchOrFilter
                                        ? const Color(0xFF111827)
                                        : const Color(0xFF9CA3AF),
                                  ),
                                ),
                              ),
                              if (_hasActiveSearchOrFilter)
                                TextButton(
                                  onPressed: () => setState(() {
                                    controller.clear();
                                    _selectedBodyFocus = null;
                                    _selectedWorkoutType = null;
                                    _selectedLevel = null;
                                    _selectedDurationBand = null;
                                  }),
                                  child: const Text('Clear all'),
                                ),
                            ],
                          ),
                        ),
                        if (results.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 20,
                            ),
                            child: Text(
                              'No workouts match. Try changing your search or filters.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (_hasActiveSearchOrFilter)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                      sliver: SliverList.builder(
                        itemCount: results.length,
                        itemBuilder: (_, i) =>
                            TrainingWorkoutTile(workout: results[i]),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w900,
          color: Color(0xFF111827),
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  Widget _buildBodyFocusList() {
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _bodyFocusItems.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final item = _bodyFocusItems[index];
          final isSelected = _selectedBodyFocus == item.label;

          return GestureDetector(
            key: ValueKey<String>('search-body-focus-${item.label}'),
            onTap: () {
              setState(() {
                _selectedBodyFocus = isSelected ? null : item.label;
              });
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF3F4F6),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF0055FF)
                          : Colors.transparent,
                      width: 2.2,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      item.asset,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.fitness_center_rounded,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFF0055FF)
                        : const Color(0xFF111827),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWorkoutTypeGrid() {
    // 4 columns: first 3 columns have 2 cards each, 4th column has 1 card (Low Impact)
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              _buildWorkoutTypeCard(_workoutTypes[0]), // Fat Burning
              const SizedBox(height: 10),
              _buildWorkoutTypeCard(_workoutTypes[1]), // Warm-Up
            ],
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              _buildWorkoutTypeCard(_workoutTypes[2]), // Build Muscle
              const SizedBox(height: 10),
              _buildWorkoutTypeCard(_workoutTypes[3]), // With Equipment
            ],
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              _buildWorkoutTypeCard(_workoutTypes[4]), // HIIT
              const SizedBox(height: 10),
              _buildWorkoutTypeCard(_workoutTypes[5]), // Stretch
            ],
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              _buildWorkoutTypeCard(_workoutTypes[6]), // Low Impact
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutTypeCard(
    ({String id, String displayLabel, String queryToken}) item,
  ) {
    final isSelected = _selectedWorkoutType == item.id;
    final fgColor = isSelected
        ? const Color(0xFF0055FF)
        : const Color(0xFF111827);

    return GestureDetector(
      key: ValueKey<String>('search-workout-type-${item.id}'),
      onTap: () {
        setState(() {
          _selectedWorkoutType = isSelected ? null : item.id;
        });
      },
      child: Container(
        width: 160,
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0055FF).withValues(alpha: 0.10)
              : const Color(0xFFF2F6FC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF0055FF) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                item.displayLabel,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: fgColor,
                  height: 1.2,
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 32,
              height: 32,
              child: CustomPaint(
                painter: _WorkoutTypeIconPainter(
                  typeId: item.id,
                  color: fgColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (var i = 0; i < _levels.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Builder(
              builder: (context) {
                final item = _levels[i];
                final isSelected = _selectedLevel == item.label;
                return GestureDetector(
                  key: ValueKey<String>('search-level-${item.label}'),
                  onTap: () {
                    setState(() {
                      _selectedLevel = isSelected ? null : item.label;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: item.bgColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? item.textColor : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: item.textColor,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDurationRow() {
    return SizedBox(
      height: 68,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _durations.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = _durations[index];
          final isSelected = _selectedDurationBand == item.band;

          return GestureDetector(
            key: ValueKey<String>('search-duration-${item.range}'),
            onTap: () {
              setState(() {
                _selectedDurationBand = isSelected ? null : item.band;
              });
            },
            child: Container(
              width: 118,
              height: 68,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF0055FF).withValues(alpha: 0.10)
                    : const Color(0xFFF3F6FC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF0055FF)
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -6,
                    bottom: -8,
                    child: SizedBox(
                      width: 62,
                      height: 62,
                      child: CustomPaint(
                        painter: _DurationClockWatermarkPainter(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.range,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: isSelected
                                ? const Color(0xFF0055FF)
                                : const Color(0xFF111827),
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'mins',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? const Color(0xFF0055FF)
                                : const Color(0xFF1F2937),
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRequestSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: const [
              Expanded(child: Divider(color: Color(0xFFF1F5F9), thickness: 1)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  "Can't find what you want?",
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
              Expanded(child: Divider(color: Color(0xFFF1F5F9), thickness: 1)),
            ],
          ),
          const SizedBox(height: 14),
          Material(
            color: const Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => showFeatureSuggestions(context),
              child: Container(
                height: 52,
                width: double.infinity,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: Color(0xFF0055FF),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Tell us what you need',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0055FF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DurationClockWatermarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-0.22);

    final strokePaint = Paint()
      ..color = const Color(0xFFE7EDF8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: 44, height: 44),
      const Radius.circular(12),
    );
    canvas.drawRRect(rrect, strokePaint);

    final handPath = Path()
      ..moveTo(0, -11)
      ..lineTo(0, 2)
      ..lineTo(9, 2);
    canvas.drawPath(handPath, strokePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WorkoutTypeIconPainter extends CustomPainter {
  const _WorkoutTypeIconPainter({required this.typeId, required this.color});

  final String typeId;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    switch (typeId) {
      case 'fat_burning':
        // Outlined flame icon
        final path = Path()
          ..moveTo(cx - 1, cy - 12)
          ..cubicTo(cx + 3, cy - 7, cx + 2, cy - 3, cx + 4, cy - 1)
          ..cubicTo(cx + 6, cy - 4, cx + 7, cy - 6, cx + 7, cy - 6)
          ..cubicTo(cx + 11, cy - 1, cx + 11, cy + 6, cx + 6, cy + 10)
          ..cubicTo(cx + 2, cy + 13, cx - 4, cy + 13, cx - 7, cy + 9)
          ..cubicTo(cx - 11, cy + 4, cx - 8, cy - 4, cx - 1, cy - 12)
          ..close();
        canvas.drawPath(path, p);

      case 'warm_up':
        // Stretching person with raised arms
        canvas.drawCircle(Offset(cx, cy - 8), 3.0, p);
        // Raised arms V-curve
        final arms = Path()
          ..moveTo(cx - 9, cy - 10)
          ..quadraticBezierTo(cx, cy - 2, cx + 9, cy - 10);
        canvas.drawPath(arms, p);
        // Torso & legs
        final body = Path()
          ..moveTo(cx - 4, cy - 4)
          ..lineTo(cx - 3, cy + 3)
          ..lineTo(cx - 5, cy + 12)
          ..moveTo(cx + 4, cy - 4)
          ..lineTo(cx + 3, cy + 3)
          ..lineTo(cx + 5, cy + 12)
          ..moveTo(cx - 3, cy + 3)
          ..lineTo(cx + 3, cy + 3);
        canvas.drawPath(body, p);

      case 'build_muscle':
        // Flexed bicep outline
        final bicep = Path()
          ..moveTo(cx - 3, cy - 10)
          ..cubicTo(cx - 9, cy - 10, cx - 12, cy - 2, cx - 11, cy + 6)
          ..cubicTo(cx - 10, cy + 10, cx - 5, cy + 11, cx + 9, cy + 10)
          ..moveTo(cx - 3, cy - 10)
          ..cubicTo(cx, cy - 10, cx + 1, cy - 7, cx - 2, cy - 5)
          ..lineTo(cx - 5, cy - 1)
          ..cubicTo(cx - 1, cy - 4, cx + 5, cy - 4, cx + 8, cy)
          ..cubicTo(cx + 10, cy + 2, cx + 10, cy + 6, cx + 8, cy + 8);
        canvas.drawPath(bicep, p);

      case 'with_equipment':
        // Tilted dumbbell outline
        canvas.save();
        canvas.translate(cx, cy);
        canvas.rotate(-math.pi / 4);
        // Center bar
        canvas.drawLine(const Offset(-5, 0), const Offset(5, 0), p);
        // Left plates
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-9, -6, 4, 12),
            const Radius.circular(1.5),
          ),
          p,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-13, -4, 4, 8),
            const Radius.circular(1.5),
          ),
          p,
        );
        // Right plates
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(5, -6, 4, 12),
            const Radius.circular(1.5),
          ),
          p,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(9, -4, 4, 8),
            const Radius.circular(1.5),
          ),
          p,
        );
        canvas.restore();

      case 'hiit':
        // Outlined lightning bolt
        final bolt = Path()
          ..moveTo(cx + 1, cy - 12)
          ..lineTo(cx - 8, cy + 1)
          ..lineTo(cx - 1, cy + 1)
          ..lineTo(cx - 3, cy + 12)
          ..lineTo(cx + 8, cy - 1)
          ..lineTo(cx + 1, cy - 1)
          ..close();
        canvas.drawPath(bolt, p);

      case 'stretch':
        // Seated forward-fold stretch figure
        canvas.drawCircle(Offset(cx, cy - 8), 2.8, p);
        final stretchPath = Path()
          ..moveTo(cx + 7, cy + 4)
          ..lineTo(cx - 4, cy - 2)
          ..quadraticBezierTo(cx - 10, cy + 1, cx - 9, cy + 7)
          ..quadraticBezierTo(cx - 8, cy + 10, cx - 2, cy + 10)
          ..lineTo(cx + 10, cy + 10)
          ..moveTo(cx - 3, cy + 6)
          ..lineTo(cx + 8, cy + 6);
        canvas.drawPath(stretchPath, p);

      case 'low_impact':
      default:
        // Outlined smiley face
        canvas.drawCircle(Offset(cx, cy), 11.5, p);
        final eyePaint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(cx - 4, cy - 2.5), 1.4, eyePaint);
        canvas.drawCircle(Offset(cx + 4, cy - 2.5), 1.4, eyePaint);
        canvas.drawArc(
          Rect.fromCenter(center: Offset(cx, cy + 1), width: 10, height: 8),
          0.15 * math.pi,
          0.7 * math.pi,
          false,
          p,
        );
    }
  }

  @override
  bool shouldRepaint(covariant _WorkoutTypeIconPainter oldDelegate) =>
      oldDelegate.typeId != typeId || oldDelegate.color != color;
}
