import { NOTIFICATION_MESSAGES } from "../constants/notificationConstants.js";
import {
  getProfileService,
  getMyPaymentCollectionService,
  updateProfileService,
  changePasswordService,
  updateLanguageService,
  updateFcmTokenService,
  softDeleteAccountService,
  uploadProfilePictureService,
  deleteProfilePictureService,
} from "../services/meService.js";
import { asyncHandler } from "../utils/asyncHandler.js";

export const getMyPaymentCollection = asyncHandler(async (req, res) => {
  const data = await getMyPaymentCollectionService(req.user.id);
  res.status(200).json({ success: true, data });
});

export const getMe = asyncHandler(async (req, res) => {
  const data = await getProfileService(req.user.id);
  res.status(200).json({ success: true, data });
});

export const updateMe = asyncHandler(async (req, res) => {
  const data = await updateProfileService(req.user.id, req.body);
  res.status(200).json({
    success: true,
    message: "Profil güncellendi.",
    data,
  });
});

export const updatePassword = asyncHandler(async (req, res) => {
  const { currentPassword, newPassword } = req.body;
  await changePasswordService(req.user.id, currentPassword, newPassword);
  res.status(200).json({
    success: true,
    message: "Şifre güncellendi. Diğer cihazlarda tekrar giriş yapmanız gerekebilir.",
  });
});

export const updateLanguage = asyncHandler(async (req, res) => {
  const data = await updateLanguageService(req.user.id, req.body.language);
  res.status(200).json({
    success: true,
    message: "Dil güncellendi.",
    data,
  });
});

export const updateFcmToken = asyncHandler(async (req, res) => {
  await updateFcmTokenService(req.user.id, req.body.fcmToken);
  res.status(200).json({ success: true, message: NOTIFICATION_MESSAGES.FCM_SAVED });
});

export const deleteMe = asyncHandler(async (req, res) => {
  await softDeleteAccountService(req.user.id);
  res.status(200).json({
    success: true,
    message: "Hesabınız kapatıldı ve kişisel veriler maskelendi.",
  });
});

export const uploadProfilePicture = asyncHandler(async (req, res) => {
  const data = await uploadProfilePictureService(req.user.id, req.file);
  res.status(200).json({
    success: true,
    message: "Profil fotoğrafı güncellendi.",
    data,
  });
});

export const deleteProfilePicture = asyncHandler(async (req, res) => {
  const data = await deleteProfilePictureService(req.user.id);
  res.status(200).json({
    success: true,
    message: "Profil fotoğrafı silindi.",
    data,
  });
});
