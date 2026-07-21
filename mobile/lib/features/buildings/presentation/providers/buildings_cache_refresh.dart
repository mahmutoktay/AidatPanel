import '../../data/buildings_store.dart';
import '../../../dues/presentation/providers/dues_provider.dart';
import '../../../sites/data/sites_store.dart';

/// Bina mutasyonlarından sonra Ana Sayfa + Binalar sekmesi listelerini senkron tutar.
///
/// İki ayrı store (`buildingsStoreProvider` / `standaloneBuildingsStoreProvider`)
/// kullanıldığı için yalnızca birini güncellemek diğer sekmede bayat liste bırakır.
Future<void> syncManagerBuildingLists(dynamic ref) async {
  final Future<void> all =
      ref.read(buildingsStoreProvider.notifier).refreshBuildings();
  final Future<void> standalone =
      ref.read(standaloneBuildingsStoreProvider.notifier).refreshBuildings();
  await Future.wait<void>([all, standalone]);
}

/// Site bloğu eklendiğinde/silindiğinde site özeti + bina listeleri + aidat haritası.
Future<void> syncAfterSiteBuildingMutation(dynamic ref) async {
  final Future<void> buildings = syncManagerBuildingLists(ref);
  final Future<void> sites =
      ref.read(sitesStoreProvider.notifier).refreshSites();
  await Future.wait<void>([buildings, sites]);
  ref.invalidate(allBuildingsDuesProvider);
}
