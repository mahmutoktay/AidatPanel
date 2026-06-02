import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/strings.g.dart';

/// Bildirimler için tarih bölümleri (50+ kullanıcı: kronolojik tarama kolaylığı).
enum NotificationDateSection { today, yesterday, thisWeek, earlier }

extension NotificationDateSectionLabel on NotificationDateSection {
  String label(BuildContext context) {
    final t = context.t.features.notifications;
    switch (this) {
      case NotificationDateSection.today:
        return t.sectionToday;
      case NotificationDateSection.yesterday:
        return t.sectionYesterday;
      case NotificationDateSection.thisWeek:
        return t.sectionThisWeek;
      case NotificationDateSection.earlier:
        return t.sectionEarlier;
    }
  }
}

/// Verilen tarihin hangi bölüme düştüğünü hesaplar.
NotificationDateSection notificationSectionFor(DateTime createdAt) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final that = DateTime(createdAt.year, createdAt.month, createdAt.day);
  final dayDiff = today.difference(that).inDays;

  if (dayDiff <= 0) return NotificationDateSection.today;
  if (dayDiff == 1) return NotificationDateSection.yesterday;
  if (dayDiff < 7) return NotificationDateSection.thisWeek;
  return NotificationDateSection.earlier;
}

/// Kısa, anlaşılır göreli zaman: "Az önce", "5 dk önce", "3 saat önce",
/// "Dün", hafta içi gün adı veya tam tarih.
String notificationRelativeTime(
  BuildContext context,
  DateTime createdAt, {
  required String locale,
}) {
  final t = context.t.features.notifications;
  final now = DateTime.now();
  final diff = now.difference(createdAt);

  if (diff.inMinutes < 1) return t.timeNow;
  if (diff.inMinutes < 60) return '${diff.inMinutes} ${t.timeMinuteShort}';

  final section = notificationSectionFor(createdAt);
  switch (section) {
    case NotificationDateSection.today:
      return '${diff.inHours} ${t.timeHourShort}';
    case NotificationDateSection.yesterday:
      return '${t.sectionYesterday}, ${DateFormat('HH:mm', locale).format(createdAt)}';
    case NotificationDateSection.thisWeek:
      return DateFormat('EEEE, HH:mm', locale).format(createdAt);
    case NotificationDateSection.earlier:
      final sameYear = createdAt.year == now.year;
      final pattern = sameYear ? 'd MMM, HH:mm' : 'd MMM yyyy';
      return DateFormat(pattern, locale).format(createdAt);
  }
}
