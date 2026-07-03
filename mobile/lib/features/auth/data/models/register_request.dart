class RegisterRequest {
  final String? email;
  final String password;
  final String name;
  final String? phone;

  RegisterRequest({
    this.email,
    required this.password,
    required this.name,
    this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      if (email != null && email!.isNotEmpty) 'email': email,
      if (phone != null && phone!.isNotEmpty) 'phone': phone,
      'password': password,
      'name': name,
    };
  }
}
