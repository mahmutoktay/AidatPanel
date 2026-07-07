import {
  getDuesByBuildingService,
  updateDueStatusService,
  getMyDuesService,
  updateBuildingDueAmountService,
  getDueTransactionsService,
} from "../services/dueService.js";
import { remindBuildingDuesService } from "../services/dueReminderService.js";
import { bulkGenerateBuildingDuesService } from "../services/dueBulkService.js";
import { asyncHandler } from "../utils/asyncHandler.js";

/**
 * GET /api/v1/buildings/:id/dues
 * Yönetici: Binadaki tüm aidatları listele
 */
export const getDuesByBuilding = asyncHandler(async (req, res) => {
  const { id: buildingId } = req.params;
  const { month, year, status, cursor, limit, paginated } = req.query;
  const managerId = req.user.id;

  const dues = await getDuesByBuildingService(buildingId, managerId, {
    month,
    year,
    status,
    cursor,
    limit,
    paginated,
  });

  res.json({
    success: true,
    data: dues,
  });
});

/**
 * GET /api/v1/buildings/:id/dues/transactions
 * Yönetici: Dekont + manuel ödemelerin birleşik işlem geçmişi
 */
export const getDueTransactions = asyncHandler(async (req, res) => {
  const { id: buildingId } = req.params;
  const { cursor, limit, paginated } = req.query;
  const managerId = req.user.id;

  const data = await getDueTransactionsService(buildingId, managerId, {
    cursor,
    limit,
    paginated,
  });

  res.json({
    success: true,
    data,
  });
});

/**
 * PATCH /api/v1/buildings/:id/dues/:dueId/status
 * Yönetici: Aidat durumunu güncelle
 */
export const updateDueStatus = asyncHandler(async (req, res) => {
  const { id: buildingId, dueId } = req.params;
  const { status, paidAt, note } = req.body;
  const managerId = req.user.id;

  const result = await updateDueStatusService(dueId, managerId, {
    status,
    paidAt,
    note,
    buildingId,
  });

  res.json({
    success: true,
    message: "Aidat durumu güncellendi.",
    data: result,
  });
});

/**
 * GET /api/v1/me/dues
 * Sakin: Kendi aidatlarını listele
 */
export const getMyDues = asyncHandler(async (req, res) => {
  const { status, year, month, cursor, limit, paginated } = req.query;
  const userId = req.user.id;

  const dues = await getMyDuesService(userId, {
    status,
    year,
    month,
    cursor,
    limit,
    paginated,
  });

  res.json({
    success: true,
    data: dues,
  });
});

/**
 * POST /api/v1/buildings/:id/dues/remind
 * Yönetici: PENDING/OVERDUE aidatlar için sakinlere hatırlatma
 */
export const postRemindBuildingDues = asyncHandler(async (req, res) => {
  const { id: buildingId } = req.params;
  const { month, year, dueIds } = req.body;

  const data = await remindBuildingDuesService(buildingId, req.user.id, {
    month,
    year,
    dueIds,
  });

  let message;
  if (data.reminded > 0) {
    message = `${data.reminded} sakine aidat hatırlatması gönderildi.`;
  } else if (data.skippedCooldown > 0) {
    message = "Son 24 saat içinde zaten hatırlatma gönderildi.";
  } else {
    message = "Hatırlatılacak aidat bulunamadı.";
  }

  res.status(200).json({
    success: true,
    message,
    data,
  });
});

/**
 * POST /api/v1/buildings/:id/dues/bulk
 * Yönetici: Eksik aidatları toplu oluştur (bulunulan ay → yıl sonu veya tek ay)
 */
export const postBulkGenerateBuildingDues = asyncHandler(async (req, res) => {
  const { id: buildingId } = req.params;
  const { month, year } = req.body ?? {};

  const data = await bulkGenerateBuildingDuesService(
    buildingId,
    { managerId: req.user.id },
    { month, year }
  );

  const created = data.created ?? 0;
  res.status(200).json({
    success: true,
    message:
      created > 0
        ? `${created} aidat kaydı oluşturuldu.`
        : data.message ?? "Oluşturulacak yeni aidat bulunamadı.",
    data,
  });
});

/**
 * PATCH /api/v1/buildings/:id/due-amount
 * Yönetici: Aidat bedelini güncelle
 */
export const updateBuildingDueAmount = asyncHandler(async (req, res) => {
  const { id: buildingId } = req.params;
  const { dueAmount, dueDay, currency, affectCurrent } = req.body;
  const managerId = req.user.id;

  const result = await updateBuildingDueAmountService(buildingId, managerId, {
    dueAmount,
    dueDay,
    currency,
    affectCurrent,
  });

  res.json({
    success: true,
    message: "Aidat bedeli güncellendi.",
    data: result,
  });
});
