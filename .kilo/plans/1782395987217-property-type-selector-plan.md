# Premium Seçici ile Siteler ve Binalar Geçişi Planı

## Bağlam ve Hedef
AidatPanel uygulamasında `ManagerPropertiesTab` içerisinde bulunan standart `TabBar` (Siteler - Binalar) yapısının kaldırılarak, anasayfadaki premium bina seçici butonuna (kart yapısı) dönüştürülmesi planlanmaktadır. Hedef kitle olan 50+ yaş kullanıcılar için daha anlaşılır, daha büyük tıklama alanı olan ve Swipe (kaydırma) yerine doğrudan dokunma (BottomSheet menü) tabanlı bir gezinme amaçlanmaktadır.

## Yapılacak Değişiklikler

1. **PropertyTypePickerSheet (Alttan Açılan Menü) Oluşturulması**
   - Siteler ve Binalar seçeneklerini gösterecek, standart `BottomSheet` bileşeni hazırlanacak.
   - Kullanıcı bu menüden hangi görünümü istediğini seçecek.
   - Dosya konumu: `mobile/lib/features/dashboard/presentation/widgets/property_type_picker_sheet.dart`

2. **Premium Seçici Buton Tasarımı (PropertyTypeSelector)**
   - Mevcut `DashboardBuildingSelector` ve `_DashboardBuildingSelectorTrigger` tasarımlarından esinlenerek oluşturulacak.
   - Sol tarafta seçili moda (Site / Bina) göre değişen dinamik ikon.
   - Kart tasarımı için `DashboardScreenStyle.whiteCard()` kullanılacak.
   - Tıklandığında üstteki `PropertyTypePickerSheet` açılacak.

3. **ManagerPropertiesTab Refactoring**
   - `mobile/lib/features/dashboard/presentation/widgets/manager_properties_tab.dart` dosyasındaki `TabController`, `TabBar` ve `TabBarView` tamamen kaldırılacak.
   - State yönetimi (seçili sekme durumu) için sayfa içi bir değişken (veya basit bir StateProvider) kullanılacak.
   - Ekranın üst kısmında oluşturulan Premium Seçici Buton yer alacak.
   - Orta kısımda ise seçime göre `ManagerSitesTab` veya `ManagerBuildingsTab` yüklenecek.
   
4. **Geçiş Animasyonları**
   - Sağ/sol kaydırmalı ekran geçişi kafa karışıklığını önlemek adına iptal edilecek.
   - Alt görünümler (`ManagerSitesTab` / `ManagerBuildingsTab`) `AnimatedSwitcher` ile sarmalanacak ve değişimlerde "fade" (belirme/solma) efekti kullanılacak.

## Test ve Doğrulama
- Buton kartının doğru UI ile `AppTypography` ve `AppColors` standartlarına uyup uymadığının kontrol edilmesi.
- Alttan açılan menünün (BottomSheet) sorunsuz açılması ve seçeneklerin doğru şekilde durum değiştirmesi.
- Değişimlerde yumuşak animasyonun (Fade) test edilmesi.
- Mevcut `BuildingsExpandableFab` öğesinin ekrandaki konumlanmasının ve işlevinin bozulmadığının teyit edilmesi.
