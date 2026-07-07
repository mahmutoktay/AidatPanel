import '../../../buildings/presentation/providers/apartment_dues_history_provider.dart';
import 'due_transactions_provider.dart';
import 'dues_provider.dart';

/// Aidat ödendi / dekont onaylandıktan sonra dashboard ve diğer sekmelerin
/// güncel veriyi göstermesi için ilgili önbellekleri temizler ve yeniden yükler.
Future<void> invalidateDuesRelatedCaches(dynamic ref) async {
  final txBuildingId = ref.read(dueTransactionsNotifierProvider).buildingId;

  ref.invalidate(allBuildingsDuesProvider);
  ref.invalidate(apartmentDuesHistoryProvider);
  ref.invalidate(dueTransactionsNotifierProvider);

  final futures = <Future<void>>[
    ref.read(duesNotifierProvider.notifier).refreshLoadedDues(),
    ref.read(allBuildingsDuesProvider.future).then((_) {}),
  ];
  if (txBuildingId != null) {
    futures.add(
      ref
          .read(dueTransactionsNotifierProvider.notifier)
          .loadBuilding(txBuildingId),
    );
  }
  await Future.wait(futures);
}
