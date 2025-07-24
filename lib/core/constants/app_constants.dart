class AppConstants {
  // App Information
  static const String appName = 'Tuition Helper';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Manage your tuition sessions effortlessly';

  // Database
  static const String databaseName = 'tuition_helper.db';
  static const int databaseVersion = 1;

  // Shared Preferences Keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyFirstLaunch = 'first_launch';
  static const String keyUserId = 'user_id';
  static const String keyUserName = 'user_name';
  static const String keyUserEmail = 'user_email';
  static const String keyLastSyncTime = 'last_sync_time';
  static const String keyOfflineMode = 'offline_mode';

  // Notification Channels
  static const String notificationChannelId = 'tuition_helper_channel';
  static const String notificationChannelName = 'Tuition Helper Notifications';
  static const String notificationChannelDescription =
      'Notifications for tuition sessions and payments';

  // API Endpoints (if using a backend)
  static const String baseUrl = 'https://api.tuitionhelper.com';
  static const String authEndpoint = '/auth';
  static const String guardiansEndpoint = '/guardians';
  static const String studentsEndpoint = '/students';
  static const String sessionsEndpoint = '/sessions';
  static const String paymentsEndpoint = '/payments';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Map
  static const double defaultLatitude = 23.8103;
  static const double defaultLongitude = 90.4125;
  static const double defaultZoom = 15.0;

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // File Upload
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx'];

  // Session Status
  static const String sessionStatusScheduled = 'scheduled';
  static const String sessionStatusCompleted = 'completed';
  static const String sessionStatusCancelled = 'cancelled';
  static const String sessionStatusInProgress = 'in_progress';

  // Payment Status
  static const String paymentStatusPending = 'pending';
  static const String paymentStatusPaid = 'paid';
  static const String paymentStatusOverdue = 'overdue';
  static const String paymentStatusCancelled = 'cancelled';

  // Backup
  static const String backupFileName = 'tuition_helper_backup';
  static const String backupFileExtension = '.json';
}
