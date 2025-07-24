import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/notification_model.dart';
import 'storage_service.dart';
import 'database_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final StorageService _storageService = StorageService();
  final DatabaseService _databaseService = DatabaseService();

  static const AndroidNotificationChannel _defaultChannel =
      AndroidNotificationChannel(
        'tuition_helper_channel',
        'Tuition Helper Notifications',
        description:
            'Notifications for tuition sessions, payments, and reminders',
        importance: Importance.high,
      );

  Future<void> initialize() async {
    await _initializeLocalNotifications();
    try {
      await _initializeFirebaseMessaging();
    } catch (e) {
      debugPrint(
        'Firebase messaging initialization failed (continuing without FCM): $e',
      );
    }
    await _requestPermissions();
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_defaultChannel);
  }

  Future<void> _initializeFirebaseMessaging() async {
    // Request permission for Firebase notifications
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');

      // Get FCM token
      String? token = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $token');

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

      // Handle notification taps when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    } else {
      debugPrint('User declined or has not accepted permission');
    }
  }

  Future<void> _requestPermissions() async {
    await Permission.notification.request();
  }

  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      try {
        final data = jsonDecode(payload);
        _handleNotificationAction(data);
      } catch (e) {
        debugPrint('Error parsing notification payload: $e');
      }
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    // Show local notification when app is in foreground
    await _showLocalNotification(
      title: message.notification?.title ?? 'Tuition Helper',
      body: message.notification?.body ?? '',
      payload: jsonEncode(message.data),
    );

    // Save notification to database
    await _saveNotificationToDb(message);
  }

  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    debugPrint('Handling background message: ${message.messageId}');
    // This function must be a top-level function
  }

  void _handleNotificationTap(RemoteMessage message) {
    _handleNotificationAction(message.data);
  }

  void _handleNotificationAction(Map<String, dynamic> data) {
    final type = data['type'] ?? '';
    // final id = data['id'] ?? ''; // Unused for now

    switch (type) {
      case 'session_reminder':
        // Navigate to session details
        break;
      case 'payment_due':
        // Navigate to payment details
        break;
      case 'session_cancelled':
        // Show session cancelled info
        break;
      default:
        // Default action
        break;
    }
  }

  Future<void> _saveNotificationToDb(RemoteMessage message) async {
    final notification = NotificationModel.create(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? 'Tuition Helper',
      body: message.notification?.body ?? '',
      type: message.data['type'] ?? 'general',
      data: message.data,
      scheduledDate: DateTime.now(),
      isLocal: false,
    );

    await _storageService.saveNotification(notification);
    await _databaseService.insertNotification(notification);
  }

  // Schedule local notifications
  Future<void> scheduleNotification({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? type,
    Map<String, dynamic>? data,
  }) async {
    final notification = NotificationModel.create(
      id: id,
      title: title,
      body: body,
      type: type ?? 'reminder',
      data: data,
      scheduledDate: scheduledDate,
      isLocal: true,
    );

    // Save to database
    await _storageService.saveNotification(notification);
    await _databaseService.insertNotification(notification);

    // Schedule local notification
    await _localNotifications.zonedSchedule(
      id.hashCode,
      title,
      body,
      _nextInstanceOfDateTime(scheduledDate),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'tuition_helper_channel',
          'Tuition Helper Notifications',
          channelDescription:
              'Notifications for tuition sessions, payments, and reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: jsonEncode(data ?? {}),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Show immediate notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'tuition_helper_channel',
          'Tuition Helper Notifications',
          channelDescription:
              'Notifications for tuition sessions, payments, and reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  // Schedule session reminders
  Future<void> scheduleSessionReminder({
    required String sessionId,
    required String studentName,
    required String subject,
    required DateTime sessionDate,
    Duration reminderBefore = const Duration(hours: 1),
  }) async {
    final reminderDate = sessionDate.subtract(reminderBefore);

    await scheduleNotification(
      id: 'session_reminder_$sessionId',
      title: 'Session Reminder',
      body: 'You have a $subject session with $studentName in 1 hour',
      scheduledDate: reminderDate,
      type: 'session_reminder',
      data: {'sessionId': sessionId, 'type': 'session_reminder'},
    );
  }

  // Schedule payment reminders
  Future<void> schedulePaymentReminder({
    required String paymentId,
    required String guardianName,
    required double amount,
    required DateTime dueDate,
    Duration reminderBefore = const Duration(days: 3),
  }) async {
    final reminderDate = dueDate.subtract(reminderBefore);

    await scheduleNotification(
      id: 'payment_reminder_$paymentId',
      title: 'Payment Reminder',
      body:
          'Payment of \$${amount.toStringAsFixed(2)} from $guardianName is due in 3 days',
      scheduledDate: reminderDate,
      type: 'payment_due',
      data: {'paymentId': paymentId, 'type': 'payment_due'},
    );
  }

  // Cancel notification
  Future<void> cancelNotification(String id) async {
    await _localNotifications.cancel(id.hashCode);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _localNotifications.pendingNotificationRequests();
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    final notification = _storageService.getNotification(notificationId);
    if (notification != null) {
      final updatedNotification = notification.copyWith(isRead: true);
      await _storageService.saveNotification(updatedNotification);
      await _databaseService.updateNotification(updatedNotification);
    }
  }

  // Get unread notification count
  int getUnreadCount() {
    return _storageService.getUnreadNotifications().length;
  }

  // Send test notification
  Future<void> sendTestNotification() async {
    await _showLocalNotification(
      title: 'Test Notification',
      body: 'This is a test notification from Tuition Helper',
    );
  }

  // Helper method to calculate next instance of date
  _nextInstanceOfDateTime(DateTime dateTime) {
    final now = DateTime.now();
    if (dateTime.isBefore(now)) {
      return dateTime.add(const Duration(days: 1));
    }
    return dateTime;
  }

  // Clean up old notifications
  Future<void> cleanupOldNotifications() async {
    final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
    final allNotifications = _storageService.getAllNotifications();

    for (final notification in allNotifications) {
      if (notification.createdAt.isBefore(cutoffDate) && notification.isRead) {
        await _storageService.deleteNotification(notification.id);
        await _databaseService.deleteNotification(notification.id);
      }
    }
  }

  // Get Firebase token
  Future<String?> getFirebaseToken() async {
    return await _firebaseMessaging.getToken();
  }

  // Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }
}
