import 'dart:math';
import 'package:flutter/foundation.dart';

/// Dekont akışı debug çıktısı — yalnızca debug/profile build.
/// Hassas bilgileri loglamaz; dosya yolu yerine sadece son 20 karakter.
void dekontDebugLog(String step, [Object? detail]) {
  if (!kDebugMode) return;
  if (detail == null) {
    debugPrint('[dekont] $step');
    return;
  }
  // Map ise dosya yolu içerebilecek alanları sanitize et
  if (detail is Map) {
    final sanitized = detail.map((key, value) {
      if (key == 'filePath' || key == 'storedPath' || key == 'path') {
        final str = value.toString();
        return MapEntry(key, str.length > 4 ? '...${str.substring(max(0, str.length - 20))}' : str);
      }
      return MapEntry(key, value);
    });
    debugPrint('[dekont] $step → $sanitized');
    return;
  }
  debugPrint('[dekont] $step → $detail');
}
