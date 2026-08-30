import {
  registerService,
  loginService,
  refreshAccessTokenService,
  joinWithInviteCodeService,
  logoutService,
  logoutAllDevicesService,
  checkIdentifierService,
  rejoinWithInviteCodeService,
} from "../services/authService.js";
import {
  sendOtpService,
  verifyOtpService,
  verifyFirebasePhoneService,
  validateInvitePublicService,
  completeResidentJoinService,
} from "../services/otpService.js";
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

export const checkIdentifier = asyncHandler(async (req, res) => {
  const data = await checkIdentifierService(req.body);
  res.status(200).json({
    success: true,
    message: "İletişim bilgisi uygun.",
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
  const data = await requestPasswordResetService({
    email: req.body.email,
    phone: req.body.phone,
    channel: req.body.channel,
  });
  res.status(200).json({
    success: true,
    message:
      "Kayıtlıysanız şifre sıfırlama kodu gönderildi. Lütfen gelen kutunuzu veya SMS'lerinizi kontrol edin.",
    data: {
      deliveredVia: data?.deliveredVia ?? null,
      smsFallbackAvailable: Boolean(data?.smsFallbackAvailable),
    },
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

export const sendOtp = asyncHandler(async (req, res) => {
  await sendOtpService(req.body);
  res.status(200).json({
    success: true,
    message: "Doğrulama kodu gönderildi.",
    data: { sent: true },
  });
});

export const verifyOtp = asyncHandler(async (req, res) => {
  const data = await verifyOtpService(req.body);
  const message =
    data?.requireName === true
      ? "Telefon numaranız doğrulandı."
      : purposeSuccessMessage(req.body.purpose);
  res.status(200).json({
    success: true,
    message,
    data,
  });
});

export const verifyFirebasePhone = asyncHandler(async (req, res) => {
  const data = await verifyFirebasePhoneService(req.body);
  let message = "Giriş başarılı.";
  if (data?.requireName === true) {
    message = "Telefon numaranız doğrulandı.";
  } else if (data?.verified === true) {
    message = "Telefon numaranız doğrulandı.";
  } else if (req.body.purpose === "resident_join") {
    message = "Hesabınız oluşturuldu.";
  }
  res.status(200).json({
    success: true,
    message,
    data,
  });
});

export const completeResidentJoin = asyncHandler(async (req, res) => {
  const data = await completeResidentJoinService(req.body);
  res.status(200).json({
    success: true,
    message: "Hesabınız oluşturuldu.",
    data,
  });
});

function purposeSuccessMessage(purpose) {
  if (purpose === "resident_join" || purpose === "manager_register") {
    return "Hesabınız oluşturuldu.";
  }
  return "Giriş başarılı.";
}

export const validateInvite = asyncHandler(async (req, res) => {
  const data = await validateInvitePublicService(req.body.inviteCode);
  res.status(200).json({
    success: true,
    message: "Davet kodu geçerli.",
    data,
  });
});

export const rejoinWithInvite = asyncHandler(async (req, res) => {
  const data = await rejoinWithInviteCodeService(req.user.id, req.body.inviteCode);
  res.status(200).json({
    success: true,
    message: "Binaya başarıyla katıldınız.",
    data,
  });
});
