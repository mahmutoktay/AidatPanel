import 'package:intl/date_symbol_data_local.dart';

/// Desteklenen diller için ay/gün adı verilerini yükler.
Future<void> initDateFormatting() async {
  await initializeDateFormatting('tr_TR');
  await initializeDateFormatting('en_US');
}
