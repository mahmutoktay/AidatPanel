import jwt from "jsonwebtoken";

/**
 * @param {object} user
 * @param {string | null | undefined} sessionId
 */
const generateAccessToken = (user, sessionId) => {
  const rv = user.refreshTokenVersion ?? 0;
  const payload = { id: user.id, role: user.role, rv };
  if (sessionId) payload.sid = sessionId;
  return jwt.sign(payload, process.env.JWT_SECRET, {
    expiresIn: "15m",
  });
};

/**
 * @param {object} user
 * @param {string | null | undefined} sessionId
 */
const generateRefreshToken = (user, sessionId) => {
  const rv = user.refreshTokenVersion ?? 0;
  const payload = { id: user.id, role: user.role, rv };
  if (sessionId) payload.sid = sessionId;
  return jwt.sign(payload, process.env.REFRESH_TOKEN_SECRET, {
    expiresIn: "30d",
  });
};

export { generateAccessToken, generateRefreshToken };
