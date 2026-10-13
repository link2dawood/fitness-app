import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../viewmodels/home_viewmodel.dart';
import '../../onboarding/widgets/ruler_picker.dart';
import 'history_calendar_view.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  // Sample weight data points (day-of-month → weight in lbs)
  final List<_WeightPoint> _weightData = [
    const _WeightPoint(6, 106.7),
  ];

  // Stats
  final int _workoutCount = 0;
  final int _kcalBurned = 0;
  final int _minutesTrained = 0;
  final int _dayStreak = 0;

  // Weight
  double _currentWeightLbs = 106.7;
  bool _useLbs = true;

  void _updateWeightDataPoint(int day, double lbs) {
    final existing = _weightData.indexWhere((p) => p.day == day);
    if (existing >= 0) {
      _weightData[existing] = _WeightPoint(day, lbs);
    } else {
      _weightData.add(_WeightPoint(day, lbs));
    }
  }

  // Week strip – base Sunday of current week
  late final DateTime _weekStart;
  late final DateTime _today;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    final daysFromSunday = _today.weekday % 7;
    _weekStart = _today.subtract(Duration(days: daysFromSunday));
  }

  // ─── Weight Logger Bottom Sheet ─────────────────────────────────────────────

  Future<void> _showWeightLogger() async {
    final initialWeightLbs = _currentWeightLbs;
    final initialUseLbs = _useLbs;
    final initialWeightData = List<_WeightPoint>.from(_weightData);

    bool localUseLbs = _useLbs;
    double pickedWeightLbs = _currentWeightLbs;
    bool isSaved = false;

    String dateLabel() {
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${months[_today.month - 1]} ${_today.day}, ${_today.year}';
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            final displayWeight =
                localUseLbs ? pickedWeightLbs : pickedWeightLbs / 2.20462;

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Title + date chip
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Weight',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          dateLabel(),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // kg / lbs toggle
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _unitBtn('kg', !localUseLbs, () {
                          if (localUseLbs) {
                            setSheet(() => localUseLbs = false);
                            setState(() => _useLbs = false);
                          }
                        }),
                        _unitBtn('lbs', localUseLbs, () {
                          if (!localUseLbs) {
                            setSheet(() => localUseLbs = true);
                            setState(() => _useLbs = true);
                          }
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Weight value
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: displayWeight.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF111827),
                            height: 1,
                          ),
                        ),
                        TextSpan(
                          text: ' ${localUseLbs ? "lbs" : "kg"}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Clean Ruler picker using RulerPicker
                  RulerPicker(
                    key: ValueKey<bool>(localUseLbs),
                    min: localUseLbs ? 66 : 30,
                    max: localUseLbs ? 440 : 200,
                    value: displayWeight.round(),
                    decimalValue: displayWeight,
                    stepWidth: 80.0,
                    labelInterval: 1,
                    visualTicksPerStep: 10,
                    onChanged: (v) {},
                    onDecimalChanged: (v) {
                      final newLbs = localUseLbs ? v : v * 2.20462;
                      pickedWeightLbs = newLbs;
                      setSheet(() {});
                      setState(() {
                        _currentWeightLbs = newLbs;
                        _updateWeightDataPoint(_today.day, newLbs);
                      });
                    },
                  ),

                  const SizedBox(height: 32),

                  // Cancel / Save
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.of(ctx).pop(),
                          child: Container(
                            height: 54,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Center(
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF374151),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            isSaved = true;
                            setState(() {
                              _currentWeightLbs = pickedWeightLbs;
                              _useLbs = localUseLbs;
                              _updateWeightDataPoint(_today.day, pickedWeightLbs);
                            });
                            Navigator.of(ctx).pop();
                          },
                          child: Container(
                            height: 54,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0066FF),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Center(
                              child: Text(
                                'Save',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (!isSaved) {
      setState(() {
        _currentWeightLbs = initialWeightLbs;
        _useLbs = initialUseLbs;
        _weightData
          ..clear()
          ..addAll(initialWeightData);
      });
    } else {
      if (mounted) {
        final kg = (_currentWeightLbs / 2.20462).round();
        context.read<HomeViewModel>().updateWeight(kg);
      }
    }
  }

  // ─── Height Picker Bottom Sheet (Matching Reference Screenshot) ───────────

  Future<void> _showHeightPicker() async {
    final vm = context.read<HomeViewModel>();
    final initialHeightCm = vm.profile?.heightCm ?? 170;

    bool localUseFt = true;
    int pickedHeightCm = initialHeightCm;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            final totalInches = (pickedHeightCm / 2.54).round();
            final ft = totalInches ~/ 12;
            final inches = totalInches % 12;

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title "Height"
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Height',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // cm / ft toggle pill
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _unitBtn('cm', !localUseFt, () {
                          setSheet(() => localUseFt = false);
                        }),
                        _unitBtn('ft', localUseFt, () {
                          setSheet(() => localUseFt = true);
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Height Display (Big blue numbers)
                  if (localUseFt)
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$ft',
                            style: const TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0066FF),
                              height: 1,
                            ),
                          ),
                          const TextSpan(
                            text: ' ft ',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                            ),
                          ),
                          TextSpan(
                            text: '$inches',
                            style: const TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0066FF),
                              height: 1,
                            ),
                          ),
                          const TextSpan(
                            text: ' in',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$pickedHeightCm',
                            style: const TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0066FF),
                              height: 1,
                            ),
                          ),
                          const TextSpan(
                            text: ' cm',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Height Ruler
                  if (localUseFt)
                    RulerPicker(
                      key: const ValueKey<String>('height_ft_modal'),
                      min: 3,
                      max: 8,
                      step: 1,
                      labelInterval: 1,
                      visualTicksPerStep: 12,
                      stepWidth: 96.0,
                      value: ft,
                      decimalValue: ft + inches / 12.0,
                      onChanged: (v) {},
                      onDecimalChanged: (val) {
                        final inTotal = (val * 12.0).round();
                        final newCm = (inTotal * 2.54).round();
                        pickedHeightCm = newCm;
                        setSheet(() {});
                      },
                    )
                  else
                    RulerPicker(
                      key: const ValueKey<String>('height_cm_modal'),
                      min: 100,
                      max: 230,
                      step: 10,
                      labelInterval: 10,
                      visualTicksPerStep: 10,
                      stepWidth: 80.0,
                      value: (pickedHeightCm / 10).round() * 10,
                      decimalValue: pickedHeightCm.toDouble(),
                      onChanged: (v) {},
                      onDecimalChanged: (val) {
                        pickedHeightCm = val.round();
                        setSheet(() {});
                      },
                    ),

                  const SizedBox(height: 32),

                  // Cancel / Save Buttons
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.of(ctx).pop(),
                          child: Container(
                            height: 54,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Center(
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            await vm.updateHeight(pickedHeightCm);
                            if (ctx.mounted) Navigator.of(ctx).pop();
                          },
                          child: Container(
                            height: 54,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0066FF),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Center(
                              child: Text(
                                'Save',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Unit toggle button helper
  Widget _unitBtn(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF0066FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : const Color(0xFF9CA3AF),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final profile = vm.profile;

    final heightCm = profile?.heightCm ?? 170;
    final totalInches = (heightCm / 2.54).round();
    final heightFt = totalInches ~/ 12;
    final heightIn = totalInches % 12;

    final weightKg = _currentWeightLbs / 2.20462;
    final heightM = heightCm / 100.0;
    final bmi = (heightM > 0)
        ? (weightKg / (heightM * heightM))
        : (profile?.bmi ?? 15.8);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── AppBar ──────────────────────────────────────────────
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Text(
                  'REPORT',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                    color: Color(0xFF111827),
                  ),
                ),
              ),

              // ── Summary Card ─────────────────────────────────────────
              _buildSummaryCard(),

              const SizedBox(height: 24),

              // ── History ──────────────────────────────────────────────
              _buildSectionHeader(
                'History',
                actionLabel: 'All records',
                onAction: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const HistoryCalendarView(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _buildHistoryCard(),

              const SizedBox(height: 24),

              // ── Weight ───────────────────────────────────────────────
              _buildSectionHeader(
                'Weight',
                actionWidget: _blueButton('Log', _showWeightLogger),
              ),
              const SizedBox(height: 10),
              _buildWeightCard(),

              const SizedBox(height: 24),

              // ── BMI ──────────────────────────────────────────────────
              _buildSectionHeader('BMI'),
              const SizedBox(height: 10),
              _buildBmiCard(bmi, heightFt, heightIn),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Summary Card ──────────────────────────────────────────────────────────

  Widget _buildSummaryCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(icon: _medalIcon(), value: '$_workoutCount', label: 'Workout'),
            _buildDivider(),
            _buildStatItem(icon: _fireIcon(), value: '$_kcalBurned', label: 'Kcal'),
            _buildDivider(),
            _buildStatItem(icon: _clockIcon(), value: '$_minutesTrained', label: 'Minute'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required Widget icon,
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Color(0xFF111827),
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF9CA3AF),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() =>
      Container(width: 1, height: 50, color: const Color(0xFFF0F0F0));

  // ─── History Card ───────────────────────────────────────────────────────────

  Widget _buildHistoryCard() {
    const dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day-of-week labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: dayLabels.map((d) {
                return SizedBox(
                  width: 36,
                  child: Center(
                    child: Text(
                      d,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFAAAAAA),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            // Date numbers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                final date = _weekStart.add(Duration(days: i));
                final isToday = date.day == _today.day &&
                    date.month == _today.month &&
                    date.year == _today.year;

                return SizedBox(
                  width: 36,
                  height: 36,
                  child: Center(
                    child: isToday
                        ? Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF0066FF),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${date.day}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ),
                          )
                        : Text(
                            '${date.day}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: date.isBefore(_today)
                                  ? const Color(0xFF6B7280)
                                  : const Color(0xFFBBBBBB),
                            ),
                          ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 20),
            const Divider(color: Color(0xFFF2F2F2), height: 1),
            const SizedBox(height: 16),

            // Day Streak
            const Text(
              'Day Streak',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF9CA3AF),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 6),
                Text(
                  '$_dayStreak',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Weight Card ────────────────────────────────────────────────────────────

  Widget _buildWeightCard() {
    final currentDisplay = _useLbs ? _currentWeightLbs : (_currentWeightLbs / 2.20462);
    final unitLabel = _useLbs ? 'lbs' : 'kg';

    final heaviestLbs = _weightData.isEmpty
        ? _currentWeightLbs
        : _weightData.map((e) => e.value).reduce(math.max);
    final lightestLbs = _weightData.isEmpty
        ? _currentWeightLbs
        : _weightData.map((e) => e.value).reduce(math.min);

    final heaviestDisplay = _useLbs ? heaviestLbs : (heaviestLbs / 2.20462);
    final lightestDisplay = _useLbs ? lightestLbs : (lightestLbs / 2.20462);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current weight
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${currentDisplay.toStringAsFixed(1)} $unitLabel',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Heaviest / Lightest
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Heaviest ',
                          style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                        ),
                        Text(
                          heaviestDisplay.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text(
                          'Lightest   ',
                          style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                        ),
                        Text(
                          lightestDisplay.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 6),
            Center(
              child: Text(
                _monthName(_today.month),
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Weight chart
            SizedBox(
              height: 140,
              child: _WeightChart(
                data: _weightData
                    .map((e) => _WeightPoint(
                          e.day,
                          _useLbs ? e.value : e.value / 2.20462,
                        ))
                    .toList(),
                currentValue: currentDisplay,
                todayDay: _today.day,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── BMI Card ───────────────────────────────────────────────────────────────

  Widget _buildBmiCard(double bmi, int heightFt, int heightIn) {
    final String bmiLabel;
    final Color bmiDotColor;

    if (bmi < 16) {
      bmiLabel = 'Very underweight';
      bmiDotColor = const Color(0xFF6366F1);
    } else if (bmi < 18.5) {
      bmiLabel = 'Underweight';
      bmiDotColor = const Color(0xFF3B82F6);
    } else if (bmi < 25) {
      bmiLabel = 'Normal weight';
      bmiDotColor = const Color(0xFF22C55E);
    } else if (bmi < 30) {
      bmiLabel = 'Overweight';
      bmiDotColor = const Color(0xFFF59E0B);
    } else if (bmi < 35) {
      bmiLabel = 'Obese';
      bmiDotColor = const Color(0xFFF97316);
    } else {
      bmiLabel = 'Very obese';
      bmiDotColor = const Color(0xFFEF4444);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  bmi.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: bmiDotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      bmiLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 14),
            _BmiScaleBar(bmi: bmi),

            const SizedBox(height: 18),
            const Divider(color: Color(0xFFF2F2F2), height: 1),
            const SizedBox(height: 14),

            // Height row with Edit icon opening Height Picker
            GestureDetector(
              onTap: _showHeightPicker,
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  const Text(
                    'Height',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$heightFt ft $heightIn in',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: Color(0xFF9CA3AF),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  Widget _buildSectionHeader(
    String title, {
    String? actionLabel,
    VoidCallback? onAction,
    Widget? actionWidget,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const Spacer(),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0066FF),
                ),
              ),
            ),
          ?actionWidget,
        ],
      ),
    );
  }

  Widget _blueButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF0066FF),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _medalIcon() => SizedBox(
        width: 38,
        height: 38,
        child: CustomPaint(painter: _MedalIconPainter()),
      );

  Widget _fireIcon() => SizedBox(
        width: 38,
        height: 38,
        child: CustomPaint(painter: _FlameIconPainter()),
      );

  Widget _clockIcon() => SizedBox(
        width: 38,
        height: 38,
        child: CustomPaint(painter: _ClockIconPainter()),
      );

  String _monthName(int month) {
    const names = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return names[month - 1];
  }
}

// ─── Weight Chart ─────────────────────────────────────────────────────────────

class _WeightPoint {
  const _WeightPoint(this.day, this.value);
  final int day;
  final double value;
}

class _WeightChart extends StatelessWidget {
  const _WeightChart({
    required this.data,
    required this.currentValue,
    required this.todayDay,
  });

  final List<_WeightPoint> data;
  final double currentValue;
  final int todayDay;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _WeightChartPainter(
        data: data,
        currentValue: currentValue,
        todayDay: todayDay,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _WeightChartPainter extends CustomPainter {
  _WeightChartPainter({
    required this.data,
    required this.currentValue,
    required this.todayDay,
  });

  final List<_WeightPoint> data;
  final double currentValue;
  final int todayDay;

  @override
  void paint(Canvas canvas, Size size) {
    const leftPad = 46.0;
    const bottomPad = 24.0;
    const topPad = 6.0;

    final chartW = size.width - leftPad;
    final chartH = size.height - bottomPad - topPad;

    const textStyle = TextStyle(
      fontSize: 10,
      color: Color(0xFFBBBBBB),
      fontWeight: FontWeight.w500,
    );

    final allValues = data.isEmpty ? [currentValue] : data.map((e) => e.value).toList();
    final minDataVal = allValues.reduce(math.min);
    final maxDataVal = allValues.reduce(math.max);
    final span = maxDataVal - minDataVal;

    double step = 0.2;
    if (span > 6.0) {
      step = (span / 5).ceilToDouble();
    } else if (span > 3.0) {
      step = 1.0;
    } else if (span > 1.2) {
      step = 0.5;
    }

    final midVal = (minDataVal + maxDataVal) / 2;
    final centerAligned = (midVal / step).round() * step;
    double minVal = centerAligned - 3 * step;
    double maxVal = centerAligned + 3 * step;

    while (minDataVal < minVal + 0.05) {
      minVal -= step;
      maxVal -= step;
    }
    while (maxDataVal > maxVal - 0.05) {
      maxVal += step;
      minVal += step;
    }

    final yLabels = <double>[];
    for (int i = 6; i >= 0; i--) {
      yLabels.add(minVal + i * step);
    }

    for (final yVal in yLabels) {
      final frac = ((yVal - minVal) / (maxVal - minVal)).clamp(0.0, 1.0);
      final y = topPad + chartH * (1.0 - frac);

      final gridPaint = Paint()
        ..color = const Color(0xFFF0F0F0)
        ..strokeWidth = 0.8;
      canvas.drawLine(Offset(leftPad, y), Offset(size.width, y), gridPaint);

      final labelText = (yVal == yVal.roundToDouble())
          ? yVal.toInt().toString()
          : yVal.toStringAsFixed(1);
      _drawText(canvas, labelText, Offset(0, y - 6), textStyle, leftPad - 4);
    }

    final maxDay = math.max(8, todayDay);
    final startDay = maxDay > 8 ? maxDay - 7 : 1;
    final endDay = maxDay;
    const totalDays = 8;

    final xLabels = List.generate(totalDays, (i) {
      final d = startDay + i;
      return d.toString().padLeft(2, '0');
    });

    for (int i = 0; i < xLabels.length; i++) {
      final x = leftPad + (i / (totalDays - 1)) * chartW;
      _drawText(
        canvas,
        xLabels[i],
        Offset(x - 10, size.height - bottomPad + 6),
        textStyle,
        22,
      );
    }

    if (data.isNotEmpty) {
      final sortedData = List<_WeightPoint>.from(data)
        ..sort((a, b) => a.day.compareTo(b.day));

      final points = <Offset>[];
      for (final pt in sortedData) {
        if (pt.day < startDay || pt.day > endDay) continue;
        final xFrac = ((pt.day - startDay) / (endDay - startDay)).clamp(0.0, 1.0);
        final yFrac = ((pt.value - minVal) / (maxVal - minVal)).clamp(0.0, 1.0);
        final x = leftPad + xFrac * chartW;
        final y = topPad + chartH * (1.0 - yFrac);
        points.add(Offset(x, y));
      }

      if (points.length > 1) {
        final linePaint = Paint()
          ..color = const Color(0xFF0066FF).withValues(alpha: 0.6)
          ..strokeWidth = 1.8
          ..style = PaintingStyle.stroke;

        final path = Path()..moveTo(points[0].dx, points[0].dy);
        for (int i = 1; i < points.length; i++) {
          path.lineTo(points[i].dx, points[i].dy);
        }
        canvas.drawPath(path, linePaint);
      }

      final dotPaint = Paint()
        ..color = const Color(0xFF0066FF)
        ..style = PaintingStyle.fill;
      for (final p in points) {
        canvas.drawCircle(p, 4, dotPaint);
      }
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    TextStyle style,
    double maxWidth,
  ) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _WeightChartPainter old) =>
      old.data != data ||
      old.currentValue != currentValue ||
      old.todayDay != todayDay;
}

// ─── BMI Scale Bar ────────────────────────────────────────────────────────────

class _BmiScaleBar extends StatelessWidget {
  const _BmiScaleBar({required this.bmi});
  final double bmi;

  static const _labelStyle = TextStyle(
    fontSize: 10,
    color: Color(0xFF9CA3AF),
    fontWeight: FontWeight.w500,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 28,
          child: CustomPaint(
            painter: _ScaleBarPainter(bmi: bmi),
            child: const SizedBox.expand(),
          ),
        ),
        const SizedBox(height: 6),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('15', style: _labelStyle),
            Text('16', style: _labelStyle),
            Text('18.5', style: _labelStyle),
            Text('25', style: _labelStyle),
            Text('30', style: _labelStyle),
            Text('35', style: _labelStyle),
            Text('40', style: _labelStyle),
          ],
        ),
      ],
    );
  }
}

class _ScaleBarPainter extends CustomPainter {
  const _ScaleBarPainter({required this.bmi});
  final double bmi;

  static const double _minBmi = 15;
  static const double _maxBmi = 40;

  static const List<_Segment> _segments = [
    _Segment(15, 16, Color(0xFF6366F1)),
    _Segment(16, 18.5, Color(0xFF3B82F6)),
    _Segment(18.5, 21.5, Color(0xFF22C55E)),
    _Segment(21.5, 25, Color(0xFF84CC16)),
    _Segment(25, 30, Color(0xFFF59E0B)),
    _Segment(30, 35, Color(0xFFF97316)),
    _Segment(35, 40, Color(0xFFEF4444)),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    const barHeight = 12.0;
    const barTop = 14.0;
    const totalRange = _maxBmi - _minBmi;

    canvas.save();
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, barTop, size.width, barHeight),
      const Radius.circular(6),
    );
    canvas.clipRRect(rrect);

    for (final seg in _segments) {
      final left = (seg.start - _minBmi) / totalRange * size.width;
      final right = (seg.end - _minBmi) / totalRange * size.width;
      canvas.drawRect(
        Rect.fromLTWH(left, barTop, right - left, barHeight),
        Paint()..color = seg.color,
      );
    }
    canvas.restore();

    final clampedBmi = bmi.clamp(_minBmi, _maxBmi);
    final indicatorX = (clampedBmi - _minBmi) / totalRange * size.width;

    final path = Path()
      ..moveTo(indicatorX, barTop - 1)
      ..lineTo(indicatorX - 5, 4)
      ..lineTo(indicatorX + 5, 4)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFF374151));
  }

  @override
  bool shouldRepaint(covariant _ScaleBarPainter old) => old.bmi != bmi;
}

class _Segment {
  const _Segment(this.start, this.end, this.color);
  final double start;
  final double end;
  final Color color;
}

// ─── Icon Painters ────────────────────────────────────────────────────────────

class _MedalIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    canvas.drawCircle(
      Offset(cx, cy + 5),
      12,
      Paint()..color = const Color(0xFF93C5FD).withValues(alpha: 0.3),
    );
    canvas.drawCircle(
      Offset(cx, cy + 5),
      12,
      Paint()
        ..color = const Color(0xFF0066FF).withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    final rib = Paint()..color = const Color(0xFF93C5FD);
    canvas.drawPath(
      Path()
        ..moveTo(cx - 6, cy - 8)
        ..lineTo(cx - 2, cy - 1)
        ..lineTo(cx, cy - 5)
        ..close(),
      rib,
    );
    canvas.drawPath(
      Path()
        ..moveTo(cx + 6, cy - 8)
        ..lineTo(cx + 2, cy - 1)
        ..lineTo(cx, cy - 5)
        ..close(),
      rib,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _FlameIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final t = size.height * 0.05;
    final b = size.height * 0.95;

    final fill = Paint()
      ..color = const Color(0xFF0066FF).withValues(alpha: 0.2);
    final stroke = Paint()
      ..color = const Color(0xFF0066FF).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final path = Path()
      ..moveTo(cx, t)
      ..cubicTo(cx + 12, t + 8, cx + 14, t + 16, cx + 8, t + 18)
      ..cubicTo(cx + 16, t + 14, cx + 12, t + 24, cx + 6, t + 28)
      ..cubicTo(cx + 10, t + 22, cx + 4, t + 30, cx, b)
      ..cubicTo(cx - 4, t + 30, cx - 10, t + 22, cx - 6, t + 28)
      ..cubicTo(cx - 12, t + 24, cx - 16, t + 14, cx - 8, t + 18)
      ..cubicTo(cx - 14, t + 16, cx - 12, t + 8, cx, t)
      ..close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _ClockIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    const r = 13.0;

    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()..color = const Color(0xFF111827).withValues(alpha: 0.08),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = const Color(0xFF374151).withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    final hand = Paint()
      ..color = const Color(0xFF374151)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, cy), Offset(cx, cy - 7), hand);
    canvas.drawLine(Offset(cx, cy), Offset(cx + 5, cy + 2), hand);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
