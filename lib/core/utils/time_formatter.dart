import 'package:intl/intl.dart';

class TimeFormatter {
  static DateTime toDate(int timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  static int toTimestamp(DateTime date) {
    return date.millisecondsSinceEpoch;
  }

  static String formatShort(int timestamp) {
    return DateFormat('dd MMM yyyy').format(toDate(timestamp));
  }

  static String formatShortWithHour(int timestamp) {
    return DateFormat('dd MMM yyyy •󠁏󠁏 HH:mm').format(toDate(timestamp));
  }

  static String formatMonthYear(int timestamp) {
    return DateFormat('MMMM yyyy').format(toDate(timestamp));
  }

  static int getStartOfDay(int timestamp) {
    DateTime d = toDate(timestamp);
    return DateTime(d.year, d.month, d.day).millisecondsSinceEpoch;
  }

  static int getEndOfDay(int timestamp) {
    DateTime d = toDate(timestamp);
    return DateTime(
      d.year,
      d.month,
      d.day,
      23,
      59,
      59,
      999,
    ).millisecondsSinceEpoch;
  }

  static int getStartOfMonth(int year, int month) {
    return DateTime(year, month, 1).millisecondsSinceEpoch;
  }

  static int getEndOfMonth(int year, int month) {
    DateTime lastDay = DateTime(year, month + 1, 0, 23, 59, 59, 999);
    return lastDay.millisecondsSinceEpoch;
  }

  static List<DateTime> getDaysInMonth(int year, int month) {
    DateTime firstDay = DateTime(year, month, 1);
    DateTime lastDay = DateTime(year, month + 1, 0);

    List<DateTime> days = [];
    for (int i = 0; i < lastDay.day; i++) {
      days.add(firstDay.add(Duration(days: i)));
    }
    return days;
  }

  static bool isSameDay(int timestamp1, int timestamp2) {
    DateTime d1 = toDate(timestamp1);
    DateTime d2 = toDate(timestamp2);
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }
}
