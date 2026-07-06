import 'package:equatable/equatable.dart';

class EventModel extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String eventType; // training, camp, event, goal
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final String? steps; // For goals: steps to complete
  final DateTime? deletedAt;
  final int? remindBeforeMinutes; // Minutes before event to send notification (e.g. 60 = 1 hour, 1440 = 1 day, 0 = at time)

  const EventModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.eventType,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    this.steps,
    this.deletedAt,
    this.remindBeforeMinutes,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      eventType: json['event_type'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      steps: json['steps'] as String?,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
      remindBeforeMinutes: json['remind_before_minutes'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'event_type': eventType,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'steps': steps,
      'deleted_at': deletedAt?.toIso8601String(),
      'remind_before_minutes': remindBeforeMinutes,
    };
  }

  EventModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? eventType,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    String? steps,
    DateTime? deletedAt,
    int? remindBeforeMinutes,
  }) {
    return EventModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      eventType: eventType ?? this.eventType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      steps: steps ?? this.steps,
      deletedAt: deletedAt ?? this.deletedAt,
      remindBeforeMinutes: remindBeforeMinutes ?? this.remindBeforeMinutes,
    );
  }

  @override
  List<Object?> get props => [id, userId, title, description, eventType, startDate, endDate, createdAt, steps, deletedAt, remindBeforeMinutes];
}
