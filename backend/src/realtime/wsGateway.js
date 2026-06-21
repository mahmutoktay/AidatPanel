import { WebSocketServer } from "ws";
import { verifyAccessTokenToUserId } from "../utils/verifyAccessToken.js";
import { subscribeUser } from "./realtimeHub.js";
import { logger } from "../config/logger.js";

/** Mobil [NotificationDeliveryConfig.webSocketPath] ile aynı */
export const REALTIME_WS_PATH = "/api/v1/realtime";

/**
 * HTTP sunucusuna WebSocket — JWT query `?token=` ile auth.
 * @param {import('http').Server} httpServer
 */
export function attachWebSocketServer(httpServer) {
  if (process.env.REALTIME_WS_ENABLED !== "true") {
    return null;
  }

  const wss = new WebSocketServer({ noServer: true });

  httpServer.on("upgrade", async (request, socket, head) => {
    try {
      const host = request.headers.host ?? "localhost";
      const url = new URL(request.url ?? "/", `http://${host}`);

      if (url.pathname !== REALTIME_WS_PATH) {
        socket.destroy();
        return;
      }

      const token = url.searchParams.get("token");
      const userId = await verifyAccessTokenToUserId(token);
      if (!userId) {
        socket.write("HTTP/1.1 401 Unauthorized\r\n\r\n");
        socket.destroy();
        return;
      }

      wss.handleUpgrade(request, socket, head, (ws) => {
        ws.userId = userId;
        wss.emit("connection", ws, request);
      });
    } catch (err) {
      logger.warn({ type: "realtime_upgrade_error", err: err?.message ?? String(err) });
      socket.destroy();
    }
  });

  wss.on("connection", (ws) => {
    const userId = ws.userId;
    const send = (payload) => {
      if (ws.readyState === ws.OPEN) {
        ws.send(JSON.stringify(payload));
      }
    };

    const unsubscribe = subscribeUser(userId, send);

    ws.send(JSON.stringify({ event: "connected", userId }));

    ws.on("close", () => unsubscribe());
    ws.on("error", () => unsubscribe());
  });

  logger.info({ type: "realtime_ws_listening", path: REALTIME_WS_PATH });

  return {
    close: () => {
      wss.close();
    },
  };
}
