import {
  createBuildingService,
  getBuildingsService,
  getBuildingByIdService,
  updateBuildingService,
  deleteBuildingService,
  getCollectionPresetsService,
} from "../services/buildingService.js";
import { asyncHandler } from "../utils/asyncHandler.js";

// CREATE
export const createBuilding = asyncHandler(async (req, res) => {
  const {
    name,
    address,
    city,
    totalFloors,
    apartmentsPerFloor,
    dueAmount,
    dueDay,
    currency,
    collectionIban,
    collectionAccountTitle,
    paymentReferenceTemplate,
  } = req.body;

  const managerId = req.user.id;

  const building = await createBuildingService({
    name,
    address,
    city,
    totalFloors,
    apartmentsPerFloor,
    dueAmount,
    dueDay,
    currency,
    managerId,
    collectionIban,
    collectionAccountTitle,
    paymentReferenceTemplate,
  });

  res.status(201).json({
    success: true,
    message: "Bina, daireler ve aidatlar başarıyla oluşturuldu.",
    data: building,
  });
});

export const getCollectionPresets = asyncHandler(async (req, res) => {
  const data = await getCollectionPresetsService(req.user.id);
  res.json({ success: true, data });
});

// GET ALL
<<<<<<< HEAD
export const getBuildings = async (req, res, next) => {
  try {
    const managerId = req.user.id;
    const { cursor, limit, paginated, search, standalone } = req.query;

    const buildings = await getBuildingsService(managerId, {
      cursor,
      limit,
      paginated,
      search,
      standalone,
    });
=======
export const getBuildings = asyncHandler(async (req, res) => {
  const managerId = req.user.id;
  const { cursor, limit, paginated, search, standalone } = req.query;

  const buildings = await getBuildingsService(managerId, {
    cursor,
    limit,
    paginated,
    search,
    standalone,
  });
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6

  res.json({
    success: true,
    data: buildings,
  });
});

// GET BY ID
export const getBuildingById = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const managerId = req.user.id;

  const building = await getBuildingByIdService(id, managerId);

<<<<<<< HEAD
    // getBuildingByIdService returns null if not found or not owned
    if (!building) {
      return res.status(404).json({
        success: false,
        message: "Bina bulunamadı",
      });
    }

    res.json({
      success: true,
      data: building,
=======
  if (!building) {
    return res.status(404).json({
      success: false,
      message: "Bina bulunamadı",
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    });
  }

  res.json({
    success: true,
    data: building,
  });
});

// UPDATE
export const updateBuilding = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const managerId = req.user.id;

  const updated = await updateBuildingService(id, managerId, req.body);

<<<<<<< HEAD
    res.json({
      success: true,
      data: updated,
    });
  } catch (error) {
    next(error);
  }
};
=======
  res.json({
    success: true,
    data: updated,
  });
});
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6

// DELETE
export const deleteBuilding = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const managerId = req.user.id;

<<<<<<< HEAD
    await deleteBuildingService(id, managerId);

    res.json({
      success: true,
      message: "Bina silindi",
    });
  } catch (error) {
    next(error);
  }
};
=======
  await deleteBuildingService(id, managerId);

  res.json({
    success: true,
    message: "Bina silindi",
  });
});
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
