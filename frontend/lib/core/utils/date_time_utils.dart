// core/utils/date_time_utils.dart
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

/// Utility class for date and time operations
class DateTimeUtils {
  /// Format date as Month day, year (e.g. January 1, 2023)
  static String formatFullDate(DateTime date) {
    return DateFormat('MMMM d, yyyy').format(date);
  }

  /// Format date as Month day (e.g. January 1)
  static String formatMonthDay(DateTime date) {
    return DateFormat('MMMM d').format(date);
  }

  /// Format date as Day of week, Month day (e.g. Monday, January 1)
  static String formatDayMonthDay(DateTime date) {
    return DateFormat('EEEE, MMMM d').format(date);
  }

  /// Format date as Day of week, Month day, year (e.g. Monday, January 1, 2023)
  static String formatFullDayDate(DateTime date) {
    return DateFormat('EEEE, MMMM d, yyyy').format(date);
  }

  /// Format date as abbreviated month day (e.g. Jan 1)
  static String formatShortMonthDay(DateTime date) {
    return DateFormat('MMM d').format(date);
  }

  /// Format date as day/month/year (e.g. 1/1/2023)
  static String formatNumericDate(DateTime date) {
    return DateFormat('d/M/yyyy').format(date);
  }

  /// Format date as time (e.g. 12:30 PM)
  static String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  /// Format date as short date (e.g. 01/15/2023)
  static String formatShortDate(DateTime date) {
    return DateFormat('MM/dd/yyyy').format(date);
  }

  /// Format date as ISO date (e.g. 2023-01-15)
  static String formatIsoDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Calculate sobriety period from start date
  static String getSobrietyPeriod(DateTime startDate) {
    final now = DateTime.now();
    final difference = now.difference(startDate);

    int days = difference.inDays;
    int months = (days / 30).floor();
    int years = (days / 365).floor();
    int remainingDays = days % 30;
    int remainingMonths = months % 12;

    if (years > 0) {
      if (remainingMonths > 0) {
        return '$years ${years == 1 ? 'year' : 'years'}, $remainingMonths ${remainingMonths == 1 ? 'month' : 'months'}';
      } else {
        return '$years ${years == 1 ? 'year' : 'years'}';
      }
    } else if (months > 0) {
      if (remainingDays > 0) {
        return '$months ${months == 1 ? 'month' : 'months'}, $remainingDays ${remainingDays == 1 ? 'day' : 'days'}';
      } else {
        return '$months ${months == 1 ? 'month' : 'months'}';
      }
    } else {
      return '$days ${days == 1 ? 'day' : 'days'}';
    }
  }

  /// Get sobriety days count
  static int getSobrietyDays(DateTime startDate) {
    final now = DateTime.now();
    return now.difference(startDate).inDays;
  }

  /// Get the age of a person in years
  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;

    // Account for month and day
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  /// Get the number of days between two dates
  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  /// Check if the date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  /// Check if the date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day;
  }

  /// Check if the date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day;
  }

  /// Check if the date is in the past
  static bool isPast(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final compareDate = DateTime(date.year, date.month, date.day);
    return compareDate.isBefore(today);
  }

  /// Check if the date is in the future
  static bool isFuture(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final compareDate = DateTime(date.year, date.month, date.day);
    return compareDate.isAfter(today);
  }

  /// Check if the date is in the current week
  static bool isCurrentWeek(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final firstDayOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 6));
    final compareDate = DateTime(date.year, date.month, date.day);
    return !compareDate.isBefore(firstDayOfWeek) && !compareDate.isAfter(lastDayOfWeek);
  }

  /// Get a relative time string (e.g. "Today", "Yesterday", "3 days ago")
  static String getRelativeTimeString(DateTime date) {
    if (isToday(date)) {
      return 'Today';
    } else if (isYesterday(date)) {
      return 'Yesterday';
    } else if (isTomorrow(date)) {
      return 'Tomorrow';
    } else {
      final days = daysBetween(date, DateTime.now());
      final isPast = days > 0;
      final absDays = days.abs();

      if (absDays < 7) {
        return isPast ? '$absDays days ago' : 'In $absDays days';
      } else if (absDays < 30) {
        final weeks = (absDays / 7).floor();
        return isPast
            ? '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago'
            : 'In $weeks ${weeks == 1 ? 'week' : 'weeks'}';
      } else if (absDays < 365) {
        final months = (absDays / 30).floor();
        return isPast
            ? '$months ${months == 1 ? 'month' : 'months'} ago'
            : 'In $months ${months == 1 ? 'month' : 'months'}';
      } else {
        final years = (absDays / 365).floor();
        return isPast
            ? '$years ${years == 1 ? 'year' : 'years'} ago'
            : 'In $years ${years == 1 ? 'year' : 'years'}';
      }
    }
  }

  /// Format time of day (e.g. 2:30 PM)
  static String formatTimeOfDay(TimeOfDay timeOfDay) {
    final hour = timeOfDay.hourOfPeriod == 0 ? 12 : timeOfDay.hourOfPeriod;
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    final period = timeOfDay.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}