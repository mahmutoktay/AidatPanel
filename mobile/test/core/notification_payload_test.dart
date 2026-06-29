import 'package:aidatpanel/core/notifications/notification_payload.dart';
import 'package:aidatpanel/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationPayload.fromFcmData', () {
    test('parses string FCM data fields', () {
      final p = NotificationPayload.fromFcmData({
        'type': 'TICKET_UPDATE',
        'notificationId': 'n1',
        'ticketId': 't1',
        'buildingId': 'b1',
        'status': 'IN_PROGRESS',
        'route': '/tickets/t1',
      });

      expect(p.type, 'TICKET_UPDATE');
      expect(p.notificationId, 'n1');
      expect(p.ticketId, 't1');
      expect(p.buildingId, 'b1');
      expect(p.status, 'IN_PROGRESS');
      expect(p.route, '/tickets/t1');
    });
  });

  group('NotificationPayload.resolveNavigationPath', () {
    test('TICKET_CREATED manager with ticketId opens detail', () {
      const p = NotificationPayload(
        type: 'TICKET_CREATED',
        ticketId: 'tid',
      );
      expect(
        p.resolveNavigationPath(role: UserRole.manager),
        '/tickets/tid',
      );
    });

    test('TICKET_UPDATE resident opens ticket detail', () {
      const p = NotificationPayload(
        type: 'TICKET_UPDATE',
        ticketId: 'tid',
      );
      expect(
        p.resolveNavigationPath(role: UserRole.resident),
        '/tickets/tid',
      );
    });

    test('ANNOUNCEMENT defaults to notifications', () {
      const p = NotificationPayload(type: 'ANNOUNCEMENT');
      expect(p.resolveNavigationPath(), '/notifications');
    });

    test('DUE_PAID resident opens dues tab with dueId', () {
      const p = NotificationPayload(
        type: 'DUE_PAID',
        dueId: 'due-42',
      );
      expect(
        p.resolveNavigationPath(role: UserRole.resident),
        '/resident-dashboard?tab=dues&dueId=due-42',
      );
    });

    test('DUE_PAID manager opens manager dues tab', () {
      const p = NotificationPayload(
        type: 'DUE_PAID',
        dueId: 'due-42',
        buildingId: 'b1',
      );
      expect(
        p.resolveNavigationPath(role: UserRole.manager),
        '/manager-dashboard?tab=dues&dueId=due-42&buildingId=b1',
      );
    });

    test('SYSTEM subscription grant opens manager subscription screen', () {
      const p = NotificationPayload(
        type: 'SYSTEM',
        code: 'subscription_granted_admin',
        route: '/subscription',
      );
      expect(
        p.resolveNavigationPath(role: UserRole.manager),
        '/manager-dashboard/subscription',
      );
    });

    test('SYSTEM normalizes legacy subscription route typo', () {
      const p = NotificationPayload(
        type: 'SYSTEM',
        route: '/subcription',
      );
      expect(
        p.resolveNavigationPath(role: UserRole.manager),
        '/manager-dashboard/subscription',
      );
    });
  });
}
