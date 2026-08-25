import 'package:flutter/material.dart';

import '../domain/feature_tour_models.dart';

/// Spotlight hedefleri — tek dashboard oturumunda paylaşılır.
abstract final class FeatureTourTargets {
  static final GlobalKey buildingSelector = GlobalKey(
    debugLabel: 'featureTour.buildingSelector',
  );
  static final GlobalKey summary = GlobalKey(
    debugLabel: 'featureTour.summary',
  );
  static final GlobalKey quickActions = GlobalKey(
    debugLabel: 'featureTour.quickActions',
  );
  static final GlobalKey bottomNav = GlobalKey(
    debugLabel: 'featureTour.bottomNav',
  );
  static final GlobalKey notifications = GlobalKey(
    debugLabel: 'featureTour.notifications',
  );

  static GlobalKey keyFor(FeatureTourStepId step) {
    return switch (step) {
      FeatureTourStepId.buildingSelector => buildingSelector,
      FeatureTourStepId.summary => summary,
      FeatureTourStepId.quickActions => quickActions,
      FeatureTourStepId.bottomNav => bottomNav,
      FeatureTourStepId.notifications => notifications,
    };
  }

  /// Hedef widget ekranda ölçülebilir ve sıfırdan büyük mü.
  static Rect? rectFor(FeatureTourStepId step) {
    final context = keyFor(step).currentContext;
    if (context == null) return null;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    final size = box.size;
    if (size.width < 1 || size.height < 1) return null;
    final topLeft = box.localToGlobal(Offset.zero);
    return topLeft & size;
  }

  static bool isLaidOut(FeatureTourStepId step) => rectFor(step) != null;
}
