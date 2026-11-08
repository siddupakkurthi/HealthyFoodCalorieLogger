/// Date formatting and comparison utilities using pure Dart.
/// No external dependencies required, making it easy to understand and explain in viva.
class AppDateUtils {
  /// Converts a DateTime into a standardized ISO date string: 'yyyy-MM-dd'.
  /// Example: DateTime(2026, 10, 27) -> '2026-10-27'
  static String formatIsoDate(DateTime date) {
    final String year = date.year.toString().padLeft(4, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// Parses an ISO date string ('yyyy-MM-dd') back into a DateTime.
  /// If parsing fails, returns today's date safely.
  static DateTime parseIsoDate(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final day = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (_) {
      // Return today as fallback if format is invalid
    }
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Returns a friendly readable label for a given date.
  /// Examples: 'Today', 'Yesterday', or 'Oct 27, 2026'
  static String formatDisplayDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    final differenceInDays = today.difference(target).inDays;

    if (differenceInDays == 0) {
      return 'Today';
    } else if (differenceInDays == 1) {
      return 'Yesterday';
    } else {
      const monthNames = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final monthName = monthNames[date.month - 1];
      return '$monthName ${date.day}, ${date.year}';
    }
  }

  /// Helper to check if two DateTime objects represent the same calendar day.
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
