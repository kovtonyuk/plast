import 'package:equatable/equatable.dart';

/// A single record in the "Інформація про сходини" page. Captures the
/// topic of a meeting, when it happened, who attended, and an optional
/// free-form comment.
///
/// `attendeeIds` stores references to [FirstUnitMemberModel] and
/// [KurinMemberModel]. Their full names are resolved at read time by
/// joining those tables, so a single column covers both sources.
class MeetupInfoModel extends Equatable {
  final String id;
  final String userId;
  final String theme;
  final DateTime date;
  final String attendees;
  final List<String> attendeeIds;
  final String comment;
  final DateTime createdAt;

  const MeetupInfoModel({
    required this.id,
    required this.userId,
    required this.theme,
    required this.date,
    this.attendees = '',
    this.attendeeIds = const [],
    this.comment = '',
    required this.createdAt,
  });

  factory MeetupInfoModel.fromJson(Map<String, dynamic> json) {
    return MeetupInfoModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      theme: json['theme'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
      attendees: json['attendees'] as String? ?? '',
      attendeeIds: (json['attendee_ids'] as List?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      comment: json['comment'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'theme': theme,
      'date': date.toIso8601String().split('T').first,
      'attendees': attendees,
      'attendee_ids': attendeeIds,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }

  MeetupInfoModel copyWith({
    String? id,
    String? userId,
    String? theme,
    DateTime? date,
    String? attendees,
    List<String>? attendeeIds,
    String? comment,
    DateTime? createdAt,
  }) {
    return MeetupInfoModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      theme: theme ?? this.theme,
      date: date ?? this.date,
      attendees: attendees ?? this.attendees,
      attendeeIds: attendeeIds ?? this.attendeeIds,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        theme,
        date,
        attendees,
        attendeeIds,
        comment,
        createdAt,
      ];
}
