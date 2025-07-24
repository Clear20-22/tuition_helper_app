import 'package:intl/intl.dart';

class DateTimeUtils {
  static const String defaultDateFormat = 'yyyy-MM-dd';
  static const String defaultTimeFormat = 'HH:mm';
  static const String defaultDateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String displayTimeFormat = 'h:mm a';
  static const String displayDateTimeFormat = 'MMM dd, yyyy h:mm a';

  /// Formats DateTime to string with given format
  static String formatDateTime(
    DateTime dateTime, [
    String format = defaultDateTimeFormat,
  ]) {
    return DateFormat(format).format(dateTime);
  }

  /// Formats DateTime to date string
  static String formatDate(DateTime dateTime) {
    return DateFormat(defaultDateFormat).format(dateTime);
  }

  /// Formats DateTime to time string
  static String formatTime(DateTime dateTime) {
    return DateFormat(defaultTimeFormat).format(dateTime);
  }

  /// Formats DateTime to display date string
  static String formatDisplayDate(DateTime dateTime) {
    return DateFormat(displayDateFormat).format(dateTime);
  }

  /// Formats DateTime to display time string
  static String formatDisplayTime(DateTime dateTime) {
    return DateFormat(displayTimeFormat).format(dateTime);
  }

  /// Formats DateTime to display date time string
  static String formatDisplayDateTime(DateTime dateTime) {
    return DateFormat(displayDateTimeFormat).format(dateTime);
  }

  /// Parses string to DateTime with given format
  static DateTime? parseDateTime(
    String dateTimeString, [
    String format = defaultDateTimeFormat,
  ]) {
    try {
      return DateFormat(format).parse(dateTimeString);
    } catch (e) {
      return null;
    }
  }

  /// Parses date string to DateTime
  static DateTime? parseDate(String dateString) {
    try {
      return DateFormat(defaultDateFormat).parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Parses time string to DateTime (today's date with given time)
  static DateTime? parseTime(String timeString) {
    try {
      final time = DateFormat(defaultTimeFormat).parse(timeString);
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, time.hour, time.minute);
    } catch (e) {
      return null;
    }
  }

  /// Gets current timestamp string
  static String getCurrentTimestamp() {
    return formatDateTime(DateTime.now());
  }

  /// Checks if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Checks if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  /// Checks if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Gets relative time string (e.g., "2 hours ago", "in 3 days")
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.isNegative) {
      final future = dateTime.difference(now);
      if (future.inDays > 0) {
        return 'in ${future.inDays} day${future.inDays > 1 ? 's' : ''}';
      } else if (future.inHours > 0) {
        return 'in ${future.inHours} hour${future.inHours > 1 ? 's' : ''}';
      } else if (future.inMinutes > 0) {
        return 'in ${future.inMinutes} minute${future.inMinutes > 1 ? 's' : ''}';
      } else {
        return 'in a moment';
      }
    }

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'just now';
    }
  }

  /// Gets time of day from DateTime
  static String getTimeOfDay(DateTime dateTime) {
    final hour = dateTime.hour;
    if (hour < 6) {
      return 'Late Night';
    } else if (hour < 12) {
      return 'Morning';
    } else if (hour < 17) {
      return 'Afternoon';
    } else if (hour < 21) {
      return 'Evening';
    } else {
      return 'Night';
    }
  }

  /// Gets start of day
  static DateTime getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Gets end of day
  static DateTime getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Gets start of week (Monday)
  static DateTime getStartOfWeek(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return getStartOfDay(date.subtract(Duration(days: daysFromMonday)));
  }

  /// Gets end of week (Sunday)
  static DateTime getEndOfWeek(DateTime date) {
    final daysToSunday = 7 - date.weekday;
    return getEndOfDay(date.add(Duration(days: daysToSunday)));
  }

  /// Gets start of month
  static DateTime getStartOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Gets end of month
  static DateTime getEndOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }

  /// Checks if two dates are on the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Gets duration between two dates in human readable format
  static String getDurationString(DateTime start, DateTime end) {
    final duration = end.difference(start);

    if (duration.inDays > 0) {
      final hours = duration.inHours % 24;
      if (hours > 0) {
        return '${duration.inDays}d ${hours}h';
      }
      return '${duration.inDays}d';
    } else if (duration.inHours > 0) {
      final minutes = duration.inMinutes % 60;
      if (minutes > 0) {
        return '${duration.inHours}h ${minutes}m';
      }
      return '${duration.inHours}h';
    } else {
      return '${duration.inMinutes}m';
    }
  }
}
