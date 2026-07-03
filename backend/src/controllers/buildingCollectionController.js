import { updateBuildingCollectionService } from "../services/buildingService.js";
import { asyncHandler } from "../utils/asyncHandler.js";

export const patchBuildingCollection = asyncHandler(async (req, res) => {
  const { id: buildingId } = req.params;
  const updated = await updateBuildingCollectionService(
    buildingId,
    req.user.id,
    req.body
  );

  if (!updated) {
    return res.status(404).json({
      success: false,
      message: "Bina bulunamadı veya erişim yetkiniz yok.",
    });
  }

  res.status(200).json({
    success: true,
    message: "Tahsilat bilgileri güncellendi.",
    data: updated,
  });
});
