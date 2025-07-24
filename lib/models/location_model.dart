import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';
import '../core/utils/date_time_utils.dart';

part 'location_model.g.dart';

@HiveType(typeId: 5)
class LocationModel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String address;

  @HiveField(3)
  final double latitude;

  @HiveField(4)
  final double longitude;

  @HiveField(5)
  final String? description;

  @HiveField(6)
  final String? contactNumber;

  @HiveField(7)
  final bool isActive;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final DateTime updatedAt;

  @HiveField(10)
  final bool isSynced;

  const LocationModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.description,
    this.contactNumber,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  factory LocationModel.create({
    required String id,
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    String? description,
    String? contactNumber,
    bool isActive = true,
  }) {
    final now = DateTime.now();
    return LocationModel(
      id: id,
      name: name,
      address: address,
      latitude: latitude,
      longitude: longitude,
      description: description,
      contactNumber: contactNumber,
      isActive: isActive,
      createdAt: now,
      updatedAt: now,
    );
  }

  LocationModel copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? description,
    String? contactNumber,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return LocationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      description: description ?? this.description,
      contactNumber: contactNumber ?? this.contactNumber,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isSynced: isSynced ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'contact_number': contactNumber,
      'is_active': isActive ? 1 : 0,
      'created_at': DateTimeUtils.formatDateTime(createdAt),
      'updated_at': DateTimeUtils.formatDateTime(updatedAt),
      'is_synced': isSynced ? 1 : 0,
    };
  }

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      description: map['description'],
      contactNumber: map['contact_number'],
      isActive: (map['is_active'] ?? 1) == 1,
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
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'contactNumber': contactNumber,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      description: json['description'],
      contactNumber: json['contactNumber'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isSynced: true,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    address,
    latitude,
    longitude,
    description,
    contactNumber,
    isActive,
    createdAt,
    updatedAt,
    isSynced,
  ];

  @override
  String toString() {
    return 'LocationModel(id: $id, name: $name, address: $address, latitude: $latitude, longitude: $longitude, description: $description, contactNumber: $contactNumber, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, isSynced: $isSynced)';
  }
}
