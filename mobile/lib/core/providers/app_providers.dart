import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/dio_client.dart';
import '../storage/secure_storage.dart';

/// Oturum sonlandığında callback almak için Provider.
/// DioClient > TokenRefreshService token yenileyemezse bu callback tetiklenir.
typedef SessionExpiredCallback = void Function();

/// Provider üzerinden erişilebilir session expired callback.
final onSessionExpiredProvider = Provider<SessionExpiredCallback?>((ref) => null);

final secureStorageProvider = Provider((ref) => SecureStorage());

final dioClientProvider = Provider((ref) {
  return DioClient(
    secureStorage: ref.watch(secureStorageProvider),
    onSessionExpiredGetter: () => ref.read(onSessionExpiredProvider),
  );
});
