import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/buildings/data/buildings_store.dart';
import '../../features/buildings/data/invite_code_store.dart';
import '../../features/buildings/presentation/providers/saved_ibans_provider.dart';
import '../../features/dekont/data/dekont_preview_cache.dart';
import '../../features/dekont/presentation/providers/dekont_provider.dart';
import '../../features/dues/presentation/providers/dues_provider.dart';
import '../../features/expenses/presentation/providers/expenses_provider.dart';
import '../../features/notifications/presentation/providers/notifications_provider.dart';
import '../../features/subscription/presentation/providers/subscription_provider.dart';
import '../../features/tickets/presentation/providers/tickets_provider.dart';
import '../../features/dekont/presentation/providers/share_intent_provider.dart';

/// Kullanıcı değiştiğinde (login/logout) tüm cached StateNotifierProvider'ları
/// [ref.invalidate] ile geçersiz kılarak yeni kullanıcının verilerinin
/// sıfırdan yüklenmesini sağlar.
///
/// Çağrıldığı her provider yeniden oluşturulur ve kendi `load*` metodunu
/// tetikler (ör. [BuildingsNotifier] construct'unda `loadBuildings()`).
void invalidateAllCachedProviders(WidgetRef ref) {
  // Binalar
  ref.invalidate(buildingsStoreProvider);
  ref.invalidate(collectionPresetsProvider);

  // Aidatlar
  ref.invalidate(duesNotifierProvider);
  ref.invalidate(allBuildingsDuesProvider);

  // Giderler
  ref.invalidate(expensesNotifierProvider);

  // Talepler
  ref.invalidate(ticketsNotifierProvider);

  // Abonelik
  ref.invalidate(subscriptionNotifierProvider);

  // Bildirimler
  ref.invalidate(notificationsNotifierProvider);

  // Davet kodları
  ref.invalidate(inviteCodeStoreProvider);

  // Kayıtlı IBAN'lar
  ref.invalidate(savedIbansListProvider);

  // Dekont / ödeme
  ref.invalidate(makePaymentNotifierProvider);
  ref.invalidate(myDekontsNotifierProvider);
  ref.invalidate(managerDekontsNotifierProvider);
  ref.invalidate(shareIntentProvider);
  ref.invalidate(pendingDekontFileProvider);
}

Future<void> _clearDekontFilePreviews(WidgetRef ref) async {
  ref.read(dekontLocalPreviewProvider.notifier).state = {};
  await DekontPreviewCache.clearAll();
}

/// Başka hesapla giriş — önceki kullanıcının dekont dosya önizlemesini sil.
Future<void> clearDekontPreviewsOnUserSwitch(WidgetRef ref) async {
  await _clearDekontFilePreviews(ref);
}

/// Oturum kapanırken tüm önbellek + dekont dosya önizlemesini temizler.
Future<void> invalidateCachesOnLogout(WidgetRef ref) async {
  invalidateAllCachedProviders(ref);
  await _clearDekontFilePreviews(ref);
}
