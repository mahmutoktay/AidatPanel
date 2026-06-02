/** Yönetici review (APPROVE / REJECT) için uygun dekont durumları */

export const DEKONT_APPROVABLE_STATUSES = new Set([
  "NEEDS_MANAGER_REVIEW",
  "MATCHED",
  "UNMATCHED",
  "MATCH_AMBIGUOUS",
  "RECIPIENT_MISMATCH",
  "PARSED",
  "PARSE_LOW_CONFIDENCE",
]);

export const DEKONT_REJECTABLE_STATUSES = new Set([
  ...DEKONT_APPROVABLE_STATUSES,
  "RECEIVED",
  "EXTRACTING",
  "EXTRACT_FAILED",
]);
