import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'feature_tour_overlay.dart';
import 'feature_tour_provider.dart';

/// Dashboard scaffold üzerine spotlight overlay.
class FeatureTourHost extends ConsumerWidget {
  final Widget child;

  const FeatureTourHost({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visible = ref.watch(
      featureTourProvider.select((s) => s.visible),
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        if (visible) const FeatureTourOverlay(),
      ],
    );
  }
}
