/// Türkiye cep telefonu normalizasyonu — kanonik 10 hane `5xxxxxxxxx`.
class PhoneUtils {
  PhoneUtils._();

  static final _nonDigit = RegExp(r'[^0-9]');

  /// Ham girişten 10 haneli telefon veya null.
  static String? normalizeTrPhone(String? input) {
    if (input == null || input.trim().isEmpty) return null;
    var digits = input.replaceAll(_nonDigit, '');
    if (digits.startsWith('90') && digits.length >= 12) {
      digits = digits.substring(2);
    }
    if (digits.startsWith('0') && digits.length == 11) {
      digits = digits.substring(1);
    }
    if (digits.length == 10 && digits.startsWith('5')) {
      return digits;
    }
    return null;
  }

  /// Login identifier: e-posta küçük harf, telefon 10 hane.
  static String normalizeLoginIdentifier(String raw) {
    final trimmed = raw.trim();
    if (trimmed.contains('@')) return trimmed.toLowerCase();
    return normalizeTrPhone(trimmed) ?? trimmed;
  }

  /// UI gösterimi: `5XX XXX XX XX`
  static String formatDisplay(String phone10) {
    if (phone10.length != 10) return phone10;
    return '${phone10.substring(0, 3)} ${phone10.substring(3, 6)} '
        '${phone10.substring(6, 8)} ${phone10.substring(8)}';
  }

  /// Maskeli: `5XX XXX XX XX`
  static String maskDisplay(String phone10) {
    if (phone10.length != 10) return '***';
    return '${phone10.substring(0, 3)} *** ** ${phone10.substring(8)}';
  }
}
