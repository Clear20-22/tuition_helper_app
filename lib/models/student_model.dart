import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';
import '../core/utils/date_time_utils.dart';

part 'student_model.g.dart';

@HiveType(typeId: 1)
class StudentModel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String guardianId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String? grade;

  @HiveField(4)
  final String? school;

  @HiveField(5)
  final List<String> subjects;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime updatedAt;

  @HiveField(8)
  final bool isSynced;

  const StudentModel({
    required this.id,
    required this.guardianId,
    required this.name,
    this.grade,
    this.school,
    required this.subjects,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  factory StudentModel.create({
    required String id,
    required String guardianId,
    required String name,
    String? grade,
    String? school,
    List<String>? subjects,
  }) {
    final now = DateTime.now();
    return StudentModel(
      id: id,
      guardianId: guardianId,
      name: name,
      grade: grade,
      school: school,
      subjects: subjects ?? [],
      createdAt: now,
      updatedAt: now,
    );
  }

  StudentModel copyWith({
    String? id,
    String? guardianId,
    String? name,
    String? grade,
    String? school,
    List<String>? subjects,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return StudentModel(
      id: id ?? this.id,
      guardianId: guardianId ?? this.guardianId,
      name: name ?? this.name,
      grade: grade ?? this.grade,
      school: school ?? this.school,
      subjects: subjects ?? this.subjects,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isSynced: isSynced ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'guardian_id': guardianId,
      'name': name,
      'grade': grade,
      'school': school,
      'subjects': subjects.join(','),
      'created_at': DateTimeUtils.formatDateTime(createdAt),
      'updated_at': DateTimeUtils.formatDateTime(updatedAt),
      'is_synced': isSynced ? 1 : 0,
    };
  }

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      id: map['id'] ?? '',
      guardianId: map['guardian_id'] ?? '',
      name: map['name'] ?? '',
      grade: map['grade'],
      school: map['school'],
      subjects: map['subjects'] != null
          ? (map['subjects'] as String)
                .split(',')
                .where((s) => s.isNotEmpty)
                .toList()
          : [],
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
      'guardianId': guardianId,
      'name': name,
      'grade': grade,
      'school': school,
      'subjects': subjects,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] ?? '',
      guardianId: json['guardianId'] ?? '',
      name: json['name'] ?? '',
      grade: json['grade'],
      school: json['school'],
      subjects: List<String>.from(json['subjects'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isSynced: true,
    );
  }

  @override
  List<Object?> get props => [
    id,
    guardianId,
    name,
    grade,
    school,
    subjects,
    createdAt,
    updatedAt,
    isSynced,
  ];

  @override
  String toString() {
    return 'StudentModel(id: $id, guardianId: $guardianId, name: $name, grade: $grade, school: $school, subjects: $subjects, createdAt: $createdAt, updatedAt: $updatedAt, isSynced: $isSynced)';
  }
}
