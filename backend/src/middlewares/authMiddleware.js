import jwt from "jsonwebtoken";
import { prisma } from "../config/db.js";

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
    const row = await prisma.user.findUnique({
      where: { id: decoded.id },
      select: { deletedAt: true, refreshTokenVersion: true },
    });
    if (!row || row.deletedAt) {
      return res.status(401).json({
        success: false,
        message: "Oturum geçersiz veya hesap kapatılmış.",
      });
    }
    // Access token içindeki rv (refreshTokenVersion) güncel değilse oturumu reddet.
    // Bu sayede logoutAllDevices anında diğer cihazların access token'ı da çalışmaz.
    const tokenRv = decoded.rv ?? 0;
    if (row.refreshTokenVersion !== tokenRv) {
      return res.status(401).json({
        success: false,
        message: "Oturum süresi doldu. Lütfen tekrar giriş yapın.",
      });
    }
    req.user = { id: decoded.id, role: decoded.role };
    next();
  } catch (error) {
    next(error);
  }
};
