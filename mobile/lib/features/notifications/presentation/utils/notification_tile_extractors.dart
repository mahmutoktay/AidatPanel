import '../../domain/entities/notification_entity.dart';

/// Bildirim kartı için daire etiketi — önce payload, sonra gövde metni.
String? notificationTileApartmentLabel(NotificationEntity notification) {
  final data = notification.data;
  if (data != null) {
    for (final key in const [
      'apartmentLabel',
      'apartmentName',
      'apartmentNumber',
    ]) {
      final value = data[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
  }

  final body = notification.body;
  if (body.startsWith('Daire ')) {
    final dashIdx = body.indexOf(' —');
    if (dashIdx != -1) return body.substring(0, dashIdx).trim();
    final colonIdx = body.indexOf(':');
    if (colonIdx != -1) return body.substring(0, colonIdx).trim();
  }
  return null;
}

/// Bildirim kartı için tutar — önce payload, sonra gövde regex.
String? notificationTileAmount(NotificationEntity notification) {
  final data = notification.data;
  if (data != null) {
    for (final key in const [
      'amount',
      'dueAmount',
      'expenseAmount',
      'parsedAmount',
    ]) {
      final value = data[key];
      if (value == null) continue;
      final formatted = _formatAmountValue(value);
      if (formatted != null) return formatted;
    }
  }

  return _extractAmountFromBody(notification.body);
}

String? _formatAmountValue(Object value) {
  if (value is num) {
    final text = value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
    return '₺$text';
  }
  final raw = value.toString().trim();
  if (raw.isEmpty) return null;
  if (raw.startsWith('₺')) return raw;
  return '₺$raw';
}

String? _extractAmountFromBody(String body) {
  final match = RegExp(r'₺\s*([0-9.,]+)').firstMatch(body);
  if (match == null) return null;
  return '₺${match.group(1)}';
}
