import '../../apartments/domain/entities/apartment_entity.dart';
import '../domain/entities/building_entity.dart';

/// Davet kodu özelliği için yardımcı saf fonksiyonlar.
class InviteCodeHelpers {
  InviteCodeHelpers._();

  /// "1A" → "1. Kat - Daire A", "12" → "12. Kat"
  static String formatApartmentLabel(String apartmentNumber) {
    final match = RegExp(r'(\d+)([A-Za-z]?)').firstMatch(apartmentNumber);
    if (match == null) return apartmentNumber;
    final floor = match.group(1);
    final letter = match.group(2);
    if (letter != null && letter.isNotEmpty) {
      return '$floor. Kat - Daire $letter';
    }
    return '$floor. Kat';
  }

  /// DateTime → "06.05.2026"
  static String formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d.$m.${date.year}';
  }

  /// Liste kartları: üst satır kod, alt satır kalan süre.
  static ({String primary, String remaining}) activeCodeListSubtitle({
    required String activeCodeLabel,
    required String code,
    required Duration remaining,
  }) {
    return (
      primary: '$activeCodeLabel: $code •',
      remaining: remainingText(remaining),
    );
  }

  /// Süre: "5 gün 3 saat", "12 saat 30 dk", "45 dk", "Süresi doldu"
  static String remainingText(Duration d) {
    if (d.isNegative) return 'Süresi doldu';
    if (d.inDays > 0) {
      final hours = d.inHours - d.inDays * 24;
      return hours > 0 ? '${d.inDays} gün $hours saat' : '${d.inDays} gün';
    }
    if (d.inHours > 0) {
      final mins = d.inMinutes - d.inHours * 60;
      return mins > 0 ? '${d.inHours} saat $mins dk' : '${d.inHours} saat';
    }
    return '${d.inMinutes} dk';
  }

  /// Paylaşılacak mesajı oluşturur.
  static String buildShareMessage({
    required String code,
    required BuildingEntity building,
    required ApartmentEntity apartment,
    required DateTime expiresAt,
  }) {
    final buffer = StringBuffer('AidatPanel davet kodu\n\n');
    final siteName = building.siteName?.trim();
    if (siteName != null && siteName.isNotEmpty) {
      buffer.writeln('Site: $siteName');
    }
    final blockLabel = building.blockLabel?.trim();
    if (blockLabel != null && blockLabel.isNotEmpty) {
      buffer.writeln('Blok: $blockLabel');
    }
    buffer
      ..writeln('Bina: ${building.displayName}')
      ..writeln('Daire: ${formatApartmentLabel(apartment.apartmentNumber)}')
      ..writeln('Kod: $code\n')
      ..writeln('Katıl: https://aidatpanel.com/join?code=$code\n')
      ..writeln('Son kullanma: ${formatDate(expiresAt)} (7 gün geçerli)\n')
      ..write(
        'Linke dokunun veya AidatPanel uygulamasını indirip bu kodu kullanın.',
      );
    return buffer.toString();
  }

  /// Sonuç ekranı alt başlığı: site + blok + daire.
  static String resultSubtitle({
    required BuildingEntity building,
    required String apartmentLabel,
  }) {
    final siteName = building.siteName?.trim();
    if (siteName != null && siteName.isNotEmpty) {
      final block = building.blockLabel?.trim();
      if (block != null && block.isNotEmpty) {
        return '$siteName • $block • $apartmentLabel';
      }
      return '$siteName • ${building.displayName} • $apartmentLabel';
    }
    return '${building.displayName} • $apartmentLabel';
  }
}
