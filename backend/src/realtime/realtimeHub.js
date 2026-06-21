/**
 * Kullanıcı bazlı canlı olay dağıtımı.
 * Bugün: in-memory abone seti (WebSocket gateway bağlanınca dolar).
 * Yarın: `wsGateway` aynı hub üzerinden publish eder — notificationService değişmez.
 */
import { logger } from "../config/logger.js";

/** @type {Map<string, Set<(payload: object) => void>>} */
const subscribersByUserId = new Map();

/**
 * @param {string} userId
 * @param {(payload: object) => void} onEvent
 * @returns {() => void} unsubscribe
 */
export function subscribeUser(userId, onEvent) {
  if (!userId || typeof onEvent !== "function") {
    return () => {};
  }
  let set = subscribersByUserId.get(userId);
  if (!set) {
    set = new Set();
    subscribersByUserId.set(userId, set);
  }
  set.add(onEvent);
  return () => {
    set.delete(onEvent);
    if (set.size === 0) subscribersByUserId.delete(userId);
  };
}

/**
 * Tek kullanıcıya olay (WebSocket bağlıysa anında; değilse yalnızca FCM yeterli).
 * @param {string} userId
 * @param {object} payload
 */
export function publishToUser(userId, payload) {
  if (!userId) return;
  const set = subscribersByUserId.get(userId);
  if (!set || set.size === 0) return;
  for (const fn of set) {
    try {
      fn(payload);
    } catch (err) {
      logger.warn({ type: "realtime_subscriber_error", err: err?.message ?? String(err) });
    }
  }
}

/**
 * @param {string[]} userIds
 * @param {object} payloadFactory — (userId) => payload
 */
export function publishToUsers(userIds, payloadFactory) {
  const unique = [...new Set(userIds.filter(Boolean))];
  for (const userId of unique) {
    const payload =
      typeof payloadFactory === "function" ? payloadFactory(userId) : payloadFactory;
    if (payload) publishToUser(userId, payload);
  }
}

export function subscriberCount(userId) {
  return subscribersByUserId.get(userId)?.size ?? 0;
}
