import 'package:flutter/material.dart';

/// Liste sonuna yaklaşınca [onLoadMore] çağırır (notifications pattern).
void attachPaginationScroll(
  ScrollController controller,
  VoidCallback onLoadMore, {
  double threshold = 120,
}) {
  controller.addListener(() {
    if (!controller.hasClients) return;
    final pos = controller.position;
    if (pos.maxScrollExtent - pos.pixels < threshold) {
      onLoadMore();
    }
  });
}
