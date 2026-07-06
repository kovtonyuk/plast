import 'package:equatable/equatable.dart';

class TrainingInfoModel extends Equatable {
  final String id;
  final String userId;
  // КВДЧ
  final String kvdchNumber;
  final DateTime? kvdchDate;
  final String kvdchCommandant;
  final String kvdchComments;
  // УПП - ВВП
  final String vvpNumber;
  final DateTime? vvpDate;
  final String vvpCommandant;
  final String vvpComments;
  // УПП - ВППТ
  final String vpptNumber;
  final DateTime? vpptDate;
  final String vpptCommandant;
  final String vpptComments;
  // УПН - РОВ
  final String rovNumber;
  final DateTime? rovDate;
  final String rovCommandant;
  final String rovComments;
  // УПН - РОВ булавних
  final String rovMaceNumber;
  final DateTime? rovMaceDate;
  final String rovMaceCommandant;
  final String rovMaceComments;
  // УПН - РОВ гніздових
  final String rovNestNumber;
  final DateTime? rovNestDate;
  final String rovNestCommandant;
  final String rovNestComments;
  // УПН - РОВ провідників таборів
  final String rovLeadersNumber;
  final DateTime? rovLeadersDate;
  final String rovLeadersCommandant;
  final String rovLeadersComments;
  // УПЮ - КВВ
  final String kvvNumber;
  final DateTime? kvvDate;
  final String kvvCommandant;
  final String kvvComments;
  // УПЮ - КВЗ
  final String kvzNumber;
  final DateTime? kvzDate;
  final String kvzCommandant;
  final String kvzComments;
  // УПЮ - КВПТ
  final String kvptNumber;
  final DateTime? kvptDate;
  final String kvptCommandant;
  final String kvptComments;
  // УПЮ - КВПВ
  final String kvpvNumber;
  final DateTime? kvpvDate;
  final String kvpvCommandant;
  final String kvpvComments;
  // УПЮ - ЛШ/ШБ
  final String lshNumber;
  final DateTime? lshDate;
  final String lshCommandant;
  final String lshComments;
  final DateTime createdAt;

  const TrainingInfoModel({
    required this.id,
    required this.userId,
    this.kvdchNumber = '',
    this.kvdchDate,
    this.kvdchCommandant = '',
    this.kvdchComments = '',
    this.vvpNumber = '',
    this.vvpDate,
    this.vvpCommandant = '',
    this.vvpComments = '',
    this.vpptNumber = '',
    this.vpptDate,
    this.vpptCommandant = '',
    this.vpptComments = '',
    this.rovNumber = '',
    this.rovDate,
    this.rovCommandant = '',
    this.rovComments = '',
    this.rovMaceNumber = '',
    this.rovMaceDate,
    this.rovMaceCommandant = '',
    this.rovMaceComments = '',
    this.rovNestNumber = '',
    this.rovNestDate,
    this.rovNestCommandant = '',
    this.rovNestComments = '',
    this.rovLeadersNumber = '',
    this.rovLeadersDate,
    this.rovLeadersCommandant = '',
    this.rovLeadersComments = '',
    this.kvvNumber = '',
    this.kvvDate,
    this.kvvCommandant = '',
    this.kvvComments = '',
    this.kvzNumber = '',
    this.kvzDate,
    this.kvzCommandant = '',
    this.kvzComments = '',
    this.kvptNumber = '',
    this.kvptDate,
    this.kvptCommandant = '',
    this.kvptComments = '',
    this.kvpvNumber = '',
    this.kvpvDate,
    this.kvpvCommandant = '',
    this.kvpvComments = '',
    this.lshNumber = '',
    this.lshDate,
    this.lshCommandant = '',
    this.lshComments = '',
    required this.createdAt,
  });

  factory TrainingInfoModel.fromJson(Map<String, dynamic> json) {
    return TrainingInfoModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      kvdchNumber: json['kvdch_number'] as String? ?? '',
      kvdchDate: json['kvdch_date'] != null ? DateTime.parse(json['kvdch_date'] as String) : null,
      kvdchCommandant: json['kvdch_commandant'] as String? ?? '',
      kvdchComments: json['kvdch_comments'] as String? ?? '',
      vvpNumber: json['vvp_number'] as String? ?? '',
      vvpDate: json['vvp_date'] != null ? DateTime.parse(json['vvp_date'] as String) : null,
      vvpCommandant: json['vvp_commandant'] as String? ?? '',
      vvpComments: json['vvp_comments'] as String? ?? '',
      vpptNumber: json['vppt_number'] as String? ?? '',
      vpptDate: json['vppt_date'] != null ? DateTime.parse(json['vppt_date'] as String) : null,
      vpptCommandant: json['vppt_commandant'] as String? ?? '',
      vpptComments: json['vppt_comments'] as String? ?? '',
      rovNumber: json['rov_number'] as String? ?? '',
      rovDate: json['rov_date'] != null ? DateTime.parse(json['rov_date'] as String) : null,
      rovCommandant: json['rov_commandant'] as String? ?? '',
      rovComments: json['rov_comments'] as String? ?? '',
      rovMaceNumber: json['rov_mace_number'] as String? ?? '',
      rovMaceDate: json['rov_mace_date'] != null ? DateTime.parse(json['rov_mace_date'] as String) : null,
      rovMaceCommandant: json['rov_mace_commandant'] as String? ?? '',
      rovMaceComments: json['rov_mace_comments'] as String? ?? '',
      rovNestNumber: json['rov_nest_number'] as String? ?? '',
      rovNestDate: json['rov_nest_date'] != null ? DateTime.parse(json['rov_nest_date'] as String) : null,
      rovNestCommandant: json['rov_nest_commandant'] as String? ?? '',
      rovNestComments: json['rov_nest_comments'] as String? ?? '',
      rovLeadersNumber: json['rov_leaders_number'] as String? ?? '',
      rovLeadersDate: json['rov_leaders_date'] != null ? DateTime.parse(json['rov_leaders_date'] as String) : null,
      rovLeadersCommandant: json['rov_leaders_commandant'] as String? ?? '',
      rovLeadersComments: json['rov_leaders_comments'] as String? ?? '',
      kvvNumber: json['kvv_number'] as String? ?? '',
      kvvDate: json['kvv_date'] != null ? DateTime.parse(json['kvv_date'] as String) : null,
      kvvCommandant: json['kvv_commandant'] as String? ?? '',
      kvvComments: json['kvv_comments'] as String? ?? '',
      kvzNumber: json['kvz_number'] as String? ?? '',
      kvzDate: json['kvz_date'] != null ? DateTime.parse(json['kvz_date'] as String) : null,
      kvzCommandant: json['kvz_commandant'] as String? ?? '',
      kvzComments: json['kvz_comments'] as String? ?? '',
      kvptNumber: json['kvpt_number'] as String? ?? '',
      kvptDate: json['kvpt_date'] != null ? DateTime.parse(json['kvpt_date'] as String) : null,
      kvptCommandant: json['kvpt_commandant'] as String? ?? '',
      kvptComments: json['kvpt_comments'] as String? ?? '',
      kvpvNumber: json['kvpv_number'] as String? ?? '',
      kvpvDate: json['kvpv_date'] != null ? DateTime.parse(json['kvpv_date'] as String) : null,
      kvpvCommandant: json['kvpv_commandant'] as String? ?? '',
      kvpvComments: json['kvpv_comments'] as String? ?? '',
      lshNumber: json['lsh_number'] as String? ?? '',
      lshDate: json['lsh_date'] != null ? DateTime.parse(json['lsh_date'] as String) : null,
      lshCommandant: json['lsh_commandant'] as String? ?? '',
      lshComments: json['lsh_comments'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'kvdch_number': kvdchNumber,
      'kvdch_date': kvdchDate?.toIso8601String(),
      'kvdch_commandant': kvdchCommandant,
      'kvdch_comments': kvdchComments,
      'vvp_number': vvpNumber,
      'vvp_date': vvpDate?.toIso8601String(),
      'vvp_commandant': vvpCommandant,
      'vvp_comments': vvpComments,
      'vppt_number': vpptNumber,
      'vppt_date': vpptDate?.toIso8601String(),
      'vppt_commandant': vpptCommandant,
      'vppt_comments': vpptComments,
      'rov_number': rovNumber,
      'rov_date': rovDate?.toIso8601String(),
      'rov_commandant': rovCommandant,
      'rov_comments': rovComments,
      'rov_mace_number': rovMaceNumber,
      'rov_mace_date': rovMaceDate?.toIso8601String(),
      'rov_mace_commandant': rovMaceCommandant,
      'rov_mace_comments': rovMaceComments,
      'rov_nest_number': rovNestNumber,
      'rov_nest_date': rovNestDate?.toIso8601String(),
      'rov_nest_commandant': rovNestCommandant,
      'rov_nest_comments': rovNestComments,
      'rov_leaders_number': rovLeadersNumber,
      'rov_leaders_date': rovLeadersDate?.toIso8601String(),
      'rov_leaders_commandant': rovLeadersCommandant,
      'rov_leaders_comments': rovLeadersComments,
      'kvv_number': kvvNumber,
      'kvv_date': kvvDate?.toIso8601String(),
      'kvv_commandant': kvvCommandant,
      'kvv_comments': kvvComments,
      'kvz_number': kvzNumber,
      'kvz_date': kvzDate?.toIso8601String(),
      'kvz_commandant': kvzCommandant,
      'kvz_comments': kvzComments,
      'kvpt_number': kvptNumber,
      'kvpt_date': kvptDate?.toIso8601String(),
      'kvpt_commandant': kvptCommandant,
      'kvpt_comments': kvptComments,
      'kvpv_number': kvpvNumber,
      'kvpv_date': kvpvDate?.toIso8601String(),
      'kvpv_commandant': kvpvCommandant,
      'kvpv_comments': kvpvComments,
      'lsh_number': lshNumber,
      'lsh_date': lshDate?.toIso8601String(),
      'lsh_commandant': lshCommandant,
      'lsh_comments': lshComments,
      'created_at': createdAt.toIso8601String(),
    };
  }

  TrainingInfoModel copyWith({
    String? id,
    String? userId,
    String? kvdchNumber,
    DateTime? kvdchDate,
    String? kvdchCommandant,
    String? kvdchComments,
    String? vvpNumber,
    DateTime? vvpDate,
    String? vvpCommandant,
    String? vvpComments,
    String? vpptNumber,
    DateTime? vpptDate,
    String? vpptCommandant,
    String? vpptComments,
    String? rovNumber,
    DateTime? rovDate,
    String? rovCommandant,
    String? rovComments,
    String? rovMaceNumber,
    DateTime? rovMaceDate,
    String? rovMaceCommandant,
    String? rovMaceComments,
    String? rovNestNumber,
    DateTime? rovNestDate,
    String? rovNestCommandant,
    String? rovNestComments,
    String? rovLeadersNumber,
    DateTime? rovLeadersDate,
    String? rovLeadersCommandant,
    String? rovLeadersComments,
    String? kvvNumber,
    DateTime? kvvDate,
    String? kvvCommandant,
    String? kvvComments,
    String? kvzNumber,
    DateTime? kvzDate,
    String? kvzCommandant,
    String? kvzComments,
    String? kvptNumber,
    DateTime? kvptDate,
    String? kvptCommandant,
    String? kvptComments,
    String? kvpvNumber,
    DateTime? kvpvDate,
    String? kvpvCommandant,
    String? kvpvComments,
    String? lshNumber,
    DateTime? lshDate,
    String? lshCommandant,
    String? lshComments,
    DateTime? createdAt,
  }) {
    return TrainingInfoModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      kvdchNumber: kvdchNumber ?? this.kvdchNumber,
      kvdchDate: kvdchDate ?? this.kvdchDate,
      kvdchCommandant: kvdchCommandant ?? this.kvdchCommandant,
      kvdchComments: kvdchComments ?? this.kvdchComments,
      vvpNumber: vvpNumber ?? this.vvpNumber,
      vvpDate: vvpDate ?? this.vvpDate,
      vvpCommandant: vvpCommandant ?? this.vvpCommandant,
      vvpComments: vvpComments ?? this.vvpComments,
      vpptNumber: vpptNumber ?? this.vpptNumber,
      vpptDate: vpptDate ?? this.vpptDate,
      vpptCommandant: vpptCommandant ?? this.vpptCommandant,
      vpptComments: vpptComments ?? this.vpptComments,
      rovNumber: rovNumber ?? this.rovNumber,
      rovDate: rovDate ?? this.rovDate,
      rovCommandant: rovCommandant ?? this.rovCommandant,
      rovComments: rovComments ?? this.rovComments,
      rovMaceNumber: rovMaceNumber ?? this.rovMaceNumber,
      rovMaceDate: rovMaceDate ?? this.rovMaceDate,
      rovMaceCommandant: rovMaceCommandant ?? this.rovMaceCommandant,
      rovMaceComments: rovMaceComments ?? this.rovMaceComments,
      rovNestNumber: rovNestNumber ?? this.rovNestNumber,
      rovNestDate: rovNestDate ?? this.rovNestDate,
      rovNestCommandant: rovNestCommandant ?? this.rovNestCommandant,
      rovNestComments: rovNestComments ?? this.rovNestComments,
      rovLeadersNumber: rovLeadersNumber ?? this.rovLeadersNumber,
      rovLeadersDate: rovLeadersDate ?? this.rovLeadersDate,
      rovLeadersCommandant: rovLeadersCommandant ?? this.rovLeadersCommandant,
      rovLeadersComments: rovLeadersComments ?? this.rovLeadersComments,
      kvvNumber: kvvNumber ?? this.kvvNumber,
      kvvDate: kvvDate ?? this.kvvDate,
      kvvCommandant: kvvCommandant ?? this.kvvCommandant,
      kvvComments: kvvComments ?? this.kvvComments,
      kvzNumber: kvzNumber ?? this.kvzNumber,
      kvzDate: kvzDate ?? this.kvzDate,
      kvzCommandant: kvzCommandant ?? this.kvzCommandant,
      kvzComments: kvzComments ?? this.kvzComments,
      kvptNumber: kvptNumber ?? this.kvptNumber,
      kvptDate: kvptDate ?? this.kvptDate,
      kvptCommandant: kvptCommandant ?? this.kvptCommandant,
      kvptComments: kvptComments ?? this.kvptComments,
      kvpvNumber: kvpvNumber ?? this.kvpvNumber,
      kvpvDate: kvpvDate ?? this.kvpvDate,
      kvpvCommandant: kvpvCommandant ?? this.kvpvCommandant,
      kvpvComments: kvpvComments ?? this.kvpvComments,
      lshNumber: lshNumber ?? this.lshNumber,
      lshDate: lshDate ?? this.lshDate,
      lshCommandant: lshCommandant ?? this.lshCommandant,
      lshComments: lshComments ?? this.lshComments,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        kvdchNumber, kvdchDate, kvdchCommandant, kvdchComments,
        vvpNumber, vvpDate, vvpCommandant, vvpComments,
        vpptNumber, vpptDate, vpptCommandant, vpptComments,
        rovNumber, rovDate, rovCommandant, rovComments,
        rovMaceNumber, rovMaceDate, rovMaceCommandant, rovMaceComments,
        rovNestNumber, rovNestDate, rovNestCommandant, rovNestComments,
        rovLeadersNumber, rovLeadersDate, rovLeadersCommandant, rovLeadersComments,
        kvvNumber, kvvDate, kvvCommandant, kvvComments,
        kvzNumber, kvzDate, kvzCommandant, kvzComments,
        kvptNumber, kvptDate, kvptCommandant, kvptComments,
        kvpvNumber, kvpvDate, kvpvCommandant, kvpvComments,
        lshNumber, lshDate, lshCommandant, lshComments,
        createdAt,
      ];
}
