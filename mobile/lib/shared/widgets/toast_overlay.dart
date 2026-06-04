import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';

enum ToastType { info, success, error, warning, notification }

class ToastMessage {
  final String id;
  final String message;
  final ToastType type;
  final Duration duration;
  final bool exiting;

  const ToastMessage({
    required this.id,
    required this.message,
    required this.type,
    required this.duration,
    this.exiting = false,
  });

  ToastMessage copyWith({bool? exiting}) {
    return ToastMessage(
      id: id,
      message: message,
      type: type,
      duration: duration,
      exiting: exiting ?? this.exiting,
    );
  }
}

class ToastNotifier extends StateNotifier<List<ToastMessage>> {
  ToastNotifier() : super([]);

  static const int maxVisible = 3;
  static const Duration displayDuration = Duration(seconds: 3);
  static const Duration notificationDisplayDuration = Duration(seconds: 4);
  static const Duration fadeDuration = Duration(milliseconds: 200);

  int _idCounter = 0;
  final List<String> _notificationQueue = [];
  bool _drainingNotifications = false;

  /// Bildirim toast'ları sırayla gösterilir (üst üste binmez).
  void showNotification(String message) {
    final text = message.trim();
    if (text.isEmpty) return;
    _notificationQueue.add(text);
    unawaited(_drainNotificationQueue());
  }

  Future<void> _drainNotificationQueue() async {
    if (_drainingNotifications) return;
    _drainingNotifications = true;
    try {
      while (_notificationQueue.isNotEmpty) {
        final message = _notificationQueue.removeAt(0);
        _dismissVisibleNotificationToasts();
        show(
          message,
          type: ToastType.notification,
          duration: notificationDisplayDuration,
        );
        await Future.delayed(
          notificationDisplayDuration + fadeDuration,
        );
      }
    } finally {
      _drainingNotifications = false;
      if (_notificationQueue.isNotEmpty) {
        unawaited(_drainNotificationQueue());
      }
    }
  }

  void _dismissVisibleNotificationToasts() {
    state = [
      for (final t in state)
        if (t.type == ToastType.notification && !t.exiting)
          t.copyWith(exiting: true)
        else
          t,
    ];
  }

  void show(
    String message, {
    ToastType type = ToastType.info,
    Duration? duration,
  }) {
    final id = '${DateTime.now().millisecondsSinceEpoch}_${_idCounter++}';
    final visibleFor = duration ?? displayDuration;
    final toast = ToastMessage(
      id: id,
      message: message,
      type: type,
      duration: visibleFor,
    );

    state = [...state, toast];

    if (state.where((t) => !t.exiting).length > maxVisible) {
      final oldest = state.firstWhere((t) => !t.exiting);
      _markAsExiting(oldest.id);
    }

    Future.delayed(visibleFor, () {
      _markAsExiting(id);
    });
  }

  void _markAsExiting(String id) {
    if (!state.any((t) => t.id == id && !t.exiting)) return;

    state = [
      for (final t in state)
        if (t.id == id) t.copyWith(exiting: true) else t,
    ];

    Future.delayed(fadeDuration, () {
      state = state.where((t) => t.id != id).toList();
    });
  }

  void dismiss(String id) => _markAsExiting(id);
}

final toastProvider =
    StateNotifierProvider<ToastNotifier, List<ToastMessage>>(
      (ref) => ToastNotifier(),
    );

class ToastOverlay extends ConsumerWidget {
  final Widget child;

  const ToastOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toasts = ref.watch(toastProvider);
    final visible = toasts.where((t) => !t.exiting).toList();

    return Stack(
      children: [
        child,
        if (visible.isNotEmpty)
          Positioned(
            top: 0,
            left: AppSizes.spacingM,
            right: AppSizes.spacingM,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(top: AppSizes.spacingS),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  for (final toast in visible.reversed)
                    _ToastItem(
                      key: ValueKey(toast.id),
                      toast: toast,
                      onTap: () =>
                          ref.read(toastProvider.notifier).dismiss(toast.id),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ToastItem extends StatefulWidget {
  final ToastMessage toast;
  final VoidCallback onTap;

  const _ToastItem({super.key, required this.toast, required this.onTap});

  @override
  State<_ToastItem> createState() => _ToastItemState();
}

class _ToastItemState extends State<_ToastItem>
    with SingleTickerProviderStateMixin {
  bool _entered = false;
  late AnimationController _lifeController;

  @override
  void initState() {
    super.initState();
    _lifeController = AnimationController(
      vsync: this,
      duration: widget.toast.duration,
    )..forward(from: 0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _entered = true);
    });
  }

  @override
  void dispose() {
    _lifeController.dispose();
    super.dispose();
  }

  IconData get _icon {
    switch (widget.toast.type) {
      case ToastType.success:
        return Icons.check_circle_outline;
      case ToastType.error:
        return Icons.error_outline;
      case ToastType.warning:
        return Icons.warning_amber_outlined;
      case ToastType.info:
        return Icons.info_outline;
      case ToastType.notification:
        return Icons.notifications_active_outlined;
    }
  }

  Color get _accentColor {
    switch (widget.toast.type) {
      case ToastType.success:
        return AppColors.success;
      case ToastType.error:
        return AppColors.error;
      case ToastType.warning:
        return AppColors.warning;
      case ToastType.info:
        return AppColors.info;
      case ToastType.notification:
        return AppColors.primary;
    }
  }

  Color get _backgroundColor {
    final Color statusBg;
    switch (widget.toast.type) {
      case ToastType.success:
        statusBg = AppColors.successBg;
      case ToastType.error:
        statusBg = AppColors.errorBg;
      case ToastType.warning:
        statusBg = AppColors.warningBg;
      case ToastType.info:
        statusBg = AppColors.infoBg;
      case ToastType.notification:
        statusBg = AppColors.infoBg;
    }
    return Color.lerp(statusBg, AppColors.surface, 0.42)!;
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor;
    final background = _backgroundColor;
    final isExiting = widget.toast.exiting;
    final visible = _entered && !isExiting;

    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: ToastNotifier.fadeDuration,
      curve: Curves.easeInOut,
      child: AnimatedSlide(
        offset: visible
            ? Offset.zero
            : (isExiting ? const Offset(0, -0.15) : const Offset(0, -0.25)),
        duration: ToastNotifier.fadeDuration,
        curve: Curves.easeInOut,
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.spacingS),
          child: Material(
            color: Colors.transparent,
            elevation: 8,
            shadowColor: AppColors.textPrimary.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              child: AnimatedBuilder(
                animation: _lifeController,
                builder: (context, _) {
                  final remaining = 1 - _lifeController.value;
                  final radius = BorderRadius.circular(AppSizes.cardRadius);
                  return ClipRRect(
                    borderRadius: radius,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: accent.withValues(alpha: 0.45),
                          width: 1.5,
                        ),
                        borderRadius: radius,
                      ),
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(
                              AppSizes.spacingM,
                              AppSizes.spacingM + 4,
                              AppSizes.spacingM,
                              AppSizes.spacingM,
                            ),
                            color: background,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  _icon,
                                  size: AppSizes.iconSize,
                                  color: accent,
                                ),
                                const SizedBox(width: AppSizes.spacingM),
                                Expanded(
                                  child: Text(
                                    widget.toast.message,
                                    style: AppTypography.bodyLarge.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: _TopCornerBeam(
                              progress: remaining,
                              accent: accent,
                              radius: AppSizes.cardRadius,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Üst kenar — sol üst köşe kart yarıçapıyla hizalı, parlamasız süre çizgisi.
class _TopCornerBeam extends StatelessWidget {
  final double progress;
  final Color accent;
  final double radius;

  const _TopCornerBeam({
    required this.progress,
    required this.accent,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    if (clamped <= 0) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final beamWidth = constraints.maxWidth * clamped;
        return Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: beamWidth,
            height: 4,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(radius),
                topRight: clamped >= 0.999
                    ? Radius.circular(radius)
                    : Radius.zero,
              ),
            ),
          ),
        );
      },
    );
  }
}
