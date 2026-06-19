---
name: fullstack-task-planner
description: >
  Hem backend (Node.js/Prisma/PostgreSQL) hem Flutter tarafını etkileyen görevlerde
  koda başlamadan önce devreye gir. Tetikleyiciler: "ekran yap", "özellik ekle",
  "modül kur", "entegre et", "bağla", "uygula" gibi kapsamlı istekler.
  Sadece Flutter veya sadece backend değişikliği gerektiren küçük/net görevlerde
  tetiklenme — bu skill yalnızca fullstack etkisi olan işler için.
modes:
  - code
  - architect
---

# Fullstack Görev Planlayıcı

## Amaç
Büyük veya belirsiz bir görev geldiğinde önce planı ortaya koy, onay al, sonra uygula.
Asla onaysız kod yazmaya başlama.

## Adım 1 — Görevi Analiz Et

Gelen isteği aşağıdaki boyutlarda değerlendir:

### Etki Alanı Tespiti
- **Sadece Backend mi?** → Bu skill'i atla, doğrudan uygula
- **Sadece Flutter mi?** → Bu skill'i atla, doğrudan uygula  
- **Her ikisi de etkileniyor mu?** → Bu skill'i çalıştır

### Belirsizlik Kontrolü
Şu bilgiler eksikse sormadan devam etme:
- Hangi veri taşınacak / gösterilecek?
- Kullanıcı kim (auth gerekiyor mu)?
- Mevcut benzer bir yapı var mı (tekrar kullanılabilir mi)?

## Adım 2 — Plan Belgesi Oluştur

Kullanıcıya şu formatta sun:

```
## Görev: [Görev Adı]

### 📦 Backend Tarafı
**Prisma Schema Değişikliği:**
- [ ] Eklenecek/değişecek model: ...
- [ ] İlişkiler: ...

**API Endpoint(ler):**
- [ ] METHOD /path — açıklama
- [ ] Request body: { field: tip, ... }
- [ ] Response: { field: tip, ... }

**Servis/Controller:**
- [ ] Dosya: src/...
- [ ] Fonksiyon: ...

### 📱 Flutter Tarafı
**Dart Model:**
- [ ] Sınıf adı: ...
- [ ] fromJson/toJson gerekli mi: Evet/Hayır

**Repository / API Katmanı:**
- [ ] Dosya: lib/features/.../data/...
- [ ] Metod: ...

**UseCase:**
- [ ] Dosya: lib/features/.../domain/usecases/...

**UI / State:**
- [ ] Ekran: lib/features/.../presentation/...
- [ ] State management: (mevcut yapıya uy)

### ⚠️ Riskler & Dikkat Edilecekler
- ...

### 📋 Uygulama Sırası
1. Prisma schema
2. Migration
3. Backend servis/controller
4. Dart model
5. Repository
6. UseCase
7. UI

---
Bu planı onaylıyor musun, yoksa değiştirilmesini istediğin bir şey var mı?
```

## Adım 3 — Onay Bekle

Kullanıcı onaylamadan HİÇBİR dosya oluşturma veya değiştirme.
Onay sonrası yukarıdaki sırayı takip ederek uygula, her adımı bitince raporla.

## Kurallar
- Plan uzunsa bile tamamını göster — kısaltma
- Emin olmadığın bir bağımlılık varsa "Bunu varsaydım: ..." diye belirt
- Planı uygularken sıradan sapma, önce backend, sonra Flutter
