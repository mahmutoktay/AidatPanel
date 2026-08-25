import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../shared/providers/navigation_provider.dart';
import '../domain/feature_tour_models.dart';
import 'feature_tour_targets.dart';

class FeatureTourState {
  final bool visible;
  final FeatureTourId? tourId;
  final int stepIndex;
  final List<FeatureTourStepId> steps;

  const FeatureTourState({
    this.visible = false,
    this.tourId,
    this.stepIndex = 0,
    this.steps = const [],
  });

  FeatureTourStepId? get currentStep {
    if (!visible || steps.isEmpty) return null;
    if (stepIndex < 0 || stepIndex >= steps.length) return null;
    return steps[stepIndex];
  }

  bool get isLastStep =>
      visible && steps.isNotEmpty && stepIndex >= steps.length - 1;

  FeatureTourState copyWith({
    bool? visible,
    FeatureTourId? tourId,
    int? stepIndex,
    List<FeatureTourStepId>? steps,
  }) {
    return FeatureTourState(
      visible: visible ?? this.visible,
      tourId: tourId ?? this.tourId,
      stepIndex: stepIndex ?? this.stepIndex,
      steps: steps ?? this.steps,
    );
  }
}

final featureTourProvider =
    NotifierProvider<FeatureTourNotifier, FeatureTourState>(
  FeatureTourNotifier.new,
);

class FeatureTourNotifier extends Notifier<FeatureTourState> {
  SecureStorage get _storage => ref.read(secureStorageProvider);

  @override
  FeatureTourState build() => const FeatureTourState();

  Future<void> tryStart(FeatureTourId tourId, {bool force = false}) async {
    if (!AppConstants.featureTourEnabled) return;
    if (state.visible) return;

    if (!force && await _storage.isFeatureTourCompleted(tourId)) {
      return;
    }

    final onHome = switch (tourId) {
      FeatureTourId.managerHome => ref.read(managerTabIndexProvider) == 0,
      FeatureTourId.residentHome => ref.read(residentTabIndexProvider) == 0,
    };
    if (!onHome) return;

    final resolved = FeatureTourCatalog.stepsFor(tourId)
        .where(FeatureTourTargets.isLaidOut)
        .toList(growable: false);
    if (resolved.isEmpty) return;

    state = FeatureTourState(
      visible: true,
      tourId: tourId,
      stepIndex: 0,
      steps: resolved,
    );
  }

  Future<void> next() async {
    if (!state.visible || state.tourId == null) return;
    if (state.isLastStep) {
      await _complete();
      return;
    }
    state = state.copyWith(stepIndex: state.stepIndex + 1);
  }

  Future<void> skip() async => _complete();

  Future<void> replay(FeatureTourId tourId) async {
    if (!AppConstants.featureTourEnabled) return;
    await _storage.clearFeatureTourCompleted(tourId);
    switch (tourId) {
      case FeatureTourId.managerHome:
        ref.read(managerTabIndexProvider.notifier).reset();
      case FeatureTourId.residentHome:
        ref.read(residentTabIndexProvider.notifier).reset();
    }
    state = const FeatureTourState();
    await Future<void>.delayed(const Duration(milliseconds: 250));
    await tryStart(tourId, force: true);
    if (state.visible) return;
    await Future<void>.delayed(const Duration(milliseconds: 200));
    await tryStart(tourId, force: true);
  }

  Future<void> _complete() async {
    final id = state.tourId;
    state = const FeatureTourState();
    if (id != null) {
      await _storage.markFeatureTourCompleted(id);
    }
  }
}
