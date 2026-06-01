import { updateBuildingCollectionService } from "../services/buildingService.js";
import { HttpError } from "../utils/httpError.js";

export const patchBuildingCollection = async (req, res, next) => {
  try {
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
  } catch (err) {
    if (err instanceof HttpError) {
      return res.status(err.statusCode).json({
        success: false,
        message: err.message,
      });
    }
    next(err);
  }
};
