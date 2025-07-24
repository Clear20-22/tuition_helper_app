import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/guardian_model.dart';
import '../models/student_model.dart';
import '../models/session_model.dart';
import '../models/payment_model.dart';
import '../models/notification_model.dart';
import '../models/location_model.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const String _guardianBoxName = 'guardians';
  static const String _studentBoxName = 'students';
  static const String _sessionBoxName = 'sessions';
  static const String _paymentBoxName = 'payments';
  static const String _notificationBoxName = 'notifications';
  static const String _locationBoxName = 'locations';
  static const String _settingsBoxName = 'settings';

  Box<GuardianModel>? _guardianBox;
  Box<StudentModel>? _studentBox;
  Box<SessionModel>? _sessionBox;
  Box<PaymentModel>? _paymentBox;
  Box<NotificationModel>? _notificationBox;
  Box<LocationModel>? _locationBox;
  Box<dynamic>? _settingsBox;

  Future<void> initHive() async {
    await Hive.initFlutter();
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(GuardianModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(StudentModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SessionModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(PaymentModelAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(NotificationModelAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(LocationModelAdapter());
    }

    // Open boxes
    _guardianBox = await Hive.openBox<GuardianModel>(_guardianBoxName);
    _studentBox = await Hive.openBox<StudentModel>(_studentBoxName);
    _sessionBox = await Hive.openBox<SessionModel>(_sessionBoxName);
    _paymentBox = await Hive.openBox<PaymentModel>(_paymentBoxName);
    _notificationBox = await Hive.openBox<NotificationModel>(_notificationBoxName);
    _locationBox = await Hive.openBox<LocationModel>(_locationBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
  }

  // Guardian operations
  Future<void> saveGuardian(GuardianModel guardian) async {
    await _guardianBox?.put(guardian.id, guardian);
  }

  GuardianModel? getGuardian(String id) {
    return _guardianBox?.get(id);
  }

  List<GuardianModel> getAllGuardians() {
    return _guardianBox?.values.toList() ?? [];
  }

  Future<void> deleteGuardian(String id) async {
    await _guardianBox?.delete(id);
  }

  // Student operations
  Future<void> saveStudent(StudentModel student) async {
    await _studentBox?.put(student.id, student);
  }

  StudentModel? getStudent(String id) {
    return _studentBox?.get(id);
  }

  List<StudentModel> getAllStudents() {
    return _studentBox?.values.toList() ?? [];
  }

  List<StudentModel> getStudentsByGuardianId(String guardianId) {
    return _studentBox?.values
        .where((student) => student.guardianId == guardianId)
        .toList() ?? [];
  }

  Future<void> deleteStudent(String id) async {
    await _studentBox?.delete(id);
  }

  // Session operations
  Future<void> saveSession(SessionModel session) async {
    await _sessionBox?.put(session.id, session);
  }

  SessionModel? getSession(String id) {
    return _sessionBox?.get(id);
  }

  List<SessionModel> getAllSessions() {
    return _sessionBox?.values.toList() ?? [];
  }

  List<SessionModel> getSessionsByStudentId(String studentId) {
    return _sessionBox?.values
        .where((session) => session.studentId == studentId)
        .toList() ?? [];
  }

  List<SessionModel> getSessionsByDateRange(DateTime start, DateTime end) {
    return _sessionBox?.values
        .where((session) => 
            session.date.isAfter(start.subtract(const Duration(days: 1))) &&
            session.date.isBefore(end.add(const Duration(days: 1))))
        .toList() ?? [];
  }

  Future<void> deleteSession(String id) async {
    await _sessionBox?.delete(id);
  }

  // Payment operations
  Future<void> savePayment(PaymentModel payment) async {
    await _paymentBox?.put(payment.id, payment);
  }

  PaymentModel? getPayment(String id) {
    return _paymentBox?.get(id);
  }

  List<PaymentModel> getAllPayments() {
    return _paymentBox?.values.toList() ?? [];
  }

  List<PaymentModel> getPaymentsByGuardianId(String guardianId) {
    return _paymentBox?.values
        .where((payment) => payment.guardianId == guardianId)
        .toList() ?? [];
  }

  List<PaymentModel> getOverduePayments() {
    final now = DateTime.now();
    return _paymentBox?.values
        .where((payment) => 
            payment.dueDate.isBefore(now) && 
            !payment.isPaid)
        .toList() ?? [];
  }

  Future<void> deletePayment(String id) async {
    await _paymentBox?.delete(id);
  }

  // Notification operations
  Future<void> saveNotification(NotificationModel notification) async {
    await _notificationBox?.put(notification.id, notification);
  }

  NotificationModel? getNotification(String id) {
    return _notificationBox?.get(id);
  }

  List<NotificationModel> getAllNotifications() {
    final notifications = _notificationBox?.values.toList() ?? [];
    notifications.sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
    return notifications;
  }

  List<NotificationModel> getUnreadNotifications() {
    return _notificationBox?.values
        .where((notification) => !notification.isRead)
        .toList() ?? [];
  }

  Future<void> deleteNotification(String id) async {
    await _notificationBox?.delete(id);
  }

  // Location operations
  Future<void> saveLocation(LocationModel location) async {
    await _locationBox?.put(location.id, location);
  }

  LocationModel? getLocation(String id) {
    return _locationBox?.get(id);
  }

  List<LocationModel> getAllLocations() {
    return _locationBox?.values.toList() ?? [];
  }

  List<LocationModel> getActiveLocations() {
    return _locationBox?.values
        .where((location) => location.isActive)
        .toList() ?? [];
  }

  Future<void> deleteLocation(String id) async {
    await _locationBox?.delete(id);
  }

  // Settings operations using SharedPreferences
  Future<void> saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is List<String>) {
      await prefs.setStringList(key, value);
    } else {
      await _settingsBox?.put(key, value);
    }
  }

  Future<T?> getSetting<T>(String key, {T? defaultValue}) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (T == String) {
      return prefs.getString(key) as T? ?? defaultValue;
    } else if (T == int) {
      return prefs.getInt(key) as T? ?? defaultValue;
    } else if (T == double) {
      return prefs.getDouble(key) as T? ?? defaultValue;
    } else if (T == bool) {
      return prefs.getBool(key) as T? ?? defaultValue;
    } else if (T == List<String>) {
      return prefs.getStringList(key) as T? ?? defaultValue;
    } else {
      return _settingsBox?.get(key, defaultValue: defaultValue) as T?;
    }
  }

  Future<void> deleteSetting(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
    await _settingsBox?.delete(key);
  }

  // Sync operations
  List<GuardianModel> getUnsyncedGuardians() {
    return _guardianBox?.values
        .where((guardian) => !guardian.isSynced)
        .toList() ?? [];
  }

  List<StudentModel> getUnsyncedStudents() {
    return _studentBox?.values
        .where((student) => !student.isSynced)
        .toList() ?? [];
  }

  List<SessionModel> getUnsyncedSessions() {
    return _sessionBox?.values
        .where((session) => !session.isSynced)
        .toList() ?? [];
  }

  List<PaymentModel> getUnsyncedPayments() {
    return _paymentBox?.values
        .where((payment) => !payment.isSynced)
        .toList() ?? [];
  }

  List<NotificationModel> getUnsyncedNotifications() {
    return _notificationBox?.values
        .where((notification) => !notification.isSynced)
        .toList() ?? [];
  }

  List<LocationModel> getUnsyncedLocations() {
    return _locationBox?.values
        .where((location) => !location.isSynced)
        .toList() ?? [];
  }

  // Clear all data
  Future<void> clearAllData() async {
    await _guardianBox?.clear();
    await _studentBox?.clear();
    await _sessionBox?.clear();
    await _paymentBox?.clear();
    await _notificationBox?.clear();
    await _locationBox?.clear();
  }

  // Backup operations
  Map<String, dynamic> exportData() {
    return {
      'guardians': _guardianBox?.values.map((g) => g.toJson()).toList() ?? [],
      'students': _studentBox?.values.map((s) => s.toJson()).toList() ?? [],
      'sessions': _sessionBox?.values.map((s) => s.toJson()).toList() ?? [],
      'payments': _paymentBox?.values.map((p) => p.toJson()).toList() ?? [],
      'notifications': _notificationBox?.values.map((n) => n.toJson()).toList() ?? [],
      'locations': _locationBox?.values.map((l) => l.toJson()).toList() ?? [],
      'exportDate': DateTime.now().toIso8601String(),
    };
  }

  Future<void> importData(Map<String, dynamic> data) async {
    try {
      // Clear existing data
      await clearAllData();

      // Import guardians
      if (data['guardians'] != null) {
        for (final guardianJson in data['guardians']) {
          final guardian = GuardianModel.fromJson(guardianJson);
          await saveGuardian(guardian);
        }
      }

      // Import students
      if (data['students'] != null) {
        for (final studentJson in data['students']) {
          final student = StudentModel.fromJson(studentJson);
          await saveStudent(student);
        }
      }

      // Import sessions
      if (data['sessions'] != null) {
        for (final sessionJson in data['sessions']) {
          final session = SessionModel.fromJson(sessionJson);
          await saveSession(session);
        }
      }

      // Import payments
      if (data['payments'] != null) {
        for (final paymentJson in data['payments']) {
          final payment = PaymentModel.fromJson(paymentJson);
          await savePayment(payment);
        }
      }

      // Import notifications
      if (data['notifications'] != null) {
        for (final notificationJson in data['notifications']) {
          final notification = NotificationModel.fromJson(notificationJson);
          await saveNotification(notification);
        }
      }

      // Import locations
      if (data['locations'] != null) {
        for (final locationJson in data['locations']) {
          final location = LocationModel.fromJson(locationJson);
          await saveLocation(location);
        }
      }
    } catch (e) {
      throw Exception('Failed to import data: $e');
    }
  }

  // Get storage statistics
  Map<String, int> getStorageStats() {
    return {
      'guardians': _guardianBox?.length ?? 0,
      'students': _studentBox?.length ?? 0,
      'sessions': _sessionBox?.length ?? 0,
      'payments': _paymentBox?.length ?? 0,
      'notifications': _notificationBox?.length ?? 0,
      'locations': _locationBox?.length ?? 0,
    };
  }

  // Close all boxes
  Future<void> close() async {
    await _guardianBox?.close();
    await _studentBox?.close();
    await _sessionBox?.close();
    await _paymentBox?.close();
    await _notificationBox?.close();
    await _locationBox?.close();
    await _settingsBox?.close();
  }
}
