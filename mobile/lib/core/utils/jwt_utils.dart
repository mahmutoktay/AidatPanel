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

  /// GET önbellek anahtarı: kullanıcı + oturum revizyonu (`rv`).
  static String sessionCacheSuffix(String? accessToken) {
    if (accessToken == null || accessToken.isEmpty) return 'anon';
    try {
      final data = _decodePayload(accessToken);
      final id = data['id'];
      final rv = data['rv'] ?? 0;
      final sid = data['sid'];
      if (sid is String && sid.isNotEmpty) {
        return '${id ?? 'u'}:$sid';
      }
      return '${id ?? 'u'}:$rv';
    } catch (_) {
      return 't${accessToken.hashCode}';
    }
  }

  /// JWT `sid` claim — cihaz oturumu kimliği.
  static String? parseSessionId(String token) {
    try {
      final sid = _decodePayload(token)['sid'];
      if (sid is String && sid.isNotEmpty) return sid;
    } catch (_) {}
    return null;
  }

  static Map<String, dynamic> _decodePayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw const FormatException('invalid jwt');
    }
    final payload = base64Url.normalize(parts[1]);
    final decoded = utf8.decode(base64Url.decode(payload));
    return jsonDecode(decoded) as Map<String, dynamic>;
  }
}
