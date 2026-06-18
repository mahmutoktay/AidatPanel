import { prisma } from "../config/db.js";
import { HttpError } from "../utils/httpError.js";
import { publishToUser } from "../realtime/realtimeHub.js";

const DEFAULT_DEVICE_LABEL = "Bilinmeyen cihaz";
const DEFAULT_PLATFORM = "unknown";

function normalizeDeviceLabel(deviceLabel) {
  const trimmed = deviceLabel?.trim()?.slice(0, 120);
  return trimmed && trimmed.length > 0 ? trimmed : DEFAULT_DEVICE_LABEL;
}

function normalizePlatform(platform) {
  const trimmed = platform?.trim()?.slice(0, 20)?.toLowerCase();
  return trimmed && trimmed.length > 0 ? trimmed : DEFAULT_PLATFORM;
}

/**
 * @param {string} userId
 * @param {{ deviceLabel?: string, platform?: string }} [meta]
 */
export async function createSession(userId, { deviceLabel, platform } = {}) {
  return prisma.userSession.create({
    data: {
      userId,
      deviceLabel: normalizeDeviceLabel(deviceLabel),
      platform: normalizePlatform(platform),
    },
  });
}

/** @param {string | null | undefined} sessionId */
export async function touchSession(sessionId) {
  if (!sessionId) return;
  await prisma.userSession.updateMany({
    where: { id: sessionId, revokedAt: null },
    data: { lastSeenAt: new Date() },
  });
}

/** @param {string | null | undefined} sessionId */
export async function assertSessionActive(sessionId) {
  if (!sessionId) return;
  const session = await prisma.userSession.findFirst({
    where: { id: sessionId, revokedAt: null },
    select: { id: true },
  });
  if (!session) {
    throw new HttpError(401, "Oturum sonlandırıldı. Lütfen tekrar giriş yapın.");
  }
}

/**
 * @param {string} userId
 * @param {string | null | undefined} currentSessionId
 */
export async function listActiveSessions(userId, currentSessionId) {
  const sessions = await prisma.userSession.findMany({
    where: { userId, revokedAt: null },
    orderBy: { lastSeenAt: "desc" },
  });

  return sessions.map((session) => ({
    id: session.id,
    deviceLabel: session.deviceLabel,
    platform: session.platform,
    createdAt: session.createdAt,
    lastSeenAt: session.lastSeenAt,
    isCurrent: session.id === currentSessionId,
  }));
}

/** @param {string} userId @param {string} sessionId */
export function publishForceLogout(userId, sessionId) {
  publishToUser(userId, { event: "force_logout", sessionId });
}

/**
 * @param {string} userId
 * @param {string} sessionId
 */
export async function revokeSession(userId, sessionId) {
  const session = await prisma.userSession.findFirst({
    where: { id: sessionId, userId, revokedAt: null },
    select: { id: true },
  });
  if (!session) {
    throw new HttpError(404, "Oturum bulunamadı.");
  }

  await prisma.userSession.update({
    where: { id: sessionId },
    data: { revokedAt: new Date() },
  });
  publishForceLogout(userId, sessionId);
}

/**
 * @param {string} userId
 * @param {string | null | undefined} keepSessionId
 * @returns {Promise<string[]>} revoked session ids
 */
export async function revokeOtherSessions(userId, keepSessionId) {
  const where = {
    userId,
    revokedAt: null,
    ...(keepSessionId ? { id: { not: keepSessionId } } : {}),
  };

  const sessions = await prisma.userSession.findMany({
    where,
    select: { id: true },
  });
  if (sessions.length === 0) return [];

  await prisma.userSession.updateMany({
    where,
    data: { revokedAt: new Date() },
  });

  for (const session of sessions) {
    publishForceLogout(userId, session.id);
  }

  return sessions.map((session) => session.id);
}

/** @param {string} userId */
export async function revokeAllUserSessions(userId) {
  await revokeOtherSessions(userId, null);
}
