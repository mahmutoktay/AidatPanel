enum DekontStatus {
  received,
  extracting,
  extractFailed,
  parsed,
  parseLowConfidence,
  matching,
  matched,
  matchAmbiguous,
  unmatched,
  paymentApplied,
  paymentPartial,
  rejected,
  recipientMismatch,
  needsManagerReview;

  String get apiValue {
    switch (this) {
      case DekontStatus.received:
        return 'RECEIVED';
      case DekontStatus.extracting:
        return 'EXTRACTING';
      case DekontStatus.extractFailed:
        return 'EXTRACT_FAILED';
      case DekontStatus.parsed:
        return 'PARSED';
      case DekontStatus.parseLowConfidence:
        return 'PARSE_LOW_CONFIDENCE';
      case DekontStatus.matching:
        return 'MATCHING';
      case DekontStatus.matched:
        return 'MATCHED';
      case DekontStatus.matchAmbiguous:
        return 'MATCH_AMBIGUOUS';
      case DekontStatus.unmatched:
        return 'UNMATCHED';
      case DekontStatus.paymentApplied:
        return 'PAYMENT_APPLIED';
      case DekontStatus.paymentPartial:
        return 'PAYMENT_PARTIAL';
      case DekontStatus.rejected:
        return 'REJECTED';
      case DekontStatus.recipientMismatch:
        return 'RECIPIENT_MISMATCH';
      case DekontStatus.needsManagerReview:
        return 'NEEDS_MANAGER_REVIEW';
    }
  }

  static DekontStatus? fromApi(String? value) {
    if (value == null || value.isEmpty) return null;
    final upper = value.toUpperCase();
    for (final s in DekontStatus.values) {
      if (s.apiValue == upper) return s;
    }
    return null;
  }

  bool get isTerminal =>
      this == DekontStatus.paymentApplied || this == DekontStatus.rejected;

  /// OCR/iş kuralı aktif çalışıyor — RECEIVED bekleyen kayıt değil.
  bool get isProcessing =>
      this == DekontStatus.extracting || this == DekontStatus.matching;

  bool get needsManagerAttention =>
      this == DekontStatus.needsManagerReview ||
      this == DekontStatus.parseLowConfidence ||
      this == DekontStatus.unmatched ||
      this == DekontStatus.recipientMismatch ||
      this == DekontStatus.matchAmbiguous ||
      this == DekontStatus.extractFailed;

  /// OCR eşleşse bile ödeme yönetici onayı olmadan uygulanmaz (auto-apply kapalı).
  bool get needsManagerApproval {
    if (isTerminal || isProcessing) return false;
    switch (this) {
      case DekontStatus.matched:
      case DekontStatus.parsed:
      case DekontStatus.needsManagerReview:
      case DekontStatus.parseLowConfidence:
      case DekontStatus.unmatched:
      case DekontStatus.recipientMismatch:
      case DekontStatus.matchAmbiguous:
      case DekontStatus.extractFailed:
        return true;
      default:
        return false;
    }
  }
}
