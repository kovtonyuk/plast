import 'package:equatable/equatable.dart';

class LinkCourierModel extends Equatable {
  final String id;
  final String userId;
  final String name;
  final DateTime? firstStepsDate;
  final String aboutFirstSteps;
  final String aboutFirstImpressions;
  final String howToBeLink;
  final DateTime createdAt;

  const LinkCourierModel({
    required this.id,
    required this.userId,
    required this.name,
    this.firstStepsDate,
    this.aboutFirstSteps = '',
    this.aboutFirstImpressions = '',
    this.howToBeLink = '',
    required this.createdAt,
  });

  factory LinkCourierModel.fromJson(Map<String, dynamic> json) {
    return LinkCourierModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String? ?? '',
      firstStepsDate: json['first_steps_date'] != null
          ? DateTime.parse(json['first_steps_date'] as String)
          : null,
      aboutFirstSteps: json['about_first_steps'] as String? ?? '',
      aboutFirstImpressions: json['about_first_impressions'] as String? ?? '',
      howToBeLink: json['how_to_be_link'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'first_steps_date': firstStepsDate?.toIso8601String(),
      'about_first_steps': aboutFirstSteps,
      'about_first_impressions': aboutFirstImpressions,
      'how_to_be_link': howToBeLink,
      'created_at': createdAt.toIso8601String(),
    };
  }

  LinkCourierModel copyWith({
    String? id,
    String? userId,
    String? name,
    DateTime? firstStepsDate,
    String? aboutFirstSteps,
    String? aboutFirstImpressions,
    String? howToBeLink,
    DateTime? createdAt,
  }) {
    return LinkCourierModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      firstStepsDate: firstStepsDate ?? this.firstStepsDate,
      aboutFirstSteps: aboutFirstSteps ?? this.aboutFirstSteps,
      aboutFirstImpressions: aboutFirstImpressions ?? this.aboutFirstImpressions,
      howToBeLink: howToBeLink ?? this.howToBeLink,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        firstStepsDate,
        aboutFirstSteps,
        aboutFirstImpressions,
        howToBeLink,
        createdAt,
      ];
}
