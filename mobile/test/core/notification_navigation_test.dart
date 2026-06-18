import 'package:aidatpanel/core/notifications/notification_navigation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isNotificationDetailPath', () {
    test('matches dekont detail', () {
      expect(isNotificationDetailPath('/dekonts/abc-123'), isTrue);
    });

    test('matches ticket detail', () {
      expect(isNotificationDetailPath('/tickets/tid-42'), isTrue);
    });

    test('matches expense detail', () {
      expect(isNotificationDetailPath('/expenses/exp-7'), isTrue);
    });

    test('rejects dashboard paths', () {
      expect(isNotificationDetailPath('/manager-dashboard'), isFalse);
      expect(isNotificationDetailPath('/resident-dashboard'), isFalse);
      expect(isNotificationDetailPath('/manager-dashboard/dekonts'), isFalse);
    });

    test('rejects ticket create path', () {
      expect(isNotificationDetailPath('/tickets/create'), isFalse);
    });

    test('rejects dekont list redirect path', () {
      expect(isNotificationDetailPath('/dekonts'), isFalse);
    });
  });
}
