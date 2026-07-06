import 'package:equatable/equatable.dart';

class FirstUnitRuleModel extends Equatable {
  final String id;
  final String firstUnitId;
  final String title;
  final String description;
  final int orderIndex;

  const FirstUnitRuleModel({
    required this.id,
    required this.firstUnitId,
    required this.title,
    this.description = '',
    this.orderIndex = 0,
  });

  factory FirstUnitRuleModel.fromJson(Map<String, dynamic> json) {
    return FirstUnitRuleModel(
      id: json['id'] as String,
      firstUnitId: json['first_unit_id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      orderIndex: json['order_index'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_unit_id': firstUnitId,
      'title': title,
      'description': description,
      'order_index': orderIndex,
    };
  }

  FirstUnitRuleModel copyWith({
    String? id,
    String? firstUnitId,
    String? title,
    String? description,
    int? orderIndex,
  }) {
    return FirstUnitRuleModel(
      id: id ?? this.id,
      firstUnitId: firstUnitId ?? this.firstUnitId,
      title: title ?? this.title,
      description: description ?? this.description,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  @override
  List<Object?> get props => [id, firstUnitId, title, description, orderIndex];
}
