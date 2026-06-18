import {
  listActiveSessions,
  revokeSession,
} from "../services/sessionService.js";
import { HttpError } from "../utils/httpError.js";

const handleHttp = (err, res, next) => {
  if (err instanceof HttpError) {
    return res.status(err.statusCode).json({
      success: false,
      message: err.message,
    });
  }
  next(err);
};

export const getMySessions = async (req, res, next) => {
  try {
    const data = await listActiveSessions(req.user.id, req.user.sessionId);
    res.status(200).json({ success: true, data });
  } catch (err) {
    handleHttp(err, res, next);
  }
};

export const revokeMySession = async (req, res, next) => {
  try {
    const { sessionId } = req.params;
    if (sessionId === req.user.sessionId) {
      throw new HttpError(400, "Bu cihazdaki oturumu buradan kapatamazsınız.");
    }
    await revokeSession(req.user.id, sessionId);
    res.status(200).json({
      success: true,
      message: "Oturum sonlandırıldı.",
    });
  } catch (err) {
    handleHttp(err, res, next);
  }
};
