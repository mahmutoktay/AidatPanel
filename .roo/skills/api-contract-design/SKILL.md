---
name: api-contract-design
description: >
  Yeni bir API endpoint yazılmadan veya mevcut bir endpoint değiştirilmeden önce
  devreye gir. Tetikleyiciler: "endpoint ekle", "API yaz", "route kur",
  "controller oluştur", "servis ekle", "veri çek", "veri gönder" gibi ifadeler.
  Backend ile Flutter arasında tip/alan tutarsızlığı riskini sıfırlar.
modes:
  - code
  - architect
---

# API Kontrat Tasarımcısı

## Amaç
Bir endpoint koda dökülmeden önce hem backend hem Flutter tarafını kapsayan
"kontrat" ı ortaya koy. Kontrat onaylanmadan implementasyona geçme.

## Kontrat Şablonu

Her yeni endpoint için aşağıdaki formatı doldur ve kullanıcıya sun:

```
## API Kontrat: [Endpoint Adı]

### Temel Bilgiler
- **Method:** GET | POST | PUT | PATCH | DELETE
- **Path:** /api/v1/...
- **Auth gerekli mi:** Evet (Bearer JWT) | Hayır
- **Açıklama:** Bu endpoint ne yapıyor?

---

### 📤 Request

**Headers:**
```
Content-Type: application/json
Authorization: Bearer <token>  // gerekiyorsa
```

**Path Params:** (varsa)
| Alan | Tip | Zorunlu | Açıklama |
|------|-----|---------|----------|
| id   | String | Evet | ... |

**Query Params:** (varsa)
| Alan | Tip | Varsayılan | Açıklama |
|------|-----|------------|----------|

**Body:** (POST/PUT/PATCH için)
```json
{
  "fieldName": "tip — String/int/bool/DateTime",
  "nested": {
    "field": "tip"
  }
}
```

---

### 📥 Response

**Başarılı (2xx):**
```json
{
  "success": true,
  "data": {
    "id": "String",
    "fieldName": "tip",
    "createdAt": "ISO8601 DateTime"
  },
  "message": "String (opsiyonel)"
}
```

**Hata Durumları:**
| Status | Durum | Açıklama |
|--------|-------|----------|
| 400 | Bad Request | Eksik/hatalı alan |
| 401 | Unauthorized | Token geçersiz |
| 404 | Not Found | Kayıt bulunamadı |
| 500 | Server Error | Beklenmedik hata |

---

### 🗄️ Prisma / Veritabanı

**Kullanılacak Model(ler):**
```prisma
model ModelAdi {
  id        String   @id @default(cuid())
  field     String
  // ...
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}
```

**Sorgu tipi:** findMany | findUnique | create | update | delete | upsert
**İlişkiler:** include: { ... } gerekiyor mu?

---

### 🎯 Flutter / Dart Tarafı

**Dart Model:**
```dart
class ModelAdi {
  final String id;
  final String field;
  final DateTime createdAt;

  const ModelAdi({
    required this.id,
    required this.field,
    required this.createdAt,
  });

  factory ModelAdi.fromJson(Map<String, dynamic> json) => ModelAdi(
    id: json['id'] as String,
    field: json['field'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'field': field,
    'createdAt': createdAt.toIso8601String(),
  };
}
```

**Repository Metodu:**
```dart
Future<ModelAdi> fetchXxx({required String id});
```

**Dikkat Edilecek Dönüşümler:**
- Backend `snake_case` → Dart `camelCase` (fromJson'da manuel map et)
- `DateTime` alanları: ISO8601 string olarak gelir, `DateTime.parse()` ile çevir
- Nullable alanlar: `String?` — backend null gönderebiliyorsa zorunlu

---

### ✅ Onay

Bu kontratı onaylıyor musun?
- Değişiklik varsa belirt, güncelleyip tekrar sunayım.
- Onaydan sonra sırayla: Prisma → Controller → Flutter Model → Repository
```

## Kurallar
- Kontrat onaylanmadan tek satır kod yazma
- Backend alan adları `snake_case`, Dart'ta `camelCase` — fromJson'da mutlaka map et
- Response yapısını düz obje olarak değil, `{ success, data, message }` wrapper ile tasarla
- Nullable olmayan alan backend'de null gönderebiliyorsa bunu kontrata yaz
- Tarih alanları her zaman ISO8601 string olarak taşı, her iki tarafta da parse et
