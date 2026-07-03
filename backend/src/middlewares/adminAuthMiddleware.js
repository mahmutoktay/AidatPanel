import jwt from "jsonwebtoken";
import { prisma } from "../config/db.js";
import { HttpError } from "../utils/httpError.js";

function extractAdminToken(req) {
  if (req.headers.authorization?.startsWith("Bearer ")) {
    return req.headers.authorization.split(" ")[1];
  }
  if (req.cookies?.admin_token) {
    return req.cookies.admin_token;
  }
  return null;
}

export const adminAuthMiddleware = async (req, res, next) => {
  const token = extractAdminToken(req);
  if (!token) {
    return res.status(401).json({ success: false, message: "Admin oturumu gerekli." });
  }

  try {
    const secret = process.env.ADMIN_JWT_SECRET || process.env.JWT_SECRET;
    const decoded = jwt.verify(token, secret);
    if (decoded.type !== "admin") {
      return res.status(401).json({ success: false, message: "Geçersiz admin oturumu." });
    }

    const admin = await prisma.adminUser.findFirst({
      where: { id: decoded.id, isActive: true },
      select: { id: true, email: true, name: true, role: true },
    });
    if (!admin) {
      return res.status(401).json({ success: false, message: "Admin hesabı bulunamadı." });
    }

    req.admin = admin;
    next();
  } catch {
    return res.status(401).json({ success: false, message: "Admin oturumu geçersiz veya süresi doldu." });
  }
};

export const requireSuperAdmin = (req, res, next) => {
  if (req.admin?.role !== "SUPER_ADMIN") {
    return res.status(403).json({ success: false, message: "Bu işlem SUPER_ADMIN yetkisi gerektirir." });
  }
  next();
};
