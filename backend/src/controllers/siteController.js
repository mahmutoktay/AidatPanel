import { asyncHandler } from "../utils/asyncHandler.js";
import {
  createSiteService,
  getSitesService,
  getSiteByIdService,
  updateSiteService,
  deleteSiteService,
  createSiteBuildingService,
  getSiteBuildingsService,
} from "../services/siteService.js";
import { getSiteAggregationService } from "../services/siteAggregationService.js";

export const createSite = asyncHandler(async (req, res) => {
  const site = await createSiteService(req.body, req.user.id);
  res.status(201).json({
    success: true,
    message: "Site başarıyla oluşturuldu.",
    data: site,
  });
});

export const getSites = asyncHandler(async (req, res) => {
  const data = await getSitesService(req.user.id, req.query);
  res.json({ success: true, data });
});

export const getSiteById = asyncHandler(async (req, res) => {
  const site = await getSiteByIdService(req.params.id, req.user.id);
  res.json({ success: true, data: site });
});

export const updateSite = asyncHandler(async (req, res) => {
  const site = await updateSiteService(req.params.id, req.user.id, req.body);
  res.json({ success: true, data: site });
});

export const deleteSite = asyncHandler(async (req, res) => {
  await deleteSiteService(req.params.id, req.user.id);
  res.json({ success: true, message: "Site ve alt binalar silindi." });
});

export const createSiteBuilding = asyncHandler(async (req, res) => {
  const building = await createSiteBuildingService(
    req.params.id,
    req.user.id,
    req.body
  );
  res.status(201).json({
    success: true,
    message: "Blok başarıyla eklendi.",
    data: building,
  });
});

export const getSiteBuildings = asyncHandler(async (req, res) => {
  const buildings = await getSiteBuildingsService(req.params.id, req.user.id);
  res.json({ success: true, data: buildings });
});

export const getSiteAggregation = asyncHandler(async (req, res) => {
  const now = new Date();
  const month = req.query.month ?? now.getMonth() + 1;
  const year = req.query.year ?? now.getFullYear();
  const data = await getSiteAggregationService(req.params.id, req.user.id, {
    month,
    year,
  });
  res.json({ success: true, data });
});
