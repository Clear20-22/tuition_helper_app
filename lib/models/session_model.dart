import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';
import '../core/utils/date_time_utils.dart';
import '../core/constants/app_constants.dart';

part 'session_model.g.dart';

@HiveType(typeId: 2)
class SessionModel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String studentId;

  @HiveField(2)
  final String subject;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final DateTime startTime;

  @HiveField(5)
  final DateTime endTime;

  @HiveField(6)
  final String status;

  @HiveField(7)
  final String? notes;

  @HiveField(8)
  final double? locationLatitude;

  @HiveField(9)
  final double? locationLongitude;

  @HiveField(10)
  final String? locationAddress;

  @HiveField(11)
  final DateTime createdAt;

  @HiveField(12)
  final DateTime updatedAt;

  @HiveField(13)
  final bool isSynced;

  const SessionModel({
    required this.id,
    required this.studentId,
    required this.subject,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.status = AppConstants.sessionStatusScheduled,
    this.notes,
    this.locationLatitude,
    this.locationLongitude,
    this.locationAddress,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  factory SessionModel.create({
    required String id,
    required String studentId,
    required String subject,
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
    String? notes,
    double? locationLatitude,
    double? locationLongitude,
    String? locationAddress,
  }) {
    final now = DateTime.now();
    return SessionModel(
      id: id,
      studentId: studentId,
      subject: subject,
      date: date,
      startTime: startTime,
      endTime: endTime,
      notes: notes,
      locationLatitude: locationLatitude,
      locationLongitude: locationLongitude,
      locationAddress: locationAddress,
      createdAt: now,
      updatedAt: now,
    );
  }

  SessionModel copyWith({
    String? id,
    String? studentId,
    String? subject,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    String? status,
    String? notes,
    double? locationLatitude,
    double? locationLongitude,
    String? locationAddress,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return SessionModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      subject: subject ?? this.subject,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      locationLatitude: locationLatitude ?? this.locationLatitude,
      locationLongitude: locationLongitude ?? this.locationLongitude,
      locationAddress: locationAddress ?? this.locationAddress,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isSynced: isSynced ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'subject': subject,
      'date': DateTimeUtils.formatDate(date),
      'start_time': DateTimeUtils.formatTime(startTime),
      'end_time': DateTimeUtils.formatTime(endTime),
      'status': status,
      'notes': notes,
      'location_latitude': locationLatitude,
      'location_longitude': locationLongitude,
      'location_address': locationAddress,
      'created_at': DateTimeUtils.formatDateTime(createdAt),
      'updated_at': DateTimeUtils.formatDateTime(updatedAt),
      'is_synced': isSynced ? 1 : 0,
    };
  }

  factory SessionModel.fromMap(Map<String, dynamic> map) {
    final dateStr = map['date'] ?? '';
    final startTimeStr = map['start_time'] ?? '00:00';
    final endTimeStr = map['end_time'] ?? '00:00';

    final date = DateTimeUtils.parseDate(dateStr) ?? DateTime.now();
    final startTime = DateTimeUtils.parseTime(startTimeStr) ?? DateTime.now();
    final endTime = DateTimeUtils.parseTime(endTimeStr) ?? DateTime.now();

    return SessionModel(
      id: map['id'] ?? '',
      studentId: map['student_id'] ?? '',
      subject: map['subject'] ?? '',
      date: date,
      startTime: DateTime(
        date.year,
        date.month,
        date.day,
        startTime.hour,
        startTime.minute,
      ),
      endTime: DateTime(
        date.year,
        date.month,
        date.day,
        endTime.hour,
        endTime.minute,
      ),
      status: map['status'] ?? AppConstants.sessionStatusScheduled,
      notes: map['notes'],
      locationLatitude: map['location_latitude']?.toDouble(),
      locationLongitude: map['location_longitude']?.toDouble(),
      locationAddress: map['location_address'],
      createdAt:
          DateTimeUtils.parseDateTime(map['created_at']) ?? DateTime.now(),
      updatedAt:
          DateTimeUtils.parseDateTime(map['updated_at']) ?? DateTime.now(),
      isSynced: (map['is_synced'] ?? 0) == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'subject': subject,
      'date': date.toIso8601String(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'status': status,
      'notes': notes,
      'locationLatitude': locationLatitude,
      'locationLongitude': locationLongitude,
      'locationAddress': locationAddress,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] ?? '',
      studentId: json['studentId'] ?? '',
      subject: json['subject'] ?? '',
      date: DateTime.parse(json['date']),
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      status: json['status'] ?? AppConstants.sessionStatusScheduled,
      notes: json['notes'],
      locationLatitude: json['locationLatitude']?.toDouble(),
      locationLongitude: json['locationLongitude']?.toDouble(),
      locationAddress: json['locationAddress'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isSynced: true,
    );
  }

  Duration get duration => endTime.difference(startTime);

  bool get isToday => DateTimeUtils.isToday(date);
  bool get isTomorrow => DateTimeUtils.isTomorrow(date);
  bool get isCompleted => status == AppConstants.sessionStatusCompleted;
  bool get isCancelled => status == AppConstants.sessionStatusCancelled;
  bool get isInProgress => status == AppConstants.sessionStatusInProgress;
  bool get isScheduled => status == AppConstants.sessionStatusScheduled;

  @override
  List<Object?> get props => [
    id,
    studentId,
    subject,
    date,
    startTime,
    endTime,
    status,
    notes,
    locationLatitude,
    locationLongitude,
    locationAddress,
    createdAt,
    updatedAt,
    isSynced,
  ];

  @override
  String toString() {
    return 'SessionModel(id: $id, studentId: $studentId, subject: $subject, date: $date, startTime: $startTime, endTime: $endTime, status: $status, notes: $notes, locationLatitude: $locationLatitude, locationLongitude: $locationLongitude, locationAddress: $locationAddress, createdAt: $createdAt, updatedAt: $updatedAt, isSynced: $isSynced)';
  }
}
