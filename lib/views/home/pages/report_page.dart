import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../viewmodels/home_viewmodel.dart';
import '../../../data/repositories/training_history_repository.dart';
import '../../../data/models/training_calendar.dart';
import '../../../core/widgets/date_rollover_builder.dart';
import '../../../data/repositories/weight_history_repository.dart';
import '../../../core/settings/general_settings.dart';
import '../../onboarding/widgets/ruler_picker.dart';
import 'history_calendar_view.dart';
import '../widgets/bmi_scale_bar.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key, this.now});
  final DateTime Function()? now;

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> with WidgetsBindingObserver {
  final _weights = WeightHistoryRepository.instance;
  bool _loadingWeights = true;
  bool _weightsFailed = false;
  List<_WeightPoint> get _weightData => _weights.records
      .where((e) => e.date.year == _now().year && e.date.month == _now().month)
      .map((e) => _WeightPoint(e.date.day, e.kg * 2.20462))
      .toList();

  Future<void> _loadWeights() async {
    setState(() {
      _loadingWeights = true;
      _weightsFailed = false;
    });
    try {
      await _weights.load();
      if (mounted) setState(() => _loadingWeights = false);
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadingWeights = false;
          _weightsFailed = true;
        });
      }
    }
  }

  // Stats
  final _history = TrainingHistoryRepository.instance;
  bool _loadingHistory = true;
  bool _historyFailed = false;
  int _loadGeneration = 0;
  bool get _historyReady => !_loadingHistory && !_historyFailed;
  int get _seconds => _history.entries.fold(0, (sum, e) => sum + e.seconds);

  Future<void> _loadHistory() async {
    final generation = ++_loadGeneration;
    setState(() {
      _loadingHistory = true;
      _historyFailed = false;
    });
    try {
      await _history.load();
      if (!mounted || generation != _loadGeneration) return;
      setState(() => _loadingHistory = false);
    } catch (_) {
      if (!mounted || generation != _loadGeneration) return;
      setState(() {
        _loadingHistory = false;
        _historyFailed = true;
      });
    }
  }

  void _onHistoryChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadHistory();
      _loadWeights();
    }
  }

  // Weight
  double _currentWeightLbs = 0;
  bool _useLbs = true;

  // Date retained for the weight logger; the history strip uses today's date.
  DateTime _now() => widget.now?.call() ?? DateTime.now();
  DateTime get _today => _now();

  @override
  void initState() {
    super.initState();
    _useLbs = GeneralSettings.instance.weightImperial;
    GeneralSettings.instance.addListener(_onUnitsChanged);
    WidgetsBinding.instance.addObserver(this);
    _history.addListener(_onHistoryChanged);
    _weights.addListener(_onHistoryChanged);
    _loadWeights();
    _loadHistory();
  }

  void _onUnitsChanged() {
    if (mounted) {
      setState(() => _useLbs = GeneralSettings.instance.weightImperial);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _history.removeListener(_onHistoryChanged);
    _weights.removeListener(_onHistoryChanged);
    GeneralSettings.instance.removeListener(_onUnitsChanged);
    super.dispose();
  }

  // ─── Weight Logger Bottom Sheet ─────────────────────────────────────────────

  Future<void> _showWeightLogger() async {
    final vm = context.read<HomeViewModel>();
    final savedKg = _weights.records.isNotEmpty
        ? _weights.records.last.kg
        : vm.profile?.weightKg;
    // A picker needs a starting position, but this draft is never report data.
    _currentWeightLbs =
        (savedKg != null && savedKg > 0 ? savedKg : 70) * 2.20462;

    bool localUseLbs = _useLbs;
    double pickedWeightLbs = _currentWeightLbs;
    bool saving = false;
    String? saveError;

    String dateLabel() {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[_today.month - 1]} ${_today.day}, ${_today.year}';
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DateRolloverBuilder(
          now: widget.now,
          builder: (_) => StatefulBuilder(
            builder: (ctx, setSheet) {
              final displayWeight = localUseLbs
                  ? pickedWeightLbs
                  : pickedWeightLbs / 2.20462;

              return SingleChildScrollView(
                child: SafeArea(
                  top: false,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
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
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          alignment: WrapAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Weight',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF111827),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
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
                                }
                              }),
                              _unitBtn('lbs', localUseLbs, () {
                                if (!localUseLbs) {
                                  setSheet(() => localUseLbs = true);
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
                            if (saving) return;
                            final newLbs = localUseLbs ? v : v * 2.20462;
                            pickedWeightLbs = newLbs;
                            setSheet(() {});
                          },
                        ),

                        const SizedBox(height: 32),

                        if (saveError != null) Text(saveError!),
                        const Text(
                          'Picker units only. Report uses General Settings.',
                          textAlign: TextAlign.center,
                        ),
                        // Cancel / Save
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: saving
                                    ? null
                                    : () => Navigator.of(ctx).pop(),
                                child: Container(
                                  constraints: const BoxConstraints(
                                    minHeight: 48,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 12,
                                  ),
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
                              child: TextButton(
                                onPressed: saving
                                    ? null
                                    : () async {
                                        if (saving) return;
                                        setSheet(() {
                                          saving = true;
                                          saveError = null;
                                        });
                                        bool historySaved = false;
                                        try {
                                          final kg = double.parse(
                                            (pickedWeightLbs / 2.20462)
                                                .toStringAsFixed(4),
                                          );
                                          await _weights.save(
                                            WeightRecord(date: _now(), kg: kg),
                                          );
                                          historySaved = true;
                                          await vm.updateWeight(kg);
                                          if (!ctx.mounted) return;
                                          Navigator.of(ctx).pop();
                                        } catch (_) {
                                          if (ctx.mounted) {
                                            setSheet(() {
                                              saving = false;
                                              saveError = historySaved
                                                  ? 'Weight log saved. Profile sync failed; tap Save to retry.'
                                                  : 'Could not save weight. Please retry.';
                                            });
                                          }
                                        }
                                      },
                                child: Container(
                                  constraints: const BoxConstraints(
                                    minHeight: 48,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 12,
                                  ),
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
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ─── Height Picker Bottom Sheet (Matching Reference Screenshot) ───────────

  Future<void> _showHeightPicker() async {
    final vm = context.read<HomeViewModel>();
    final savedHeightCm = vm.profile?.heightCm;
    final initialHeightCm = savedHeightCm != null && savedHeightCm > 0
        ? savedHeightCm
        : 170;

    bool localUseFt = GeneralSettings.instance.heightImperial;
    int pickedHeightCm = initialHeightCm;
    bool saving = false;
    String? saveError;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DateRolloverBuilder(
          now: widget.now,
          builder: (_) => StatefulBuilder(
            builder: (ctx, setSheet) {
              final totalInches = (pickedHeightCm / 2.54).round();
              final ft = totalInches ~/ 12;
              final inches = totalInches % 12;

              return SingleChildScrollView(
                child: SafeArea(
                  top: false,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
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
                              if (saving) return;
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
                              if (saving) return;
                              pickedHeightCm = val.round();
                              setSheet(() {});
                            },
                          ),

                        const SizedBox(height: 32),

                        if (saveError != null) Text(saveError!),
                        const Text(
                          'Picker units only. Report uses General Settings.',
                          textAlign: TextAlign.center,
                        ),
                        // Cancel / Save Buttons
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: saving
                                    ? null
                                    : () => Navigator.of(ctx).pop(),
                                child: Container(
                                  constraints: const BoxConstraints(
                                    minHeight: 48,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 12,
                                  ),
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
                              child: TextButton(
                                onPressed: saving
                                    ? null
                                    : () async {
                                        if (saving) return;
                                        setSheet(() {
                                          saving = true;
                                          saveError = null;
                                        });
                                        try {
                                          await vm.updateHeight(pickedHeightCm);
                                          if (ctx.mounted) {
                                            Navigator.of(ctx).pop();
                                          }
                                        } catch (_) {
                                          if (ctx.mounted) {
                                            setSheet(() {
                                              saving = false;
                                              saveError =
                                                  'Could not save height. Please retry.';
                                            });
                                          }
                                        }
                                      },
                                child: Container(
                                  constraints: const BoxConstraints(
                                    minHeight: 48,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 12,
                                  ),
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
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // Unit toggle button helper
  Widget _unitBtn(String label, bool active, VoidCallback onTap) => Semantics(
    selected: active,
    child: TextButton(
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 48),
        backgroundColor: active ? const Color(0xFF0066FF) : Colors.transparent,
        foregroundColor: active ? Colors.white : const Color(0xFF374151),
      ),
      onPressed: onTap,
      child: Text(label),
    ),
  );

  @override
  Widget build(BuildContext context) =>
      DateRolloverBuilder(now: widget.now, builder: _buildReport);

  Widget _buildReport(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final profile = vm.profile;

    final heightCm = profile?.heightCm ?? 0;
    final totalInches = (heightCm / 2.54).round();
    final heightFt = totalInches ~/ 12;
    final heightIn = totalInches % 12;

    final weightKg =
        !_loadingWeights && !_weightsFailed && _weights.records.isNotEmpty
        ? _weights.records.last.kg
        : profile?.weightKg;
    final validWeight = weightKg != null && weightKg > 0;
    final heightM = heightCm / 100.0;
    final bmi = validWeight && heightCm > 0
        ? weightKg / (heightM * heightM)
        : null;

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
                actionWidget: _blueButton('Log', () {
                  if (!_loadingWeights && !_weightsFailed) _showWeightLogger();
                }),
              ),
              const SizedBox(height: 10),
              _buildWeightCard(validWeight ? weightKg.toDouble() : null),

              const SizedBox(height: 24),

              // ── BMI ──────────────────────────────────────────────────
              _buildSectionHeader('BMI'),
              const SizedBox(height: 10),
              (_loadingWeights || _weightsFailed)
                  ? _measurementEmpty('Load weight history to view BMI.')
                  : bmi == null
                  ? _measurementEmpty(
                      'BMI unavailable. Add a saved weight and height.',
                      onEdit: _showHeightPicker,
                    )
                  : _buildBmiCard(bmi, heightFt, heightIn, heightCm),

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
        child: Column(
          children: [
            const Text('All-time completed workouts'),
            if (_loadingHistory) const CircularProgressIndicator(),
            if (_historyFailed) ...[
              const Text('Could not load workout history.'),
              TextButton(onPressed: _loadHistory, child: const Text('Retry')),
            ],
            if (_historyReady && _history.entries.isEmpty)
              const Text('No completed workouts yet.'),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.spaceAround,
              spacing: 20,
              runSpacing: 16,
              children: [
                _buildStatItem(
                  icon: _medalIcon(),
                  value: _historyReady ? '${_history.entries.length}' : '—',
                  label: 'Workout',
                ),
                _buildStatItem(icon: _fireIcon(), value: '—', label: 'Kcal'),
                _buildStatItem(
                  icon: _clockIcon(),
                  value: _historyReady
                      ? (_seconds / 60).toStringAsFixed(
                          _seconds % 60 == 0 ? 0 : 1,
                        )
                      : '—',
                  label: 'Minute',
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_historyReady)
              Text(
                'Recorded duration: ${_seconds ~/ 60} min ${_seconds % 60} sec',
              ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Calories unavailable: not recorded for completed workouts.',
                textAlign: TextAlign.center,
              ),
            ),
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

  // ─── History Card ───────────────────────────────────────────────────────────

  Widget _buildHistoryCard() {
    final today = TrainingHistoryRepository.day(_now());
    final firstDay =
        context.read<HomeViewModel>().profile?.firstDayOfWeek ?? 'SUNDAY';
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final dayLabels = TrainingCalendar.weekdays(
      firstDay,
    ).map((d) => labels[d - 1]).toList();
    final dates = TrainingCalendar.week(today, firstDay);
    final completed = _historyReady
        ? _history.entries
              .map((e) => TrainingHistoryRepository.day(e.finishedAt))
              .toSet()
        : <DateTime>{};

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
                return Expanded(
                  child: SizedBox(
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
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            // Date numbers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                final date = dates[i];
                final didComplete = completed.contains(date);
                final isToday = date == today;

                return Expanded(
                  child: Semantics(
                    label:
                        '${date.year}-${date.month}-${date.day}${didComplete ? ', workout completed' : ''}',
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: Center(
                        child: (isToday || didComplete)
                            ? Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: didComplete
                                      ? const Color(0xFFDCEBFF)
                                      : null,
                                  border: Border.all(
                                    color: const Color(0xFF0066FF),
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      '${date.day}',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '${date.day}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: date.isBefore(today)
                                        ? const Color(0xFF6B7280)
                                        : const Color(0xFFBBBBBB),
                                  ),
                                ),
                              ),
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
                  _historyReady ? '${_history.streak(today)}' : '—',
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

  Widget _measurementEmpty(
    String message, {
    VoidCallback? onEdit,
    String actionLabel = 'Set height',
  }) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Text(message),
            if (onEdit != null)
              TextButton(onPressed: onEdit, child: Text(actionLabel)),
          ],
        ),
      ),
    ),
  );

  Widget _buildWeightCard(double? savedKg) {
    if (_loadingWeights) return _measurementEmpty('Loading weight history…');
    if (_weightsFailed) {
      return _measurementEmpty(
        'Could not load weight history.',
        onEdit: _loadWeights,
        actionLabel: 'Retry',
      );
    }
    if (savedKg == null) {
      return _measurementEmpty(
        'No saved weight yet. Tap Log to add your weight.',
      );
    }
    final savedLbs = savedKg * 2.20462;
    final currentDisplay = _useLbs ? savedLbs : savedKg;
    final unitLabel = _useLbs ? 'lbs' : 'kg';

    final heaviestLbs = _weights.records.isEmpty
        ? savedLbs
        : _weights.records.map((e) => e.kg * 2.20462).reduce(math.max);
    final lightestLbs = _weights.records.isEmpty
        ? savedLbs
        : _weights.records.map((e) => e.kg * 2.20462).reduce(math.min);

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
            Wrap(
              spacing: 20,
              runSpacing: 12,
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
                // Heaviest / Lightest
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 4,
                      children: [
                        const Text(
                          'Heaviest ',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                        Text(
                          _weights.records.isEmpty
                              ? '—'
                              : heaviestDisplay.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      children: [
                        const Text(
                          'Lightest   ',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                        Text(
                          _weights.records.isEmpty
                              ? '—'
                              : lightestDisplay.toStringAsFixed(1),
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

            // Profile weight has no recorded date; do not invent a chart point.
            if (_weightData.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 36),
                child: Center(child: Text('No logged weight history yet.')),
              )
            else
              SizedBox(
                height: 140,
                child: Semantics(
                  label:
                      'Weight history. ${_weights.records.where((e) => e.date.year == _today.year && e.date.month == _today.month).map((e) => '${e.date.year}-${e.date.month}-${e.date.day}: ${(_useLbs ? e.kg * 2.20462 : e.kg).toStringAsFixed(1)} $unitLabel').join('; ')}',
                  excludeSemantics: true,
                  child: _WeightChart(
                    data: _weightData
                        .map(
                          (e) => _WeightPoint(
                            e.day,
                            _useLbs ? e.value : e.value / 2.20462,
                          ),
                        )
                        .toList(),
                    currentValue: currentDisplay,
                    todayDay: _today.day,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── BMI Card ───────────────────────────────────────────────────────────────

  Widget _buildBmiCard(double bmi, int heightFt, int heightIn, int heightCm) {
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
            Wrap(
              spacing: 16,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  bmi.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),
                Wrap(
                  spacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
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
            BmiScaleBar(bmi: bmi),

            const SizedBox(height: 18),
            const Divider(color: Color(0xFFF2F2F2), height: 1),
            const SizedBox(height: 14),

            // Height row with Edit icon opening Height Picker
            TextButton(
              key: const ValueKey('report-height-edit'),
              onPressed: _showHeightPicker,
              style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Height',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      GeneralSettings.instance.heightImperial
                          ? '$heightFt ft $heightIn in'
                          : '$heightCm cm',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
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
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
          ),
          const SizedBox(width: 16),
          if (actionLabel != null)
            TextButton(
              key: ValueKey('report-action-$actionLabel'),
              style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
              onPressed: onAction,
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

  Widget _blueButton(String label, VoidCallback onTap) => FilledButton(
    key: ValueKey('report-action-$label'),
    style: FilledButton.styleFrom(
      minimumSize: const Size(48, 48),
      backgroundColor: const Color(0xFF0066FF),
    ),
    onPressed: onTap,
    child: Text(label),
  );

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
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
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

    final allValues = data.isEmpty
        ? [currentValue]
        : data.map((e) => e.value).toList();
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
        final xFrac = ((pt.day - startDay) / (endDay - startDay)).clamp(
          0.0,
          1.0,
        );
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
