import {
  listActiveSessions,
  revokeSession,
} from "../services/sessionService.js";
import { HttpError } from "../utils/httpError.js";
import { asyncHandler } from "../utils/asyncHandler.js";

export const getMySessions = asyncHandler(async (req, res) => {
  const data = await listActiveSessions(req.user.id, req.user.sessionId);
  res.status(200).json({ success: true, data });
});

export const revokeMySession = asyncHandler(async (req, res) => {
  const { sessionId } = req.params;
  if (sessionId === req.user.sessionId) {
    throw new HttpError(400, "Bu cihazdaki oturumu buradan kapatamazsınız.");
  }
  await revokeSession(req.user.id, sessionId);
  res.status(200).json({
    success: true,
    message: "Oturum sonlandırıldı.",
  });
});
