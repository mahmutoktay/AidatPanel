# Admin Panel — Responsive Onay Kapısı

Her ekran aşağıdaki viewport genişliklerinde doğrulanmalıdır:

| Viewport | Cihaz örneği |
| -------- | ------------ |
| 320px    | iPhone SE    |
| 480px    | Küçük telefon |
| 768px    | iPad         |
| 1024px   | iPad landscape |
| 1440px   | Desktop      |

## Referans ekranlar

### 1. Login
- [ ] Form mobilde tam genişlik
- [ ] Desktop'ta merkez kart (max-width ~400px)
- [ ] Buton min 44px yükseklik

### 2. Dashboard
- [ ] KPI grid: 1 → 2 → 4 sütun
- [ ] Sidebar: drawer (mobil) / ikon-only (md) / tam (lg+)
- [ ] Grafik container responsive yükseklik

### 3. Liste sayfası (üyeler)
- [ ] lg+ tablo görünümü
- [ ] &lt; lg kart satır görünümü
- [ ] Filtreler mobilde collapsible

### 4. Detay / modal
- [ ] Mobilde tam ekran sheet
- [ ] md+ modal veya yan panel

## Genel kurallar
- [ ] Yatay sayfa scroll yok (tablo container hariç)
- [ ] Escape ile drawer kapanır
- [ ] `prefers-reduced-motion` desteklenir
