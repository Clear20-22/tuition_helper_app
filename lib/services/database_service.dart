import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/guardian_model.dart';
import '../models/student_model.dart';
import '../models/session_model.dart';
import '../models/payment_model.dart';
import '../models/notification_model.dart';
import '../models/location_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'tuition_helper.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Guardians table
    await db.execute('''
      CREATE TABLE guardians (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        address TEXT,
        profession TEXT,
        emergency_contact TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    // Students table
    await db.execute('''
      CREATE TABLE students (
        id TEXT PRIMARY KEY,
        guardian_id TEXT NOT NULL,
        name TEXT NOT NULL,
        grade TEXT,
        school TEXT,
        subjects TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_synced INTEGER DEFAULT 0,
        FOREIGN KEY (guardian_id) REFERENCES guardians (id)
      )
    ''');

    // Sessions table
    await db.execute('''
      CREATE TABLE sessions (
        id TEXT PRIMARY KEY,
        student_id TEXT NOT NULL,
        subject TEXT NOT NULL,
        date TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        status TEXT NOT NULL,
        notes TEXT,
        location_latitude REAL,
        location_longitude REAL,
        location_address TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_synced INTEGER DEFAULT 0,
        FOREIGN KEY (student_id) REFERENCES students (id)
      )
    ''');

    // Payments table
    await db.execute('''
      CREATE TABLE payments (
        id TEXT PRIMARY KEY,
        guardian_id TEXT NOT NULL,
        student_id TEXT NOT NULL,
        amount REAL NOT NULL,
        payment_method TEXT NOT NULL,
        payment_date TEXT NOT NULL,
        due_date TEXT NOT NULL,
        status TEXT NOT NULL,
        description TEXT,
        receipt_url TEXT,
        transaction_id TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_synced INTEGER DEFAULT 0,
        FOREIGN KEY (guardian_id) REFERENCES guardians (id),
        FOREIGN KEY (student_id) REFERENCES students (id)
      )
    ''');

    // Notifications table
    await db.execute('''
      CREATE TABLE notifications (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        type TEXT NOT NULL,
        data TEXT,
        scheduled_date TEXT NOT NULL,
        is_read INTEGER DEFAULT 0,
        is_local INTEGER DEFAULT 0,
        image_url TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    // Locations table
    await db.execute('''
      CREATE TABLE locations (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        address TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        description TEXT,
        contact_number TEXT,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    // Create indexes for better performance
    await db.execute(
      'CREATE INDEX idx_students_guardian_id ON students(guardian_id)',
    );
    await db.execute(
      'CREATE INDEX idx_sessions_student_id ON sessions(student_id)',
    );
    await db.execute('CREATE INDEX idx_sessions_date ON sessions(date)');
    await db.execute(
      'CREATE INDEX idx_payments_guardian_id ON payments(guardian_id)',
    );
    await db.execute(
      'CREATE INDEX idx_payments_student_id ON payments(student_id)',
    );
    await db.execute(
      'CREATE INDEX idx_payments_due_date ON payments(due_date)',
    );
    await db.execute(
      'CREATE INDEX idx_notifications_scheduled_date ON notifications(scheduled_date)',
    );
    await db.execute(
      'CREATE INDEX idx_notifications_is_read ON notifications(is_read)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    if (oldVersion < newVersion) {
      // Add migration logic here when needed
    }
  }

  // Guardian operations
  Future<int> insertGuardian(GuardianModel guardian) async {
    final db = await database;
    return await db.insert('guardians', guardian.toMap());
  }

  Future<List<GuardianModel>> getAllGuardians() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('guardians');
    return List.generate(maps.length, (i) => GuardianModel.fromMap(maps[i]));
  }

  Future<GuardianModel?> getGuardianById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'guardians',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return GuardianModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateGuardian(GuardianModel guardian) async {
    final db = await database;
    return await db.update(
      'guardians',
      guardian.toMap(),
      where: 'id = ?',
      whereArgs: [guardian.id],
    );
  }

  Future<int> deleteGuardian(String id) async {
    final db = await database;
    return await db.delete('guardians', where: 'id = ?', whereArgs: [id]);
  }

  // Student operations
  Future<int> insertStudent(StudentModel student) async {
    final db = await database;
    return await db.insert('students', student.toMap());
  }

  Future<List<StudentModel>> getAllStudents() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('students');
    return List.generate(maps.length, (i) => StudentModel.fromMap(maps[i]));
  }

  Future<List<StudentModel>> getStudentsByGuardianId(String guardianId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'students',
      where: 'guardian_id = ?',
      whereArgs: [guardianId],
    );
    return List.generate(maps.length, (i) => StudentModel.fromMap(maps[i]));
  }

  Future<StudentModel?> getStudentById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'students',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return StudentModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateStudent(StudentModel student) async {
    final db = await database;
    return await db.update(
      'students',
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  Future<int> deleteStudent(String id) async {
    final db = await database;
    return await db.delete('students', where: 'id = ?', whereArgs: [id]);
  }

  // Session operations
  Future<int> insertSession(SessionModel session) async {
    final db = await database;
    return await db.insert('sessions', session.toMap());
  }

  Future<List<SessionModel>> getAllSessions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('sessions');
    return List.generate(maps.length, (i) => SessionModel.fromMap(maps[i]));
  }

  Future<List<SessionModel>> getSessionsByStudentId(String studentId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sessions',
      where: 'student_id = ?',
      whereArgs: [studentId],
    );
    return List.generate(maps.length, (i) => SessionModel.fromMap(maps[i]));
  }

  Future<List<SessionModel>> getSessionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sessions',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date ASC',
    );
    return List.generate(maps.length, (i) => SessionModel.fromMap(maps[i]));
  }

  Future<int> updateSession(SessionModel session) async {
    final db = await database;
    return await db.update(
      'sessions',
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  Future<int> deleteSession(String id) async {
    final db = await database;
    return await db.delete('sessions', where: 'id = ?', whereArgs: [id]);
  }

  // Payment operations
  Future<int> insertPayment(PaymentModel payment) async {
    final db = await database;
    return await db.insert('payments', payment.toMap());
  }

  Future<List<PaymentModel>> getAllPayments() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('payments');
    return List.generate(maps.length, (i) => PaymentModel.fromMap(maps[i]));
  }

  Future<List<PaymentModel>> getPaymentsByGuardianId(String guardianId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'payments',
      where: 'guardian_id = ?',
      whereArgs: [guardianId],
    );
    return List.generate(maps.length, (i) => PaymentModel.fromMap(maps[i]));
  }

  Future<List<PaymentModel>> getOverduePayments() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final List<Map<String, dynamic>> maps = await db.query(
      'payments',
      where: 'due_date < ? AND status != ?',
      whereArgs: [now, 'paid'],
    );
    return List.generate(maps.length, (i) => PaymentModel.fromMap(maps[i]));
  }

  Future<int> updatePayment(PaymentModel payment) async {
    final db = await database;
    return await db.update(
      'payments',
      payment.toMap(),
      where: 'id = ?',
      whereArgs: [payment.id],
    );
  }

  Future<int> deletePayment(String id) async {
    final db = await database;
    return await db.delete('payments', where: 'id = ?', whereArgs: [id]);
  }

  // Notification operations
  Future<int> insertNotification(NotificationModel notification) async {
    final db = await database;
    return await db.insert('notifications', notification.toMap());
  }

  Future<List<NotificationModel>> getAllNotifications() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notifications',
      orderBy: 'scheduled_date DESC',
    );
    return List.generate(
      maps.length,
      (i) => NotificationModel.fromMap(maps[i]),
    );
  }

  Future<List<NotificationModel>> getUnreadNotifications() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notifications',
      where: 'is_read = ?',
      whereArgs: [0],
      orderBy: 'scheduled_date DESC',
    );
    return List.generate(
      maps.length,
      (i) => NotificationModel.fromMap(maps[i]),
    );
  }

  Future<int> updateNotification(NotificationModel notification) async {
    final db = await database;
    return await db.update(
      'notifications',
      notification.toMap(),
      where: 'id = ?',
      whereArgs: [notification.id],
    );
  }

  Future<int> deleteNotification(String id) async {
    final db = await database;
    return await db.delete('notifications', where: 'id = ?', whereArgs: [id]);
  }

  // Location operations
  Future<int> insertLocation(LocationModel location) async {
    final db = await database;
    return await db.insert('locations', location.toMap());
  }

  Future<List<LocationModel>> getAllLocations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('locations');
    return List.generate(maps.length, (i) => LocationModel.fromMap(maps[i]));
  }

  Future<List<LocationModel>> getActiveLocations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'locations',
      where: 'is_active = ?',
      whereArgs: [1],
    );
    return List.generate(maps.length, (i) => LocationModel.fromMap(maps[i]));
  }

  Future<int> updateLocation(LocationModel location) async {
    final db = await database;
    return await db.update(
      'locations',
      location.toMap(),
      where: 'id = ?',
      whereArgs: [location.id],
    );
  }

  Future<int> deleteLocation(String id) async {
    final db = await database;
    return await db.delete('locations', where: 'id = ?', whereArgs: [id]);
  }

  // Sync operations
  Future<List<Map<String, dynamic>>> getUnsyncedData(String tableName) async {
    final db = await database;
    return await db.query(tableName, where: 'is_synced = ?', whereArgs: [0]);
  }

  Future<int> markAsSynced(String tableName, String id) async {
    final db = await database;
    return await db.update(
      tableName,
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Clear all data
  Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('notifications');
      await txn.delete('payments');
      await txn.delete('sessions');
      await txn.delete('students');
      await txn.delete('guardians');
      await txn.delete('locations');
    });
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
