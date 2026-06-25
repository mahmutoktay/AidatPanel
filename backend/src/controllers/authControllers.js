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
import { asyncHandler } from "../utils/asyncHandler.js";

export const register = asyncHandler(async (req, res) => {
  const data = await registerService(req.body);
  res.status(201).json({
    success: true,
    message: "Hesabınız başarıyla oluşturuldu.",
    data,
  });
});

export const login = asyncHandler(async (req, res) => {
  const data = await loginService(req.body);
  res.status(200).json({
    success: true,
    message: "Giriş başarılı.",
    data,
  });
});

export const refreshToken = asyncHandler(async (req, res) => {
  const data = await refreshAccessTokenService(
    req.body.refreshToken,
    req.body
  );
  res.status(200).json({ success: true, data });
});

export const join = asyncHandler(async (req, res) => {
  const data = await joinWithInviteCodeService(req.body);
  res.status(201).json({
    success: true,
    message: "Apartmana başarıyla katıldınız.",
    data,
  });
});

export const logout = asyncHandler(async (req, res) => {
  await logoutService(req.user.id, req.user.sessionId);
  res.status(200).json({
    success: true,
    message: "Çıkış başarılı.",
  });
});

export const logoutAllDevices = asyncHandler(async (req, res) => {
  const data = await logoutAllDevicesService(req.user.id, req.user.sessionId);
  res.status(200).json({
    success: true,
    message: "Diğer cihazlardaki oturumlar sonlandırıldı.",
    data,
  });
});

export const forgotPassword = asyncHandler(async (req, res) => {
  await requestPasswordResetService(req.body.email);
  res.status(200).json({
    success: true,
    message:
      "E-posta adresi sistemde kayıtlıysa şifre sıfırlama talimatları gönderildi.",
  });
});

export const resetPassword = asyncHandler(async (req, res) => {
  const { token, password } = req.body;
  await resetPasswordWithTokenService(token, password);
  res.status(200).json({
    success: true,
    message: "Şifreniz güncellendi. Yeni şifreyle giriş yapabilirsiniz.",
  });
});
