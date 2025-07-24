import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';
import '../core/utils/date_time_utils.dart';

part 'guardian_model.g.dart';

@HiveType(typeId: 0)
class GuardianModel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? email;

  @HiveField(3)
  final String? phone;

  @HiveField(4)
  final String? address;

  @HiveField(5)
  final String? profession;

  @HiveField(6)
  final String? emergencyContact;

  @HiveField(7)
  final String? notes;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final DateTime updatedAt;

  @HiveField(10)
  final bool isSynced;

  const GuardianModel({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.profession,
    this.emergencyContact,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  factory GuardianModel.create({
    required String id,
    required String name,
    String? email,
    String? phone,
    String? address,
    String? profession,
    String? emergencyContact,
    String? notes,
  }) {
    final now = DateTime.now();
    return GuardianModel(
      id: id,
      name: name,
      email: email,
      phone: phone,
      address: address,
      profession: profession,
      emergencyContact: emergencyContact,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
  }

  GuardianModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? profession,
    String? emergencyContact,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return GuardianModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      profession: profession ?? this.profession,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isSynced: isSynced ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'profession': profession,
      'emergency_contact': emergencyContact,
      'notes': notes,
      'created_at': DateTimeUtils.formatDateTime(createdAt),
      'updated_at': DateTimeUtils.formatDateTime(updatedAt),
      'is_synced': isSynced ? 1 : 0,
    };
  }

  factory GuardianModel.fromMap(Map<String, dynamic> map) {
    return GuardianModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'],
      phone: map['phone'],
      address: map['address'],
      profession: map['profession'],
      emergencyContact: map['emergency_contact'],
      notes: map['notes'],
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
      'email': email,
      'phone': phone,
      'address': address,
      'profession': profession,
      'emergencyContact': emergencyContact,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory GuardianModel.fromJson(Map<String, dynamic> json) {
    return GuardianModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      profession: json['profession'],
      emergencyContact: json['emergencyContact'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isSynced: true,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        address,
        profession,
        emergencyContact,
        notes,
        createdAt,
        updatedAt,
        isSynced,
      ];

  @override
  String toString() {
    return 'GuardianModel(id: $id, name: $name, email: $email, phone: $phone, address: $address, profession: $profession, emergencyContact: $emergencyContact, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt, isSynced: $isSynced)';
  }
}
