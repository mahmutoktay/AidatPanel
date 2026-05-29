import 'package:flutter/widgets.dart';

import '../../domain/entities/collection_preset_entity.dart';
import '../../../../l10n/strings.g.dart';

/// Kayıtlı IBAN kartlarında `{{number}}` gibi şablonları kullanıcı dilinde gösterir.
/// API'ye giden `paymentReferenceTemplate` değişmez.
class CollectionPresetDisplay {
  CollectionPresetDisplay._();

  static List<String> detailLines(
    BuildContext context,
    CollectionPresetEntity preset,
  ) {
    final t = context.t.features.buildings.collection;
    final lines = <String>[];

    final accountTitle = preset.collectionAccountTitle?.trim();
    if (accountTitle != null && accountTitle.isNotEmpty) {
      lines.add('${t.detailAccountHolder}: $accountTitle');
    }

    final reference = _referenceDetailLine(t, preset.paymentReferenceTemplate);
    if (reference != null) {
      lines.add(reference);
    }

    if (preset.buildingCount > 1) {
      lines.add(
        t.detailUsedInBuildings.replaceAll('{count}', '${preset.buildingCount}'),
      );
    }

    return lines;
  }

  static String? _referenceDetailLine(
    // ignore: avoid_unused_parameters — slang nested type is library-private
    dynamic t,
    String? template,
  ) {
    if (template == null || template.trim().isEmpty) return null;

    final raw = template.trim();
    if (!raw.contains('{{number}}')) {
      return '${t.detailReference as String}: $raw';
    }

    final normalized = raw
        .replaceAll('{{number}}', '')
        .replaceAll(RegExp(r'[\s\-–—:/]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .toLowerCase();

    if (normalized.isEmpty || normalized == 'daire') {
      return t.detailReferenceDaireOnly as String;
    }
    if (normalized.contains('aidat') && normalized.contains('daire')) {
      return t.detailReferenceDaireAidat as String;
    }
    if (normalized.contains('aidat')) {
      return t.detailReferenceAidat as String;
    }
    if (normalized.contains('havale')) {
      return t.detailReferenceHavale as String;
    }

    return t.detailReferenceAuto as String;
  }
}
