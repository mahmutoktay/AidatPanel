# Canlı bildirim mimarisi (Instagram-benzeri)

Uygulama **açık** → WebSocket anında rozet/toast. **Kapalı** → FCM tray. **Yedek** → seyrek HTTP poll.

## Katmanlar

```text
Olay → notificationService (DB)
     → notificationDeliveryService
           ├─ realtimeHub → WebSocket aboneleri
           └─ FCM push

Mobil → NotificationDeliveryCoordinator
           ├─ WebSocketNotificationRealtimeSource  (açık app)
           ├─ FcmNotificationRealtimeSource         (tray + ön plan)
           └─ PollingNotificationRealtimeSource     (yedek)
```

## Backend

| Dosya | Rol |
|-------|-----|
| `src/constants/realtimeEvents.js` | Olay adları + payload |
| `src/realtime/realtimeHub.js` | publish/subscribe |
| `src/realtime/wsGateway.js` | `ws` + JWT `?token=` |
| `src/utils/verifyAccessToken.js` | WS auth |
| `src/services/notificationDeliveryService.js` | Hub + FCM |
| `GET /notifications/unread-count` | Hafif rozet |

Env: `REALTIME_WS_ENABLED=true`

## Mobil

| Dosya | Rol |
|-------|-----|
| `realtime/notification_delivery_config.dart` | `webSocketEnabled` |
| `realtime/websocket_notification_realtime_source.dart` | `web_socket_channel` |
| `realtime/notification_delivery_coordinator.dart` | Orchestrator |
| `api_constants.dart` | `realtimeWebSocketUri()` |

## WebSocket sözleşmesi

Bağlantı: `wss://api.aidatpanel.com/api/v1/realtime?token=ACCESS_JWT`

Sunucu → istemci:

```json
{
  "event": "notification.created",
  "notificationId": "uuid",
  "type": "TICKET_UPDATE",
  "title": "...",
  "body": "...",
  "data": { "ticketId": "...", "route": "/resident-dashboard" }
}
```

## Deploy (canlı)

1. Backend: `REALTIME_WS_ENABLED=true`, Firebase JSON, `npx prisma migrate deploy`, `pm2 restart`
2. Nginx: `/api/v1/realtime` için WebSocket upgrade (`Upgrade`, `Connection "upgrade"`)
3. Mobil: `main.dart` (mock değil), logcat `[realtime] WebSocket bağlandı` ve `[FCM] PUT /me/fcm-token başarılı`
4. Sorun giderme: `fcmToken` DB dolu mu, Nginx WS upgrade, Android bildirim izni

