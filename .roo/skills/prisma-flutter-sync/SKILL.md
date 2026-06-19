---
name: prisma-flutter-sync
description: >
  Prisma schema'da model ekleme veya değişiklik yapılırken ya da Flutter tarafında
  Dart modeli güncellenirken devreye gir. Tetikleyiciler: "modeli güncelle",
  "şemaya alan ekle", "Prisma'ya ekle", "Dart class güncelle", "fromJson güncelle",
  "migration", "yeni alan ekle". İki taraf arasındaki tip/alan uyumsuzluğunu önler.
modes:
  - code
---

# Prisma ↔ Flutter Senkronizasyon Kılavuzu

## Amaç
Prisma schema'da yapılan her değişikliğin Flutter tarafına doğru ve eksiksiz
yansıtılmasını sağla. Sessizce geçme — her senkronizasyonu raporla.

## Tetiklenme Koşulları

Bu skill şu durumlarda devreye girer:
1. Prisma schema'ya yeni model ekleniyor
2. Mevcut modele alan ekleniyor/kaldırılıyor/tipi değişiyor
3. Flutter'da Dart model güncellemesi isteniyor
4. "fromJson/toJson güncelle" talebi geliyor

## Tip Eşleme Tablosu

Her zaman bu tabloyu referans al:

| Prisma Tipi | PostgreSQL | Dart Tipi | Notlar |
|-------------|------------|-----------|--------|
| `String` | VARCHAR/TEXT | `String` | |
| `Int` | INTEGER | `int` | |
| `Float` | DOUBLE | `double` | |
| `Boolean` | BOOLEAN | `bool` | |
| `DateTime` | TIMESTAMP | `DateTime` | JSON'da ISO8601 String |
| `Json` | JSONB | `Map<String, dynamic>` | |
| `String?` | nullable | `String?` | fromJson'da null check |
| `String[]` | ARRAY | `List<String>` | |
| `@id` | PRIMARY KEY | `final String id` | genelde String (cuid/uuid) |
| `@relation` | FOREIGN KEY | başka Dart class | nested veya id olarak taşı |

## Senkronizasyon Akışı

### Prisma → Flutter (schema değiştiğinde)

```
1. Değişen alanları tespit et
2. Tip eşlemesini uygula (yukarıdaki tablo)
3. Dart class'ını güncelle
4. fromJson metodunu güncelle
5. toJson metodunu güncelle
6. Etkilenen Repository metodlarını kontrol et
7. Değişiklikleri raporla
```

### Çıktı Formatı

Her senkronizasyon sonunda şunu sun:

```
## Senkronizasyon Raporu

### Prisma Değişikliği
```prisma
// Önceki hali
model User {
  id   String @id
  name String
}

// Yeni hali
model User {
  id        String   @id @default(cuid())
  name      String
  phone     String?  // YENİ
  isActive  Boolean  @default(true)  // YENİ
  updatedAt DateTime @updatedAt  // YENİ
}
```

### Dart Model Güncellemesi
```dart
class User {
  final String id;
  final String name;
  final String? phone;      // YENİ - nullable
  final bool isActive;      // YENİ
  final DateTime updatedAt; // YENİ

  const User({
    required this.id,
    required this.name,
    this.phone,             // opsiyonel parametre
    required this.isActive,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String,
    name: json['name'] as String,
    phone: json['phone'] as String?,         // null-safe
    isActive: json['isActive'] as bool,
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (phone != null) 'phone': phone,       // nullable alan kontrolü
    'isActive': isActive,
    'updatedAt': updatedAt.toIso8601String(),
  };
}
```

### ⚠️ Dikkat Edilecekler
- `phone` nullable — backend null gönderebilir, Flutter tarafı buna hazır
- `isActive` backend'de default: true — yeni kayıtlarda göndermene gerek yok
- Migration çalıştırmayı unutma: `npx prisma migrate dev --name add_phone_isactive`

### Etkilenen Dosyalar
- [ ] prisma/schema.prisma
- [ ] lib/features/auth/data/models/user_model.dart
- [ ] (varsa) lib/features/auth/data/datasources/auth_remote_datasource.dart
```

## Özel Durumlar

### İlişkili Modeller (@relation)
- Backend `include: { relation: true }` ile nested döndürüyorsa → Dart'ta nested class kullan
- Backend sadece ID döndürüyorsa → Dart'ta sadece `String relationId` yeterli
- Her iki durumu da kontrata yaz, sessizce karar verme

### Enum Tipler
```prisma
enum Role {
  ADMIN
  USER
  MODERATOR
}
```
```dart
enum Role { admin, user, moderator }

// fromJson'da:
role: Role.values.byName((json['role'] as String).toLowerCase()),
// toJson'da:
'role': role.name.toUpperCase(),
```

### JSON Alanları (@db.Json / Json tipi)
- Backend'den `Map<String, dynamic>` olarak gelir
- Dart'ta tip güvenliği için ayrı bir model class'a parse et, `dynamic` olarak bırakma

## Kurallar
- snake_case ↔ camelCase dönüşümünü fromJson'da her zaman elle yönet
- Nullable Prisma alanı → Dart'ta `?` zorunlu, asla `!` ile zorla
- DateTime alanlarını string olarak JSON'a yaz, DateTime olarak parse et
- Migration komutunu her schema değişikliğinde hatırlat
- Etkilenen tüm Dart dosyalarını listele, sadece modeli değiştirip geçme
