class TrainingCalendar {
  static List<int> weekdays(String firstDay) =>
      firstDay == 'MONDAY' ? [1, 2, 3, 4, 5, 6, 7] : [7, 1, 2, 3, 4, 5, 6];
  static List<DateTime> week(DateTime date, String firstDay) {
    final offset = firstDay == 'MONDAY' ? date.weekday - 1 : date.weekday % 7;
    return List.generate(
      7,
      (i) => DateTime(date.year, date.month, date.day - offset + i),
    );
  }

  static List<DateTime?> month(DateTime date, String firstDay) {
    final first = DateTime(date.year, date.month);
    final offset = firstDay == 'MONDAY' ? first.weekday - 1 : first.weekday % 7;
    final count = DateTime(date.year, date.month + 1, 0).day;
    return [
      for (var i = 0; i < offset; i++) null,
      for (var i = 1; i <= count; i++) DateTime(date.year, date.month, i),
    ];
  }
}
