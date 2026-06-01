import jwt from "jsonwebtoken";
import { prisma } from "../config/db.js";

/**
 * Access JWT → aktif kullanıcı id (WebSocket upgrade, vb.).
 * @param {string | null | undefined} token
 * @returns {Promise<string | null>}
 */
export async function verifyAccessTokenToUserId(token) {
  if (!token || typeof token !== "string" || token.length < 10) {
    return null;
  }
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const id = decoded?.id;
    if (!id) return null;

    const row = await prisma.user.findUnique({
      where: { id },
      select: { deletedAt: true },
    });
    if (!row || row.deletedAt) return null;
    return id;
  } catch {
    return null;
  }
}
