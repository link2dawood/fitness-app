import 'package:flutter/material.dart';
import '../../workouts/training_history_sheet.dart';

/// Report uses the same storage-backed calendar and day details as other tabs.
class HistoryCalendarView extends StatelessWidget {
  const HistoryCalendarView({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
    backgroundColor: Colors.white,
    body: PersistedTrainingHistorySheet(),
  );
}
