import 'package:flutter/foundation.dart';

/// Dekont akışı debug çıktısı — yalnızca debug/profile build.
/// Production öncesi: bu dosyayı kaldırın veya çağrıları silin.
void dekontDebugLog(String step, [Object? detail]) {
  if (!kDebugMode) return;
  if (detail == null) {
    debugPrint('[dekont] $step');
    return;
  }
  debugPrint('[dekont] $step → $detail');
}
