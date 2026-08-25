/// Dashboard spotlight rehberi kimlikleri (v1).
enum FeatureTourId {
  managerHome,
  residentHome,
}

/// Rehber adım hedefleri — [FeatureTourTargets] GlobalKey ile eşleşir.
enum FeatureTourStepId {
  buildingSelector,
  summary,
  quickActions,
  bottomNav,
  notifications,
}

/// Rol bazlı adım sırası (geçersiz hedefler runtime'da elenir).
abstract final class FeatureTourCatalog {
  static const List<FeatureTourStepId> managerHomeSteps = [
    FeatureTourStepId.buildingSelector,
    FeatureTourStepId.summary,
    FeatureTourStepId.quickActions,
    FeatureTourStepId.bottomNav,
    FeatureTourStepId.notifications,
  ];

  static const List<FeatureTourStepId> residentHomeSteps = [
    FeatureTourStepId.summary,
    FeatureTourStepId.quickActions,
    FeatureTourStepId.bottomNav,
    FeatureTourStepId.notifications,
  ];

  static List<FeatureTourStepId> stepsFor(FeatureTourId id) {
    return switch (id) {
      FeatureTourId.managerHome => managerHomeSteps,
      FeatureTourId.residentHome => residentHomeSteps,
    };
  }
}
