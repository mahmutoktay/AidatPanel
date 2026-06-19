/**
 * Multer Cleanup Middleware
 * 
 * File upload exception'ında temp file'ları siler.
 * Disk leak risk'ini azaltır.
 * 
 * Usage:
 *   // errorHandler'dan ÖNCE mount et
 *   app.use(multerCleanup);
 *   app.use(errorHandler);
 */

import fs from 'fs';

/**
 * Cleanup error middleware — uploaded temp file'ları temizle
 */
export const multerCleanup = (err, req, res, next) => {
  if (req.files && Array.isArray(req.files)) {
    for (const file of req.files) {
      if (file?.path && fs.existsSync(file.path)) {
        fs.unlink(file.path, (unlinkErr) => {
          if (unlinkErr) {
            console.warn(`Failed to delete temp file: ${file.path}`, unlinkErr.message);
          }
        });
      }
    }
  }

  // file object varsa (single file)
  if (req.file?.path && fs.existsSync(req.file.path)) {
    fs.unlink(req.file.path, (unlinkErr) => {
      if (unlinkErr) {
        console.warn(`Failed to delete temp file: ${req.file.path}`, unlinkErr.message);
      }
    });
  }

  // Hata'yı errorHandler'a ilet
  next(err);
};
