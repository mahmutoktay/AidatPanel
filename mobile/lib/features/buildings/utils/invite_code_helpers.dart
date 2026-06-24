import '../../../core/constants/invite_link_constants.dart';
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

  /// Davet linki (web landing — uygulama yüklüyse App Link ile açılır).
  static String buildInviteLink(String code) {
    return InviteLinkConstants.joinPathWithCode(code);
  }

  /// Paylaşılacak mesajı oluşturur.
  static String buildShareMessage({
    required String code,
    required BuildingEntity building,
    required ApartmentEntity apartment,
    required DateTime expiresAt,
  }) {
    final link = buildInviteLink(code);
    final siteLine = building.siteName != null && building.siteName!.isNotEmpty
        ? 'Site: ${building.siteName}\n'
        : '';
    final blockLine =
        building.blockLabel != null && building.blockLabel!.isNotEmpty
            ? 'Blok: ${building.blockLabel}\n'
            : '';
    return 'AidatPanel davet\n\n'
        '$siteLine'
        'Bina: ${building.name}\n'
        '$blockLine'
        'Daire: ${formatApartmentLabel(apartment.apartmentNumber)}\n\n'
        'Katılmak için bağlantıya dokunun:\n$link\n\n'
        'Davet kodu: $code\n'
        'Son kullanma: ${formatDate(expiresAt)} (7 gün geçerli)\n\n'
        'Uygulama yüklü değilse bağlantıdan indirebilir, kurulumdan sonra '
        'aynı bağlantıya tekrar dokunarak kayıt olabilirsiniz.';
  }

  static String buildingListSubtitle(BuildingEntity building) {
    if (building.siteName != null && building.siteName!.isNotEmpty) {
      final block =
          building.blockLabel != null && building.blockLabel!.isNotEmpty
              ? ' · ${building.blockLabel}'
              : '';
      return '${building.siteName}$block · ${building.displayAddress}';
    }
    return building.displayAddress;
  }
}
