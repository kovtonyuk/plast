import 'package:equatable/equatable.dart';

class GoalModel extends Equatable {
  final String id;
  final String userId;
  final String title;
  final DateTime targetDate;
  final List<String> steps;
  final List<bool> stepsCompleted;
  final DateTime createdAt;
  final DateTime? deletedAt;

  const GoalModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.targetDate,
    required this.steps,
    required this.stepsCompleted,
    required this.createdAt,
    this.deletedAt,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      targetDate: DateTime.parse(json['target_date'] as String),
      steps: (json['steps'] as String?)?.split('|||') ?? [],
      stepsCompleted: (json['steps_completed'] as String?)?.split('|||').map((e) => e == '1').toList() ?? [],
      createdAt: DateTime.parse(json['created_at'] as String),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'target_date': targetDate.toIso8601String(),
      'steps': steps.join('|||'),
      'steps_completed': stepsCompleted.map((e) => e ? '1' : '0').join('|||'),
      'created_at': createdAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  GoalModel copyWith({
    String? id,
    String? userId,
    String? title,
    DateTime? targetDate,
    List<String>? steps,
    List<bool>? stepsCompleted,
    DateTime? createdAt,
    DateTime? deletedAt,
  }) {
    return GoalModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      targetDate: targetDate ?? this.targetDate,
      steps: steps ?? this.steps,
      stepsCompleted: stepsCompleted ?? this.stepsCompleted,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  int get completedStepsCount => stepsCompleted.where((s) => s).length;
  bool get isCompleted => stepsCompleted.isNotEmpty && stepsCompleted.every((s) => s);

  @override
  List<Object?> get props => [id, userId, title, targetDate, steps, stepsCompleted, createdAt, deletedAt];
}
