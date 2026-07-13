/// `POST /auth/forgot-password` yanıtındaki `data` alanı.
class ForgotPasswordResult {
  const ForgotPasswordResult({
    this.deliveredVia,
    this.smsFallbackAvailable = false,
  });

  /// `"email"` | `"sms"` | `null` (hesap yok / kanal yok — enumeration koruması).
  final String? deliveredVia;

  /// E-posta gönderildiyse ve hesapta telefon varsa `true` → SMS yedek butonu.
  final bool smsFallbackAvailable;

  factory ForgotPasswordResult.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ForgotPasswordResult();
    }
    final via = json['deliveredVia'];
    return ForgotPasswordResult(
      deliveredVia: via is String ? via : null,
      smsFallbackAvailable: json['smsFallbackAvailable'] == true,
    );
  }
}

/// Reset ekranına taşınan argümanlar (GoRouter `extra`).
class ResetPasswordArgs {
  const ResetPasswordArgs({
    this.identifier,
    this.email,
    this.phone,
    this.deliveredVia,
    this.smsFallbackAvailable = false,
  });

  /// Gösterim için ham identifier (e-posta veya telefon).
  final String? identifier;

  /// API çağrısı için e-posta (varsa).
  final String? email;

  /// API çağrısı için kanonik telefon (varsa).
  final String? phone;

  final String? deliveredVia;
  final bool smsFallbackAvailable;
}
