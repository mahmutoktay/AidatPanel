import {
  createSiteService,
  getSitesService,
  getSiteByIdService,
  updateSiteService,
  updateSiteCollectionService,
  deleteSiteService,
  createSiteBuildingService,
  getSiteBuildingsService,
} from "../services/siteService.js";
import { resolveEffectiveBuildingConfig } from "../utils/effectiveBuildingConfig.js";
import { HttpError } from "../utils/httpError.js";

export const createSite = async (req, res, next) => {
  try {
    const site = await createSiteService({
      ...req.body,
      managerId: req.user.id,
    });
    res.status(201).json({
      success: true,
      message: "Site başarıyla oluşturuldu.",
      data: site,
    });
  } catch (error) {
    next(error);
  }
};

export const getSites = async (req, res, next) => {
  try {
    const data = await getSitesService(req.user.id, req.query);
    res.json({ success: true, data });
  } catch (error) {
    next(error);
  }
};

export const getSiteById = async (req, res, next) => {
  try {
    const site = await getSiteByIdService(req.params.id, req.user.id);
    if (!site) {
      throw new HttpError(404, "Site bulunamadı.");
    }
    res.json({ success: true, data: site });
  } catch (error) {
    next(error);
  }
};

export const updateSite = async (req, res, next) => {
  try {
    const site = await updateSiteService(req.params.id, req.user.id, req.body);
    res.json({
      success: true,
      message: "Site güncellendi.",
      data: site,
    });
  } catch (error) {
    next(error);
  }
};

export const patchSiteCollection = async (req, res, next) => {
  try {
    const site = await updateSiteCollectionService(
      req.params.id,
      req.user.id,
      req.body
    );
    res.json({
      success: true,
      message: "Tahsilat bilgileri güncellendi.",
      data: site,
    });
  } catch (error) {
    next(error);
  }
};

export const deleteSite = async (req, res, next) => {
  try {
    await deleteSiteService(req.params.id, req.user.id);
    res.json({
      success: true,
      message: "Site ve bağlı binalar silindi.",
    });
  } catch (error) {
    next(error);
  }
};

export const createSiteBuilding = async (req, res, next) => {
  try {
    const building = await createSiteBuildingService(
      req.params.id,
      req.user.id,
      req.body
    );
    const data = resolveEffectiveBuildingConfig(building);
    res.status(201).json({
      success: true,
      message: "Site altında bina, daireler ve aidatlar oluşturuldu.",
      data,
    });
  } catch (error) {
    next(error);
  }
};

export const getSiteBuildings = async (req, res, next) => {
  try {
    const data = await getSiteBuildingsService(req.params.id, req.user.id);
    res.json({ success: true, data });
  } catch (error) {
    next(error);
  }
};
