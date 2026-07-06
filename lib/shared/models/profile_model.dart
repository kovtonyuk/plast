import 'package:equatable/equatable.dart';

class ProfileModel extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String? nickname;
  final String? avatarUrl;
  final String phone;
  final String location;
  final String? email;
  final int emailVerified;
  final DateTime? dateOfBirth;
  final String? plastUnit;
  final DateTime? dateOfNaming;
  final String? whoNamed;
  final DateTime? dateJoinedPlast;
  final String? heardAboutPlast;
  final DateTime? dateOath;
  // Станичний
  final String? stanychnyPhone;
  // Заступник станичного
  final String? zamistnykStanychnogoPhone;
  // Референт/ка УСП/УПС
  final String? referentUspUpsPhone;
  // Референт/ка УПП/УПН/УПЮ
  final String? referentUppUpnUpuPhone;
  // Скарбник/ча
  final String? skarbnykPhone;
  final DateTime createdAt;

  const ProfileModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.nickname,
    this.avatarUrl,
    required this.phone,
    required this.location,
    this.email,
    this.emailVerified = 0,
    this.dateOfBirth,
    this.plastUnit,
    this.dateOfNaming,
    this.whoNamed,
    this.dateJoinedPlast,
    this.heardAboutPlast,
    this.dateOath,
    this.stanychnyPhone,
    this.zamistnykStanychnogoPhone,
    this.referentUspUpsPhone,
    this.referentUppUpnUpuPhone,
    this.skarbnykPhone,
    required this.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      nickname: json['nickname'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      phone: json['phone'] as String? ?? '',
      location: json['location'] as String? ?? '',
      email: json['email'] as String?,
      emailVerified: json['email_verified'] as int? ?? 0,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      plastUnit: json['plast_unit'] as String?,
      dateOfNaming: json['date_of_naming'] != null
          ? DateTime.parse(json['date_of_naming'] as String)
          : null,
      whoNamed: json['who_named'] as String?,
      dateJoinedPlast: json['date_joined_plast'] != null
          ? DateTime.parse(json['date_joined_plast'] as String)
          : null,
      heardAboutPlast: json['heard_about_plast'] as String?,
      dateOath: json['date_oath'] != null
          ? DateTime.parse(json['date_oath'] as String)
          : null,
      stanychnyPhone: json['stanychny_phone'] as String?,
      zamistnykStanychnogoPhone: json['zamistnyk_stanychnogo_phone'] as String?,
      referentUspUpsPhone: json['referent_usp_ups_phone'] as String?,
      referentUppUpnUpuPhone: json['referent_upp_upn_upu_phone'] as String?,
      skarbnykPhone: json['skarbnyk_phone'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'nickname': nickname,
      'avatar_url': avatarUrl,
      'phone': phone,
      'location': location,
      'email': email,
      'email_verified': emailVerified,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'plast_unit': plastUnit,
      'date_of_naming': dateOfNaming?.toIso8601String(),
      'who_named': whoNamed,
      'date_joined_plast': dateJoinedPlast?.toIso8601String(),
      'heard_about_plast': heardAboutPlast,
      'date_oath': dateOath?.toIso8601String(),
      'stanychny_phone': stanychnyPhone,
      'zamistnyk_stanychnogo_phone': zamistnykStanychnogoPhone,
      'referent_usp_ups_phone': referentUspUpsPhone,
      'referent_upp_upn_upu_phone': referentUppUpnUpuPhone,
      'skarbnyk_phone': skarbnykPhone,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ProfileModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? nickname,
    String? phone,
    String? location,
    String? email,
    int? emailVerified,
    DateTime? dateOfBirth,
    String? plastUnit,
    DateTime? dateOfNaming,
    String? whoNamed,
    DateTime? dateJoinedPlast,
    String? heardAboutPlast,
    DateTime? dateOath,
    String? stanychnyPhone,
    String? zamistnykStanychnogoPhone,
    String? referentUspUpsPhone,
    String? referentUppUpnUpuPhone,
    String? skarbnykPhone,
    DateTime? createdAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      nickname: nickname ?? this.nickname,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      email: email ?? this.email,
      emailVerified: emailVerified ?? this.emailVerified,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      plastUnit: plastUnit ?? this.plastUnit,
      dateOfNaming: dateOfNaming ?? this.dateOfNaming,
      whoNamed: whoNamed ?? this.whoNamed,
      dateJoinedPlast: dateJoinedPlast ?? this.dateJoinedPlast,
      heardAboutPlast: heardAboutPlast ?? this.heardAboutPlast,
      dateOath: dateOath ?? this.dateOath,
      stanychnyPhone: stanychnyPhone ?? this.stanychnyPhone,
      zamistnykStanychnogoPhone: zamistnykStanychnogoPhone ?? this.zamistnykStanychnogoPhone,
      referentUspUpsPhone: referentUspUpsPhone ?? this.referentUspUpsPhone,
      referentUppUpnUpuPhone: referentUppUpnUpuPhone ?? this.referentUppUpnUpuPhone,
      skarbnykPhone: skarbnykPhone ?? this.skarbnykPhone,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        nickname,
        phone,
        location,
        email,
        emailVerified,
        dateOfBirth,
        plastUnit,
        dateOfNaming,
        whoNamed,
        dateJoinedPlast,
        heardAboutPlast,
        dateOath,
        stanychnyPhone,
        zamistnykStanychnogoPhone,
        referentUspUpsPhone,
        referentUppUpnUpuPhone,
        skarbnykPhone,
        createdAt,
      ];
}
