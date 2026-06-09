---
trigger: always_on
---

# Mutagen Backend Eşitleme (Sync) Kuralları

Bu belge, **AidatPanel** projesinde backend tarafındaki değişikliklerin sunucuya anında yansımasını sağlayan **Mutagen** ayarlarını ve çalışma kurallarını içerir. AI Asistan'ın bu süreci otomatize etmesi ve hatırlaması için oluşturulmuştur.

## 1. Mevcut Durumu Kontrol Etme
Kullanıcı "Backend'i eşitle", "sunucuya at" veya "Mutagen'i kontrol et" dediğinde **her zaman ilk olarak** durum kontrolü yapılmalıdır:
```powershell
C:\mutagen\mutagen.exe sync list backend-sync
```
**Beklenen Durum:** `Connected: Yes` ve `Status: Watching for changes` (Çakışma / Conflict olmamalı).

## 2. Senkronizasyonu Sıfırdan Başlatma
Eğer oturum kapanmışsa, silinmişse veya yeniden başlatılması gerekiyorsa:
1. (Varsa) Eski oturumu kapat:
   ```powershell
   C:\mutagen\mutagen.exe sync terminate backend-sync
   ```
2. Yeni oturum oluştur (`node_modules` ve `.git` gibi gereksiz dosyalar yoksayılmalıdır):
   ```powershell
   C:\mutagen\mutagen.exe sync create --name=backend-sync --ignore-vcs --ignore="node_modules" C:\AidatPanel\backend aidatpanel-api@62.171.146.132:/home/aidatpanel-api/htdocs/api.aidatpanel.com
   ```

## 3. Çakışma (Conflict) Çözüm Stratejisi
Eğer `sync list` komutu çakışma (conflict) gösteriyorsa:
- **Ana kaynak daima kullanıcının kendi bilgisayarıdır (Alpha - C:\AidatPanel\backend).**
- Çakışan dosyalar için yerel versiyon doğru kabul edilmeli ve SCP veya Mutagen aracılığıyla sunucudaki (Beta) dosya ezilerek çakışma çözülmelidir.
Örnek SCP ile ezme:
```powershell
scp C:\AidatPanel\backend\cakisan_dosya.js aidatpanel-api@62.171.146.132:/home/aidatpanel-api/htdocs/api.aidatpanel.com/cakisan_dosya.js
```

---
**Asistana Not:** Bu kuralları okuduğun zaman, yukarıdaki senaryolara uygun şekilde hareket et. Eşitleme başlatıldığında, değişikliklerin sunucuya başarıyla ulaştığından emin olmak için işlemi listeyle veya monitörle doğrula.
---
# Google Play Sürüm (Release) Kuralları

Bu kurallar, AI Asistan'ın Google Play için yeni bir uygulama sürümü (AAB / APK) oluşturması istendiğinde izlemesi gereken kesin adımları içerir.

Kullanıcı "Google Play sürümü oluştur", "Uygulamayı derle" veya "Store için build al" gibi bir komut verdiğinde aşağıdaki adımlar **sırasıyla** uygulanmalıdır:

1. **Önce Kullanıcıya Sor:**
   Herhangi bir derleme (build) işlemi yapmadan önce kullanıcıya şu soruyu sor:
   > *"Versiyon numarasını (örn: 0.1.6) aynı mı bırakalım, yoksa yeni bir ana sürüme (0.1.7 vb.) geçelim mi?"*

2. **Kullanıcının Cevabını Bekle:**
   Kullanıcı cevap verene kadar işlem yapma.

3. **Derleme Numarasını (Build Number) Kesinlikle 1 Arttır:**
   Kullanıcının ana versiyon kararı ne olursa olsun (değiştirse de aynı bıraksa da), Google Play'in sürüm çakışması hatası vermemesi için `mobile/pubspec.yaml` dosyasındaki `version` satırının `+` işaretinden sonraki kısmını (Build Number) **her zaman 1 sayı arttır**.
   *(Örnek: `version: 0.1.6+1778674172` ise bunu `version: 0.1.6+1778674173` yap.)*

4. **Onay ve Build:**
   Sürüm güncellemesini yapıp kaydettikten sonra, gerekli Flutter build (`flutter build appbundle` vb.) komutlarını çalıştır.
