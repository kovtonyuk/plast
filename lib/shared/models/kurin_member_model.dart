import 'package:equatable/equatable.dart';
import 'first_unit_member_model.dart';

/// A single member of a "Курінь" (kurin). Same shape as
/// [FirstUnitMemberModel] but tied to `your_kurin.id` instead of
/// `first_units.id`, so it lives in a separate table.
class KurinMemberModel extends Equatable {
  final String id;
  final String kurinId;
  final String firstName;
  final String lastName;
  final MemberType? memberType;
  final DateTime? dateOfBirth;
  final String address;
  final String phone;

  const KurinMemberModel({
    required this.id,
    required this.kurinId,
    required this.firstName,
    required this.lastName,
    this.memberType,
    this.dateOfBirth,
    this.address = '',
    this.phone = '',
  });

  factory KurinMemberModel.fromJson(Map<String, dynamic> json) {
    return KurinMemberModel(
      id: json['id'] as String,
      kurinId: json['kurin_id'] as String,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      memberType: MemberType.fromString(json['member_type'] as String?),
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      address: json['address'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kurin_id': kurinId,
      'first_name': firstName,
      'last_name': lastName,
      'member_type': memberType?.name,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'address': address,
      'phone': phone,
    };
  }

  KurinMemberModel copyWith({
    String? id,
    String? kurinId,
    String? firstName,
    String? lastName,
    MemberType? memberType,
    DateTime? dateOfBirth,
    String? address,
    String? phone,
  }) {
    return KurinMemberModel(
      id: id ?? this.id,
      kurinId: kurinId ?? this.kurinId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      memberType: memberType ?? this.memberType,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      phone: phone ?? this.phone,
    );
  }

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [
        id,
        kurinId,
        firstName,
        lastName,
        memberType,
        dateOfBirth,
        address,
        phone,
      ];
}
