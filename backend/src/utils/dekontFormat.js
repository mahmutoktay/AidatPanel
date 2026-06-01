/** Dekont API yanıt alanları — servisler arası paylaşım (döngüsel import önleme). */

export const dekontListSelect = {
  id: true,
  buildingId: true,
  apartmentId: true,
  uploadedById: true,
  dueId: true,
  status: true,
  source: true,
  originalFilename: true,
  mimeType: true,
  sizeBytes: true,
  recipientVerified: true,
  referenceNumber: true,
  parsedAmount: true,
  transactionDate: true,
  aiConfidence: true,
  reviewedAt: true,
  reviewNote: true,
  rejectionReason: true,
  createdAt: true,
  updatedAt: true,
};

export function formatDekont(row) {
  if (!row) return null;
  const { storedPath: _storedPath, rawText: _rawText, verificationJson: _v, ...rest } =
    row;
  return {
    ...rest,
    parsedAmount: row.parsedAmount != null ? String(row.parsedAmount) : null,
  };
}
