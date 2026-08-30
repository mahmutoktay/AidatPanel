import { asyncHandler } from "../utils/asyncHandler.js";
import {
  reportTicketService,
  restrictTicketCreationService,
  liftTicketRestrictionService,
  getApartmentRestrictionService,
  getMyTicketRestrictionService,
} from "../services/ticketModerationService.js";

export const reportTicket = asyncHandler(async (req, res) => {
  const data = await reportTicketService(req.params.ticketId, req.user, {
    ticketUpdateId: req.body.ticketUpdateId,
  });
  res.status(200).json({
    success: true,
    message: "Bildiriminiz alındı.",
    data,
  });
});

export const createTicketRestriction = asyncHandler(async (req, res) => {
  const data = await restrictTicketCreationService(
    req.params.apartmentId,
    req.user.id,
    req.body
  );
  res.status(201).json({
    success: true,
    message: "Talep gönderimi kısıtlandı.",
    data,
  });
});

export const deleteTicketRestriction = asyncHandler(async (req, res) => {
  const data = await liftTicketRestrictionService(
    req.params.apartmentId,
    req.user.id
  );
  res.status(200).json({
    success: true,
    message: "Talep kısıtlaması kaldırıldı.",
    data,
  });
});

export const getApartmentTicketRestriction = asyncHandler(async (req, res) => {
  const data = await getApartmentRestrictionService(
    req.params.apartmentId,
    req.user.id
  );
  res.status(200).json({ success: true, data });
});

export const getMyTicketRestriction = asyncHandler(async (req, res) => {
  const data = await getMyTicketRestrictionService(req.user.id);
  res.status(200).json({ success: true, data });
});
