/**
 * Async Route Handler Wrapper
 *
 * Express 5, async route handler'lardan fırlayan Promise rejection'ları
 * otomatik olarak next(error)'a yönlendirir. Ancak bu wrapper:
 *
 * 1. Express 5 öncesi (Express 4) ile uyumluluğu garanti eder
 * 2. Tüm controller'larda try-catch boilerplate'ini ortadan kaldırır
 * 3. Hataların merkezi errorHandler'a (src/middlewares/errorHandler.js) ulaşmasını sağlar
 *
 * Kullanım:
 *   import { asyncHandler } from "../utils/asyncHandler.js";
 *   export const getMe = asyncHandler(async (req, res) => {
 *     const data = await getProfileService(req.user.id);
 *     res.json({ success: true, data });
 *   });
 *
 * NOT: HttpError, ZodError, Prisma hataları errorHandler'da yakalanır.
 *       Controller'da ayrıca handleHttp() çağırmaya gerek yoktur.
 */

/**
 * @template {(...args: any[]) => Promise<any>} T
 * @param {T} fn - Async route handler
 * @returns {T}
 */
export const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};
