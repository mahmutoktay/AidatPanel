import fs from "fs/promises";
import path from "path";
import sharp from "sharp";
import { prisma } from "../../config/db.js";
import { HttpError } from "../../utils/httpError.js";
import { toPublicUser, userPublicSelect } from "./userPublic.js";

const AVATAR_DIR = "uploads/avatars";

/**
 * Uploads/updates a user's profile picture.
 * @param {string} userId
 * @param {Object} file - Multer file object (in memory)
 * @returns {Promise<Object>} Updated public user object
 */
export async function uploadProfilePictureService(userId, file) {
  if (!file) {
    throw new HttpError(400, "Lütfen bir dosya yükleyin.");
  }

  // Validate mime type
  const allowedMimeTypes = ["image/jpeg", "image/png", "image/gif"];
  if (!allowedMimeTypes.includes(file.mimetype)) {
    throw new HttpError(400, "Desteklenmeyen dosya türü. Sadece JPG, PNG veya GIF yükleyebilirsiniz.");
  }

  // Validate size (5MB limit)
  const maxSizeBytes = 5 * 1024 * 1024;
  if (file.size > maxSizeBytes) {
    throw new HttpError(400, "Dosya boyutu çok büyük. Maksimum 5MB yükleyebilirsiniz.");
  }

  // Ensure directory exists
  await fs.mkdir(AVATAR_DIR, { recursive: true });

  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: { id: true, profilePicture: true },
  });

  if (!user) {
    throw new HttpError(404, "Kullanıcı bulunamadı.");
  }

  // Delete old avatar if it exists
  if (user.profilePicture) {
    const oldPath = path.join(AVATAR_DIR, user.profilePicture);
    await fs.unlink(oldPath).catch(() => {
      // Ignore error if file doesn't exist on disk
    });
  }

  // Define unique filename
  const extension = file.mimetype === "image/gif" ? "gif" : "jpg";
  const filename = `avatar-${userId}-${Date.now()}.${extension}`;
  const destPath = path.join(AVATAR_DIR, filename);

  // Process and save the file
  if (file.mimetype === "image/gif") {
    // Keep GIF as-is to preserve animation
    await fs.writeFile(destPath, file.buffer);
  } else {
    // Resize and optimize JPG/PNG to 512x512 JPEG
    await sharp(file.buffer)
      .resize(512, 512, {
        fit: "cover",
        withoutEnlargement: true,
      })
      .jpeg({ quality: 85 })
      .toFile(destPath);
  }

  // Update DB
  const updatedUser = await prisma.user.update({
    where: { id: userId },
    data: { profilePicture: filename },
    select: userPublicSelect,
  });

  return toPublicUser(updatedUser);
}

/**
 * Deletes a user's profile picture.
 * @param {string} userId
 * @returns {Promise<Object>} Updated public user object
 */
export async function deleteProfilePictureService(userId) {
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: { id: true, profilePicture: true },
  });

  if (!user) {
    throw new HttpError(404, "Kullanıcı bulunamadı.");
  }

  if (user.profilePicture) {
    const filePath = path.join(AVATAR_DIR, user.profilePicture);
    await fs.unlink(filePath).catch(() => {
      // Ignore error if file doesn't exist on disk
    });
  }

  // Update DB
  const updatedUser = await prisma.user.update({
    where: { id: userId },
    data: { profilePicture: null },
    select: userPublicSelect,
  });

  return toPublicUser(updatedUser);
}

/**
 * Auth korumalı profil fotoğrafı dosyasını döndürür (public static mount alternatifi).
 * @param {string} userId
 * @returns {Promise<{absolutePath: string, mimeType: string}|null>}
 */
export async function getProfilePictureFileService(userId) {
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: { id: true, profilePicture: true },
  });

  if (!user || !user.profilePicture) {
    return null;
  }

  const ext = path.extname(user.profilePicture).toLowerCase();
  const mimeType =
    ext === ".gif" ? "image/gif" :
    ext === ".png" ? "image/png" :
    "image/jpeg";

  const absolutePath = path.resolve(AVATAR_DIR, user.profilePicture);

  // Dosyanın diskte var olduğunu kontrol et
  try {
    await fs.access(absolutePath);
  } catch {
    return null;
  }

  return { absolutePath, mimeType };
}
