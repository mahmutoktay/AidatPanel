import {
  getApartmentsService,
  createApartmentService,
  deleteApartmentService,
  updateApartmentService,
  removeResidentFromApartmentService,
} from "../services/apartmentService.js";
import { HttpError } from "../utils/httpError.js";
<<<<<<< HEAD

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
=======
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
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6

// POST /api/v1/buildings/:buildingId/apartments
export const createApartment = asyncHandler(async (req, res) => {
  const { buildingId } = req.params;
  const { number, floor } = req.body;
  const managerId = req.user.id;

<<<<<<< HEAD
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
=======
  if (!number) {
    throw new HttpError(400, "Daire numarası zorunludur.");
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
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

<<<<<<< HEAD
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
=======
  const apartment = await removeResidentFromApartmentService(id, buildingId, managerId);

  res.status(200).json({
    success: true,
    message: "Sakin daireden ayrıldı.",
    data: apartment,
  });
});
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6

// DELETE /api/v1/buildings/:buildingId/apartments/:id
export const deleteApartment = asyncHandler(async (req, res) => {
  const { buildingId, id } = req.params;
  const managerId = req.user.id;

<<<<<<< HEAD
    await deleteApartmentService(id, buildingId, managerId);

    res.status(200).json({
      success: true,
      message: "Daire silindi.",
    });
  } catch (error) {
    next(error);
  }
};
=======
  await deleteApartmentService(id, buildingId, managerId);

  res.status(200).json({
    success: true,
    message: "Daire silindi.",
  });
});
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6

// PUT /api/v1/buildings/:buildingId/apartments/:id
export const updateApartment = asyncHandler(async (req, res) => {
  const { buildingId, id } = req.params;
  const { number, floor } = req.body;
  const managerId = req.user.id;

  const updateData = {};
  if (number !== undefined) updateData.number = number.trim();
  if (floor !== undefined) updateData.floor = Number(floor);

  const apartment = await updateApartmentService(id, buildingId, managerId, updateData);

<<<<<<< HEAD
    res.status(200).json({
      success: true,
      message: "Daire başarıyla güncellendi.",
      data: apartment,
    });
  } catch (error) {
    next(error);
  }
};
=======
  res.status(200).json({
    success: true,
    message: "Daire başarıyla güncellendi.",
    data: apartment,
  });
});
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
