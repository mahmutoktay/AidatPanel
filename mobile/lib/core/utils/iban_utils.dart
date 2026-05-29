/// Türkiye IBAN doğrulama ve gösterim (backend: `^TR\d{24}$`, boşluksuz).
class IbanUtils {
  IbanUtils._();

  static final RegExp _trIbanPattern = RegExp(r'^TR\d{24}$');

  /// Boşlukları kaldırır, büyük harfe çevirir.
  static String normalize(String raw) =>
      raw.replaceAll(RegExp(r'\s'), '').toUpperCase();

  /// Dolu IBAN geçerli TR formatında mı?
  static bool isValidTrIban(String? raw) {
    if (raw == null) return false;
    final n = normalize(raw);
    if (n.isEmpty) return false;
    return _trIbanPattern.hasMatch(n);
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
