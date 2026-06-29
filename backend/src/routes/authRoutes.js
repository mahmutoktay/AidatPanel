import express from "express";
import {
  register,
  login,
  refreshToken,
  join,
  logout,
  logoutAllDevices,
  forgotPassword,
  resetPassword,
  sendOtp,
  verifyOtp,
  validateInvite,
} from "../controllers/authControllers.js";
import {
  authLimiter,
  otpLimiter,
  strictLimiter,
} from "../middlewares/rateLimitMiddleware.js";
import { validate, authSchemas } from "../middlewares/validate.js";
import { authMiddleware } from "../middlewares/authMiddleware.js";

const router = express.Router();

// Rate limiting - Brute force koruması (başarısız girişleri sayar)
router.use(authLimiter);

// Auth endpoint'leri
router.post("/register", validate(authSchemas.register), register);
router.post("/login", validate(authSchemas.login), login);
router.post("/refresh", validate(authSchemas.refreshToken), refreshToken);
router.post("/join", validate(authSchemas.join), join);
router.post("/otp/send", otpLimiter, validate(authSchemas.otpSend), sendOtp);
router.post("/otp/verify", otpLimiter, validate(authSchemas.otpVerify), verifyOtp);
router.post("/invite/validate", strictLimiter, validate(authSchemas.inviteValidate), validateInvite);
router.post("/forgot-password", strictLimiter, validate(authSchemas.forgotPassword), forgotPassword);
router.post("/reset-password", strictLimiter, validate(authSchemas.resetPassword), resetPassword);
router.post("/logout", authMiddleware, logout);
router.post("/logout-all-devices", authMiddleware, logoutAllDevices);

export default router;
