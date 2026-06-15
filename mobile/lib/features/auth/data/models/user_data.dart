import '../../../auth/domain/entities/user_entity.dart';

class UserData {
  final String id;
  final String? email;
  final String name;
  final String? phone;
  final String role;
  final String language;
  final String? apartmentId;
  final String? profilePicture;
  final DateTime? createdAt;

  UserData({
    required this.id,
    this.email,
    required this.name,
    this.phone,
    required this.role,
    this.language = 'tr',
    this.apartmentId,
    this.profilePicture,
    this.createdAt,
  });

  static DateTime? _parseCreatedAt(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] as String,
      email: json['email'] as String?,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      role: json['role'] as String,
      language: json['language'] as String? ?? 'tr',
      apartmentId: json['apartmentId'] as String?,
      profilePicture: json['profilePicture'] as String?,
      createdAt: _parseCreatedAt(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role,
      'language': language,
      'apartmentId': apartmentId,
      'profilePicture': profilePicture,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      name: name,
      phone: phone,
      role: role == 'MANAGER' ? UserRole.manager : UserRole.resident,
      language: language,
      apartmentId: apartmentId,
      profilePicture: profilePicture,
      createdAt: createdAt,
    );
  }
}
