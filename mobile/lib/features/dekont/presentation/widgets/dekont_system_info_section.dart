import 'package:flutter/material.dart';

import '../../../../core/theme/app_sizes.dart';
import '../../domain/entities/dekont_entity.dart';
import 'dekont_detail_hero.dart';
import 'dekont_detail_metrics_card.dart';

/// Dekont sistem bilgisi — hero + metrik kart kompozisyonu.
class DekontSystemInfoSection extends StatelessWidget {
  final DekontEntity dekont;
  final bool isManager;

  const DekontSystemInfoSection({
    super.key,
    required this.dekont,
    required this.isManager,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DekontDetailHero(dekont: dekont, forResident: !isManager),
        const SizedBox(height: AppSizes.spacingM),
        DekontDetailMetricsCard(dekont: dekont, isManager: isManager),
      ],
    );
  }
}
