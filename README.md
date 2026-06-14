<div align="center">
  <img src="resources/banner.png" alt="AidatPanel Banner" width="100%" />
</div>

# AidatPanel 🏢

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](mobile/)
[![NodeJS](https://img.shields.io/badge/node.js-6DA55F?style=for-the-badge&logo=node.js&logoColor=white)](backend/)
[![PostgreSQL](https://img.shields.io/badge/postgresql-4169e1?style=for-the-badge&logo=postgresql&logoColor=white)](backend/)
[![Prisma](https://img.shields.io/badge/Prisma-3982CE?style=for-the-badge&logo=Prisma&logoColor=white)](backend/)

Türk apartman ve site yönetimi için geliştirilmiş modern, hızlı ve tam yığın (full-stack) monorepo çözümüdür. Yönetici ve sakinler için pratik kullanım sunan **mobil (Flutter)**, güçlü **backend (Node.js)** ve **web** bileşenlerinden oluşur.

---

## 📂 Proje Yapısı

| Klasör | Açıklama |
|--------|----------|
| [`mobile/`](mobile/) | **📱 Flutter Uygulaması:** Yönetici ve sakinler için iOS & Android arayüzü |
| [`backend/`](backend/) | **⚙️ Node.js API:** Express 5 + Prisma + PostgreSQL altyapısı |
| [`resources/`](resources/) | **📚 Kaynaklar:** Yol haritası, API notları, tasarımlar ve rehberler |
| [`web/`](web/) | **🌐 Web Sitesi:** Tanıtım ve landing sayfası (varsa) |

---

## 🚀 Hızlı Başlangıç

### 1️⃣ Backend (Yerel Geliştirme)

Backend klasörüne geçip bağımlılıkları yükleyin ve veritabanı ayarlarını yapılandırın:

```bash
cd backend
npm install
cp .env.example .env
# .env içindeki DATABASE_URL, JWT_* gibi değişkenleri düzenleyin
npx prisma migrate deploy
npm run dev
```

> **API Endpoint:** `http://127.0.0.1:4200/api/v1` 
> *Daha fazla detay için:* [`backend/README.md`](backend/README.md)

### 2️⃣ Mobil (Flutter)

Mobil uygulamayı derleyip çalıştırmak için:

```bash
cd mobile
flutter pub get
flutter run
```

> **Not:** Canlı API ve push bildirimleri test etmek için `main.dart` kullanılır. Mock verilerle geliştirmek için `flutter run -t lib/main_dev.dart` çalıştırabilirsiniz.

---

## 🔔 Bildirim Mimarisi (FCM & Realtime)

Uygulama içinde anlık bildirim (push) ve gerçek zamanlı rozet güncellemeleri kullanılmaktadır:

- **Push Bildirimleri:** Backend (`pushService.js`) üzerinden Firebase FCM'e iletilir. Mobil cihaz token'ı `PUT /me/fcm-token` ile kaydedilir.
- **Canlı güncelleme:** WebSocket (`/api/v1/realtime`) + FCM yedek — ayrıntı: [`resources/AIDATPANEL.md`](resources/AIDATPANEL.md) (Bildirim Sistemi)

---

## 📖 Ek Belgeler

- **Faz ve Görevler:** [`resources/yol-haritası/FAZ_DURUMU.md`](resources/yol-haritası/FAZ_DURUMU.md)
- **AI Asistan Kuralları:** [`CLAUDE.md`](CLAUDE.md)
- **Mimari + API + Bildirim:** [`resources/AIDATPANEL.md`](resources/AIDATPANEL.md)
- **Backend API:** [`backend/README.md`](backend/README.md)
- **Değişiklik geçmişi:** [`CHANGELOG.md`](CHANGELOG.md)
