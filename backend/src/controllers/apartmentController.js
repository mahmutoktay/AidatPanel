import {
  getApartmentsService,
  createApartmentService,
  deleteApartmentService,
  updateApartmentService,
  removeResidentFromApartmentService,
} from "../services/apartmentService.js";
import { HttpError } from "../utils/httpError.js";
import { asyncHandler } from "../utils/asyncHandler.js";

// GET /api/v1/buildings/:buildingId/apartments
export const getApartments = asyncHandler(async (req, res) => {
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
});

// POST /api/v1/buildings/:buildingId/apartments
export const createApartment = asyncHandler(async (req, res) => {
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
});

// DELETE /api/v1/buildings/:buildingId/apartments/:id/resident
export const removeResidentFromApartment = asyncHandler(async (req, res) => {
  const { buildingId, id } = req.params;
  const managerId = req.user.id;

  const apartment = await removeResidentFromApartmentService(id, buildingId, managerId);

  res.status(200).json({
    success: true,
    message: "Sakin daireden ayrıldı.",
    data: apartment,
  });
});

// DELETE /api/v1/buildings/:buildingId/apartments/:id
export const deleteApartment = asyncHandler(async (req, res) => {
  const { buildingId, id } = req.params;
  const managerId = req.user.id;

  await deleteApartmentService(id, buildingId, managerId);

  res.status(200).json({
    success: true,
    message: "Daire silindi.",
  });
});

// PUT /api/v1/buildings/:buildingId/apartments/:id
export const updateApartment = asyncHandler(async (req, res) => {
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
});
