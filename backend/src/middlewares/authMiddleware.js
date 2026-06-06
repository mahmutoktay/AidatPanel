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
    
    // Veritabanına (DB) gitmiyoruz. Access token süresine (15dk) ve JWT imzasına güveniyoruz.
    // 'Tüm cihazlardan çıkış' esnasında anında düşürme işlemi artık WebSocket üzerinden sağlanıyor.
    
    req.user = { id: decoded.id, role: decoded.role };
    next();
  } catch (error) {
    next(error);
  }
};
