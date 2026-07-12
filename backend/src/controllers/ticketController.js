import {
  listTicketsByBuildingService,
  listMyTicketsService,
  getTicketByIdService,
  createTicketService,
  addTicketUpdateService,
  changeTicketStatusService,
  uploadTicketAttachmentService,
} from "../services/ticketService.js";
import { asyncHandler } from "../utils/asyncHandler.js";

export const getTicketsByBuilding = asyncHandler(async (req, res) => {
  const { id: buildingId } = req.params;
  const { status, category, cursor, limit, paginated } = req.query;
  const data = await listTicketsByBuildingService(buildingId, req.user.id, {
    status,
    category,
    cursor,
    limit,
    paginated,
  });
  res.status(200).json({ success: true, data });
});

export const getMyTickets = asyncHandler(async (req, res) => {
  const { status, category, cursor, limit, paginated } = req.query;
  const data = await listMyTicketsService(req.user.id, {
    status,
    category,
    cursor,
    limit,
    paginated,
  });
  res.status(200).json({ success: true, data });
});

export const getTicketById = asyncHandler(async (req, res) => {
  const data = await getTicketByIdService(req.params.ticketId, req.user);
  res.status(200).json({ success: true, data });
});

export const createTicket = asyncHandler(async (req, res) => {
  const { apartmentId } = req.params;
  const data = await createTicketService(apartmentId, req.user.id, req.body);
  res.status(201).json({
    success: true,
    message: "Talep oluşturuldu.",
    data,
  });
});

export const uploadTicketAttachment = asyncHandler(async (req, res) => {
  const data = await uploadTicketAttachmentService(
    req.params.ticketId,
    req.user.id,
    req.file
  );
  res.status(200).json({
    success: true,
    message: "Görsel eklendi.",
    data,
  });
});

export const addTicketUpdate = asyncHandler(async (req, res) => {
  const ticket = await addTicketUpdateService(
    req.params.ticketId,
    req.user.id,
    req.body.message
  );
  res.status(201).json({
    success: true,
    message: "Güncelleme eklendi.",
    data: ticket,
  });
});

export const patchTicketStatus = asyncHandler(async (req, res) => {
  const data = await changeTicketStatusService(
    req.params.ticketId,
    req.user.id,
    req.body.status
  );
  res.status(200).json({
    success: true,
    message: "Talep durumu güncellendi.",
    data,
  });
});
