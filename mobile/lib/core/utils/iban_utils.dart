/// Türkiye IBAN doğrulama ve gösterim (backend `iban.js` ile uyumlu: format + mod-97).
class IbanUtils {
  IbanUtils._();

  static final RegExp _trIbanPattern = RegExp(r'^TR\d{24}$');

  /// Boşlukları kaldırır, büyük harfe çevirir.
  static String normalize(String raw) =>
      raw.replaceAll(RegExp(r'\s'), '').toUpperCase();

  /// Dolu IBAN geçerli TR formatında ve kontrol hanesi doğru mu?
  static bool isValidTrIban(String? raw) {
    if (raw == null) return false;
    final n = normalize(raw);
    if (n.isEmpty) return false;
    if (!_trIbanPattern.hasMatch(n)) return false;
    return _passesMod97(n);
  }

  /// ISO 13616 mod-97 checksum (backend ile aynı algoritma).
  static bool _passesMod97(String normalized) {
    final rearranged = normalized.substring(4) + normalized.substring(0, 4);
    final buffer = StringBuffer();
    for (final code in rearranged.codeUnits) {
      if (code >= 48 && code <= 57) {
        buffer.writeCharCode(code);
      } else {
        buffer.write(code - 55);
      }
    }
    final numeric = buffer.toString();
    var remainder = 0;
    for (var i = 0; i < numeric.length; i++) {
      remainder = (remainder * 10 + (numeric.codeUnitAt(i) - 48)) % 97;
    }
    return remainder == 1;
  }

  /// En az bir tahsilat alanı dolu mu?
  static bool hasAnyCollectionInput({
    String? iban,
    String? accountTitle,
    String? referenceTemplate,
  }) {
    return normalize(iban ?? '').isNotEmpty ||
        (accountTitle?.trim().isNotEmpty ?? false) ||
        (referenceTemplate?.trim().isNotEmpty ?? false);
  }

  /// 4’lü gruplar halinde gösterim.
  static String formatDisplay(String raw) {
    final c = normalize(raw);
    if (c.isEmpty) return '';
    return RegExp(r'.{1,4}')
        .allMatches(c)
        .map((m) => m.group(0))
        .join(' ');
  }
}
