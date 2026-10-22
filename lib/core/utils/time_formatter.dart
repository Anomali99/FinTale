import 'package:intl/intl.dart';

class TimeFormatter {
  static final List<DateFormat> _ocrDatePatterns = [
    DateFormat('d MMM yyyy HH:mm', 'en'),
    DateFormat('d MMM yyyy', 'en'),
    DateFormat('dd/MM/yyyy HH:mm'),
    DateFormat('dd/MM/yyyy'),
    DateFormat('dd/MM/yy HH:mm'),
    DateFormat('dd/MM/yy'),
    DateFormat('dd.MM.yy-HH:mm'),
    DateFormat('dd.MM.yy'),
    DateFormat('d.M.yyyy HH:mm'),
    DateFormat('d.M.yyyy'),
  ];

  static final RegExp _dayNamePrefixPattern = RegExp(
    r'^('
    r'Senin|Sen|'
    r'Selasa|Sel|'
    r'Rabu|Rab|'
    r'Kamis|Kam|'
    r"Jum'at|Jumat|Jum|"
    r'Sabtu|Sab|'
    r'Minggu|Min|'
    r'Monday|Mon|'
    r'Tuesday|Tues|Tue|'
    r'Wednesday|Wed|'
    r'Thursday|Thurs|Thu|'
    r'Friday|Fri|'
    r'Saturday|Sat|'
    r'Sunday|Sun'
    r'),?\s*',
    caseSensitive: false,
  );

  static DateTime? parseFromOcrText(String rawText) {
    String cleaned = rawText.trim();

    cleaned = cleaned.replaceFirst(_dayNamePrefixPattern, '');
    cleaned = cleaned.replaceAll('. ', ' ').trim();

    for (final pattern in _ocrDatePatterns) {
      try {
        return pattern.parseStrict(cleaned);
      } catch (_) {
        continue;
      }
    }

    return null;
  }

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
