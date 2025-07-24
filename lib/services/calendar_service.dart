import 'package:table_calendar/table_calendar.dart';
import '../models/session_model.dart';
import '../models/payment_model.dart';
import 'storage_service.dart';

class CalendarService {
  static final CalendarService _instance = CalendarService._internal();
  factory CalendarService() => _instance;
  CalendarService._internal();

  final StorageService _storageService = StorageService();

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Getters
  CalendarFormat get calendarFormat => _calendarFormat;
  DateTime get focusedDay => _focusedDay;
  DateTime? get selectedDay => _selectedDay;

  // Setters
  void setCalendarFormat(CalendarFormat format) {
    _calendarFormat = format;
  }

  void setFocusedDay(DateTime day) {
    _focusedDay = day;
  }

  void setSelectedDay(DateTime? day) {
    _selectedDay = day;
  }

  // Get events for a specific day
  List<dynamic> getEventsForDay(DateTime day) {
    return [...getSessionsForDay(day), ...getPaymentsForDay(day)];
  }

  // Get sessions for a specific day
  List<SessionModel> getSessionsForDay(DateTime day) {
    final sessions = _storageService.getAllSessions();
    return sessions.where((session) => isSameDay(session.date, day)).toList();
  }

  // Get payments for a specific day (due dates)
  List<PaymentModel> getPaymentsForDay(DateTime day) {
    final payments = _storageService.getAllPayments();
    return payments
        .where((payment) => isSameDay(payment.dueDate, day))
        .toList();
  }

  // Get sessions for date range
  List<SessionModel> getSessionsForDateRange(DateTime start, DateTime end) {
    return _storageService.getSessionsByDateRange(start, end);
  }

  // Get upcoming sessions (next 7 days)
  List<SessionModel> getUpcomingSessions({int days = 7}) {
    final now = DateTime.now();
    final endDate = now.add(Duration(days: days));
    return getSessionsForDateRange(now, endDate);
  }

  // Get overdue payments
  List<PaymentModel> getOverduePayments() {
    return _storageService.getOverduePayments();
  }

  // Get payments due in the next N days
  List<PaymentModel> getUpcomingPayments({int days = 30}) {
    final now = DateTime.now();
    final endDate = now.add(Duration(days: days));
    final payments = _storageService.getAllPayments();

    return payments.where((payment) {
      return payment.dueDate.isAfter(now) &&
          payment.dueDate.isBefore(endDate) &&
          !payment.isPaid;
    }).toList();
  }

  // Get calendar event markers for a month
  Map<DateTime, List<dynamic>> getEventMarkersForMonth(DateTime month) {
    final markers = <DateTime, List<dynamic>>{};

    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);

    // Get sessions for the month
    final sessions = getSessionsForDateRange(startOfMonth, endOfMonth);
    for (final session in sessions) {
      final day = DateTime(
        session.date.year,
        session.date.month,
        session.date.day,
      );
      if (markers[day] == null) {
        markers[day] = [];
      }
      markers[day]!.add(session);
    }

    // Get payments for the month
    final payments = _storageService.getAllPayments();
    for (final payment in payments) {
      final day = DateTime(
        payment.dueDate.year,
        payment.dueDate.month,
        payment.dueDate.day,
      );
      if (day.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
          day.isBefore(endOfMonth.add(const Duration(days: 1)))) {
        if (markers[day] == null) {
          markers[day] = [];
        }
        markers[day]!.add(payment);
      }
    }

    return markers;
  }

  // Get day summary
  Map<String, dynamic> getDaySummary(DateTime day) {
    final sessions = getSessionsForDay(day);
    final payments = getPaymentsForDay(day);

    return {
      'date': day,
      'sessionCount': sessions.length,
      'paymentCount': payments.length,
      'sessions': sessions,
      'payments': payments,
      'hasEvents': sessions.isNotEmpty || payments.isNotEmpty,
    };
  }

  // Get week summary
  Map<String, dynamic> getWeekSummary(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    final sessions = getSessionsForDateRange(weekStart, weekEnd);
    final payments = _storageService.getAllPayments().where((payment) {
      return payment.dueDate.isAfter(
            weekStart.subtract(const Duration(days: 1)),
          ) &&
          payment.dueDate.isBefore(weekEnd.add(const Duration(days: 1)));
    }).toList();

    return {
      'weekStart': weekStart,
      'weekEnd': weekEnd,
      'totalSessions': sessions.length,
      'totalPayments': payments.length,
      'sessions': sessions,
      'payments': payments,
    };
  }

  // Get month summary
  Map<String, dynamic> getMonthSummary(DateTime month) {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);

    final sessions = getSessionsForDateRange(startOfMonth, endOfMonth);
    final payments = _storageService.getAllPayments().where((payment) {
      return payment.dueDate.isAfter(
            startOfMonth.subtract(const Duration(days: 1)),
          ) &&
          payment.dueDate.isBefore(endOfMonth.add(const Duration(days: 1)));
    }).toList();

    final completedSessions = sessions
        .where((s) => s.status.toLowerCase() == 'completed')
        .length;
    final cancelledSessions = sessions
        .where((s) => s.status.toLowerCase() == 'cancelled')
        .length;
    final paidPayments = payments.where((p) => p.isPaid).length;

    return {
      'month': month,
      'totalSessions': sessions.length,
      'completedSessions': completedSessions,
      'cancelledSessions': cancelledSessions,
      'totalPayments': payments.length,
      'paidPayments': paidPayments,
      'sessions': sessions,
      'payments': payments,
    };
  }

  // Search events by date range
  List<dynamic> searchEvents({
    required DateTime startDate,
    required DateTime endDate,
    String? type, // 'session', 'payment', or null for all
    String? status,
  }) {
    final events = <dynamic>[];

    if (type == null || type == 'session') {
      final sessions = getSessionsForDateRange(startDate, endDate);
      if (status != null) {
        events.addAll(
          sessions.where((s) => s.status.toLowerCase() == status.toLowerCase()),
        );
      } else {
        events.addAll(sessions);
      }
    }

    if (type == null || type == 'payment') {
      final payments = _storageService.getAllPayments().where((payment) {
        final inRange =
            payment.dueDate.isAfter(
              startDate.subtract(const Duration(days: 1)),
            ) &&
            payment.dueDate.isBefore(endDate.add(const Duration(days: 1)));
        if (!inRange) return false;

        if (status != null) {
          return payment.status.toLowerCase() == status.toLowerCase();
        }
        return true;
      }).toList();
      events.addAll(payments);
    }

    // Sort by date
    events.sort((a, b) {
      DateTime dateA = a is SessionModel ? a.date : (a as PaymentModel).dueDate;
      DateTime dateB = b is SessionModel ? b.date : (b as PaymentModel).dueDate;
      return dateA.compareTo(dateB);
    });

    return events;
  }

  // Get calendar statistics
  Map<String, dynamic> getCalendarStatistics() {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);

    final thisMonthSessions = getSessionsForDateRange(thisMonth, nextMonth);
    final thisMonthPayments = _storageService.getAllPayments().where((payment) {
      return payment.dueDate.isAfter(
            thisMonth.subtract(const Duration(days: 1)),
          ) &&
          payment.dueDate.isBefore(nextMonth);
    }).toList();

    final upcomingSessions = getUpcomingSessions();
    final overduePayments = getOverduePayments();
    final upcomingPayments = getUpcomingPayments();

    return {
      'thisMonthSessions': thisMonthSessions.length,
      'thisMonthPayments': thisMonthPayments.length,
      'upcomingSessions': upcomingSessions.length,
      'overduePayments': overduePayments.length,
      'upcomingPayments': upcomingPayments.length,
      'totalSessions': _storageService.getAllSessions().length,
      'totalPayments': _storageService.getAllPayments().length,
    };
  }

  // Get busy days (days with multiple events)
  List<DateTime> getBusyDays({int minEvents = 3}) {
    final now = DateTime.now();
    final endDate = now.add(const Duration(days: 30));
    final busyDays = <DateTime>[];

    for (
      DateTime day = now;
      day.isBefore(endDate);
      day = day.add(const Duration(days: 1))
    ) {
      final events = getEventsForDay(day);
      if (events.length >= minEvents) {
        busyDays.add(day);
      }
    }

    return busyDays;
  }

  // Get free time slots
  List<Map<String, dynamic>> getFreeTimeSlots(DateTime date) {
    final sessions = getSessionsForDay(date);
    final freeSlots = <Map<String, dynamic>>[];

    // Define working hours (9 AM to 6 PM)
    final workStart = DateTime(date.year, date.month, date.day, 9);
    final workEnd = DateTime(date.year, date.month, date.day, 18);

    if (sessions.isEmpty) {
      freeSlots.add({
        'start': workStart,
        'end': workEnd,
        'duration': workEnd.difference(workStart),
      });
      return freeSlots;
    }

    // Sort sessions by start time
    sessions.sort((a, b) => a.startTime.compareTo(b.startTime));

    // Check for free time before first session
    if (sessions.first.startTime.isAfter(workStart)) {
      freeSlots.add({
        'start': workStart,
        'end': sessions.first.startTime,
        'duration': sessions.first.startTime.difference(workStart),
      });
    }

    // Check for free time between sessions
    for (int i = 0; i < sessions.length - 1; i++) {
      final currentEnd = sessions[i].endTime;
      final nextStart = sessions[i + 1].startTime;

      if (nextStart.isAfter(currentEnd)) {
        freeSlots.add({
          'start': currentEnd,
          'end': nextStart,
          'duration': nextStart.difference(currentEnd),
        });
      }
    }

    // Check for free time after last session
    if (sessions.last.endTime.isBefore(workEnd)) {
      freeSlots.add({
        'start': sessions.last.endTime,
        'end': workEnd,
        'duration': workEnd.difference(sessions.last.endTime),
      });
    }

    return freeSlots;
  }

  // Check if a time slot is available
  bool isTimeSlotAvailable(DateTime startTime, DateTime endTime) {
    final date = DateTime(startTime.year, startTime.month, startTime.day);
    final sessions = getSessionsForDay(date);

    for (final session in sessions) {
      // Check for overlap
      if (startTime.isBefore(session.endTime) &&
          endTime.isAfter(session.startTime)) {
        return false;
      }
    }

    return true;
  }

  // Get next available time slot
  DateTime? getNextAvailableSlot({
    Duration sessionDuration = const Duration(hours: 1),
    DateTime? startFrom,
  }) {
    final start = startFrom ?? DateTime.now();

    for (int dayOffset = 0; dayOffset < 30; dayOffset++) {
      final checkDate = start.add(Duration(days: dayOffset));
      final freeSlots = getFreeTimeSlots(checkDate);

      for (final slot in freeSlots) {
        if (slot['duration'] >= sessionDuration) {
          return slot['start'];
        }
      }
    }

    return null;
  }

  // Export calendar data
  Map<String, dynamic> exportCalendarData({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final sessions = getSessionsForDateRange(startDate, endDate);
    final payments = _storageService.getAllPayments().where((payment) {
      return payment.dueDate.isAfter(
            startDate.subtract(const Duration(days: 1)),
          ) &&
          payment.dueDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();

    return {
      'exportDate': DateTime.now().toIso8601String(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'sessions': sessions.map((s) => s.toJson()).toList(),
      'payments': payments.map((p) => p.toJson()).toList(),
    };
  }

  // Reset calendar to current month
  void resetToCurrentMonth() {
    _focusedDay = DateTime.now();
    _selectedDay = null;
    _calendarFormat = CalendarFormat.month;
  }
}
