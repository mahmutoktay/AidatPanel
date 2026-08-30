import { Router } from "express";
import { authMiddleware } from "../middlewares/authMiddleware.js";
import { requireRoles } from "../middlewares/roleMiddleware.js";
import { validate, moderationSchemas } from "../middlewares/validate.js";
import {
  createTicketRestriction,
  deleteTicketRestriction,
  getApartmentTicketRestriction,
} from "../controllers/ticketModerationController.js";

const router = Router({ mergeParams: true });

router.use(authMiddleware);
router.use(requireRoles("MANAGER"));

router.get(
  "/",
  validate(moderationSchemas.getApartmentRestriction),
  getApartmentTicketRestriction
);

router.post(
  "/",
  validate(moderationSchemas.createRestriction),
  createTicketRestriction
);

router.delete(
  "/",
  validate(moderationSchemas.getApartmentRestriction),
  deleteTicketRestriction
);

export default router;
