import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';
import '../core/utils/date_time_utils.dart';

part 'payment_model.g.dart';

@HiveType(typeId: 3)
class PaymentModel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String guardianId;

  @HiveField(2)
  final String studentId;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final String paymentMethod;

  @HiveField(5)
  final DateTime paymentDate;

  @HiveField(6)
  final DateTime dueDate;

  @HiveField(7)
  final String status;

  @HiveField(8)
  final String? description;

  @HiveField(9)
  final String? receiptUrl;

  @HiveField(10)
  final String? transactionId;

  @HiveField(11)
  final DateTime createdAt;

  @HiveField(12)
  final DateTime updatedAt;

  @HiveField(13)
  final bool isSynced;

  const PaymentModel({
    required this.id,
    required this.guardianId,
    required this.studentId,
    required this.amount,
    required this.paymentMethod,
    required this.paymentDate,
    required this.dueDate,
    required this.status,
    this.description,
    this.receiptUrl,
    this.transactionId,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  factory PaymentModel.create({
    required String id,
    required String guardianId,
    required String studentId,
    required double amount,
    required String paymentMethod,
    required DateTime paymentDate,
    required DateTime dueDate,
    required String status,
    String? description,
    String? receiptUrl,
    String? transactionId,
  }) {
    final now = DateTime.now();
    return PaymentModel(
      id: id,
      guardianId: guardianId,
      studentId: studentId,
      amount: amount,
      paymentMethod: paymentMethod,
      paymentDate: paymentDate,
      dueDate: dueDate,
      status: status,
      description: description,
      receiptUrl: receiptUrl,
      transactionId: transactionId,
      createdAt: now,
      updatedAt: now,
    );
  }

  PaymentModel copyWith({
    String? id,
    String? guardianId,
    String? studentId,
    double? amount,
    String? paymentMethod,
    DateTime? paymentDate,
    DateTime? dueDate,
    String? status,
    String? description,
    String? receiptUrl,
    String? transactionId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      guardianId: guardianId ?? this.guardianId,
      studentId: studentId ?? this.studentId,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentDate: paymentDate ?? this.paymentDate,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      description: description ?? this.description,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      transactionId: transactionId ?? this.transactionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isSynced: isSynced ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'guardian_id': guardianId,
      'student_id': studentId,
      'amount': amount,
      'payment_method': paymentMethod,
      'payment_date': DateTimeUtils.formatDateTime(paymentDate),
      'due_date': DateTimeUtils.formatDateTime(dueDate),
      'status': status,
      'description': description,
      'receipt_url': receiptUrl,
      'transaction_id': transactionId,
      'created_at': DateTimeUtils.formatDateTime(createdAt),
      'updated_at': DateTimeUtils.formatDateTime(updatedAt),
      'is_synced': isSynced ? 1 : 0,
    };
  }

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      id: map['id'] ?? '',
      guardianId: map['guardian_id'] ?? '',
      studentId: map['student_id'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      paymentMethod: map['payment_method'] ?? '',
      paymentDate:
          DateTimeUtils.parseDateTime(map['payment_date']) ?? DateTime.now(),
      dueDate: DateTimeUtils.parseDateTime(map['due_date']) ?? DateTime.now(),
      status: map['status'] ?? '',
      description: map['description'],
      receiptUrl: map['receipt_url'],
      transactionId: map['transaction_id'],
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
      'studentId': studentId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'paymentDate': paymentDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'status': status,
      'description': description,
      'receiptUrl': receiptUrl,
      'transactionId': transactionId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] ?? '',
      guardianId: json['guardianId'] ?? '',
      studentId: json['studentId'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? '',
      paymentDate: DateTime.parse(json['paymentDate']),
      dueDate: DateTime.parse(json['dueDate']),
      status: json['status'] ?? '',
      description: json['description'],
      receiptUrl: json['receiptUrl'],
      transactionId: json['transactionId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isSynced: true,
    );
  }

  bool get isPaid => status.toLowerCase() == 'paid';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isOverdue => status.toLowerCase() == 'overdue';

  @override
  List<Object?> get props => [
        id,
        guardianId,
        studentId,
        amount,
        paymentMethod,
        paymentDate,
        dueDate,
        status,
        description,
        receiptUrl,
        transactionId,
        createdAt,
        updatedAt,
        isSynced,
      ];

  @override
  String toString() {
    return 'PaymentModel(id: $id, guardianId: $guardianId, studentId: $studentId, amount: $amount, paymentMethod: $paymentMethod, paymentDate: $paymentDate, dueDate: $dueDate, status: $status, description: $description, receiptUrl: $receiptUrl, transactionId: $transactionId, createdAt: $createdAt, updatedAt: $updatedAt, isSynced: $isSynced)';
  }
}
