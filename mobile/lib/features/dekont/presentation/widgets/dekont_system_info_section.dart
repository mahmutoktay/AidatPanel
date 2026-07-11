import 'package:flutter/material.dart';

import '../../domain/entities/dekont_entity.dart';
import 'dekont_detail_hero.dart';

/// Dekont sistem bilgisi — sadeleştirilmiş hero (sakin + yönetici).
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
    return DekontDetailHero(dekont: dekont, forResident: !isManager);
  }
}
