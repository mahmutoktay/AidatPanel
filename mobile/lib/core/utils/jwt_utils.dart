import 'dart:convert';

/// JWT `exp` claim'inden access token bitiş zamanını okur.
class JwtUtils {
  JwtUtils._();

  static const Duration defaultAccessTtl = Duration(minutes: 15);

  /// `exp` yoksa veya parse başarısızsa [fallback] döner.
  static DateTime parseExpiry(
    String token, {
    DateTime? fallback,
  }) {
    final fb = fallback ?? DateTime.now().add(defaultAccessTtl);
    try {
      final parts = token.split('.');
      if (parts.length != 3) return fb;
      final payload = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(payload));
      final data = jsonDecode(decoded) as Map<String, dynamic>;
      final exp = data['exp'] as int?;
      if (exp == null) return fb;
      return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    } catch (_) {
      return fb;
    }
  }
}
