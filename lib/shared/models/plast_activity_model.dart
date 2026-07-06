import 'package:equatable/equatable.dart';

class PlastActivityModel extends Equatable {
  final String id;
  final String userId;
  final String projectName;
  final String position;
  final DateTime? date;
  final String area;
  final DateTime createdAt;

  const PlastActivityModel({
    required this.id,
    required this.userId,
    required this.projectName,
    required this.position,
    this.date,
    this.area = '',
    required this.createdAt,
  });

  factory PlastActivityModel.fromJson(Map<String, dynamic> json) {
    return PlastActivityModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      projectName: json['project_name'] as String? ?? '',
      position: json['position'] as String? ?? '',
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : null,
      area: json['area'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'project_name': projectName,
      'position': position,
      'date': date?.toIso8601String(),
      'area': area,
      'created_at': createdAt.toIso8601String(),
    };
  }

  PlastActivityModel copyWith({
    String? id,
    String? userId,
    String? projectName,
    String? position,
    DateTime? date,
    String? area,
    DateTime? createdAt,
  }) {
    return PlastActivityModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      projectName: projectName ?? this.projectName,
      position: position ?? this.position,
      date: date ?? this.date,
      area: area ?? this.area,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, projectName, position, date, area, createdAt];
}
