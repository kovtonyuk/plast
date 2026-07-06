import 'package:equatable/equatable.dart';

class TrainingEntryModel extends Equatable {
  final String id;
  final String userId;
  final String trainingType; // kvdch, vvp, vppt, rov, rovMace, rovNest, rovLeaders, kvv, kvz, kvpt, kvpv, lsh
  final String number;
  final DateTime? startDate;
  final DateTime? endDate;
  final String commandant;
  final String comments;
  final String role; // For custom types: role participant took
  final DateTime createdAt;

  const TrainingEntryModel({
    required this.id,
    required this.userId,
    required this.trainingType,
    this.number = '',
    this.startDate,
    this.endDate,
    this.commandant = '',
    this.comments = '',
    this.role = '',
    required this.createdAt,
  });

  factory TrainingEntryModel.fromJson(Map<String, dynamic> json) {
    return TrainingEntryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      trainingType: json['training_type'] as String,
      number: json['number'] as String? ?? '',
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date'] as String) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date'] as String) : null,
      commandant: json['commandant'] as String? ?? '',
      comments: json['comments'] as String? ?? '',
      role: json['role'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'training_type': trainingType,
      'number': number,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'commandant': commandant,
      'comments': comments,
      'role': role,
      'created_at': createdAt.toIso8601String(),
    };
  }

  TrainingEntryModel copyWith({
    String? id,
    String? userId,
    String? trainingType,
    String? number,
    DateTime? startDate,
    DateTime? endDate,
    String? commandant,
    String? comments,
    String? role,
    DateTime? createdAt,
  }) {
    return TrainingEntryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      trainingType: trainingType ?? this.trainingType,
      number: number ?? this.number,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      commandant: commandant ?? this.commandant,
      comments: comments ?? this.comments,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, trainingType, number, startDate, endDate, commandant, comments, role, createdAt];
}

class TrainingTypeInfo {
  final String type;
  final String labelKey; // localization key
  final String category; // upp, upn, upy, other, custom

  const TrainingTypeInfo({
    required this.type,
    required this.labelKey,
    required this.category,
  });

  bool get isCustom => category == 'custom';

  static const List<TrainingTypeInfo> allTypes = [
    TrainingTypeInfo(type: 'kvdch', labelKey: 'toolKVDCH', category: 'other'),
    TrainingTypeInfo(type: 'vvp', labelKey: 'toolVVP', category: 'upp'),
    TrainingTypeInfo(type: 'vppt', labelKey: 'toolVPPT', category: 'upp'),
    TrainingTypeInfo(type: 'rov', labelKey: 'toolROV', category: 'upn'),
    TrainingTypeInfo(type: 'rovMace', labelKey: 'toolROVMace', category: 'upn'),
    TrainingTypeInfo(type: 'rovNest', labelKey: 'toolROVNesting', category: 'upn'),
    TrainingTypeInfo(type: 'rovLeaders', labelKey: 'toolROVConductors', category: 'upn'),
    TrainingTypeInfo(type: 'kvv', labelKey: 'toolKVV', category: 'upy'),
    TrainingTypeInfo(type: 'kvz', labelKey: 'toolKVZ', category: 'upy'),
    TrainingTypeInfo(type: 'kvpt', labelKey: 'toolKVPT', category: 'upy'),
    TrainingTypeInfo(type: 'kvpv', labelKey: 'toolKVPV', category: 'upy'),
    TrainingTypeInfo(type: 'lsh', labelKey: 'toolLSH', category: 'upy'),
  ];

  // For custom types added by user
  static TrainingTypeInfo customType(String name) {
    return TrainingTypeInfo(
      type: 'custom_$name',
      labelKey: name,
      category: 'custom',
    );
  }

  String getDisplayName() {
    if (isCustom) return labelKey;
    return labelKey; // For built-in types, return the key - UI layer handles localization
  }

  static TrainingTypeInfo? getByType(String type) {
    try {
      return allTypes.firstWhere((t) => t.type == type);
    } catch (_) {
      if (type.startsWith('custom_')) {
        return customType(type.substring(7));
      }
      return null;
    }
  }
}
