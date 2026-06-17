import 'dart:async';

import 'package:flutter/material.dart';

/// Liste sonuna yaklaşınca [onLoadMore] çağırır.
///
/// [canLoad] false dönerse veya yükleme zaten sürüyorsa tetiklenmez.
/// [debounce] ile ardışık scroll olaylarında tek istek yapılır.
void attachPaginationScroll(
  ScrollController controller,
  VoidCallback onLoadMore, {
  double threshold = 120,
  bool Function()? canLoad,
  Duration debounce = const Duration(milliseconds: 200),
}) {
  Timer? debounceTimer;

  controller.addListener(() {
    if (!controller.hasClients) return;
    final pos = controller.position;
    if (pos.maxScrollExtent - pos.pixels >= threshold) return;
    if (canLoad != null && !canLoad()) return;

    debounceTimer?.cancel();
    debounceTimer = Timer(debounce, () {
      if (!controller.hasClients) return;
      final current = controller.position;
      if (current.maxScrollExtent - current.pixels >= threshold) return;
      if (canLoad != null && !canLoad()) return;
      onLoadMore();
    });
  });
}
