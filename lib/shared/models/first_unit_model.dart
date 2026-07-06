import 'package:equatable/equatable.dart';

class FirstUnitModel extends Equatable {
  final String id;
  final String userId;
  final String name;
  final DateTime? firstStepsDate;
  final DateTime? scarfTyingDate;
  final String aboutFirstSteps;
  final String aboutFirstImpressions;
  final DateTime createdAt;

  const FirstUnitModel({
    required this.id,
    required this.userId,
    required this.name,
    this.firstStepsDate,
    this.scarfTyingDate,
    this.aboutFirstSteps = '',
    this.aboutFirstImpressions = '',
    required this.createdAt,
  });

  factory FirstUnitModel.fromJson(Map<String, dynamic> json) {
    return FirstUnitModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String? ?? '',
      firstStepsDate: json['first_steps_date'] != null
          ? DateTime.parse(json['first_steps_date'] as String)
          : null,
      scarfTyingDate: json['scarf_tying_date'] != null
          ? DateTime.parse(json['scarf_tying_date'] as String)
          : null,
      aboutFirstSteps: json['about_first_steps'] as String? ?? '',
      aboutFirstImpressions: json['about_first_impressions'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'first_steps_date': firstStepsDate?.toIso8601String(),
      'scarf_tying_date': scarfTyingDate?.toIso8601String(),
      'about_first_steps': aboutFirstSteps,
      'about_first_impressions': aboutFirstImpressions,
      'created_at': createdAt.toIso8601String(),
    };
  }

  FirstUnitModel copyWith({
    String? id,
    String? userId,
    String? name,
    DateTime? firstStepsDate,
    DateTime? scarfTyingDate,
    String? aboutFirstSteps,
    String? aboutFirstImpressions,
    DateTime? createdAt,
  }) {
    return FirstUnitModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      firstStepsDate: firstStepsDate ?? this.firstStepsDate,
      scarfTyingDate: scarfTyingDate ?? this.scarfTyingDate,
      aboutFirstSteps: aboutFirstSteps ?? this.aboutFirstSteps,
      aboutFirstImpressions: aboutFirstImpressions ?? this.aboutFirstImpressions,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        firstStepsDate,
        scarfTyingDate,
        aboutFirstSteps,
        aboutFirstImpressions,
        createdAt,
      ];
}
