import 'package:equatable/equatable.dart';

class YourKurinModel extends Equatable {
  final String id;
  final String userId;
  final String name;
  final DateTime? firstMeetingDate;
  final DateTime? supporterDate;
  final DateTime? dcKurinDate;
  final String whyThisKurin;
  final String aboutThoughts;
  final DateTime createdAt;

  const YourKurinModel({
    required this.id,
    required this.userId,
    required this.name,
    this.firstMeetingDate,
    this.supporterDate,
    this.dcKurinDate,
    this.whyThisKurin = '',
    this.aboutThoughts = '',
    required this.createdAt,
  });

  factory YourKurinModel.fromJson(Map<String, dynamic> json) {
    return YourKurinModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String? ?? '',
      firstMeetingDate: json['first_meeting_date'] != null
          ? DateTime.parse(json['first_meeting_date'] as String)
          : null,
      supporterDate: json['supporter_date'] != null
          ? DateTime.parse(json['supporter_date'] as String)
          : null,
      dcKurinDate: json['dc_kurin_date'] != null
          ? DateTime.parse(json['dc_kurin_date'] as String)
          : null,
      whyThisKurin: json['why_this_kurin'] as String? ?? '',
      aboutThoughts: json['about_thoughts'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'first_meeting_date': firstMeetingDate?.toIso8601String(),
      'supporter_date': supporterDate?.toIso8601String(),
      'dc_kurin_date': dcKurinDate?.toIso8601String(),
      'why_this_kurin': whyThisKurin,
      'about_thoughts': aboutThoughts,
      'created_at': createdAt.toIso8601String(),
    };
  }

  YourKurinModel copyWith({
    String? id,
    String? userId,
    String? name,
    DateTime? firstMeetingDate,
    DateTime? supporterDate,
    DateTime? dcKurinDate,
    String? whyThisKurin,
    String? aboutThoughts,
    DateTime? createdAt,
  }) {
    return YourKurinModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      firstMeetingDate: firstMeetingDate ?? this.firstMeetingDate,
      supporterDate: supporterDate ?? this.supporterDate,
      dcKurinDate: dcKurinDate ?? this.dcKurinDate,
      whyThisKurin: whyThisKurin ?? this.whyThisKurin,
      aboutThoughts: aboutThoughts ?? this.aboutThoughts,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        firstMeetingDate,
        supporterDate,
        dcKurinDate,
        whyThisKurin,
        aboutThoughts,
        createdAt,
      ];
}
