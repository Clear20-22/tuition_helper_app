import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';
import '../core/utils/date_time_utils.dart';

part 'notification_model.g.dart';

@HiveType(typeId: 4)
class NotificationModel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String body;

  @HiveField(3)
  final String type;

  @HiveField(4)
  final Map<String, dynamic>? data;

  @HiveField(5)
  final DateTime scheduledDate;

  @HiveField(6)
  final bool isRead;

  @HiveField(7)
  final bool isLocal;

  @HiveField(8)
  final String? imageUrl;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  final DateTime updatedAt;

  @HiveField(11)
  final bool isSynced;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.data,
    required this.scheduledDate,
    this.isRead = false,
    this.isLocal = false,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  factory NotificationModel.create({
    required String id,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
    required DateTime scheduledDate,
    bool isRead = false,
    bool isLocal = false,
    String? imageUrl,
  }) {
    final now = DateTime.now();
    return NotificationModel(
      id: id,
      title: title,
      body: body,
      type: type,
      data: data,
      scheduledDate: scheduledDate,
      isRead: isRead,
      isLocal: isLocal,
      imageUrl: imageUrl,
      createdAt: now,
      updatedAt: now,
    );
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    Map<String, dynamic>? data,
    DateTime? scheduledDate,
    bool? isRead,
    bool? isLocal,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      isRead: isRead ?? this.isRead,
      isLocal: isLocal ?? this.isLocal,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isSynced: isSynced ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'data': data?.toString(),
      'scheduled_date': DateTimeUtils.formatDateTime(scheduledDate),
      'is_read': isRead ? 1 : 0,
      'is_local': isLocal ? 1 : 0,
      'image_url': imageUrl,
      'created_at': DateTimeUtils.formatDateTime(createdAt),
      'updated_at': DateTimeUtils.formatDateTime(updatedAt),
      'is_synced': isSynced ? 1 : 0,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: map['type'] ?? '',
      data: map['data'] != null ? {'raw': map['data']} : null,
      scheduledDate:
          DateTimeUtils.parseDateTime(map['scheduled_date']) ?? DateTime.now(),
      isRead: (map['is_read'] ?? 0) == 1,
      isLocal: (map['is_local'] ?? 0) == 1,
      imageUrl: map['image_url'],
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
      'title': title,
      'body': body,
      'type': type,
      'data': data,
      'scheduledDate': scheduledDate.toIso8601String(),
      'isRead': isRead,
      'isLocal': isLocal,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? '',
      data: json['data'],
      scheduledDate: DateTime.parse(json['scheduledDate']),
      isRead: json['isRead'] ?? false,
      isLocal: json['isLocal'] ?? false,
      imageUrl: json['imageUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isSynced: true,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    body,
    type,
    data,
    scheduledDate,
    isRead,
    isLocal,
    imageUrl,
    createdAt,
    updatedAt,
    isSynced,
  ];

  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title, body: $body, type: $type, data: $data, scheduledDate: $scheduledDate, isRead: $isRead, isLocal: $isLocal, imageUrl: $imageUrl, createdAt: $createdAt, updatedAt: $updatedAt, isSynced: $isSynced)';
  }
}
