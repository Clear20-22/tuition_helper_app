import 'package:sqflite/sqflite.dart';
import '../constants/app_constants.dart';

class DatabaseConfig {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = '$databasePath/${AppConstants.databaseName}';

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Create Guardians table
    await db.execute('''
      CREATE TABLE guardians (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT,
        phone TEXT NOT NULL,
        address TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    // Create Students table
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

    // Create Sessions table
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

    // Create Payments table
    await db.execute('''
      CREATE TABLE payments (
        id TEXT PRIMARY KEY,
        guardian_id TEXT NOT NULL,
        student_id TEXT,
        amount REAL NOT NULL,
        currency TEXT DEFAULT 'BDT',
        payment_date TEXT NOT NULL,
        due_date TEXT,
        status TEXT NOT NULL,
        payment_method TEXT,
        transaction_id TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_synced INTEGER DEFAULT 0,
        FOREIGN KEY (guardian_id) REFERENCES guardians (id),
        FOREIGN KEY (student_id) REFERENCES students (id)
      )
    ''');

    // Create Notifications table
    await db.execute('''
      CREATE TABLE notifications (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        type TEXT NOT NULL,
        reference_id TEXT,
        is_read INTEGER DEFAULT 0,
        scheduled_at TEXT,
        created_at TEXT NOT NULL,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    // Create Locations table
    await db.execute('''
      CREATE TABLE locations (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        address TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        is_default INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    // Create Sync Queue table
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT NOT NULL,
        record_id TEXT NOT NULL,
        operation TEXT NOT NULL,
        data TEXT,
        created_at TEXT NOT NULL,
        retry_count INTEGER DEFAULT 0
      )
    ''');

    // Create App Settings table
    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at TEXT NOT NULL
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
    await db.execute('CREATE INDEX idx_payments_status ON payments(status)');
    await db.execute(
      'CREATE INDEX idx_notifications_type ON notifications(type)',
    );
    await db.execute(
      'CREATE INDEX idx_sync_queue_table_name ON sync_queue(table_name)',
    );
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Handle database upgrades here
    if (oldVersion < 2) {
      // Add new columns or tables for version 2
    }
  }

  static Future<void> closeDatabase() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  static Future<void> deleteDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = '$databasePath/${AppConstants.databaseName}';
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
