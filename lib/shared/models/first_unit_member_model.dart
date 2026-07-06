import 'package:equatable/equatable.dart';

enum MemberType {
  novak,
  ptasha,
  yunak,
  pidvykhovnyk,
  vykhovnyk;

  String get translationKey {
    switch (this) {
      case MemberType.novak:
        return 'memberTypeNovak';
      case MemberType.ptasha:
        return 'memberTypePtasha';
      case MemberType.yunak:
        return 'memberTypeYunak';
      case MemberType.pidvykhovnyk:
        return 'memberTypePidvykhovnyk';
      case MemberType.vykhovnyk:
        return 'memberTypeVykhovnyk';
    }
  }

  static MemberType? fromString(String? value) {
    if (value == null) return null;
    return MemberType.values.cast<MemberType?>().firstWhere(
          (e) => e?.name == value,
          orElse: () => null,
        );
  }
}

class FirstUnitMemberModel extends Equatable {
  final String id;
  final String firstUnitId;
  final String firstName;
  final String lastName;
  final DateTime? dateOfBirth;
  final String address;
  final String phone;
  final MemberType? memberType;

  const FirstUnitMemberModel({
    required this.id,
    required this.firstUnitId,
    required this.firstName,
    required this.lastName,
    this.dateOfBirth,
    this.address = '',
    this.phone = '',
    this.memberType,
  });

  factory FirstUnitMemberModel.fromJson(Map<String, dynamic> json) {
    return FirstUnitMemberModel(
      id: json['id'] as String,
      firstUnitId: json['first_unit_id'] as String,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      address: json['address'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      memberType: MemberType.fromString(json['member_type'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_unit_id': firstUnitId,
      'first_name': firstName,
      'last_name': lastName,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'address': address,
      'phone': phone,
      'member_type': memberType?.name,
    };
  }

  FirstUnitMemberModel copyWith({
    String? id,
    String? firstUnitId,
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    String? address,
    String? phone,
    MemberType? memberType,
  }) {
    return FirstUnitMemberModel(
      id: id ?? this.id,
      firstUnitId: firstUnitId ?? this.firstUnitId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      memberType: memberType ?? this.memberType,
    );
  }

  @override
  List<Object?> get props => [id, firstUnitId, firstName, lastName, dateOfBirth, address, phone, memberType];
}
