class TrainingCalendar {
  static const firstDays = [
    'SUNDAY',
    'MONDAY',
    'TUESDAY',
    'WEDNESDAY',
    'THURSDAY',
    'FRIDAY',
    'SATURDAY',
  ];
  static int firstWeekday(String firstDay) {
    final index = firstDays.indexOf(firstDay);
    return index <= 0 ? DateTime.sunday : index;
  }

  static List<int> weekdays(String firstDay) =>
      List.generate(7, (i) => (firstWeekday(firstDay) - 1 + i) % 7 + 1);
  static List<DateTime> week(DateTime date, String firstDay) {
    final offset = (date.weekday - firstWeekday(firstDay)) % 7;
    return List.generate(
      7,
      (i) => DateTime(date.year, date.month, date.day - offset + i),
    );
  }

  static List<DateTime?> month(DateTime date, String firstDay) {
    final first = DateTime(date.year, date.month);
    final offset = (first.weekday - firstWeekday(firstDay)) % 7;
    final count = DateTime(date.year, date.month + 1, 0).day;
    return [
      for (var i = 0; i < offset; i++) null,
      for (var i = 1; i <= count; i++) DateTime(date.year, date.month, i),
    ];
  }
}
