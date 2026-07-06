import 'package:equatable/equatable.dart';

class AdminActivityModel extends Equatable {
  final String id;
  final String userId;
  final String position;
  final DateTime? startDate;
  final DateTime? endDate;
  final String stanytsia;
  final DateTime createdAt;

  const AdminActivityModel({
    required this.id,
    required this.userId,
    required this.position,
    this.startDate,
    this.endDate,
    this.stanytsia = '',
    required this.createdAt,
  });

  factory AdminActivityModel.fromJson(Map<String, dynamic> json) {
    return AdminActivityModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      position: json['position'] as String? ?? '',
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date'] as String) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date'] as String) : null,
      stanytsia: json['stanytsia'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'position': position,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'stanytsia': stanytsia,
      'created_at': createdAt.toIso8601String(),
    };
  }

  AdminActivityModel copyWith({
    String? id,
    String? userId,
    String? position,
    DateTime? startDate,
    DateTime? endDate,
    String? stanytsia,
    DateTime? createdAt,
  }) {
    return AdminActivityModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      position: position ?? this.position,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      stanytsia: stanytsia ?? this.stanytsia,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, position, startDate, endDate, stanytsia, createdAt];
}
