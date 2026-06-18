class JoinRequest {
  final String inviteCode;
  final String email;
  final String password;
  final String name;
  final String? phone;
  final String? deviceLabel;
  final String? platform;

  JoinRequest({
    required this.inviteCode,
    required this.email,
    required this.password,
    required this.name,
    this.phone,
    this.deviceLabel,
    this.platform,
  });

  Map<String, dynamic> toJson() {
    final cleanPhone = phone?.trim();
    return {
      'inviteCode': inviteCode,
      'email': email,
      'password': password,
      'name': name,
      if (cleanPhone != null && cleanPhone.isNotEmpty) 'phone': cleanPhone,
      if (deviceLabel != null && deviceLabel!.isNotEmpty)
        'deviceLabel': deviceLabel,
      if (platform != null && platform!.isNotEmpty) 'platform': platform,
    };
  }
}
