import { sendBuildingAnnouncementService } from "../services/announcementService.js";
import { asyncHandler } from "../utils/asyncHandler.js";

export const postBuildingAnnouncement = asyncHandler(async (req, res) => {
  const { id: buildingId } = req.params;
  const data = await sendBuildingAnnouncementService(
    buildingId,
    req.user.id,
    req.body
  );

  res.status(201).json({
    success: true,
    message:
      data.created > 0
        ? `${data.created} sakine duyuru gönderildi.`
        : "Bu binada kayıtlı sakin bulunamadı.",
    data,
  });
});
