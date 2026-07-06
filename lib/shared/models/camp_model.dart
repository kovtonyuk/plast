import 'package:equatable/equatable.dart';

enum CampUlad { upp, upn, upj, usp, ups }

enum CampLevel { stanych, okruzhnuj, krajehyj, mizhkrajehyj }

enum CampRole { uchasnyk, vykhovnyk, provid, bulava, volonter }

enum CampResultType { stupin, vmilist, zdobutakvalifikacija }

class CampModel extends Equatable {
  final String id;
  final String userId;
  final String name;
  final CampUlad ulad;
  final CampLevel level;
  final DateTime? startDate;
  final DateTime? endDate;
  final String location;
  final CampRole role;
  final CampResultType resultType;
  final String resultComment;
  final DateTime createdAt;

  const CampModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.ulad,
    required this.level,
    this.startDate,
    this.endDate,
    this.location = '',
    required this.role,
    required this.resultType,
    this.resultComment = '',
    required this.createdAt,
  });

  static String uladToString(CampUlad ulad) {
    switch (ulad) {
      case CampUlad.upp: return 'УПП';
      case CampUlad.upn: return 'УПН';
      case CampUlad.upj: return 'УПЮ';
      case CampUlad.usp: return 'УСП';
      case CampUlad.ups: return 'УПС';
    }
  }

  static CampUlad uladFromString(String s) {
    switch (s) {
      case 'upp': return CampUlad.upp;
      case 'upn': return CampUlad.upn;
      case 'upj': return CampUlad.upj;
      case 'usp': return CampUlad.usp;
      case 'ups': return CampUlad.ups;
      default: return CampUlad.upj;
    }
  }

  static String levelToString(CampLevel level) {
    switch (level) {
      case CampLevel.stanych: return 'станичний';
      case CampLevel.okruzhnuj: return 'окружний';
      case CampLevel.krajehyj: return 'крайовий';
      case CampLevel.mizhkrajehyj: return 'міжкрайовий';
    }
  }

  static CampLevel levelFromString(String s) {
    switch (s) {
      case 'stanych': return CampLevel.stanych;
      case 'okruzhnuj': return CampLevel.okruzhnuj;
      case 'krajehyj': return CampLevel.krajehyj;
      case 'mizhkrajehyj': return CampLevel.mizhkrajehyj;
      default: return CampLevel.stanych;
    }
  }

  static String roleToString(CampRole role) {
    switch (role) {
      case CampRole.uchasnyk: return 'учасник';
      case CampRole.vykhovnyk: return 'виховник';
      case CampRole.provid: return 'провід';
      case CampRole.bulava: return 'булава';
      case CampRole.volonter: return 'волонтер';
    }
  }

  static CampRole roleFromString(String s) {
    switch (s) {
      case 'uchasnyk': return CampRole.uchasnyk;
      case 'vykhovnyk': return CampRole.vykhovnyk;
      case 'provid': return CampRole.provid;
      case 'bulava': return CampRole.bulava;
      case 'volonter': return CampRole.volonter;
      default: return CampRole.uchasnyk;
    }
  }

  static String resultTypeToString(CampResultType type) {
    switch (type) {
      case CampResultType.stupin: return 'ступінь';
      case CampResultType.vmilist: return 'вмілість';
      case CampResultType.zdobutakvalifikacija: return 'здобута кваліфікація';
    }
  }

  static CampResultType resultTypeFromString(String s) {
    switch (s) {
      case 'stupin': return CampResultType.stupin;
      case 'vmilist': return CampResultType.vmilist;
      case 'zdobutakvalifikacija': return CampResultType.zdobutakvalifikacija;
      default: return CampResultType.stupin;
    }
  }

  factory CampModel.fromJson(Map<String, dynamic> json) {
    return CampModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String? ?? '',
      ulad: uladFromString(json['ulad'] as String? ?? 'upj'),
      level: levelFromString(json['level'] as String? ?? 'stanych'),
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date'] as String) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date'] as String) : null,
      location: json['location'] as String? ?? '',
      role: roleFromString(json['role'] as String? ?? 'uchasnyk'),
      resultType: resultTypeFromString(json['result_type'] as String? ?? 'stupin'),
      resultComment: json['result_comment'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'ulad': ulad.name,
      'level': level.name,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'location': location,
      'role': role.name,
      'result_type': resultType.name,
      'result_comment': resultComment,
      'created_at': createdAt.toIso8601String(),
    };
  }

  CampModel copyWith({
    String? id,
    String? userId,
    String? name,
    CampUlad? ulad,
    CampLevel? level,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    CampRole? role,
    CampResultType? resultType,
    String? resultComment,
    DateTime? createdAt,
  }) {
    return CampModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      ulad: ulad ?? this.ulad,
      level: level ?? this.level,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      role: role ?? this.role,
      resultType: resultType ?? this.resultType,
      resultComment: resultComment ?? this.resultComment,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, name, ulad, level, startDate, endDate, location, role, resultType, resultComment, createdAt];
}
