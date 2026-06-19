# Fullstack Tutarlılık Kuralları

Bu kurallar her mesajda geçerlidir. Backend (Node.js/Prisma/PostgreSQL) ve
Flutter (Dart) arasındaki tutarsızlıkları önlemek için tasarlanmıştır.

---

## 1. İsimlendirme Dönüşümü

Backend ve Flutter arasında alan adları farklı konvansiyonla yazılır:

- **Backend / JSON:** `snake_case` → `created_at`, `user_id`, `is_active`
- **Dart:** `camelCase` → `createdAt`, `userId`, `isActive`

**Kural:** fromJson() içinde her zaman açıkça map et. Asla "zaten aynı gelir" varsayımı yapma.

```dart
// DOĞRU
createdAt: json['created_at'] as String,

// YANLIŞ — backend snake_case gönderirse patlar
createdAt: json['createdAt'] as String,
```

---

## 2. Tip Uyumsuzluğu

Şu tipler sık karıştırılır:

| Durum | Yanlış | Doğru |
|-------|--------|-------|
| Backend `int` gönderir | `json['count'] as String` | `json['count'] as int` |
| Backend null gönderebilir | `json['field'] as String` | `json['field'] as String?` |
| DateTime alanı | `json['date'] as DateTime` | `DateTime.parse(json['date'] as String)` |
| Boolean | `json['active'] == 'true'` | `json['active'] as bool` |

**Kural:** Tip uyumsuzluğu tespit edersen sessizce geçme — uyarı ver ve düzelt.

---

## 3. Response Wrapper Tutarlılığı

API response'ları tutarlı bir wrapper ile geliyorsa her yerde aynı şekilde parse et:

```dart
// Standart wrapper varsayımı:
// { "success": true, "data": {...}, "message": "..." }

final data = response['data'] as Map<String, dynamic>;
// Direkt response['field'] okuma — wrapper varsa patlar
```

**Kural:** Projedeki response yapısını gördükten sonra her endpoint'te aynı wrapper'ı kullan.

---

## 4. Nullable Alanlar

- Prisma schema'da `?` olan alan → Dart'ta mutlaka `?` ile tanımla
- Dart'ta `!` operatörü kullanmak için açık bir neden olmalı — "zaten gelir" varsayımı yok
- toJson() içinde nullable alanları koşullu ekle:

```dart
// DOĞRU
if (phone != null) 'phone': phone,

// YANLIŞ — null gönderilince backend 422 hatası verebilir
'phone': phone,
```

---

## 5. Sessizce Geçme Yasağı

Şu durumlar tespit edildiğinde mutlaka uyar:

- Backend'den gelen alan adı Dart modelinde eksik
- Tip eşleşmesi belirsiz (ör. `dynamic` kullanımı)
- Nullable/non-nullable uyumsuzluğu
- Yeni Prisma alanı Flutter tarafına yansıtılmamış
- Migration çalıştırılması gerekiyor ama hatırlatılmamış

Uyarı formatı:
```
⚠️ Tutarsızlık: [açıklama]
Önerilen düzeltme: [kod/komut]
```
