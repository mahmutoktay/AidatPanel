import 'user_entity.dart';

/// Rol başına kayıtlı giriş bilgisi — aynı telefon hem yönetici hem sakin olabilir.
class SavedLoginHint {
  const SavedLoginHint({
    required this.role,
    required this.name,
    this.phone,
    this.email,
  });

  final UserRole role;
  final String name;
  final String? phone;
  final String? email;

  Map<String, dynamic> toJson() => {
        'role': role == UserRole.manager ? 'MANAGER' : 'RESIDENT',
        'name': name,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
      };

  factory SavedLoginHint.fromJson(Map<String, dynamic> json) {
    final roleRaw = json['role']?.toString().toUpperCase();
    return SavedLoginHint(
      role: roleRaw == 'MANAGER' ? UserRole.manager : UserRole.resident,
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
    );
  }
}
