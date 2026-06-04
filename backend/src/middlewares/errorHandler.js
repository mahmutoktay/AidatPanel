/**
 * Global Error Handler Middleware
 * Tüm hataları merkezi olarak yönetir
 */

import { HttpError } from "../utils/httpError.js";

function isDekontRoute(req) {
  const url = req?.originalUrl || req?.url || "";
  return url.includes("/dekonts");
}

function logUnhandledError(err, req) {
  const route = `${req?.method ?? "?"} ${req?.originalUrl ?? req?.url ?? "?"}`;
  console.error("[api] unhandled error", {
    route,
    name: err?.name,
    message: err?.message,
    code: err?.code,
    stack: err?.stack,
  });
}

export const errorHandler = (err, req, res, next) => {
  // Console.error kaldırıldı - Node.js crash'i önlendi

  // Zod validation hatası
  if (err.name === "ZodError") {
    return res.status(400).json({
      success: false,
      message: "Validasyon hatası",
      errors: (err.issues && Array.isArray(err.issues)) 
        ? err.issues.map((e) => ({
            field: e.path?.join(".") || "unknown",
            message: e.message || "Validation error",
          }))
        : [],
    });
  }

  // Prisma hataları
  if (err.code) {
    // Prisma unique constraint hatası
    if (err.code === "P2002") {
      return res.status(400).json({
        success: false,
        message: "Bu kayıt zaten mevcut",
        error: `Unique constraint failed on: ${err.meta?.target}`,
      });
    }

    // Prisma foreign key hatası
    if (err.code === "P2003") {
      return res.status(400).json({
        success: false,
        message: "İlişkili kayıt bulunamadı",
        error: "Foreign key constraint failed",
      });
    }

    // Prisma kayıt bulunamadı
    if (err.code === "P2025") {
      return res.status(404).json({
        success: false,
        message: "Kayıt bulunamadı",
        error: err.meta?.cause || "Record not found",
      });
    }
  }

  // JWT hataları
  if (err.name === "JsonWebTokenError") {
    return res.status(401).json({
      success: false,
      message: "Geçersiz token",
      error: err.message,
    });
  }

  if (err.name === "TokenExpiredError") {
    return res.status(401).json({
      success: false,
      message: "Token süresi dolmuş",
      error: err.message,
    });
  }

  // HttpError (access.js, service katmanı)
  if (err instanceof HttpError || (err instanceof Error && err.name === "HttpError" && err.statusCode)) {
    const body = {
      success: false,
      message: err.message,
    };
    if (err.data != null) {
      body.data = err.data;
    }
    return res.status(err.statusCode).json(body);
  }

  // Multer (dosya yükleme)
  if (err.name === "MulterError") {
    if (err.code === "LIMIT_FILE_SIZE") {
      return res.status(413).json({
        success: false,
        message: "Dosya boyutu limiti aşıldı.",
      });
    }
    return res.status(400).json({
      success: false,
      message: err.message || "Dosya yükleme hatası",
    });
  }

  if (err.message?.includes("Desteklenmeyen dosya türü")) {
    return res.status(400).json({
      success: false,
      message: err.message,
    });
  }

  // Rate limit hatası
  if (err.status === 429) {
    return res.status(429).json({
      success: false,
      message: "Çok fazla istek gönderdiniz",
      error: "Rate limit exceeded",
    });
  }

  // Varsayılan hata (500)
  const statusCode = err.statusCode || err.status || 500;
  const message = err.message || "Sunucu hatası";
  const dekontRoute = isDekontRoute(req);

  if (dekontRoute) {
    logUnhandledError(err, req);
  }

  const clientMessage =
    process.env.NODE_ENV === "production"
      ? dekontRoute
        ? statusCode >= 500
          ? "Dekont yüklenemedi. Lütfen tekrar deneyin."
          : "Bir hata oluştu"
        : "Bir hata oluştu"
      : message;

  res.status(statusCode).json({
    success: false,
    message: clientMessage,
    ...(dekontRoute && process.env.NODE_ENV === "production" && {
      errorCode: statusCode >= 500 ? "DEKONT_UPLOAD_FAILED" : "DEKONT_REQUEST_FAILED",
    }),
    ...(process.env.NODE_ENV !== "production" && { stack: err.stack }),
  });
};

/**
 * 404 Not Found Handler
 * Tanımlanmamış route'lar için
 */
export const notFoundHandler = (req, res) => {
  res.status(404).json({
    success: false,
    message: `Route bulunamadı: ${req.method} ${req.originalUrl}`,
  });
};
