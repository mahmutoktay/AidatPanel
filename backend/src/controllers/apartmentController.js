import {
  getApartmentsService,
  createApartmentService,
  deleteApartmentService,
  updateApartmentService,
  removeResidentFromApartmentService,
} from "../services/apartmentService.js";
import { HttpError } from "../utils/httpError.js";

// GET /api/v1/buildings/:buildingId/apartments
export const getApartments = async (req, res, next) => {
  try {
    const { buildingId } = req.params;
    const managerId = req.user.id;
    const { cursor, limit, paginated, search } = req.query;

    const apartments = await getApartmentsService(buildingId, managerId, {
      cursor,
      limit,
      paginated,
      search,
    });

    res.status(200).json({
      success: true,
      data: apartments,
    });
  } catch (error) {
    next(error);
  }
};

// POST /api/v1/buildings/:buildingId/apartments
export const createApartment = async (req, res, next) => {
  try {
    const { buildingId } = req.params;
    const { number, floor } = req.body;
    const managerId = req.user.id;

    if (!number) {
      throw new HttpError(400, "Daire numarası zorunludur.");
    }

    const apartment = await createApartmentService({
      buildingId,
      number: number.trim(),
      floor: floor ? Number(floor) : null,
      managerId,
    });

    res.status(201).json({
      success: true,
      message: "Daire başarıyla oluşturuldu.",
      data: apartment,
    });
  } catch (error) {
    next(error);
  }
};

// DELETE /api/v1/buildings/:buildingId/apartments/:id/resident
export const removeResidentFromApartment = async (req, res, next) => {
  try {
    const { buildingId, id } = req.params;
    const managerId = req.user.id;

    const apartment = await removeResidentFromApartmentService(id, buildingId, managerId);

    res.status(200).json({
      success: true,
      message: "Sakin daireden ayrıldı.",
      data: apartment,
    });
  } catch (error) {
    next(error);
  }
};

// DELETE /api/v1/buildings/:buildingId/apartments/:id
export const deleteApartment = async (req, res, next) => {
  try {
    const { buildingId, id } = req.params;
    const managerId = req.user.id;

    await deleteApartmentService(id, buildingId, managerId);

    res.status(200).json({
      success: true,
      message: "Daire silindi.",
    });
  } catch (error) {
    next(error);
  }
};

// PUT /api/v1/buildings/:buildingId/apartments/:id
export const updateApartment = async (req, res, next) => {
  try {
    const { buildingId, id } = req.params;
    const { number, floor } = req.body;
    const managerId = req.user.id;

    const updateData = {};
    if (number !== undefined) updateData.number = number.trim();
    if (floor !== undefined) updateData.floor = Number(floor);

    const apartment = await updateApartmentService(id, buildingId, managerId, updateData);

    res.status(200).json({
      success: true,
      message: "Daire başarıyla güncellendi.",
      data: apartment,
    });
  } catch (error) {
    next(error);
  }
};