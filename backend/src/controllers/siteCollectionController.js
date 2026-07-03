import { asyncHandler } from "../utils/asyncHandler.js";
import { updateSiteCollectionService } from "../services/siteService.js";

export const patchSiteCollection = asyncHandler(async (req, res) => {
  const site = await updateSiteCollectionService(req.params.id, req.user.id, req.body);
  res.json({
    success: true,
    message: "Site tahsilat bilgileri güncellendi.",
    data: site,
  });
});
