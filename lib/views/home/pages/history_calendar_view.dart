import 'package:flutter/material.dart';

class HistoryCalendarView extends StatefulWidget {
  const HistoryCalendarView({super.key});

  @override
  State<HistoryCalendarView> createState() => _HistoryCalendarViewState();
}

class _HistoryCalendarViewState extends State<HistoryCalendarView> {
  late DateTime _displayedMonth;
  final DateTime _today = DateTime.now();

  // Workout-logged days – replace/extend with real data later
  final Set<int> _loggedDays = {}; // day numbers in the displayed month

  @override
  void initState() {
    super.initState();
    _displayedMonth = DateTime(_today.year, _today.month);
  }

  void _prevMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'History',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          children: [
            const SizedBox(height: 8),
            _buildMonthHeader(),
            const SizedBox(height: 20),
            _buildDayLabels(),
            const SizedBox(height: 12),
            _buildCalendarGrid(),
          ],
        ),
      ),
    );
  }

  // ─── Month header with arrows ────────────────────────────────────────────────
  Widget _buildMonthHeader() {
    final label =
        '${_displayedMonth.year}/${_displayedMonth.month.toString().padLeft(2, '0')}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, color: Color(0xFF9CA3AF)),
          onPressed: _prevMonth,
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
          onPressed: _nextMonth,
        ),
      ],
    );
  }

  // ─── Day-of-week row ─────────────────────────────────────────────────────────
  Widget _buildDayLabels() {
    const labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: labels.map((l) {
        return SizedBox(
          width: 40,
          child: Center(
            child: Text(
              l,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── Calendar grid ───────────────────────────────────────────────────────────
  Widget _buildCalendarGrid() {
    // First day of displayed month
    final firstOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    // 0 = Sunday … 6 = Saturday (Flutter weekday: Mon=1…Sun=7)
    final startOffset = firstOfMonth.weekday % 7;

    final daysInMonth = DateUtils.getDaysInMonth(
      _displayedMonth.year,
      _displayedMonth.month,
    );

    // Build a flat list of cells: nulls for empty leading slots, then 1..daysInMonth
    final cells = <int?>[
      ...List.filled(startOffset, null),
      ...List.generate(daysInMonth, (i) => i + 1),
    ];

    // Pad to full rows
    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    // Split into weeks
    final weeks = <List<int?>>[];
    for (int i = 0; i < cells.length; i += 7) {
      weeks.add(cells.sublist(i, i + 7));
    }

    return Column(
      children: weeks.map((week) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: week.map((day) => _buildDayCell(day)).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDayCell(int? day) {
    if (day == null) {
      return const SizedBox(width: 40, height: 40);
    }

    final isToday = _displayedMonth.year == _today.year &&
        _displayedMonth.month == _today.month &&
        day == _today.day;

    final isPast = DateTime(_displayedMonth.year, _displayedMonth.month, day)
        .isBefore(DateTime(_today.year, _today.month, _today.day));

    final isLogged = _loggedDays.contains(day);

    return SizedBox(
      width: 40,
      height: 40,
      child: Center(
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isToday
                ? const Color(0xFF111827)
                : isLogged
                    ? const Color(0xFF2563EB)
                    : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$day',
              style: TextStyle(
                fontSize: 15,
                fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                color: isToday || isLogged
                    ? Colors.white
                    : isPast
                        ? const Color(0xFF374151)
                        : const Color(0xFFD1D5DB),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
