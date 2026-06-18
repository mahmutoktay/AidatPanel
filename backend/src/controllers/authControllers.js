import {
  registerService,
  loginService,
  refreshAccessTokenService,
  joinWithInviteCodeService,
  logoutService,
  logoutAllDevicesService,
} from "../services/authService.js";
import {
  requestPasswordResetService,
  resetPasswordWithTokenService,
} from "../services/passwordResetService.js";
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

export const register = async (req, res, next) => {
  try {
    const data = await registerService(req.body);
    res.status(201).json({
      success: true,
      message: "Hesabınız başarıyla oluşturuldu.",
      data,
    });
  } catch (err) {
    handleHttp(err, res, next);
  }
};

export const login = async (req, res, next) => {
  try {
    const data = await loginService(req.body);
    res.status(200).json({
      success: true,
      message: "Giriş başarılı.",
      data,
    });
  } catch (err) {
    handleHttp(err, res, next);
  }
};

export const refreshToken = async (req, res, next) => {
  try {
    const data = await refreshAccessTokenService(
      req.body.refreshToken,
      req.body
    );
    res.status(200).json({ success: true, data });
  } catch (err) {
    handleHttp(err, res, next);
  }
};

export const join = async (req, res, next) => {
  try {
    const data = await joinWithInviteCodeService(req.body);
    res.status(201).json({
      success: true,
      message: "Apartmana başarıyla katıldınız.",
      data,
    });
  } catch (err) {
    handleHttp(err, res, next);
  }
};

export const logout = async (req, res, next) => {
  try {
    await logoutService(req.user.id, req.user.sessionId);
    res.status(200).json({
      success: true,
      message: "Çıkış başarılı.",
    });
  } catch (err) {
    next(err);
  }
};

export const logoutAllDevices = async (req, res, next) => {
  try {
    const data = await logoutAllDevicesService(req.user.id, req.user.sessionId);
    res.status(200).json({
      success: true,
      message: "Diğer cihazlardaki oturumlar sonlandırıldı.",
      data,
    });
  } catch (err) {
    next(err);
  }
};

export const forgotPassword = async (req, res, next) => {
  try {
    await requestPasswordResetService(req.body.email);
    res.status(200).json({
      success: true,
      message:
        "E-posta adresi sistemde kayıtlıysa şifre sıfırlama talimatları gönderildi.",
    });
  } catch (err) {
    next(err);
  }
};

export const resetPassword = async (req, res, next) => {
  try {
    const { token, password } = req.body;
    await resetPasswordWithTokenService(token, password);
    res.status(200).json({
      success: true,
      message: "Şifreniz güncellendi. Yeni şifreyle giriş yapabilirsiniz.",
    });
  } catch (err) {
    handleHttp(err, res, next);
  }
};
