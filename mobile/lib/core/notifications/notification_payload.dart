import '../../features/auth/domain/entities/user_entity.dart';

/// FCM `data` alanı — backend tüm değerleri string gönderir.
class NotificationPayload {
  final String? type;
  final String? notificationId;
  final String? ticketId;
  final String? dekontId;
  final String? dueId;
  final String? buildingId;
  final String? status;
  final String? route;
  final String? sessionId;

  const NotificationPayload({
    this.type,
    this.notificationId,
    this.ticketId,
    this.dekontId,
    this.dueId,
    this.buildingId,
    this.status,
    this.route,
    this.sessionId,
  });

  factory NotificationPayload.fromFcmData(Map<String, dynamic> data) {
    String? str(dynamic v) {
      if (v == null) return null;
      final s = v.toString().trim();
      return s.isEmpty ? null : s;
    }

    return NotificationPayload(
      type: str(data['type']),
      notificationId: str(data['notificationId']),
      ticketId: str(data['ticketId']),
      dekontId: str(data['dekontId']),
      dueId: str(data['dueId']),
      buildingId: str(data['buildingId']),
      status: str(data['status']),
      route: str(data['route']),
      sessionId: str(data['sessionId']),
    );
  }

  String _dashboardPath({
    required String basePath,
    required String tab,
    UserRole? role,
  }) {
    final q = <String, String>{'tab': tab};
    if (dueId != null && dueId!.isNotEmpty) q['dueId'] = dueId!;
    if (role == UserRole.manager &&
        buildingId != null &&
        buildingId!.isNotEmpty) {
      q['buildingId'] = buildingId!;
    }
    return Uri(path: basePath, queryParameters: q).toString();
  }

  /// GoRouter yolu; rol ve `type` ile backend deep link matrisine uyumlu.
  String? resolveNavigationPath({UserRole? role}) {
    final normalized = type?.toUpperCase();
    final tid = ticketId;
    final did = dekontId;

    switch (normalized) {
      case 'TICKET_CREATED':
        if (tid != null) {
          return role == UserRole.manager ? '/tickets/$tid' : null;
        }
        return role == UserRole.manager ? '/manager/tickets' : null;
      case 'TICKET_UPDATE':
        if (tid != null) return '/tickets/$tid';
        return route ?? '/resident-dashboard';
      case 'DEKONT_PAYMENT_APPLIED':
        if (did != null) return '/dekonts/$did';
        return route ?? '/dekonts';
      case 'DEKONT_RECEIVED':
      case 'DEKONT_NEEDS_REVIEW':
      case 'DEKONT_MATCHED':
        if (did != null) return '/dekonts/$did';
        return role == UserRole.manager ? '/manager/dekonts' : '/dekonts';
      case 'ANNOUNCEMENT':
        return route ?? '/notifications';
      case 'DUE_PAID':
      case 'DUE_REMINDER':
      case 'EXPENSE_ADDED':
        if (role == UserRole.manager) {
          return _dashboardPath(
            basePath: '/manager-dashboard',
            tab: 'dues',
            role: role,
          );
        }
        return _dashboardPath(
          basePath: '/resident-dashboard',
          tab: 'dues',
          role: role,
        );
      default:
        if (normalized == 'SYSTEM' && did != null) {
          return '/dekonts/$did';
        }
        if (route != null && route!.isNotEmpty) return route;
        return '/notifications';
    }
  }
}
