import jwt from "jsonwebtoken";
import { prisma } from "../config/db.js";
import { logger } from "../config/logger.js";

export const authMiddleware = async (req, res, next) => {
  let token;
  if (
    req.headers.authorization &&
    req.headers.authorization.startsWith("Bearer")
  ) {
    token = req.headers.authorization.split(" ")[1];
  } else if (req.cookies?.jwt) {
    token = req.cookies.jwt;
  }

  if (!token) {
    return res.status(401).json({ success: false, message: "Token gerekli." });
  }
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // Hesap ve session geçerlilik kontrolü (DB sorgusu başarısız olursa token'a güven)
    try {
      const user = await prisma.user.findFirst({
        where: { id: decoded.id, deletedAt: null },
        select: { id: true, role: true },
      });
      if (!user) {
        return res.status(401).json({ success: false, message: "Hesap bulunamadı veya kapatılmış." });
      }

      // Session revoked kontrolü
      const sessionId = decoded.sid ?? null;
      if (sessionId) {
        const session = await prisma.userSession.findFirst({
          where: { id: sessionId, userId: decoded.id, revokedAt: null },
          select: { id: true },
        });
        if (!session) {
          return res.status(401).json({ success: false, message: "Oturum sonlandırılmış." });
        }
      }
    } catch (dbErr) {
      logger.warn({ type: "auth_middleware_db_fallback", err: dbErr?.message }, "DB query failed, falling back to JWT trust");
    }

    req.user = { id: decoded.id, role: decoded.role, sessionId: decoded.sid ?? null };
    next();
  } catch (error) {
    next(error);
  }
};
