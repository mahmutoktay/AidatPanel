import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'rolling_metric_value.dart';

/// Ortak dashboard kutu stili — çerçevesiz fill zemin.
abstract final class _DashboardTileStyle {
  static const double radius = 12;
  static const EdgeInsets padding =
      EdgeInsets.symmetric(horizontal: 12, vertical: 12);


  static BoxDecoration decoration() => BoxDecoration(
        color: AppColors.fill,
        borderRadius: BorderRadius.circular(radius),
      );
}

/// Salt okunur özet metrik (üst satır: daire / tahsilat / gecikmiş).
class DashboardMetricTile extends StatelessWidget {
  /// Hero metrik büyük rakam satırı — layout çöküşünü önler.
  static double get kMetricValueHeight =>
      RollingMetricValue.measureSlotHeight(_metricValueStyle(AppColors.textPrimary));

  static const double _labelRowSpacing = 6;

  /// İki satır etiket + ikon satırı yüksekliği.
  static double get kLabelRowHeight {
    final captionStyle = AppTypography.caption.copyWith(
      fontWeight: FontWeight.w600,
    );
    final painter = TextPainter(
      text: TextSpan(text: 'Ör\nÖr', style: captionStyle),
      textDirection: TextDirection.ltr,
      maxLines: 2,
    )..layout();
    const iconHeight = 18.0;
    return painter.height > iconHeight ? painter.height : iconHeight;
  }

  /// Hero satırı — [SingleChildScrollView] içinde güvenli sabit yükseklik.
  static double get kTileHeight =>
      _DashboardTileStyle.padding.vertical +
      kMetricValueHeight +
      _labelRowSpacing +
      kLabelRowHeight;

  final IconData icon;
  final String label;

  /// [animatedValue] verilirse kaydırmalı odometer animasyonu kullanılır.
  final num? animatedValue;
  final String? valuePrefix;

  /// [animatedValue] yokken gösterilen düz metin.
  final String value;
  final Color? valueColor;
  final bool animateValue;

  const DashboardMetricTile({
    super.key,
    required this.icon,
    required this.label,
    this.value = '',
    this.animatedValue,
    this.valuePrefix,
    this.valueColor,
    this.animateValue = true,
  });

  static TextStyle _metricValueStyle(Color valueTint) {
    return AppTypography.h2.copyWith(
      color: valueTint,
      fontWeight: FontWeight.w800,
      fontSize: 22,
    );
  }

  @override
  Widget build(BuildContext context) {
    final valueTint = valueColor ?? AppColors.textPrimary;
    final metricStyle = _metricValueStyle(valueTint);

    return SizedBox(
      height: kTileHeight,
      width: double.infinity,
      child: Container(
        decoration: _DashboardTileStyle.decoration(),
        padding: _DashboardTileStyle.padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: kMetricValueHeight,
              width: double.infinity,
              child: Align(
                alignment: Alignment.centerLeft,
                child: animatedValue != null
                    ? RollingMetricValue(
                        target: animatedValue!,
                        prefix: valuePrefix,
                        style: metricStyle,
                        color: valueTint,
                        animate: animateValue,
                      )
                    : Text(
                        value,
                        style: metricStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
            ),
            const SizedBox(height: _labelRowSpacing),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  icon,
                  size: 18,
                  color: AppColors.textSecondary.withValues(alpha: 0.85),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Tıklanabilir hızlı işlem kutusu.
///
/// [compact] true → 3 sütun grid (ikon üstte); false → tam genişlik satır + chevron.
class DashboardActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final Color? iconColor;
  final VoidCallback onTap;

  /// 3 sütun grid hücreleri için `true`.
  final bool compact;

  /// 3 sütun hızlı işlem satırı yüksekliği (overflow önleme marjı).
  static const double compactRowHeight = 100;

  const DashboardActionTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.onTap,
    this.compact = false,
    this.valueColor,
    this.iconColor,
  });

  int get _count => int.tryParse(value) ?? 0;

  @override
  Widget build(BuildContext context) {
    final accent = iconColor ?? valueColor ?? AppColors.textPrimary;
    final countTint = valueColor ?? AppColors.textPrimary;
    final radius = BorderRadius.circular(_DashboardTileStyle.radius);

    return Container(
      width: double.infinity,
      height: compact ? double.infinity : null,
      decoration: _DashboardTileStyle.decoration(),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          splashColor: AppColors.border.withValues(alpha: 0.4),
          highlightColor: AppColors.border.withValues(alpha: 0.25),
          child: compact
              ? _CompactActionBody(
                  icon: icon,
                  label: label,
                  count: _count,
                  accent: accent,
                  countTint: countTint,
                )
              : _ExpandedActionBody(
                  icon: icon,
                  label: label,
                  count: _count,
                  accent: accent,
                  countTint: countTint,
                ),
        ),
      ),
    );
  }
}

/// 3 sütun grid — ikon üstte, etiket altta, sayı rozeti ikon köşesinde.
class _CompactActionBody extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color accent;
  final Color countTint;

  const _CompactActionBody({
    required this.icon,
    required this.label,
    required this.count,
    required this.accent,
    required this.countTint,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: accent.withValues(alpha: 0.18)),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: accent, size: 19),
              ),
              if (count > 0)
                Positioned(
                  top: -4,
                  right: -6,
                  child: _CountBadge(
                    count: count,
                    emphasized: true,
                    color: countTint,
                    compact: true,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 15,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Tam genişlik veya geniş hücre — yatay satır + chevron.
class _ExpandedActionBody extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color accent;
  final Color countTint;

  const _ExpandedActionBody({
    required this.icon,
    required this.label,
    required this.count,
    required this.accent,
    required this.countTint,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: accent.withValues(alpha: 0.18)),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTypography.body1.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          _CountBadge(
            count: count,
            emphasized: count > 0,
            color: countTint,
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.chevron_right,
            size: 22,
            color: AppColors.textSecondary.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  final bool emphasized;
  final Color color;
  final bool compact;

  const _CountBadge({
    required this.count,
    required this.emphasized,
    required this.color,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final text = count.toString();
    if (emphasized) {
      final minSide = compact ? 20.0 : 28.0;
      return Container(
        constraints: BoxConstraints(minWidth: minSide, minHeight: minSide),
        padding: EdgeInsets.symmetric(horizontal: compact ? 4 : 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(compact ? 10 : 14),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: AppTypography.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: compact ? 11 : 14,
          ),
        ),
      );
    }
    return Text(
      text,
      style: AppTypography.caption.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
  }
}

/// Geriye uyumluluk — yeni ekranlarda [DashboardMetricTile] / [DashboardActionTile] kullanın.
@Deprecated('Use DashboardMetricTile or DashboardActionTile')
class TintDashboardTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final Color? iconColor;
  final VoidCallback? onTap;

  const TintDashboardTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.valueColor,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (onTap != null) {
      return DashboardActionTile(
        icon: icon,
        value: value,
        label: label,
        valueColor: valueColor,
        iconColor: iconColor,
        onTap: onTap!,
      );
    }
    return DashboardMetricTile(
      icon: icon,
      value: value,
      label: label,
      valueColor: valueColor,
    );
  }
}
