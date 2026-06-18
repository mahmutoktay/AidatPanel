/// Belge §3 `POST /auth/login`: body `identifier` (email **veya** telefon)
/// + `password`. Field adı `identifier` çünkü backend her iki formatı kabul
/// eder ve sunucu tarafında parse edilir.
class LoginRequest {
  final String identifier;
  final String password;
  final String? deviceLabel;
  final String? platform;

  LoginRequest({
    required this.identifier,
    required this.password,
    this.deviceLabel,
    this.platform,
  });

  Map<String, dynamic> toJson() {
    return {
      'identifier': identifier,
      'password': password,
      if (deviceLabel != null && deviceLabel!.isNotEmpty)
        'deviceLabel': deviceLabel,
      if (platform != null && platform!.isNotEmpty) 'platform': platform,
    };
  }
}
