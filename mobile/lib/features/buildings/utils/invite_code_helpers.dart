import 'dart:math';

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

  /// Davet kodu artık yalnızca backend tarafından üretilir
  /// (`POST /api/v1/apartments/:apartmentId/invite-code`); canlı akışta
  /// **bu fonksiyon çağrılmamalıdır** (çift kaynak olmasın).
  ///
  /// Yalnızca offline test / mock senaryoları için bırakılmıştır. Üretilen
  /// kod `AuthValidators.isValidInviteCode` regex'i ile birebir uyumludur:
  /// `AP` + 1 hex + `-` + 3 hex + `-` + 4 hex (örn. `AP3-B12-A9F0`).
  @Deprecated(
    'Davet kodu backend tarafından üretilir; yalnızca test/mock için kullanın.',
  )
  static String generateCode(BuildingEntity b, ApartmentEntity a) {
    const hex = '0123456789ABCDEF';
    final rnd = Random.secure();
    String pick(int n) =>
        List.generate(n, (_) => hex[rnd.nextInt(hex.length)]).join();

    return 'AP${pick(1)}-${pick(3)}-${pick(4)}';
  }

  /// Paylaşılacak mesajı oluşturur.
  static String buildShareMessage({
    required String code,
    required BuildingEntity building,
    required ApartmentEntity apartment,
    required DateTime expiresAt,
  }) {
    return 'AidatPanel davet kodu\n\n'
        'Bina: ${building.name}\n'
        'Daire: ${formatApartmentLabel(apartment.apartmentNumber)}\n'
        'Kod: $code\n\n'
        'Son kullanma: ${formatDate(expiresAt)} (7 gün geçerli)\n\n'
        'AidatPanel uygulamasını indirip kayıt olurken bu kodu kullanabilirsiniz.';
  }
}
