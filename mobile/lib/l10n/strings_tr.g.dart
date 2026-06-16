///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class TranslationsTr with BaseTranslations<AppLocale, Translations> implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsTr({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.tr,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <tr>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key);

	late final TranslationsTr _root = this; // ignore: unused_field

	@override 
	TranslationsTr $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsTr(meta: meta ?? this.$meta);

	// Translations
	@override late final _Translations$common$tr common = _Translations$common$tr._(_root);
	@override late final _Translations$validation$tr validation = _Translations$validation$tr._(_root);
	@override late final _Translations$features$tr features = _Translations$features$tr._(_root);
	@override late final _Translations$legal$tr legal = _Translations$legal$tr._(_root);
	@override late final _Translations$db_context$tr db_context = _Translations$db_context$tr._(_root);
}

// Path: common
class _Translations$common$tr implements Translations$common$en {
	_Translations$common$tr._(this._root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get logout => 'Çıkış Yap';
	@override String get cancel => 'İptal';
	@override String get confirm => 'Onayla';
	@override String get ok => 'Tamam';
	@override String get save => 'Kaydet';
	@override String get delete => 'Sil';
	@override String get edit => 'Düzenle';
	@override String get close => 'Kapat';
	@override String get yes => 'Evet';
	@override String get no => 'Hayır';
	@override String get register => 'Kaydol';
	@override String get login => 'Giriş Yap';
	@override String get join => 'Katıl';
	@override String get confirmMessage => 'Emin misiniz?';
	@override String get logoutConfirm => 'Çıkış yapmak istediğinize emin misiniz?';
	@override String get logoutSuccess => 'Başarıyla çıkış yaptınız.';
	@override String get logoutAllDevices => 'Diğer cihazlardan çıkış';
	@override String get logoutAllDevicesConfirm => 'Diğer telefon ve tabletlerdeki oturumlar kapanır. Bu cihazda girişiniz devam eder.';
	@override String get logoutAllDevicesSuccess => 'Diğer cihazlardaki oturumlar kapatıldı.';
	@override String get logoutAllDevicesFailed => 'İşlem tamamlanamadı. Lütfen tekrar deneyin.';
	@override String get sessionExpired => 'Bu cihazdaki oturumunuz başka bir cihazdan sonlandırıldı.';
	@override String get account => 'Hesap';
	@override String get editProfile => 'Profili Düzenle';
	@override String get changePassword => 'Şifre Değiştir';
	@override String get language => 'Dil';
	@override String get turkish => 'Türkçe';
	@override String get notifications => 'Bildirimler';
	@override String get info => 'Bilgi';
	@override String get privacyPolicy => 'Gizlilik Politikası';
	@override String get kvkk => 'KVKK';
	@override String get helpSupport => 'Yardım ve Destek';
	@override String get about => 'Hakkında';
	@override String get comingSoon => 'Bu özellik yakında eklenecek';
	@override String get multiLanguageComingSoon => 'Çoklu dil desteği yakında eklenecek';
	@override String get copyright => ' 2026 AidatPanel\nTüm hakları saklıdır.';
	@override String get aboutDescription => 'Türk apartman ve site yöneticileri için aidat yönetim platformu.';
	@override String get manager => 'Yönetici';
	@override String get resident => 'Sakin';
	@override String get tokenExpiryTest => 'Token Süresi Kontrol (Test)';
	@override String get tokenExpired => 'Token süresi DOLMUŞ! Login ekranına atılıyorsunuz.';
	@override String get tokenActive => 'Token aktif! Kalan süre';
	@override String get pressBackAgainToExit => 'Çıkmak için geri tuşuna tekrar basın';
	@override String get loading => 'Yükleniyor…';
	@override String get loadingBuildings => 'Binalar yükleniyor…';
	@override String get loadFailed => 'Yüklenemedi';
	@override String get unexpectedError => 'İşlem tamamlanamadı. Lütfen tekrar deneyin.';
	@override late final _Translations$common$api$tr api = _Translations$common$api$tr._(_root);
	@override String get rateLimitHint => 'Sunucu şu an yoğun görünüyor. Kısa süre sonra yeniden denenecek.';
	@override String get tryAgain => 'Tekrar Dene';
	@override late final _Translations$common$documentPreview$tr documentPreview = _Translations$common$documentPreview$tr._(_root);
	@override String get home => 'Ana Sayfa';
	@override String get buildings => 'Binalar';
	@override String get dues => 'Aidatlar';
	@override String get settings => 'Ayarlar';
	@override String get user => 'Kullanıcı';
	@override String get welcome => 'Hoş Geldiniz';
	@override String get managedBuildings => 'Yönetilen Binalar';
	@override String get issues => 'Arızalar';
	@override String get issuesTab => 'Arızalar Sekmesi';
	@override String get apartment => 'Daire';
	@override String get addBuilding => 'Bina Ekle';
	@override String get inviteCode => 'Davet Kodu';
	@override String get myBuildings => 'Binalarım';
	@override String get apartments => 'Daireler';
	@override String get collection => 'Tahsilat';
	@override String get duesTab => 'Aidatlar Sekmesi';
	@override String get totalApartments => 'Toplam Daire';
	@override String get occupiedApartments => 'Dolu Daire';
	@override String get duesCollection => 'Aidat Tahsilatı';
	@override String get totalDues => 'Toplam Aidat';
	@override String get recentTransactions => 'Son İşlemler';
	@override String get paid => 'Ödendi';
	@override String get pending => 'Beklemede';
	@override String get overdue => 'Gecikmiş';
	@override String get balance => 'Bakiye';
	@override String get amountDue => 'Ödenmesi Gereken';
	@override String get lastPayment => 'Son Ödeme';
	@override String get makePayment => 'Ödeme Yap';
	@override String get bills => 'Faturalar';
	@override String get support => 'Destek';
	@override String get quickActions => 'Hızlı işlemler';
	@override String get residentName => 'Sakin Adı';
	@override String get addBuildingNew => 'Yeni Bina Ekle';
	@override String get basicInfo => 'Temel Bilgiler';
	@override String get buildingName => 'Bina Adı';
	@override String get buildingNameHint => 'Örn: Güneş Apartmanı';
	@override String get location => 'Konum';
	@override String get streetAddress => 'Sokak / Cadde Adresi';
	@override String get streetAddressHint => 'Örn: Bağdat Cad. No: 123';
	@override String get details => 'Detaylar';
	@override String get floorCount => 'Kat Sayısı';
	@override String get floorCountHint => '1 ile 200 arası';
	@override String get apartmentsPerFloor => 'Kattaki Daire';
	@override String get apartmentsPerFloorHint => '1 ile 50 arası';
	@override String get floorRangeError => 'Kat sayısı 1 ile 200 arasında olmalı';
	@override String get apartmentsPerFloorRangeError => 'Kat başına daire 1 ile 50 arasında olmalı';
	@override String get buildingAddFailed => 'Bina eklenemedi. Lütfen tekrar deneyin.';
	@override String get monthlyDues => 'Aylık Aidat';
	@override String get monthlyDuesLabel => 'Aylık Aidat (₺)';
	@override String get monthlyDuesHint => 'Örn: 1000';
	@override String get createBuilding => 'Bina Oluştur';
	@override String get cancelBtn => 'Vazgeç';
	@override String get cityRequired => 'Şehir *';
	@override String get selectCity => 'Şehir seçin';
	@override String get districtRequired => 'İlçe *';
	@override String get selectDistrict => 'İlçe seçin';
	@override String get selectCityFirst => 'Önce şehir seçin';
	@override String get selectCityTitle => 'Şehir Seçin';
	@override String get selectDistrictTitle => 'İlçe Seçin';
	@override String get search => 'Ara...';
	@override String get noResults => 'Sonuç bulunamadı';
	@override String get fieldRequired => 'boş bırakılamaz';
	@override String get fillRequiredFields => 'Lütfen zorunlu alanları doldurun';
	@override String get selectCityAndDistrict => 'Şehir ve ilçe seçmelisiniz';
	@override String get floorApartmentMustBePositive => 'Kat sayısı ve daire sayısı 0\'dan büyük olmalı';
	@override String get buildingAddedSuccess => 'Bina başarıyla eklendi';
	@override String get createInviteCode => 'Davet Kodu Oluştur';
	@override String get whichBuildingForCode => 'Hangi binadan kod üretilecek?';
	@override String get whichApartmentForCode => 'Hangi daire için kod üretilecek?';
	@override String get noApartmentsInBuilding => 'Bu binaya henüz daire eklenmemiş';
	@override String get activeCodeBadge => 'Aktif Kod';
	@override String get occupiedBadge => 'Dolu';
	@override String get emptyBadge => 'Boş';
	@override String get activeCodePrefix => 'Aktif kod';
	@override String get residentPrefix => 'Sakin';
	@override String get emptyApartment => 'Boş daire';
	@override String get codeRevoked => 'Kod iptal edildi';
	@override String get codeCopied => 'Kod kopyalandı';
	@override String get clipboardCopied => 'Mesaj panoya kopyalandı';
	@override String get expiresAtPrefix => 'Son kullanma';
	@override String get remainingPrefix => 'Kalan';
	@override String get buildingDetail => 'Bina Detayı';
	@override String get residents => 'Sakinler';
	@override String get apartmentsBadge => 'Daire';
	@override String get emptyApartmentText => 'Boş Daire';
	@override String get vacantBadge => 'Boş';
	@override String get phoneNotShared => 'Telefon paylaşılmadı';
	@override String get residentDetailsLink => 'Detayları Gör';
	@override String get duesPaidStatus => 'Aidat Ödendi';
	@override String get duesPendingStatus => 'Aidat Bekliyor';
	@override String get duesOverdueStatus => 'Aidat Gecikmiş';
	@override String get noResidentInApartment => 'Sakin atanmadı';
	@override String get residentDetailsSheetTitle => 'Sakin bilgileri';
	@override String get apartmentDetailsSheetTitle => 'Daire bilgileri';
	@override String get noResidentAssigned => 'Sakin atanmamış';
	@override String get noApartmentsYet => 'Henüz daire eklenmemiş';
	@override String get paidStatus => 'Ödendi';
	@override String get pendingStatus => 'Bekliyor';
	@override String get overdueStatus => 'Gecikmiş';
	@override String get waivedStatus => 'Muaf';
	@override String get all => 'Tümü';
	@override String get status => 'Durum';
	@override String get month => 'Ay';
	@override String get dayLabel => 'Gün';
	@override String get pickDate => 'Tarih seçin';
	@override String get monthJanuary => 'Ocak';
	@override String get monthFebruary => 'Şubat';
	@override String get monthMarch => 'Mart';
	@override String get monthApril => 'Nisan';
	@override String get monthMay => 'Mayıs';
	@override String get monthJune => 'Haziran';
	@override String get monthJuly => 'Temmuz';
	@override String get monthAugust => 'Ağustos';
	@override String get monthSeptember => 'Eylül';
	@override String get monthOctober => 'Ekim';
	@override String get monthNovember => 'Kasım';
	@override String get monthDecember => 'Aralık';
	@override String get allMonths => 'Tüm aylar';
	@override String get year => 'Yıl';
	@override String get allYears => 'Tüm yıllar';
	@override String get note => 'Not';
	@override String get myDuesHistory => 'Aidat Geçmişim';
	@override String get currentPeriodDue => 'Güncel aidat';
	@override String get myPastDues => 'Geçmiş aidatlarım';
	@override String get buildingDues => 'Bina Aidatları';
	@override String get noDuesYet => 'Henüz aidat kaydı yok';
	@override String get duesUpdated => 'Aidat durumu güncellendi';
	@override String get amount => 'Tutar';
	@override String get updateDueAmount => 'Aidat Tutarını Güncelle';
	@override String get dueAmountUpdated => 'Aidat tutarı güncellendi';
	@override String get dueAmountUpdateFailed => 'Aidat tutarı güncellenemedi';
	@override String get dueDay => 'Aidat Günü (1-28)';
	@override String get selectDueDay => 'Gün seçin';
	@override String get affectCurrentDues => 'Bekleyen aidatlara da uygula';
	@override String get affectCurrentDuesHint => 'Açık olduğunda mevcut bekleyen (PENDING) aidat tutarları da yeni tutara güncellenir.';
	@override String get dueUpdateNeedAmountOrDay => 'Güncellemek için tutar girin veya aidat günü seçin.';
	@override String get dueUpdateNeedStoredAmount => 'Bu bina için kayıtlı tutar yok. Aidat gününü güncellemek için önce tutar yazın.';
	@override String get dueAmountInvalidPositive => 'Geçerli bir tutar yazın.';
	@override String get dueDayOutOfRange => 'Aidat günü 1 ile 28 arasında olmalıdır.';
	@override String get update => 'Güncelle';
	@override String get overdueDays => 'gün gecikmiş';
	@override String get dueMetaOverdueDelay => '{days} gün gecikme';
	@override String get dueMetaPaidInMonth => '{month} {year}\'de ödendi';
	@override String get dueMetaPaidOnDay => '{day} {month}\'ta ödendi';
	@override String get dueMetaPendingDueDate => 'son ödeme {day} {month}';
	@override String get payShort => 'Öde';
	@override String get dekontShort => 'Dekont';
	@override String get monthChipLabel => 'AY';
	@override String get yearChipLabel => 'YIL';
	@override String get dueDateLabel => 'Son ödeme';
	@override String get perMonth => '/ ay';
	@override String get floorLabel => 'KAT';
	@override String get apartmentLabel => 'DAİRE';
	@override String get turkishLanguage => 'Türkçe';
	@override String get englishLanguage => 'English';
	@override String get stepBuilding => 'Bina';
	@override String get stepApartment => 'Daire';
	@override String get stepCode => 'Kod';
	@override String get editBuilding => 'Binayı Düzenle';
	@override String get deleteBuilding => 'Binayı Sil';
	@override String get buildingUpdated => 'Bina güncellendi';
	@override String get buildingDeleted => 'Bina silindi';
	@override String get buildingUpdateFailed => 'Bina güncellenemedi';
	@override String get buildingDeleteFailed => 'Bina silinemedi';
	@override String get buildingDeleteFailedFK => 'Bu binayı silemezsiniz: hâlâ daire, sakin veya aidat kayıtları var. Önce daireleri/aidatları temizleyip tekrar deneyin.';
	@override String get deleteBuildingHeader => 'Bu işlem geri alınamaz.';
	@override String get deleteBuildingTypeHint => 'Onaylamak için aşağıya bina adını aynen yazın:';
	@override String get deleteBuildingTypeFieldLabel => 'Bina adı';
	@override String get buildingNameMismatch => 'Yazdığınız metin bina adıyla aynı değil.';
	@override String get editApartment => 'Daireyi Düzenle';
	@override String get deleteApartment => 'Daireyi Sil';
	@override String get apartmentUpdated => 'Daire güncellendi';
	@override String get apartmentDeleted => 'Daire silindi';
	@override String get apartmentUpdateFailed => 'Daire güncellenemedi';
	@override String get apartmentDeleteFailed => 'Daire silinemedi';
	@override String get apartmentDeleteFailedFK => 'Bu daireyi silemezsiniz: sakin veya aidat kayıtları var. Önce sakinin hesap kapatmasını bekleyip aidatları temizleyin.';
	@override String get deleteApartmentConfirm => 'Daireyi silmek istediğinize emin misiniz?';
	@override String get apartmentNumberLabel => 'Daire No (örn. 5A)';
	@override String get floorLabel2 => 'Kat (opsiyonel)';
	@override String get floorOptional => 'Kat (-5 ile 200 arası)';
	@override String get buildingNameField => 'Bina adı';
	@override String get buildingAddressField => 'Adres';
	@override String get buildingCityField => 'Şehir';
	@override String get monthlyDuesPerApartment => 'Aylık aidat / daire';
	@override String get remove => 'Çıkar';
	@override String get removeResident => 'Sakini Çıkar';
	@override String get removeResidentConfirm => 'Bu sakini daireden çıkarmak istediğinize emin misiniz?';
	@override String get removeResidentNote => 'Sakinin hesabı silinmez, sadece bu daireden bağlantısı kopar. Geçmiş aidat kayıtları korunur. Sakin başka bir daireye davet kodu ile tekrar katılabilir.';
	@override String get residentRemoved => 'Sakin daireden çıkarıldı';
	@override String get residentRemoveFailed => 'Sakin çıkarılamadı';
	@override String get residentRemoveForbidden => 'Bu işlem için yetkiniz yok. Yalnızca binanın yöneticisi sakin çıkarabilir.';
	@override String get residentRemoveNotFound => 'Bu dairede çıkarılacak sakin bulunamadı.';
	@override String get multiSelectResidents => 'Çoklu seç';
	@override String get multiSelectTapHint => 'Seçmek için karta dokunun';
	@override String get selectTriggerShort => 'Seç';
	@override String get selectedCountLabel => 'seçili';
	@override String get selectionRemoveHint => 'Çıkarmak istediğiniz sakinleri seçin';
	@override String get selectionDeleteIbanHint => 'Silmek istediğiniz IBAN\'ları seçin';
	@override String get removeSelectedResidents => 'Seçilenleri çıkar';
	@override String get removeSelectedResidentsTitle => 'Seçilen sakinleri çıkar';
	@override String get removeSelectedResidentsMessage => 'Aşağıda listelenen dairelerde oturan sakinler daireden çıkarılır. Hesapları silinmez; yalnızca bu binadaki bağlantıları kalkar. Geçmiş aidat kayıtları korunur.';
	@override String get removeSelectedResidentsAffectedListTitle => 'Etkilenecek daireler';
	@override String get removeSelectedResidentsListUnavailable => 'Daire listesi şu an gösterilemiyor. Seçilen daire sayısı aşağıda; onaylarsanız işlem yine de uygulanır.';
	@override String get pickResidentsFirst => 'Önce listeden en az bir dolu daire seçin';
	@override String get noResidentsToRemoveInBuilding => 'Bu binada çıkarılacak sakin bulunmuyor.';
	@override String get removeSelectedProgress => 'İşlem yapılıyor…';
	@override String get removeSelectedSuccess => 'Seçilen sakinler dairelerden çıkarıldı';
	@override String get removeSelectedFailed => 'Seçilenleri çıkarma tamamlanamadı';
	@override String get currentPassword => 'Mevcut Şifre';
	@override String get newPassword => 'Yeni Şifre';
	@override String get newPasswordConfirm => 'Yeni Şifre (Tekrar)';
	@override String get currentPasswordRequired => 'Mevcut şifrenizi girin';
	@override String get passwordsMustDiffer => 'Yeni şifre eski şifre ile aynı olamaz';
	@override String get changePasswordTitle => 'Şifre Değiştir';
	@override String get changePasswordSubtitle => 'Güvenliğiniz için şifrenizi düzenli olarak değiştirin.';
	@override String get changePasswordSuccess => 'Şifreniz değiştirildi. Lütfen yeni şifrenizle tekrar giriş yapın.';
	@override String get changePasswordFailed => 'Şifre değiştirilemedi. Lütfen tekrar deneyin.';
	@override String get changePasswordWrongCurrent => 'Mevcut şifre hatalı.';
	@override String get deleteAccount => 'Hesabımı Kapat';
	@override String get deleteAccountTitle => 'Hesabınızı kapatmak istiyor musunuz?';
	@override String get deleteAccountWarning => 'Bu işlem geri alınamaz. Kişisel bilgileriniz silinir, ancak yasal nedenlerle bazı kayıtlar (aidat geçmişi gibi) anonim olarak saklanır.';
	@override String get deleteAccountTypeHint => 'Onaylamak için aşağıya "HESABIMI KAPAT" yazın:';
	@override String get deleteAccountTypePhrase => 'HESABIMI KAPAT';
	@override String get deleteAccountTypeMismatch => 'Yazdığınız metin eşleşmiyor.';
	@override String get deleteAccountConfirmButton => 'Hesabımı Kapat';
	@override String get deleteAccountSuccess => 'Hesabınız kapatıldı. Bizi tercih ettiğiniz için teşekkürler.';
	@override String get deleteAccountFailed => 'Hesap kapatılamadı. Lütfen tekrar deneyin.';
	@override String get deleteAccountFailedManager => 'Önce yönettiğiniz binaları silmeniz veya başka bir yöneticiye devretmeniz gerekiyor.';
	@override String get dangerZone => 'Tehlikeli Bölge';
	@override String get forgotPassword => 'Şifremi Unuttum';
	@override String get forgotPasswordTitle => 'Şifremi Unuttum';
	@override String get forgotPasswordSubtitle => 'Kayıtlı e-posta adresinizi girin, size bir sıfırlama kodu gönderelim.';
	@override String get forgotPasswordSuccess => 'Eğer bu e-posta sistemimizde kayıtlıysa, sıfırlama kodu gönderildi. Lütfen e-postanızı kontrol edin.';
	@override String get sendResetCode => 'Kodu Gönder';
	@override String get iHaveACode => 'Zaten kodum var';
	@override String get resetPasswordTitle => 'Yeni Şifre Belirle';
	@override String get resetPasswordSubtitle => 'E-postanıza gelen 6 haneli kodu ve yeni şifrenizi girin.';
	@override String get resetCode => 'Sıfırlama Kodu';
	@override String get resetCodeHint => 'ABC123';
	@override String get resetCodeRequired => 'Sıfırlama kodu gerekli';
	@override String get resetCodeInvalid => 'Kod 6 karakter olmalı';
	@override String get resetPasswordSuccess => 'Şifreniz sıfırlandı. Yeni şifrenizle giriş yapabilirsiniz.';
	@override String get resetPasswordFailed => 'Şifre sıfırlanamadı. Kod hatalı veya süresi dolmuş olabilir.';
	@override String get resetPasswordSubmit => 'Şifreyi Sıfırla';
	@override String get backToLogin => 'Giriş ekranına dön';
}

// Path: validation
class _Translations$validation$tr implements Translations$validation$en {
	_Translations$validation$tr._(this._root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get emailRequired => 'Email adresi boş bırakılamaz';
	@override String get emailInvalid => 'Geçerli bir email adresi giriniz';
	@override String get emailTooLong => 'Email adresi çok uzun';
	@override String get phoneRequired => 'Telefon numarası boş bırakılamaz';
	@override String get phoneInvalid => 'Telefon numarası 10 haneli olmalıdır';
	@override String get passwordRequired => 'Şifre boş bırakılamaz';
	@override String get passwordTooShort => 'Şifre en az 6 karakter olmalıdır';
	@override String get passwordTooLong => 'Şifre çok uzun';
	@override String get passwordUppercaseRequired => 'Şifrede en az 1 büyük harf olmalıdır';
	@override String get passwordLowercaseRequired => 'Şifrede en az 1 küçük harf olmalıdır';
	@override String get passwordNumberRequired => 'Şifrede en az 1 rakam olmalıdır';
	@override String get passwordSpecialCharRequired => 'Şifrede en az 1 özel karakter olmalıdır';
}

// Path: features
class _Translations$features$tr implements Translations$features$en {
	_Translations$features$tr._(this._root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override late final _Translations$features$buildings$tr buildings = _Translations$features$buildings$tr._(_root);
	@override late final _Translations$features$auth$tr auth = _Translations$features$auth$tr._(_root);
	@override late final _Translations$features$apartments$tr apartments = _Translations$features$apartments$tr._(_root);
	@override late final _Translations$features$tickets$tr tickets = _Translations$features$tickets$tr._(_root);
	@override late final _Translations$features$dekont$tr dekont = _Translations$features$dekont$tr._(_root);
	@override late final _Translations$features$expenses$tr expenses = _Translations$features$expenses$tr._(_root);
	@override late final _Translations$features$notifications$tr notifications = _Translations$features$notifications$tr._(_root);
	@override late final _Translations$features$profile$tr profile = _Translations$features$profile$tr._(_root);
	@override late final _Translations$features$subscription$tr subscription = _Translations$features$subscription$tr._(_root);
	@override late final _Translations$features$reports$tr reports = _Translations$features$reports$tr._(_root);
	@override late final _Translations$features$dashboard$tr dashboard = _Translations$features$dashboard$tr._(_root);
	@override late final _Translations$features$faz2$tr faz2 = _Translations$features$faz2$tr._(_root);
}

// Path: legal
class _Translations$legal$tr implements Translations$legal$en {
	_Translations$legal$tr._(this._root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get companyName => 'Vefa Yazılım';
	@override String get contactEmail => 'store@vefayazilim.com';
	@override String get contactBlock => 'Veri sorumlusu: Vefa Yazılım\nE-posta: store@vefayazilim.com';
	@override String get updatedLabel => 'Son güncelleme';
	@override String get updatedDate => 'Haziran 2026';
	@override String get privacyIntro => 'Bu metin, Vefa Yazılım tarafından sunulan AidatPanel mobil uygulamasını kullanırken kişisel verilerinizin nasıl işlendiğini açıklar. Uygulamayı kullanmaya devam ederek bu politikayı okuduğunuzu kabul etmiş sayılırsınız.';
	@override String get privacyS1Title => '1. Veri sorumlusu';
	@override String get privacyS1Body => 'AidatPanel hizmeti kapsamında kişisel verileriniz, veri sorumlusu Vefa Yazılım tarafından 6698 sayılı Kişisel Verilerin Korunması Kanunu (KVKK) ve ilgili mevzuata uygun olarak işlenir. KVKK ve gizlilik talepleriniz için: store@vefayazilim.com';
	@override String get privacyS2Title => '2. Toplanan veriler';
	@override String get privacyS2Body => 'Hesap bilgileri (ad, e-posta, telefon, dil tercihi), apartman ve daire ilişkisi, aidat ve ödeme kayıtları, destek talepleri, duyuru ve bildirim tercihleri, dekont ve makbuz görselleri (yüklediğinizde), cihaz bildirim anahtarı (FCM) ve güvenli oturum bilgileri (şifrelenmiş token) işlenebilir.';
	@override String get privacyS3Title => '3. İşleme amaçları';
	@override String get privacyS3Body => 'Verileriniz; aidat ve gider yönetimi, tahsilat ve dekont süreçleri, apartman içi iletişim ve duyurular, kimlik doğrulama, hizmet güvenliği, yasal yükümlülükler ve size bildirim göndermek amacıyla işlenir.';
	@override String get privacyS4Title => '4. Saklama ve güvenlik';
	@override String get privacyS4Body => 'Veriler güvenli sunucularda saklanır; iletişim HTTPS ile şifrelenir. Oturum bilgileri cihazınızda güvenli depolamada tutulur. Yasal zorunluluklar dışında veriler, hizmet ilişkisi süresince ve mevzuattaki süreler boyunca muhafaza edilir.';
	@override String get privacyS5Title => '5. Paylaşım';
	@override String get privacyS5Body => 'Kişisel verileriniz üçüncü taraflara satılmaz. Yalnızca hizmetin sunulması için gerekli altyapı sağlayıcıları (barındırma, bildirim servisi vb.) ve kanunen yetkili kurumlarla, mevzuata uygun şekilde paylaşılabilir.';
	@override String get privacyS6Title => '6. Haklarınız';
	@override String get privacyS6Body => 'KVKK kapsamında verilerinize erişme, düzeltme, silme, işlemeyi kısıtlama ve itiraz etme haklarına sahipsiniz. Hesap kapatma (soft delete) Ayarlar üzerinden yapılabilir; yasal saklama gerektiren kayıtlar anonimleştirilerek tutulabilir. Başvurularınızı store@vefayazilim.com adresine iletebilirsiniz.';
	@override String get kvkkIntro => '6698 sayılı Kanun uyarınca Vefa Yazılım tarafından işlenen kişisel verilerinize ilişkin aydınlatma metnidir.';
	@override String get kvkkS1Title => 'Veri sorumlusu ve iletişim';
	@override String get kvkkS1Body => 'AidatPanel kapsamındaki kişisel veri işleme faaliyetleri için veri sorumlusu Vefa Yazılım’dır. KVKK taleplerinizi store@vefayazilim.com adresine veya uygulamada kayıtlı e-posta adresinizle iletebilirsiniz.';
	@override String get kvkkS2Title => 'İşlenen veri kategorileri';
	@override String get kvkkS2Body => 'Kimlik ve iletişim, müşteri işlem (aidat, ödeme, gider), görsel kayıt (dekont), işlem güvenliği (log, token) ve pazarlama/iletişim (bildirim izni) kategorilerinde veri işlenebilir.';
	@override String get kvkkS3Title => 'İşleme amaçları ve hukuki sebepler';
	@override String get kvkkS3Body => 'Verileriniz; sözleşmenin kurulması ve ifası, hukuki yükümlülük, meşru menfaat ve açık rızanız (bildirimler gibi) kapsamında işlenir.';
	@override String get kvkkS4Title => 'Aktarım';
	@override String get kvkkS4Body => 'Veriler, yurt içinde barındırma ve teknik hizmet sağlayıcılarına, hizmetin gerektirdiği ölçüde aktarılabilir. Aktarım yapılan taraflarla gerekli güvenlik önlemleri alınır.';
	@override String get kvkkS5Title => 'Toplama yöntemi';
	@override String get kvkkS5Body => 'Veriler; uygulama formları, otomatik kayıtlar, yüklediğiniz belgeler ve bildirim altyapısı aracılığıyla elektronik ortamda toplanır.';
	@override String get kvkkS6Title => 'İlgili kişi hakları';
	@override String get kvkkS6Body => 'Kanunun 11. maddesi kapsamındaki haklarınızı kullanmak için talebinizi Vefa Yazılım’a (store@vefayazilim.com) iletebilirsiniz; başvurularınız mevzuattaki sürelerde yanıtlanır.';
	@override String get helpIntro => 'Yardım merkezi hazırlanıyor';
	@override String get helpBody => 'Sık sorulan sorular, adım adım rehberler ve destek kanalları yakında bu bölümde yer alacak. Uygulama desteği için: store@vefayazilim.com (Vefa Yazılım). Acil apartman işleri için yöneticiniz veya site yönetiminizle iletişime geçebilirsiniz.';
}

// Path: db_context
class _Translations$db_context$tr implements Translations$db_context$en {
	_Translations$db_context$tr._(this._root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get user_entry => 'Kayıt: {value}';
	@override String get building_name => 'Bina: {value}';
	@override String get apartment_label => 'Daire: {value}';
	@override String get code_value => 'Kod: {value}';
	@override String get expiry_date => 'Son kullanma: {value}';
}

// Path: common.api
class _Translations$common$api$tr implements Translations$common$api$en {
	_Translations$common$api$tr._(this._root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get networkError => 'İnternet bağlantınızı kontrol edip tekrar deneyin.';
	@override String get serverError => 'Sunucuya ulaşılamadı. Lütfen biraz sonra tekrar deneyin.';
	@override String get validationError => 'Girdiğiniz bilgileri kontrol edin.';
	@override String get notFound => 'İstenen kayıt bulunamadı.';
	@override String get unauthorized => 'Oturumunuz sona erdi. Lütfen tekrar giriş yapın.';
	@override String get rateLimit => 'Çok fazla deneme yaptınız. Lütfen kısa süre bekleyip tekrar deneyin.';
	@override String get forbidden => 'Bu işlem için yetkiniz yok.';
	@override String get genericError => 'İşlem tamamlanamadı. Lütfen tekrar deneyin.';
	@override String get invalidCredentials => 'E-posta, telefon veya şifre hatalı. Bilgilerinizi kontrol edip tekrar deneyin.';
	@override String get duplicateEmail => 'Bu e-posta adresi zaten kayıtlı. Giriş yapmayı deneyin.';
	@override String get duplicatePhone => 'Bu telefon numarası zaten kayıtlı.';
	@override String get invalidInviteCode => 'Davet kodu geçersiz. Kodu kontrol edip tekrar deneyin.';
	@override String get inviteCodeUsed => 'Bu davet kodu daha önce kullanılmış.';
	@override String get inviteCodeExpired => 'Davet kodunun süresi dolmuş. Yöneticinizden yeni kod isteyin.';
	@override String get resetTokenInvalid => 'Kod hatalı veya süresi dolmuş. Yeni kod isteyip tekrar deneyin.';
	@override String get recordConflict => 'Bu kayıt zaten mevcut.';
	@override String get relatedRecordMissing => 'İşlem için gerekli bağlı kayıt bulunamadı.';
	@override String get buildingAccessDenied => 'Bina bulunamadı veya bu binaya erişim yetkiniz yok.';
	@override String get invalidIban => 'IBAN geçersiz. TR ile başlayan 26 haneli IBAN girin.';
	@override String get apartmentNoResident => 'Bu dairede çıkarılacak sakin yok.';
	@override String get ticketClosedNote => 'Kapalı veya sonuçlanmış talebe not eklenemez.';
	@override String get ticketClosedStatus => 'Kapatılmış talebin durumu değiştirilemez.';
	@override String get ticketInvalidStatus => 'Bu durum geçişi yapılamıyor. Listeyi yenileyip tekrar deneyin.';
	@override String get serviceUnavailable => 'İşlem şu an yapılamıyor. Lütfen biraz sonra tekrar deneyin.';
	@override String get fileUploadError => 'Dosya yüklenemedi. Lütfen tekrar deneyin.';
	@override String get fileContentMismatch => 'Dosya türü ile içerik uyuşmuyor. Başka bir dosya seçin.';
	@override String get invalidPdf => 'PDF dosyası okunamadı veya bozuk. Başka bir dosya deneyin.';
	@override String get notificationNotFound => 'Bildirim bulunamadı.';
	@override String get invalidCursor => 'Liste yenilenemedi. Sayfayı yenileyip tekrar deneyin.';
	@override String get expenseNotFound => 'Gider kaydı bulunamadı.';
	@override String get dueNotFound => 'Aidat kaydı bulunamadı.';
	@override String get dekontNotFound => 'Dekont bulunamadı.';
	@override String get noApartmentForPayment => 'Ödeme bilgisi için önce bir daireye atanmanız gerekir.';
}

// Path: common.documentPreview
class _Translations$common$documentPreview$tr implements Translations$common$documentPreview$en {
	_Translations$common$documentPreview$tr._(this._root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Belge görüntüle';
	@override String get share => 'Paylaş';
	@override String get pdfUnavailable => 'PDF bu cihazda açılamadı. Paylaş ile başka bir uygulamada açabilirsiniz.';
	@override String get pinchHint => 'İki parmakla yakınlaştırıp kaydırın';
}

// Path: features.buildings
class _Translations$features$buildings$tr implements Translations$features$buildings$en {
	_Translations$features$buildings$tr._(this._root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get managerPanel => 'Yönetici';
	@override String get buildingDetail => 'Bina Detayı';
	@override String get addBuilding => 'Bina Ekle';
	@override String get newBuilding => 'Yeni Bina Ekle';
	@override String get inviteCode => 'Davet Kodu';
	@override String get createInviteCode => 'Davet Kodu Oluştur';
	@override String get cancelCode => 'Kodu İptal Et';
	@override String get apartmentOccupied => 'Daire Dolu';
	@override String get copy => 'Kopyala';
	@override String get share => 'Paylaş';
	@override String get anotherApartment => 'Başka Daire';
	@override String get codeRevoked => 'Kod iptal edildi';
	@override String get occupiedDialog => 'Yeni kod üretirsen eski kullanıcı çıkarılır. Emin misiniz?';
	@override String get revokeDialog => 'Mevcut kod geçersiz hale gelir. Emin misiniz?';
	@override String get produceAnyway => 'Yine de Üret';
	@override String get newCodePrefix => 'Yeni kod üretirsen ';
	@override String get oldUserRemoved => 'eski kullanıcı çıkarılır';
	@override String get currentCodePrefix => 'Mevcut kod ';
	@override String get codeInvalid => 'geçersiz hale gelir';
	@override String get codeReady => 'Davet Kodu Hazır';
	@override String get code => 'KOD';
	@override String get validFor7Days => '7 gün geçerli';
	@override String get expiresAt => 'Son kullanma:';
	@override String get remaining => 'Kalan:';
	@override String get activeCodeNote => 'Bu kod aktifken aynı daireye yeni kod üretilemez. Yeni kod için önce mevcut kodu iptal etmelisin.';
	@override String get backToMainMenu => 'Ana Menüye Dön';
	@override String get tekrarDene => 'Tekrar Dene';
	@override late final _Translations$features$buildings$collection$tr collection = _Translations$features$buildings$collection$tr._(_root);
	@override late final _Translations$features$buildings$list$tr list = _Translations$features$buildings$list$tr._(_root);
}

// Path: features.auth
class _Translations$features$auth$tr implements Translations$features$auth$en {
	_Translations$features$auth$tr._(this._root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get register => 'Kaydol';
	@override String get login => 'Giriş Yap';
	@override String get join => 'Katıl';
	@override String get passwordRequired => 'Şifre gerekli';
	@override String get errorOccurred => 'Bir hata oluştu';
	@override String get registrationSuccess => 'Hesabınız oluşturuldu. Giriş yapabilirsiniz.';
	@override String get loginSuccess => 'Giriş başarılı. Hoş geldiniz.';
	@override String get appTitle => 'AidatPanel';
	@override String get appSubtitle => 'Apartman Yönetim Sistemi';
	@override String get splashConnectionError => 'Sunucuya bağlanılamadı';
	@override String get splashConnectionHint => 'İnternet bağlantını kontrol edip tekrar dene.';
	@override String get skipToLogin => 'Giriş ekranına git';
	@override String get phone => 'Telefon';
	@override String get email => 'Email';
	@override String get phoneHint => '5XX XXX XX XX';
	@override String get emailHint => 'ornek@email.com';
	@override String get password => 'Şifre';
	@override String get passwordHint => '••••••••';
	@override String get emailLogin => 'Email ile Giriş Yap';
	@override String get phoneLogin => 'Telefon ile Giriş Yap';
	@override String get or => 'veya';
	@override String get noAccount => 'Hesabınız yok mu? Kaydolun';
	@override String get joinWithCode => 'Davet kodu ile katılın';
	@override String get signUp => 'Üye ol';
	@override String get signUpTitle => 'Üye Ol';
	@override String get signUpSubtitle => 'Nasıl katılmak istiyorsunuz?';
	@override String get beManager => 'Yönetici ol';
	@override String get beManagerHint => 'Bina oluşturup yönetici hesabı açın';
	@override String get joinWithInvite => 'Davet koduyla katıl';
	@override String get joinWithInviteHint => 'Yöneticinizin verdiği kod ile sakin olun';
	@override String get copyright => '© Vefa Yazılım';
	@override String get createAccount => 'Yeni Hesap Oluştur';
	@override String get name => 'Ad Soyad';
	@override String get nameHint => 'Örn: Furkan Kaya';
	@override String get phoneOptional => 'Telefon (Opsiyonel)';
	@override String get phoneHintOptional => '5XX XXX XXXX';
	@override String get minLength => 'En az 6 karakter';
	@override String get hasUpperCase => 'En az 1 büyük harf';
	@override String get hasLowerCase => 'En az 1 küçük harf';
	@override String get hasNumber => 'En az 1 rakam';
	@override String get hasSpecialChar => 'En az 1 özel karakter';
	@override String get confirmPassword => 'Şifre Tekrar';
	@override String get passwordsDoNotMatch => 'Şifreler eşleşmiyor';
	@override String get emailAndPasswordRequired => 'Email ve şifre boş bırakılamaz';
	@override String get hasAccount => 'Zaten hesabınız var mı? Giriş yapın';
	@override String get joinApartment => 'Apartmana Katıl';
	@override String get inviteCode => 'Davet Kodu';
	@override String get inviteCodeHint => 'AP3-B12-A9F0';
	@override String get invalidInviteCodeFormat => 'Geçersiz davet kodu formatı (Örn: AP3-B12-A9F0)';
	@override String get invalidPhoneFormat => 'Geçerli bir telefon numarası giriniz (5XX XXX XX XX)';
	@override String get inviteCodeAndPasswordRequired => 'Davet kodu, ad ve şifre boş bırakılamaz';
	@override String get invalidPhoneNumber => 'Geçerli bir telefon numarası giriniz';
	@override String get areYouManager => 'Yönetici misiniz? Kaydolun';
}

// Path: features.apartments
class _Translations$features$apartments$tr implements Translations$features$apartments$en {
	_Translations$features$apartments$tr._(this._root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get residentPanel => 'Sakin';
}

// Path: features.tickets
class _Translations$features$tickets$tr implements Translations$features$tickets$en {
	_Translations$features$tickets$tr._(this._root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get myTickets => 'Taleplerim';
	@override String get newTicket => 'Yeni Talep';
	@override String get createTitle => 'Arıza / Talep Bildir';
	@override String get fieldTitle => 'Başlık';
	@override String get fieldTitleHint => 'Örn: Asansör arızası';
	@override String get fieldDescription => 'Açıklama';
	@override String get fieldDescriptionHint => 'Sorunu kısaca anlatın';
	@override String get fieldCategory => 'Kategori';
	@override String get categoryComplaint => 'Şikayet';
	@override String get categoryRequest => 'Talep';
	@override String get categoryMalfunction => 'Arıza';
	@override String get categoryOther => 'Diğer';
	@override String get submit => 'Gönder';
	@override String get createSuccess => 'Talebiniz alındı';
	@override String get createFailed => 'Talep kaydedilemedi. Lütfen tekrar deneyin.';
	@override String get createServiceUnavailable => 'Talep servisi şu an hazır değil. Lütfen daha sonra tekrar deneyin.';
	@override String get emptyTitle => 'Henüz talep yok';
	@override String get emptySubtitle => 'Arıza veya talebinizi buradan bildirebilirsiniz';
	@override String get titleTooShort => 'Başlık en az 3 karakter olmalı';
	@override String get descriptionTooShort => 'Açıklama en az 10 karakter olmalı';
	@override String get statusOpen => 'Açık';
	@override String get statusInProgress => 'İşlemde';
	@override String get statusResolved => 'Çözüldü';
	@override String get statusClosed => 'Kapalı';
	@override String get statusTrackerTitle => 'TALEP DURUMU';
	@override String get statusStepWaiting => 'Bekliyor';
	@override String get statusStepInProgress => 'İşlemde';
	@override String get statusStepResolved => 'Çözüldü';
	@override String get statusStepClosed => 'Kapalı';
	@override String get statusHeadlineOpen => 'Talebiniz beklemede';
	@override String get statusHeadlineInProgress => 'Talebiniz işlemde';
	@override String get statusHeadlineResolved => 'Talebiniz çözüldü';
	@override String get statusHeadlineClosed => 'Talebiniz kapatıldı';
	@override String get detailTitle => 'Talep Detayı';
	@override String get managerTitle => 'Bina Talepleri';
	@override String get statusLabel => 'Durum';
	@override String get updatesTitle => 'Güncellemeler';
	@override String get changeStatus => 'Durum değiştir';
	@override String get managerNote => 'Yönetici notu';
	@override String get addNote => 'Not ekle';
	@override String get statusUpdated => 'Durum güncellendi';
	@override String get noteAdded => 'Not eklendi';
	@override String get loadError => 'Talepler yüklenemedi';
	@override String get noteDisabledClosed => 'Kapalı talebe not eklenemez';
	@override String get statusClosedHint => 'Bu talep kapatıldı; durum değiştirilemez.';
	@override String get apartmentRequired => 'Daire bilgisi bulunamadı. Lütfen tekrar giriş yapın.';
}

// Path: features.dekont
class _Translations$features$dekont$tr implements Translations$features$dekont$en {
	_Translations$features$dekont$tr._(this._root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get makePaymentTitle => 'Ödeme Yap';
	@override String get myDekontsTitle => 'Dekontlarım';
	@override String get managerTitle => 'Dekont İnceleme';
	@override String get reviewAction => 'Dekont İncele';
	@override String get detailTitle => 'Dekont Detayı';
	@override String get paymentInfoTitle => 'Havale bilgileri';
	@override String get collectionNotConfigured => 'Yöneticiniz henüz tahsilat IBAN bilgisini tanımlamadı. Yine de dekont yükleyebilirsiniz.';
	@override String get ibanLabel => 'IBAN';
	@override String get accountTitleLabel => 'Alıcı unvanı';
	@override String get referenceLabel => 'Havale açıklaması';
	@override String get copy => 'Kopyala';
	@override String get copied => 'Panoya kopyalandı';
	@override String get selectDue => 'Aidat seçin';
	@override String get selectDueHint => 'Ödeme yaptığınız aidatı seçin';
	@override String get noPendingDues => 'Bekleyen aidat bulunmuyor';
	@override String get uploadSectionTitle => 'Dekont yükle';
	@override String get uploadHint => 'PDF belgesi veya fotoğraf (JPEG, PNG) (Maks. 10 MB)';
	@override String get pickFile => 'Dosya seç';
	@override String get upload => 'Dekontu yükle';
	@override String get uploadSuccess => 'Dekont yüklendi';
	@override String get uploadRecoveredExisting => 'Bu dekont zaten kayıtlı; mevcut kaydınız açıldı.';
	@override String get uploadFailed => 'Dekont yüklenemedi';
	@override String get errorUploadDuplicate => 'Bu dekontu daha önce yüklemişsiniz. Dekontlarım bölümünden kontrol edebilirsiniz.';
	@override String get errorUploadRateLimit => 'Kısa sürede çok fazla dekont yüklediniz. Lütfen bir süre bekleyin.';
	@override String get errorUploadServer => 'Dekont sunucuya kaydedilemedi. Lütfen biraz sonra tekrar deneyin.';
	@override String get errorUploadFileRequired => 'Lütfen bir dosya seçin.';
	@override String get errorPaymentInfo => 'Havale bilgileri alınamadı. Lütfen tekrar deneyin.';
	@override String get errorListLoad => 'Dekont listesi yüklenemedi. Lütfen tekrar deneyin.';
	@override String get errorDetailLoad => 'Dekont detayı yüklenemedi. Lütfen tekrar deneyin.';
	@override String get errorFileDownload => 'Dekont dosyası açılamadı. Lütfen tekrar deneyin.';
	@override String get errorReviewPaymentDone => 'Bu dekont için ödeme zaten işlenmiş.';
	@override String get errorReviewRejected => 'Reddedilmiş bir dekont tekrar onaylanamaz.';
	@override String get errorReviewNeedDue => 'Onaylamak için bir aidat seçmelisiniz.';
	@override String get errorReviewStatus => 'Bu dekont şu an onaylanamaz veya reddedilemez. Biraz sonra tekrar deneyin.';
	@override String get errorNoFileSelected => 'Lütfen önce bir dekont dosyası seçin.';
	@override String get fileTooLarge => 'Dosya en fazla 10 MB olabilir';
	@override String get fileEmpty => 'Seçilen dosya boş';
	@override String get fileNotFound => 'Dosya bulunamadı';
	@override String get invalidExtension => 'Yalnızca PDF, JPEG veya PNG yükleyebilirsiniz';
	@override String get processing => 'Dekont işleniyor…';
	@override String get viewDekonts => 'Dekontlarım';
	@override String get breakdownDetails => 'Detaylar';
	@override String get breakdownBaseDue => 'Baz aidat';
	@override String get breakdownTotal => 'Toplam';
	@override String get emptyTitle => 'Henüz dekont yok';
	@override String get emptySubtitleResident => 'Henüz bir dekontunuz bulunmuyor. Yeni dekont eklemek için sağ üst köşedeki yükleme butonunu kullanabilirsiniz.';
	@override String get emptySubtitleManager => 'Kullanıcılar tarafından yüklenmiş herhangi bir dekont bulunmamaktadır.';
	@override String get filterAll => 'Tümü';
	@override String get filterPending => 'İncelemede';
	@override String get filterApproved => 'Onaylandı';
	@override String get filterRejected => 'Reddedildi';
	@override String get statusReceived => 'Alındı';
	@override String get statusExtracting => 'Okunuyor';
	@override String get statusExtractFailed => 'Okunamadı';
	@override String get statusParsed => 'Okundu';
	@override String get statusParseLowConfidence => 'Düşük güven';
	@override String get statusMatching => 'Eşleştiriliyor';
	@override String get statusMatched => 'Eşleşti';
	@override String get statusMatchAmbiguous => 'Belirsiz eşleşme';
	@override String get statusUnmatched => 'Eşleşmedi';
	@override String get statusPaymentApplied => 'Ödeme uygulandı';
	@override String get statusPaymentPartial => 'Kısmi ödeme';
	@override String get statusRejected => 'Reddedildi';
	@override String get statusRecipientMismatch => 'Alıcı uyuşmuyor';
	@override String get statusNeedsManagerReview => 'Yönetici incelemesi';
	@override String get reupload => 'Yeniden yükle';
	@override String get rejectionReason => 'Red nedeni';
	@override String get parsedAmount => 'Okunan tutar';
	@override String get paymentDetailsSection => 'Ödeme bilgileri';
	@override String get fileSection => 'Dosya';
	@override String get filePreview => 'Dosya önizleme';
	@override String get pdfPreviewHint => 'İki parmakla yakınlaştırıp kaydırabilirsiniz.';
	@override String get pdfPreviewUnavailable => 'PDF bu cihazda açılamadı. Aşağıdaki «Dosyayı paylaş» ile başka bir uygulamada açabilirsiniz.';
	@override String get shareFile => 'Dosyayı paylaş';
	@override String get approve => 'Onayla';
	@override String get reject => 'Reddet';
	@override String get reviewNote => 'Not (opsiyonel)';
	@override String get reviewSuccess => 'İnceleme kaydedildi';
	@override String get reviewFailed => 'İnceleme kaydedilemedi';
	@override String get selectDueForApprove => 'Onay için aidat seçin';
	@override String get uploadedBy => 'Yükleyen';
	@override String get apartment => 'Daire';
	@override String get amount => 'Tutar';
	@override String get loadError => 'Dekontlar yüklenemedi';
	@override String get systemInfoTitle => 'Sistem bilgileri';
	@override String get systemInfoSubtitle => 'Dekontunuzdan okuduğumuz bilgiler aşağıdadır. Ödeme otomatik onaylanmaz; yönetici hesabını kontrol ederek onaylar.';
	@override String get systemReadLabel => 'Dekonttan okunanlar';
	@override String get systemInfoProcessing => 'Dekontunuz işleniyor. Okunan tutar, tarih ve banka bilgileri birkaç dakika içinde burada görünecek.';
	@override String get systemInfoNoData => 'Okunan bilgi';
	@override String get systemInfoNoDataHint => 'Dekonttan henüz tutar veya tarih okunamadı. Yine de yönetici onayına sunulacaktır.';
	@override String get transactionDateLabel => 'İşlem tarihi';
	@override String get bankLabel => 'Banka';
	@override String get receiverIbanLabel => 'Alıcı IBAN';
	@override String get receiverNameLabel => 'Alıcı unvanı';
	@override String get referenceNumberLabel => 'Referans no';
	@override String get ibanUnreadableNotice => 'Yüklediğiniz aidat ödeme dekontunda alıcı IBAN bilgisi okunamamıştır. Bu haliyle yönetici onayına sunulacaktır.';
	@override String get ibanMismatchNotice => 'Dekonttaki alıcı IBAN, binanızın tahsilat hesabıyla eşleşmiyor. Yönetici hesabını kontrol ederek karar verecektir.';
	@override String get ibanVerifiedNotice => 'Alıcı IBAN, binanızın tahsilat hesabıyla eşleşiyor. Yine de ödeme yönetici onayı olmadan işlenmez.';
	@override String get residentPendingReviewNotice => 'Dekontunuz yönetici onayına sunuldu. Ödeme otomatik onaylanmaz; yöneticiniz hesabını kontrol ederek onaylayacaktır.';
	@override String get managerApprovalHint => 'Hesabınıza gelen tutarı kontrol ederek onaylayın veya gerekirse reddedin.';
	@override String get managerPaymentSummary => '{resident}, {date} tarihinde {bank} aracılığıyla {amount} aidat gönderdi. Hesabınızı kontrol ederek onaylayınız.';
	@override String get residentWithApartment => '{name} (Daire {apartment})';
	@override String get apartmentOnly => 'Daire {apartment}';
	@override String get residentUnknown => 'Sakin';
	@override String get amountUnknown => 'belirtilen tutarda';
	@override String get receiptPhotoTitle => 'Dekont görüntüsü';
	@override String get receiptPhotoHint => 'Önce yukarıdaki sistem bilgilerini inceleyin. Dekont dosyasını istediğiniz zaman açabilirsiniz.';
	@override String get viewDekont => 'Dekontu görüntüle';
	@override String get bankKuveytTurk => 'Kuveyt Türk';
	@override String get bankZiraat => 'Ziraat Bankası';
	@override String get bankIsbank => 'İş Bankası';
	@override String get bankGaranti => 'Garanti BBVA';
	@override String get bankHalkbank => 'Halkbank';
	@override String get bankVakifbank => 'VakıfBank';
	@override String get bankYapiKredi => 'Yapı Kredi';
	@override String get bankAkbank => 'Akbank';
	@override String get bankQnb => 'QNB Finansbank';
	@override String get bankGeneric => 'Banka (genel)';
	@override String get bankUnknown => 'Banka bilgisi okunamadı';
}

// Path: features.expenses
class _Translations$features$expenses$tr implements Translations$features$expenses$en {
	_Translations$features$expenses$tr._(this._root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Giderler';
	@override String get createTitle => 'Gider Ekle';
	@override String get fieldTitle => 'Başlık';
	@override String get fieldAmount => 'Tutar (₺)';
	@override String get fieldCategory => 'Kategori';
	@override String get fieldNote => 'Not (opsiyonel)';
	@override String get submit => 'Kaydet';
	@override String get required => 'Zorunlu alan';
	@override String get amountInvalid => 'Geçerli tutar girin';
	@override String get amountFromReceiptsHint => 'Tutar makbuzlardan otomatik okunur.';
	@override String get receiptRequired => 'En az bir makbuz fotoğrafı ekleyin';
	@override String get amountOcrPending => 'Makbuz tutarları okunuyor. Birkaç saniye sonra listede görünür.';
	@override String get total => 'Toplam';
	@override String get createSuccess => 'Gider kaydedildi';
	@override String get categoryCleaning => 'Temizlik';
	@override String get categoryElevator => 'Asansör';
	@override String get categoryElectricity => 'Elektrik';
	@override String get categoryWater => 'Su';
	@override String get categoryInsurance => 'Sigorta';
	@override String get categoryRepair => 'Onarım';
	@override String get categoryGarden => 'Bahçe';
	@override String get categoryOther => 'Diğer';
	@override String get fieldDate => 'Gider tarihi';
	@override String get fieldDateHint => 'Makbuz veya fatura üzerindeki tarih';
	@override String get fieldMonth => 'Ay';
	@override String get fieldYear => 'Yıl';
	@override String get editTitle => 'Gideri Düzenle';
	@override String get editAction => 'Düzenle';
	@override String get deleteTitle => 'Gideri sil';
	@override String get deleteAction => 'Sil';
	@override String get deleteConfirm => 'Bu gider kaydını silmek istediğinize emin misiniz?';
	@override String get deleteSuccess => 'Gider silindi';
	@override String get updateSuccess => 'Gider güncellendi';
	@override String get loadError => 'Giderler yüklenemedi';
	@override String get emptyTitle => 'Bu dönemde gider yok';
	@override String get emptySubtitle => 'Sağ üstten yeni gider ekleyebilirsiniz';
	@override String get receiptUrlLabel => 'Makbuz bağlantısı (HTTPS)';
	@override String get receiptUrlHint => 'Opsiyonel — internetteki makbuz dosyası adresi';
	@override String get receiptUrlInvalid => 'Adres https:// ile başlamalıdır';
	@override String get receiptTitle => 'Makbuz fotoğrafı';
	@override String get receiptHint => 'PDF veya fotoğraf (JPEG, PNG). Tutar makbuzlardan otomatik okunur (Maks. 10 MB)';
	@override String get receiptAdd => 'Fotoğraf ekle';
	@override String get receiptChange => 'Fotoğrafı değiştir';
	@override String get receiptRemove => 'Fotoğrafı kaldır';
	@override String get receiptPendingBackend => 'Gider kaydedildi. Makbuz sunucuya yüklenecek (API hazır olunca).';
	@override String get receiptUploadFailed => 'Makbuz yüklenemedi. Gider kaydı oluşturuldu.';
	@override String get receiptPickFailed => 'Fotoğraf seçilemedi';
	@override String get detailTitle => 'Gider Detayı';
	@override String get fieldCreatedAt => 'Eklenme zamanı';
	@override String get viewReceipt => 'Makbuzu gör';
	@override String get receiptMissing => 'Makbuz yüklenmemiş';
	@override String get targetMonthLabel => 'Aidata yansıyacağı ay';
	@override String get targetThisMonth => 'Bu ay';
	@override String get targetNextMonth => 'Sonraki ay';
	@override String get targetSpecificMonth => 'Belirli ay';
	@override String get targetPeriodSummary => '{month} {year} aidatına yansır';
	@override String get pastMonthWarning => 'Geçmiş aya gider eklendiğinde aidat tutarları güncellenir.';
	@override String get splitMonthsEnable => 'Birden fazla aya böl';
	@override String get splitMonthsHint => 'Toplam tutar seçilen aylara eşit dağıtılır';
	@override String get splitMonthsCount => 'Ay sayısı';
	@override String get splitMonthsUnit => 'ay';
	@override String get carryForwardDialogTitle => 'Ödenmiş aidatlar';
	@override String get carryForwardAuto => 'Farkı sonraki aya ekle';
	@override String get carryForwardManual => 'Manuel halledeceğim';
}

// Path: features.notifications
class _Translations$features$notifications$tr implements Translations$features$notifications$en {
	_Translations$features$notifications$tr._(this._root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get markAllRead => 'Tümünü oku';
	@override String get markAllReadLong => 'Tümünü okundu işaretle';
	@override String get viewRelated => 'İlgili kayda git';
	@override String get unreadBadge => 'Yeni';
	@override String get emptyTitle => 'Bildirim yok';
	@override String get emptySubtitle => 'Yeni bildirimler burada görünecek';
	@override String get emptyUnreadTitle => 'Okunmamış bildirim yok';
	@override String get emptyUnreadSubtitle => 'Tüm bildirimleri okudunuz';
	@override String get loadError => 'Bildirimler yüklenemedi';
	@override String get filterAll => 'Tümü';
	@override String get filterUnread => 'Okunmamış';
	@override String get sectionToday => 'Bugün';
	@override String get sectionYesterday => 'Dün';
	@override String get sectionThisWeek => 'Bu hafta';
	@override String get sectionEarlier => 'Daha eski';
	@override String get timeNow => 'Az önce';
	@override String get timeMinuteShort => 'dk önce';
	@override String get timeHourShort => 'saat önce';
	@override String get detailLoadError => 'Detay yüklenemedi';
	@override String get fieldStatus => 'Durum';
	@override String get fieldCategory => 'Kategori';
	@override String get fieldApartment => 'Daire';
	@override String get fieldAmount => 'Tutar';
	@override String get fieldUploadedBy => 'Yükleyen';
	@override String get fieldDescription => 'Açıklama';
	@override String get fieldManagerNote => 'Yönetici notu';
	@override String get fieldRejectionReason => 'Red nedeni';
	@override String get fieldLatestUpdate => 'Son güncelleme';
	@override String get fieldCreatedAt => 'Oluşturulma';
	@override String get fieldPeriod => 'Dönem';
	@override String get actionViewTicket => 'Talebi Görüntüle';
	@override String get actionViewDekont => 'Dekontu İncele';
	@override String get actionViewDue => 'Aidatı Gör';
	@override String get typeDueReminder => 'Aidat hatırlatma';
	@override String get typeDuePaid => 'Aidat ödendi';
	@override String get typeTicketCreated => 'Yeni talep';
	@override String get typeTicketUpdate => 'Talep güncellendi';
	@override String get typeAnnouncement => 'Duyuru';
	@override String get typeDekontReceived => 'Yeni dekont';
	@override String get typeDekontNeedsReview => 'Dekont inceleme';
	@override String get typeDekontMatched => 'Dekont eşleşti';
	@override String get typeDekontPaymentApplied => 'Dekont onaylandı';
	@override String get typeExpenseAdded => 'Yeni gider';
	@override String get typeSystem => 'Sistem';
	@override String get typeOther => 'Bildirim';
	@override String get sendTitle => 'Sakinlere Duyuru';
	@override String get fieldTitle => 'Başlık';
	@override String get fieldBody => 'Mesaj';
	@override String get sendButton => 'Gönder';
	@override String get sendSuccess => 'Duyuru gönderildi';
	@override String get sendFailed => 'Duyuru gönderilemedi';
	@override String get fieldRequired => 'Zorunlu alan';
	@override String get titleTooLong => 'Başlık en fazla 120 karakter olabilir';
	@override String get bodyTooLong => 'Mesaj en fazla 2000 karakter olabilir';
	@override String get noBuilding => 'Önce bir bina ekleyin';
}

// Path: features.profile
class _Translations$features$profile$tr implements Translations$features$profile$en {
	_Translations$features$profile$tr._(this._root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Profil Bilgileri';
	@override String get fullName => 'Ad Soyad';
	@override String get email => 'E-posta';
	@override String get phone => 'Telefon';
	@override String get role => 'Rol';
	@override String get languagePref => 'Dil tercihi';
	@override String get notProvided => 'Belirtilmemiş';
	@override String get editHint => 'Profil düzenleme yakında eklenecek.';
	@override String get sectionPersonal => 'Kişisel Bilgiler';
	@override String get sectionAccount => 'Hesap Bilgileri';
	@override String get editPhotoHint => 'Fotoğrafı değiştirmek için dokunun';
	@override String get editTitle => 'Profili Düzenle';
	@override String get phoneOptionalHint => 'Boş bırakılabilir';
	@override String get profileUpdated => 'Profil bilgileriniz güncellendi.';
	@override String get profileUpdateFailed => 'Profil güncellenemedi. Lütfen tekrar deneyin.';
	@override String get profileLoadFailed => 'Profil bilgileri yüklenemedi.';
	@override String get readOnlySection => 'Buradan düzenlenemez';
	@override String get editSheetHint => 'Yalnızca ad ve telefon güncellenir. Diğer bilgiler yukarıdaki profil ekranında görünür.';
	@override String get photoSaved => 'Profil fotoğrafı bu hesap için kaydedildi.';
	@override String get photoRemoved => 'Profil fotoğrafı kaldırıldı.';
	@override String get removePhoto => 'Profil fotoğrafını kaldır';
	@override String get accountCreatedAt => 'Hesap oluşturulma: {date}';
}

// Path: features.subscription
class _Translations$features$subscription$tr implements Translations$features$subscription$en {
	_Translations$features$subscription$tr._(this._root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Abonelik';
	@override String get statusActive => 'Aktif';
	@override String get statusExpired => 'Süresi doldu';
	@override String get statusCancelled => 'İptal edildi';
	@override String get statusTrial => 'Deneme';
	@override String get statusUnknown => 'Bilinmiyor';
	@override String get planMonthly => 'Aylık plan';
	@override String get planAnnual => 'Yıllık plan';
	@override String get planUnknown => 'Plan';
	@override String get renewsOn => 'Yenileme: {date}';
	@override String get noSubscription => 'Henüz abonelik kaydı yok.';
	@override String get backendPending => 'Abonelik sunucuya henüz bağlanmadı. Satın alma yakında açılacak.';
	@override String get purchaseComingSoon => 'Satın alma yakında';
	@override String get purchaseMonthly => 'Aylık abone ol';
	@override String get purchaseAnnual => 'Yıllık abone ol';
	@override String get purchaseSuccess => 'Satın alma tamamlandı. Abonelik birkaç dakika içinde güncellenir.';
	@override String get purchaseCancelled => 'Satın alma iptal edildi.';
	@override String get purchasesUnavailable => 'Satın alma bu sürümde henüz etkin değil.';
	@override String get loadFailed => 'Abonelik bilgisi alınamadı.';
	@override String get purchaseProductNotFound => 'Abonelik ürünü bulunamadı. Uygulamayı Play Store test linkinden yükleyin ve birkaç saat bekleyin.';
	@override String get purchaseStoreError => 'Google Play ödeme şu an kullanılamıyor. Test hesabınızı kontrol edin.';
	@override String get purchaseFailed => 'Satın alma tamamlanamadı. Lütfen tekrar deneyin.';
	@override String get sectionSelectPlan => 'Plan seç ve satın al';
	@override String get cycleMonthly => 'Her ay yenilenir';
	@override String get cycleAnnual => 'Her yıl yenilenir';
	@override String get featureUnlimitedUnits => 'Sınırsız daire';
	@override String get featureDuesTracking => 'Aidat takibi';
	@override String get featureAdvancedReports => 'Gelişmiş raporlar';
	@override String get featurePrioritySupport => 'Öncelikli destek';
	@override String get trialActive => 'Deneme süresi aktif';
	@override String get subscriptionActive => 'Abonelik aktif';
	@override String get subscriptionCancelled => 'Abonelik iptal edildi';
	@override String get subscriptionExpired => 'Abonelik süresi doldu';
	@override String get noActiveSubscription => 'Aktif abonelik yok';
	@override String get daysLeft => '{count} gün kaldı';
	@override String get planLabel => 'PLAN';
	@override String get statusLabel => 'DURUM';
	@override String get renewalLabel => 'YENİLEME';
	@override String get planAnnualShort => 'Yıllık';
	@override String get planMonthlyShort => 'Aylık';
	@override String get priceExclVatMonth => 'KDV hariç / ay';
	@override String get priceExclVatYear => 'KDV hariç / yıl';
	@override String get savingBadge => '{amount} tasarruf';
	@override String get bestValueBadge => 'En avantajlı';
	@override String get purchaseMonthlyCta => 'Aylık aboneliği satın al';
	@override String get purchaseAnnualCta => 'Yıllık aboneliği satın al';
	@override String get kdvNote => 'Fiyatlara KDV dahil değildir · İstediğin zaman iptal edebilirsin';
	@override String get guestUser => 'Kullanıcı';
	@override String get priceUnavailable => '—';
	@override String get loadingPlans => 'Planlar yükleniyor…';
	@override String get purchasesDisabledHint => 'Satın alma bu sürümde henüz etkin değil.';
}

// Path: features.reports
class _Translations$features$reports$tr implements Translations$features$reports$en {
	_Translations$features$reports$tr._(this._root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get menuDownload => 'Rapor indir';
	@override String get sheetTitle => 'PDF rapor';
	@override String get reportTypeLabel => 'Rapor türü';
	@override String get typeMonthly => 'Aylık özet';
	@override String get typeAnnual => 'Yıllık özet';
	@override String get periodHintMonthly => '{month} {year} dönemi için rapor';
	@override String get periodHintAnnual => '{year} yılı için yıllık rapor';
	@override String get fieldMonth => 'Ay';
	@override String get fieldYear => 'Yıl';
	@override String get selectMonthTitle => 'Ay seçin';
	@override String get selectYearTitle => 'Yıl seçin';
	@override String get download => 'Raporu göster';
	@override String get downloading => 'Rapor hazırlanıyor…';
	@override String get previewTitle => 'Rapor önizleme';
	@override String get pdfPreviewHint => 'İki parmakla yakınlaştırıp kaydırabilirsiniz.';
	@override String get pdfPreviewUnavailable => 'PDF bu cihazda açılamadı. Alttaki «Raporu paylaş» ile başka bir uygulamada açabilirsiniz.';
	@override String get shareReport => 'Raporu paylaş';
	@override String get shareFailed => 'Rapor paylaşılamadı. Lütfen tekrar deneyin.';
	@override String get failed => 'Rapor oluşturulamadı. Lütfen tekrar deneyin.';
}

// Path: features.dashboard
class _Translations$features$dashboard$tr implements Translations$features$dashboard$en {
	_Translations$features$dashboard$tr._(this._root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get allBuildings => 'Tüm Binalar';
	@override String get selectBuilding => 'Bina seç';
	@override String get searchBuildings => 'Bina adı veya adres ara';
	@override String get buildingPickerTapHint => 'Dokunarak bina arayın ve seçin';
	@override String get allBuildingsSummary => '{count} bina';
	@override String get buildingUnitsSummary => '{apartments} daire';
	@override String get collectionRate => 'Tahsilat Oranı';
	@override String get overduePayments => 'Geciken Ödeme';
	@override String get openTicketRequests => 'Açık Arıza Talebi';
	@override String get monthTotalExpense => 'Bu Ay Toplam Gider';
	@override String get pendingDekonts => 'Bekleyen Dekont';
	@override String get duesCollectionStatus => 'Aidat Tahsilat Durumu';
	@override String get incomeExpenseComparison => 'Gelir / Gider Karşılaştırması';
	@override String get last6Months => 'Son 6 Ay';
	@override String get collectedDues => 'Toplanan Aidat';
	@override String get totalExpense => 'Toplam Gider';
	@override String get ticketStatusTitle => 'Arıza Talepleri Durumu';
	@override String get ticketOpen => 'Açık';
	@override String get ticketInProgress => 'İşlemde';
	@override String get ticketResolved => 'Çözüldü';
	@override String get overdueApartments => 'Ödemesi Geciken Daireler';
	@override String get apartmentCountBadge => '{count} daire';
	@override String get legendPaid => 'Ödendi';
	@override String get legendOverdue => 'Gecikmiş';
	@override String get legendPending => 'Bekliyor';
	@override String get legendUnit => '{count} aidat';
	@override String get remind => 'Hatırlat';
	@override String get remindSent => 'Hatırlatma gönderildi';
	@override String get remindNoRecipient => 'Bu dairede hatırlatma gönderilecek sakin bulunamadı.';
	@override String get apartmentTitle => 'Daire {number}';
	@override String get apartmentWithFloor => 'Daire {number} · {floor}. Kat';
	@override String get noOverdueApartments => 'Geciken ödeme bulunmuyor';
	@override String get noChartData => 'Henüz yeterli veri yok';
	@override String get seeMoreOverdue => 'Daha fazlası (+{count})';
	@override String get payNow => 'Şimdi Öde';
	@override String get overduePaymentsBadge => '{count} gecikmiş ödeme';
	@override String get featuredDuePeriod => '{month} {year} aidatı';
}

// Path: features.faz2
class _Translations$features$faz2$tr implements Translations$features$faz2$en {
	_Translations$features$faz2$tr._(this._root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get sectionTitle => 'Faz 2';
	@override String get tickets => 'Talepler';
	@override String get expenses => 'Giderler';
	@override String get announcement => 'Duyuru';
}

// Path: features.buildings.collection
class _Translations$features$buildings$collection$tr implements Translations$features$buildings$collection$en {
	_Translations$features$buildings$collection$tr._(this._root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get sectionTitle => 'Tahsilat bilgileri';
	@override String get sectionHint => 'Sakinlerin havale yapacağı IBAN. Boş bırakılabilir; sonradan da ekleyebilirsiniz.';
	@override String get modeSaved => 'Kayıtlı IBAN';
	@override String get modeNew => 'Yeni IBAN';
	@override String get savedListTitle => 'Daha önce kullandıklarınız';
	@override String get savedListSectionLabel => 'Kayıtlı IBAN\'lar';
	@override String get pickSavedIban => 'Kayıtlı IBAN seçin';
	@override String get changeSavedIban => 'Başka IBAN seçmek için dokunun';
	@override String get searchSavedIban => 'IBAN veya unvan ara';
	@override String get detailAccountHolder => 'Hesap sahibi';
	@override String get detailReference => 'Havale açıklaması';
	@override String get detailReferenceAuto => 'Havale açıklamasına daire numarası otomatik eklenir';
	@override String get detailReferenceDaireOnly => 'Havale açıklaması: Daire numarası';
	@override String get detailReferenceDaireAidat => 'Havale açıklaması: Daire no + aidat';
	@override String get detailReferenceAidat => 'Havale açıklaması: Aidat (daire no otomatik)';
	@override String get detailReferenceHavale => 'Havale açıklaması: Daire numarası ile havale';
	@override String get detailUsedInBuildings => '{count} binada kullanılıyor';
	@override String get ibanLabel => 'IBAN';
	@override String get ibanHint => 'TR33 0006 1005 1978 6457 8413 26';
	@override String get ibanInvalid => 'Geçerli bir Türkiye IBAN girin (TR + 24 rakam)';
	@override String get ibanRequiredIfOtherFilled => 'Alıcı veya açıklama girdiniz; geçerli IBAN girin';
	@override String get accountTitleLabel => 'Hesap sahibi / alıcı unvanı';
	@override String get accountTitleHint => 'Örn: Site Yönetimi';
	@override String get referenceTemplateLabel => 'Havale açıklama şablonu';
	@override String get referenceTemplateHint => 'Örn: Daire {{number}}';
	@override String get presetsEmpty => 'Henüz kayıtlı tahsilat bilgisi yok';
	@override String get presetsLoadFailed => 'Öneriler yüklenemedi';
	@override String get presetBuildingCount => '{count} bina';
	@override String get menuEdit => 'Tahsilat / IBAN';
	@override String get editSheetTitle => 'Tahsilat bilgileri';
	@override String get saveSuccess => 'Tahsilat bilgileri kaydedildi';
	@override String get savedIbansTitle => 'Kayıtlı IBAN\'larım';
	@override String get savedIbansEmpty => 'Henüz kayıtlı IBAN yok. Bina eklerken tahsilat bilgisi tanımlayabilirsiniz.';
	@override String get savedIbansNoBuildingMatch => 'Bu sete bağlı bina bulunamadı';
	@override String get savedIbansBuildingNames => 'Binalar: {names}';
	@override String get savedIbansUpdateSuccess => '{count} bina için tahsilat bilgisi güncellendi';
	@override String get savedIbansUpdateHint => 'Güncellenecek binalar: {names}';
	@override String get editSavedIbanTitle => 'IBAN düzenle';
	@override String get savedIbansOrphanHint => 'Henüz bir binaya atanmamış kayıtlı set. Değişiklik yalnızca bu listede saklanır.';
	@override String get savedIbansAddTitle => 'Yeni IBAN ekle';
	@override String get savedIbansAddHint => 'Bu bilgileri bina eklerken veya tahsilat ayarlarında kullanabilirsiniz.';
	@override String get savedIbansAddSuccess => 'IBAN kaydedildi';
	@override String get savedIbansSelectMode => 'Çoklu seç';
	@override String get savedIbansSelectedLabel => 'seçili';
	@override String get savedIbansDeleteSelected => 'Seçilenleri sil';
	@override String get savedIbansPickFirst => 'Önce silmek istediğiniz IBAN\'ları seçin';
	@override String get savedIbansDeleteTitle => 'IBAN silinsin mi?';
	@override String get savedIbansDeleteMessage => 'Bu kayıtlı IBAN listeden kaldırılacak.';
	@override String get savedIbansDeleteBulkTitle => 'Seçilen IBAN\'lar silinsin mi?';
	@override String get savedIbansDeleteBulkMessage => '{count} kayıtlı IBAN silinecek.';
	@override String get savedIbansDeleteBuildingWarning => '{count} binanın tahsilat bilgisi de temizlenecek.';
	@override String get savedIbansDeleteSuccess => 'IBAN silindi';
	@override String get savedIbansDeleteBulkSuccess => '{count} IBAN silindi';
	@override String get ibanNotConfigured => 'Tahsilat IBAN tanımlı değil';
	@override String get ibanAlreadyExists => 'Bu IBAN numarası zaten sistemde kayıtlı. Lütfen farklı bir IBAN kontrol edip tekrar deneyiniz.';
}

// Path: features.buildings.list
class _Translations$features$buildings$list$tr implements Translations$features$buildings$list$en {
	_Translations$features$buildings$list$tr._(this._root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get buildingCount => 'Bina';
	@override String get unitCount => 'Daire';
	@override String get overdueShort => 'Geciken';
	@override String get collectionShort => 'Tahsilat';
	@override String get sort => 'Sırala';
	@override String get sortByOverdue => 'Gecikmişe Göre';
	@override String get sortByCollectionRate => 'Tahsilat Oranına Göre';
	@override String get sortByName => 'İsme Göre';
	@override String get paidUnitsProgress => '{paid} / {total} daire ödedi';
	@override String get perUnitDues => '{amount} / daire';
	@override String get unitsOverdue => '{count} daire gecikmiş';
	@override String get unitsWaiting => '{count} daire bekliyor';
	@override String get allPaymentsComplete => 'Tüm ödemeler tamam';
	@override String get monthlyDuesShort => 'Aylık Aidat';
}

/// The flat map containing all translations for locale <tr>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsTr {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'common.logout' => 'Çıkış Yap',
			'common.cancel' => 'İptal',
			'common.confirm' => 'Onayla',
			'common.ok' => 'Tamam',
			'common.save' => 'Kaydet',
			'common.delete' => 'Sil',
			'common.edit' => 'Düzenle',
			'common.close' => 'Kapat',
			'common.yes' => 'Evet',
			'common.no' => 'Hayır',
			'common.register' => 'Kaydol',
			'common.login' => 'Giriş Yap',
			'common.join' => 'Katıl',
			'common.confirmMessage' => 'Emin misiniz?',
			'common.logoutConfirm' => 'Çıkış yapmak istediğinize emin misiniz?',
			'common.logoutSuccess' => 'Başarıyla çıkış yaptınız.',
			'common.logoutAllDevices' => 'Diğer cihazlardan çıkış',
			'common.logoutAllDevicesConfirm' => 'Diğer telefon ve tabletlerdeki oturumlar kapanır. Bu cihazda girişiniz devam eder.',
			'common.logoutAllDevicesSuccess' => 'Diğer cihazlardaki oturumlar kapatıldı.',
			'common.logoutAllDevicesFailed' => 'İşlem tamamlanamadı. Lütfen tekrar deneyin.',
			'common.sessionExpired' => 'Bu cihazdaki oturumunuz başka bir cihazdan sonlandırıldı.',
			'common.account' => 'Hesap',
			'common.editProfile' => 'Profili Düzenle',
			'common.changePassword' => 'Şifre Değiştir',
			'common.language' => 'Dil',
			'common.turkish' => 'Türkçe',
			'common.notifications' => 'Bildirimler',
			'common.info' => 'Bilgi',
			'common.privacyPolicy' => 'Gizlilik Politikası',
			'common.kvkk' => 'KVKK',
			'common.helpSupport' => 'Yardım ve Destek',
			'common.about' => 'Hakkında',
			'common.comingSoon' => 'Bu özellik yakında eklenecek',
			'common.multiLanguageComingSoon' => 'Çoklu dil desteği yakında eklenecek',
			'common.copyright' => ' 2026 AidatPanel\nTüm hakları saklıdır.',
			'common.aboutDescription' => 'Türk apartman ve site yöneticileri için aidat yönetim platformu.',
			'common.manager' => 'Yönetici',
			'common.resident' => 'Sakin',
			'common.tokenExpiryTest' => 'Token Süresi Kontrol (Test)',
			'common.tokenExpired' => 'Token süresi DOLMUŞ! Login ekranına atılıyorsunuz.',
			'common.tokenActive' => 'Token aktif! Kalan süre',
			'common.pressBackAgainToExit' => 'Çıkmak için geri tuşuna tekrar basın',
			'common.loading' => 'Yükleniyor…',
			'common.loadingBuildings' => 'Binalar yükleniyor…',
			'common.loadFailed' => 'Yüklenemedi',
			'common.unexpectedError' => 'İşlem tamamlanamadı. Lütfen tekrar deneyin.',
			'common.api.networkError' => 'İnternet bağlantınızı kontrol edip tekrar deneyin.',
			'common.api.serverError' => 'Sunucuya ulaşılamadı. Lütfen biraz sonra tekrar deneyin.',
			'common.api.validationError' => 'Girdiğiniz bilgileri kontrol edin.',
			'common.api.notFound' => 'İstenen kayıt bulunamadı.',
			'common.api.unauthorized' => 'Oturumunuz sona erdi. Lütfen tekrar giriş yapın.',
			'common.api.rateLimit' => 'Çok fazla deneme yaptınız. Lütfen kısa süre bekleyip tekrar deneyin.',
			'common.api.forbidden' => 'Bu işlem için yetkiniz yok.',
			'common.api.genericError' => 'İşlem tamamlanamadı. Lütfen tekrar deneyin.',
			'common.api.invalidCredentials' => 'E-posta, telefon veya şifre hatalı. Bilgilerinizi kontrol edip tekrar deneyin.',
			'common.api.duplicateEmail' => 'Bu e-posta adresi zaten kayıtlı. Giriş yapmayı deneyin.',
			'common.api.duplicatePhone' => 'Bu telefon numarası zaten kayıtlı.',
			'common.api.invalidInviteCode' => 'Davet kodu geçersiz. Kodu kontrol edip tekrar deneyin.',
			'common.api.inviteCodeUsed' => 'Bu davet kodu daha önce kullanılmış.',
			'common.api.inviteCodeExpired' => 'Davet kodunun süresi dolmuş. Yöneticinizden yeni kod isteyin.',
			'common.api.resetTokenInvalid' => 'Kod hatalı veya süresi dolmuş. Yeni kod isteyip tekrar deneyin.',
			'common.api.recordConflict' => 'Bu kayıt zaten mevcut.',
			'common.api.relatedRecordMissing' => 'İşlem için gerekli bağlı kayıt bulunamadı.',
			'common.api.buildingAccessDenied' => 'Bina bulunamadı veya bu binaya erişim yetkiniz yok.',
			'common.api.invalidIban' => 'IBAN geçersiz. TR ile başlayan 26 haneli IBAN girin.',
			'common.api.apartmentNoResident' => 'Bu dairede çıkarılacak sakin yok.',
			'common.api.ticketClosedNote' => 'Kapalı veya sonuçlanmış talebe not eklenemez.',
			'common.api.ticketClosedStatus' => 'Kapatılmış talebin durumu değiştirilemez.',
			'common.api.ticketInvalidStatus' => 'Bu durum geçişi yapılamıyor. Listeyi yenileyip tekrar deneyin.',
			'common.api.serviceUnavailable' => 'İşlem şu an yapılamıyor. Lütfen biraz sonra tekrar deneyin.',
			'common.api.fileUploadError' => 'Dosya yüklenemedi. Lütfen tekrar deneyin.',
			'common.api.fileContentMismatch' => 'Dosya türü ile içerik uyuşmuyor. Başka bir dosya seçin.',
			'common.api.invalidPdf' => 'PDF dosyası okunamadı veya bozuk. Başka bir dosya deneyin.',
			'common.api.notificationNotFound' => 'Bildirim bulunamadı.',
			'common.api.invalidCursor' => 'Liste yenilenemedi. Sayfayı yenileyip tekrar deneyin.',
			'common.api.expenseNotFound' => 'Gider kaydı bulunamadı.',
			'common.api.dueNotFound' => 'Aidat kaydı bulunamadı.',
			'common.api.dekontNotFound' => 'Dekont bulunamadı.',
			'common.api.noApartmentForPayment' => 'Ödeme bilgisi için önce bir daireye atanmanız gerekir.',
			'common.rateLimitHint' => 'Sunucu şu an yoğun görünüyor. Kısa süre sonra yeniden denenecek.',
			'common.tryAgain' => 'Tekrar Dene',
			'common.documentPreview.title' => 'Belge görüntüle',
			'common.documentPreview.share' => 'Paylaş',
			'common.documentPreview.pdfUnavailable' => 'PDF bu cihazda açılamadı. Paylaş ile başka bir uygulamada açabilirsiniz.',
			'common.documentPreview.pinchHint' => 'İki parmakla yakınlaştırıp kaydırın',
			'common.home' => 'Ana Sayfa',
			'common.buildings' => 'Binalar',
			'common.dues' => 'Aidatlar',
			'common.settings' => 'Ayarlar',
			'common.user' => 'Kullanıcı',
			'common.welcome' => 'Hoş Geldiniz',
			'common.managedBuildings' => 'Yönetilen Binalar',
			'common.issues' => 'Arızalar',
			'common.issuesTab' => 'Arızalar Sekmesi',
			'common.apartment' => 'Daire',
			'common.addBuilding' => 'Bina Ekle',
			'common.inviteCode' => 'Davet Kodu',
			'common.myBuildings' => 'Binalarım',
			'common.apartments' => 'Daireler',
			'common.collection' => 'Tahsilat',
			'common.duesTab' => 'Aidatlar Sekmesi',
			'common.totalApartments' => 'Toplam Daire',
			'common.occupiedApartments' => 'Dolu Daire',
			'common.duesCollection' => 'Aidat Tahsilatı',
			'common.totalDues' => 'Toplam Aidat',
			'common.recentTransactions' => 'Son İşlemler',
			'common.paid' => 'Ödendi',
			'common.pending' => 'Beklemede',
			'common.overdue' => 'Gecikmiş',
			'common.balance' => 'Bakiye',
			'common.amountDue' => 'Ödenmesi Gereken',
			'common.lastPayment' => 'Son Ödeme',
			'common.makePayment' => 'Ödeme Yap',
			'common.bills' => 'Faturalar',
			'common.support' => 'Destek',
			'common.quickActions' => 'Hızlı işlemler',
			'common.residentName' => 'Sakin Adı',
			'common.addBuildingNew' => 'Yeni Bina Ekle',
			'common.basicInfo' => 'Temel Bilgiler',
			'common.buildingName' => 'Bina Adı',
			'common.buildingNameHint' => 'Örn: Güneş Apartmanı',
			'common.location' => 'Konum',
			'common.streetAddress' => 'Sokak / Cadde Adresi',
			'common.streetAddressHint' => 'Örn: Bağdat Cad. No: 123',
			'common.details' => 'Detaylar',
			'common.floorCount' => 'Kat Sayısı',
			'common.floorCountHint' => '1 ile 200 arası',
			'common.apartmentsPerFloor' => 'Kattaki Daire',
			'common.apartmentsPerFloorHint' => '1 ile 50 arası',
			'common.floorRangeError' => 'Kat sayısı 1 ile 200 arasında olmalı',
			'common.apartmentsPerFloorRangeError' => 'Kat başına daire 1 ile 50 arasında olmalı',
			'common.buildingAddFailed' => 'Bina eklenemedi. Lütfen tekrar deneyin.',
			'common.monthlyDues' => 'Aylık Aidat',
			'common.monthlyDuesLabel' => 'Aylık Aidat (₺)',
			'common.monthlyDuesHint' => 'Örn: 1000',
			'common.createBuilding' => 'Bina Oluştur',
			'common.cancelBtn' => 'Vazgeç',
			'common.cityRequired' => 'Şehir *',
			'common.selectCity' => 'Şehir seçin',
			'common.districtRequired' => 'İlçe *',
			'common.selectDistrict' => 'İlçe seçin',
			'common.selectCityFirst' => 'Önce şehir seçin',
			'common.selectCityTitle' => 'Şehir Seçin',
			'common.selectDistrictTitle' => 'İlçe Seçin',
			'common.search' => 'Ara...',
			'common.noResults' => 'Sonuç bulunamadı',
			'common.fieldRequired' => 'boş bırakılamaz',
			'common.fillRequiredFields' => 'Lütfen zorunlu alanları doldurun',
			'common.selectCityAndDistrict' => 'Şehir ve ilçe seçmelisiniz',
			'common.floorApartmentMustBePositive' => 'Kat sayısı ve daire sayısı 0\'dan büyük olmalı',
			'common.buildingAddedSuccess' => 'Bina başarıyla eklendi',
			'common.createInviteCode' => 'Davet Kodu Oluştur',
			'common.whichBuildingForCode' => 'Hangi binadan kod üretilecek?',
			'common.whichApartmentForCode' => 'Hangi daire için kod üretilecek?',
			'common.noApartmentsInBuilding' => 'Bu binaya henüz daire eklenmemiş',
			'common.activeCodeBadge' => 'Aktif Kod',
			'common.occupiedBadge' => 'Dolu',
			'common.emptyBadge' => 'Boş',
			'common.activeCodePrefix' => 'Aktif kod',
			'common.residentPrefix' => 'Sakin',
			'common.emptyApartment' => 'Boş daire',
			'common.codeRevoked' => 'Kod iptal edildi',
			'common.codeCopied' => 'Kod kopyalandı',
			'common.clipboardCopied' => 'Mesaj panoya kopyalandı',
			'common.expiresAtPrefix' => 'Son kullanma',
			'common.remainingPrefix' => 'Kalan',
			'common.buildingDetail' => 'Bina Detayı',
			'common.residents' => 'Sakinler',
			'common.apartmentsBadge' => 'Daire',
			'common.emptyApartmentText' => 'Boş Daire',
			'common.vacantBadge' => 'Boş',
			'common.phoneNotShared' => 'Telefon paylaşılmadı',
			'common.residentDetailsLink' => 'Detayları Gör',
			'common.duesPaidStatus' => 'Aidat Ödendi',
			'common.duesPendingStatus' => 'Aidat Bekliyor',
			'common.duesOverdueStatus' => 'Aidat Gecikmiş',
			'common.noResidentInApartment' => 'Sakin atanmadı',
			'common.residentDetailsSheetTitle' => 'Sakin bilgileri',
			'common.apartmentDetailsSheetTitle' => 'Daire bilgileri',
			'common.noResidentAssigned' => 'Sakin atanmamış',
			'common.noApartmentsYet' => 'Henüz daire eklenmemiş',
			'common.paidStatus' => 'Ödendi',
			'common.pendingStatus' => 'Bekliyor',
			'common.overdueStatus' => 'Gecikmiş',
			'common.waivedStatus' => 'Muaf',
			'common.all' => 'Tümü',
			'common.status' => 'Durum',
			'common.month' => 'Ay',
			'common.dayLabel' => 'Gün',
			'common.pickDate' => 'Tarih seçin',
			'common.monthJanuary' => 'Ocak',
			'common.monthFebruary' => 'Şubat',
			'common.monthMarch' => 'Mart',
			'common.monthApril' => 'Nisan',
			'common.monthMay' => 'Mayıs',
			'common.monthJune' => 'Haziran',
			'common.monthJuly' => 'Temmuz',
			'common.monthAugust' => 'Ağustos',
			'common.monthSeptember' => 'Eylül',
			'common.monthOctober' => 'Ekim',
			'common.monthNovember' => 'Kasım',
			'common.monthDecember' => 'Aralık',
			'common.allMonths' => 'Tüm aylar',
			'common.year' => 'Yıl',
			'common.allYears' => 'Tüm yıllar',
			'common.note' => 'Not',
			'common.myDuesHistory' => 'Aidat Geçmişim',
			'common.currentPeriodDue' => 'Güncel aidat',
			'common.myPastDues' => 'Geçmiş aidatlarım',
			'common.buildingDues' => 'Bina Aidatları',
			'common.noDuesYet' => 'Henüz aidat kaydı yok',
			'common.duesUpdated' => 'Aidat durumu güncellendi',
			'common.amount' => 'Tutar',
			'common.updateDueAmount' => 'Aidat Tutarını Güncelle',
			'common.dueAmountUpdated' => 'Aidat tutarı güncellendi',
			'common.dueAmountUpdateFailed' => 'Aidat tutarı güncellenemedi',
			'common.dueDay' => 'Aidat Günü (1-28)',
			'common.selectDueDay' => 'Gün seçin',
			'common.affectCurrentDues' => 'Bekleyen aidatlara da uygula',
			'common.affectCurrentDuesHint' => 'Açık olduğunda mevcut bekleyen (PENDING) aidat tutarları da yeni tutara güncellenir.',
			'common.dueUpdateNeedAmountOrDay' => 'Güncellemek için tutar girin veya aidat günü seçin.',
			'common.dueUpdateNeedStoredAmount' => 'Bu bina için kayıtlı tutar yok. Aidat gününü güncellemek için önce tutar yazın.',
			'common.dueAmountInvalidPositive' => 'Geçerli bir tutar yazın.',
			'common.dueDayOutOfRange' => 'Aidat günü 1 ile 28 arasında olmalıdır.',
			'common.update' => 'Güncelle',
			'common.overdueDays' => 'gün gecikmiş',
			'common.dueMetaOverdueDelay' => '{days} gün gecikme',
			'common.dueMetaPaidInMonth' => '{month} {year}\'de ödendi',
			'common.dueMetaPaidOnDay' => '{day} {month}\'ta ödendi',
			'common.dueMetaPendingDueDate' => 'son ödeme {day} {month}',
			'common.payShort' => 'Öde',
			'common.dekontShort' => 'Dekont',
			'common.monthChipLabel' => 'AY',
			'common.yearChipLabel' => 'YIL',
			'common.dueDateLabel' => 'Son ödeme',
			'common.perMonth' => '/ ay',
			'common.floorLabel' => 'KAT',
			'common.apartmentLabel' => 'DAİRE',
			'common.turkishLanguage' => 'Türkçe',
			'common.englishLanguage' => 'English',
			'common.stepBuilding' => 'Bina',
			'common.stepApartment' => 'Daire',
			'common.stepCode' => 'Kod',
			'common.editBuilding' => 'Binayı Düzenle',
			'common.deleteBuilding' => 'Binayı Sil',
			'common.buildingUpdated' => 'Bina güncellendi',
			'common.buildingDeleted' => 'Bina silindi',
			'common.buildingUpdateFailed' => 'Bina güncellenemedi',
			'common.buildingDeleteFailed' => 'Bina silinemedi',
			'common.buildingDeleteFailedFK' => 'Bu binayı silemezsiniz: hâlâ daire, sakin veya aidat kayıtları var. Önce daireleri/aidatları temizleyip tekrar deneyin.',
			'common.deleteBuildingHeader' => 'Bu işlem geri alınamaz.',
			'common.deleteBuildingTypeHint' => 'Onaylamak için aşağıya bina adını aynen yazın:',
			'common.deleteBuildingTypeFieldLabel' => 'Bina adı',
			'common.buildingNameMismatch' => 'Yazdığınız metin bina adıyla aynı değil.',
			'common.editApartment' => 'Daireyi Düzenle',
			'common.deleteApartment' => 'Daireyi Sil',
			'common.apartmentUpdated' => 'Daire güncellendi',
			'common.apartmentDeleted' => 'Daire silindi',
			'common.apartmentUpdateFailed' => 'Daire güncellenemedi',
			'common.apartmentDeleteFailed' => 'Daire silinemedi',
			'common.apartmentDeleteFailedFK' => 'Bu daireyi silemezsiniz: sakin veya aidat kayıtları var. Önce sakinin hesap kapatmasını bekleyip aidatları temizleyin.',
			'common.deleteApartmentConfirm' => 'Daireyi silmek istediğinize emin misiniz?',
			'common.apartmentNumberLabel' => 'Daire No (örn. 5A)',
			'common.floorLabel2' => 'Kat (opsiyonel)',
			'common.floorOptional' => 'Kat (-5 ile 200 arası)',
			'common.buildingNameField' => 'Bina adı',
			'common.buildingAddressField' => 'Adres',
			'common.buildingCityField' => 'Şehir',
			'common.monthlyDuesPerApartment' => 'Aylık aidat / daire',
			'common.remove' => 'Çıkar',
			'common.removeResident' => 'Sakini Çıkar',
			'common.removeResidentConfirm' => 'Bu sakini daireden çıkarmak istediğinize emin misiniz?',
			'common.removeResidentNote' => 'Sakinin hesabı silinmez, sadece bu daireden bağlantısı kopar. Geçmiş aidat kayıtları korunur. Sakin başka bir daireye davet kodu ile tekrar katılabilir.',
			'common.residentRemoved' => 'Sakin daireden çıkarıldı',
			'common.residentRemoveFailed' => 'Sakin çıkarılamadı',
			'common.residentRemoveForbidden' => 'Bu işlem için yetkiniz yok. Yalnızca binanın yöneticisi sakin çıkarabilir.',
			'common.residentRemoveNotFound' => 'Bu dairede çıkarılacak sakin bulunamadı.',
			'common.multiSelectResidents' => 'Çoklu seç',
			'common.multiSelectTapHint' => 'Seçmek için karta dokunun',
			'common.selectTriggerShort' => 'Seç',
			'common.selectedCountLabel' => 'seçili',
			'common.selectionRemoveHint' => 'Çıkarmak istediğiniz sakinleri seçin',
			'common.selectionDeleteIbanHint' => 'Silmek istediğiniz IBAN\'ları seçin',
			'common.removeSelectedResidents' => 'Seçilenleri çıkar',
			'common.removeSelectedResidentsTitle' => 'Seçilen sakinleri çıkar',
			'common.removeSelectedResidentsMessage' => 'Aşağıda listelenen dairelerde oturan sakinler daireden çıkarılır. Hesapları silinmez; yalnızca bu binadaki bağlantıları kalkar. Geçmiş aidat kayıtları korunur.',
			'common.removeSelectedResidentsAffectedListTitle' => 'Etkilenecek daireler',
			'common.removeSelectedResidentsListUnavailable' => 'Daire listesi şu an gösterilemiyor. Seçilen daire sayısı aşağıda; onaylarsanız işlem yine de uygulanır.',
			'common.pickResidentsFirst' => 'Önce listeden en az bir dolu daire seçin',
			'common.noResidentsToRemoveInBuilding' => 'Bu binada çıkarılacak sakin bulunmuyor.',
			'common.removeSelectedProgress' => 'İşlem yapılıyor…',
			'common.removeSelectedSuccess' => 'Seçilen sakinler dairelerden çıkarıldı',
			'common.removeSelectedFailed' => 'Seçilenleri çıkarma tamamlanamadı',
			'common.currentPassword' => 'Mevcut Şifre',
			'common.newPassword' => 'Yeni Şifre',
			'common.newPasswordConfirm' => 'Yeni Şifre (Tekrar)',
			'common.currentPasswordRequired' => 'Mevcut şifrenizi girin',
			'common.passwordsMustDiffer' => 'Yeni şifre eski şifre ile aynı olamaz',
			'common.changePasswordTitle' => 'Şifre Değiştir',
			'common.changePasswordSubtitle' => 'Güvenliğiniz için şifrenizi düzenli olarak değiştirin.',
			'common.changePasswordSuccess' => 'Şifreniz değiştirildi. Lütfen yeni şifrenizle tekrar giriş yapın.',
			'common.changePasswordFailed' => 'Şifre değiştirilemedi. Lütfen tekrar deneyin.',
			'common.changePasswordWrongCurrent' => 'Mevcut şifre hatalı.',
			'common.deleteAccount' => 'Hesabımı Kapat',
			'common.deleteAccountTitle' => 'Hesabınızı kapatmak istiyor musunuz?',
			'common.deleteAccountWarning' => 'Bu işlem geri alınamaz. Kişisel bilgileriniz silinir, ancak yasal nedenlerle bazı kayıtlar (aidat geçmişi gibi) anonim olarak saklanır.',
			'common.deleteAccountTypeHint' => 'Onaylamak için aşağıya "HESABIMI KAPAT" yazın:',
			'common.deleteAccountTypePhrase' => 'HESABIMI KAPAT',
			'common.deleteAccountTypeMismatch' => 'Yazdığınız metin eşleşmiyor.',
			'common.deleteAccountConfirmButton' => 'Hesabımı Kapat',
			'common.deleteAccountSuccess' => 'Hesabınız kapatıldı. Bizi tercih ettiğiniz için teşekkürler.',
			'common.deleteAccountFailed' => 'Hesap kapatılamadı. Lütfen tekrar deneyin.',
			'common.deleteAccountFailedManager' => 'Önce yönettiğiniz binaları silmeniz veya başka bir yöneticiye devretmeniz gerekiyor.',
			'common.dangerZone' => 'Tehlikeli Bölge',
			'common.forgotPassword' => 'Şifremi Unuttum',
			'common.forgotPasswordTitle' => 'Şifremi Unuttum',
			'common.forgotPasswordSubtitle' => 'Kayıtlı e-posta adresinizi girin, size bir sıfırlama kodu gönderelim.',
			'common.forgotPasswordSuccess' => 'Eğer bu e-posta sistemimizde kayıtlıysa, sıfırlama kodu gönderildi. Lütfen e-postanızı kontrol edin.',
			'common.sendResetCode' => 'Kodu Gönder',
			'common.iHaveACode' => 'Zaten kodum var',
			'common.resetPasswordTitle' => 'Yeni Şifre Belirle',
			'common.resetPasswordSubtitle' => 'E-postanıza gelen 6 haneli kodu ve yeni şifrenizi girin.',
			'common.resetCode' => 'Sıfırlama Kodu',
			'common.resetCodeHint' => 'ABC123',
			'common.resetCodeRequired' => 'Sıfırlama kodu gerekli',
			'common.resetCodeInvalid' => 'Kod 6 karakter olmalı',
			'common.resetPasswordSuccess' => 'Şifreniz sıfırlandı. Yeni şifrenizle giriş yapabilirsiniz.',
			'common.resetPasswordFailed' => 'Şifre sıfırlanamadı. Kod hatalı veya süresi dolmuş olabilir.',
			'common.resetPasswordSubmit' => 'Şifreyi Sıfırla',
			'common.backToLogin' => 'Giriş ekranına dön',
			'validation.emailRequired' => 'Email adresi boş bırakılamaz',
			'validation.emailInvalid' => 'Geçerli bir email adresi giriniz',
			'validation.emailTooLong' => 'Email adresi çok uzun',
			'validation.phoneRequired' => 'Telefon numarası boş bırakılamaz',
			'validation.phoneInvalid' => 'Telefon numarası 10 haneli olmalıdır',
			'validation.passwordRequired' => 'Şifre boş bırakılamaz',
			'validation.passwordTooShort' => 'Şifre en az 6 karakter olmalıdır',
			'validation.passwordTooLong' => 'Şifre çok uzun',
			'validation.passwordUppercaseRequired' => 'Şifrede en az 1 büyük harf olmalıdır',
			'validation.passwordLowercaseRequired' => 'Şifrede en az 1 küçük harf olmalıdır',
			'validation.passwordNumberRequired' => 'Şifrede en az 1 rakam olmalıdır',
			'validation.passwordSpecialCharRequired' => 'Şifrede en az 1 özel karakter olmalıdır',
			'features.buildings.managerPanel' => 'Yönetici',
			'features.buildings.buildingDetail' => 'Bina Detayı',
			'features.buildings.addBuilding' => 'Bina Ekle',
			'features.buildings.newBuilding' => 'Yeni Bina Ekle',
			'features.buildings.inviteCode' => 'Davet Kodu',
			'features.buildings.createInviteCode' => 'Davet Kodu Oluştur',
			'features.buildings.cancelCode' => 'Kodu İptal Et',
			'features.buildings.apartmentOccupied' => 'Daire Dolu',
			'features.buildings.copy' => 'Kopyala',
			'features.buildings.share' => 'Paylaş',
			'features.buildings.anotherApartment' => 'Başka Daire',
			'features.buildings.codeRevoked' => 'Kod iptal edildi',
			'features.buildings.occupiedDialog' => 'Yeni kod üretirsen eski kullanıcı çıkarılır. Emin misiniz?',
			'features.buildings.revokeDialog' => 'Mevcut kod geçersiz hale gelir. Emin misiniz?',
			'features.buildings.produceAnyway' => 'Yine de Üret',
			'features.buildings.newCodePrefix' => 'Yeni kod üretirsen ',
			'features.buildings.oldUserRemoved' => 'eski kullanıcı çıkarılır',
			'features.buildings.currentCodePrefix' => 'Mevcut kod ',
			'features.buildings.codeInvalid' => 'geçersiz hale gelir',
			'features.buildings.codeReady' => 'Davet Kodu Hazır',
			'features.buildings.code' => 'KOD',
			'features.buildings.validFor7Days' => '7 gün geçerli',
			'features.buildings.expiresAt' => 'Son kullanma:',
			'features.buildings.remaining' => 'Kalan:',
			'features.buildings.activeCodeNote' => 'Bu kod aktifken aynı daireye yeni kod üretilemez. Yeni kod için önce mevcut kodu iptal etmelisin.',
			'features.buildings.backToMainMenu' => 'Ana Menüye Dön',
			'features.buildings.tekrarDene' => 'Tekrar Dene',
			'features.buildings.collection.sectionTitle' => 'Tahsilat bilgileri',
			'features.buildings.collection.sectionHint' => 'Sakinlerin havale yapacağı IBAN. Boş bırakılabilir; sonradan da ekleyebilirsiniz.',
			'features.buildings.collection.modeSaved' => 'Kayıtlı IBAN',
			'features.buildings.collection.modeNew' => 'Yeni IBAN',
			'features.buildings.collection.savedListTitle' => 'Daha önce kullandıklarınız',
			'features.buildings.collection.savedListSectionLabel' => 'Kayıtlı IBAN\'lar',
			'features.buildings.collection.pickSavedIban' => 'Kayıtlı IBAN seçin',
			'features.buildings.collection.changeSavedIban' => 'Başka IBAN seçmek için dokunun',
			'features.buildings.collection.searchSavedIban' => 'IBAN veya unvan ara',
			'features.buildings.collection.detailAccountHolder' => 'Hesap sahibi',
			'features.buildings.collection.detailReference' => 'Havale açıklaması',
			'features.buildings.collection.detailReferenceAuto' => 'Havale açıklamasına daire numarası otomatik eklenir',
			'features.buildings.collection.detailReferenceDaireOnly' => 'Havale açıklaması: Daire numarası',
			'features.buildings.collection.detailReferenceDaireAidat' => 'Havale açıklaması: Daire no + aidat',
			'features.buildings.collection.detailReferenceAidat' => 'Havale açıklaması: Aidat (daire no otomatik)',
			'features.buildings.collection.detailReferenceHavale' => 'Havale açıklaması: Daire numarası ile havale',
			'features.buildings.collection.detailUsedInBuildings' => '{count} binada kullanılıyor',
			'features.buildings.collection.ibanLabel' => 'IBAN',
			'features.buildings.collection.ibanHint' => 'TR33 0006 1005 1978 6457 8413 26',
			'features.buildings.collection.ibanInvalid' => 'Geçerli bir Türkiye IBAN girin (TR + 24 rakam)',
			'features.buildings.collection.ibanRequiredIfOtherFilled' => 'Alıcı veya açıklama girdiniz; geçerli IBAN girin',
			'features.buildings.collection.accountTitleLabel' => 'Hesap sahibi / alıcı unvanı',
			'features.buildings.collection.accountTitleHint' => 'Örn: Site Yönetimi',
			'features.buildings.collection.referenceTemplateLabel' => 'Havale açıklama şablonu',
			'features.buildings.collection.referenceTemplateHint' => 'Örn: Daire {{number}}',
			'features.buildings.collection.presetsEmpty' => 'Henüz kayıtlı tahsilat bilgisi yok',
			'features.buildings.collection.presetsLoadFailed' => 'Öneriler yüklenemedi',
			'features.buildings.collection.presetBuildingCount' => '{count} bina',
			'features.buildings.collection.menuEdit' => 'Tahsilat / IBAN',
			'features.buildings.collection.editSheetTitle' => 'Tahsilat bilgileri',
			'features.buildings.collection.saveSuccess' => 'Tahsilat bilgileri kaydedildi',
			'features.buildings.collection.savedIbansTitle' => 'Kayıtlı IBAN\'larım',
			'features.buildings.collection.savedIbansEmpty' => 'Henüz kayıtlı IBAN yok. Bina eklerken tahsilat bilgisi tanımlayabilirsiniz.',
			'features.buildings.collection.savedIbansNoBuildingMatch' => 'Bu sete bağlı bina bulunamadı',
			'features.buildings.collection.savedIbansBuildingNames' => 'Binalar: {names}',
			'features.buildings.collection.savedIbansUpdateSuccess' => '{count} bina için tahsilat bilgisi güncellendi',
			'features.buildings.collection.savedIbansUpdateHint' => 'Güncellenecek binalar: {names}',
			'features.buildings.collection.editSavedIbanTitle' => 'IBAN düzenle',
			'features.buildings.collection.savedIbansOrphanHint' => 'Henüz bir binaya atanmamış kayıtlı set. Değişiklik yalnızca bu listede saklanır.',
			'features.buildings.collection.savedIbansAddTitle' => 'Yeni IBAN ekle',
			'features.buildings.collection.savedIbansAddHint' => 'Bu bilgileri bina eklerken veya tahsilat ayarlarında kullanabilirsiniz.',
			'features.buildings.collection.savedIbansAddSuccess' => 'IBAN kaydedildi',
			'features.buildings.collection.savedIbansSelectMode' => 'Çoklu seç',
			'features.buildings.collection.savedIbansSelectedLabel' => 'seçili',
			'features.buildings.collection.savedIbansDeleteSelected' => 'Seçilenleri sil',
			'features.buildings.collection.savedIbansPickFirst' => 'Önce silmek istediğiniz IBAN\'ları seçin',
			'features.buildings.collection.savedIbansDeleteTitle' => 'IBAN silinsin mi?',
			'features.buildings.collection.savedIbansDeleteMessage' => 'Bu kayıtlı IBAN listeden kaldırılacak.',
			'features.buildings.collection.savedIbansDeleteBulkTitle' => 'Seçilen IBAN\'lar silinsin mi?',
			'features.buildings.collection.savedIbansDeleteBulkMessage' => '{count} kayıtlı IBAN silinecek.',
			'features.buildings.collection.savedIbansDeleteBuildingWarning' => '{count} binanın tahsilat bilgisi de temizlenecek.',
			'features.buildings.collection.savedIbansDeleteSuccess' => 'IBAN silindi',
			'features.buildings.collection.savedIbansDeleteBulkSuccess' => '{count} IBAN silindi',
			'features.buildings.collection.ibanNotConfigured' => 'Tahsilat IBAN tanımlı değil',
			'features.buildings.collection.ibanAlreadyExists' => 'Bu IBAN numarası zaten sistemde kayıtlı. Lütfen farklı bir IBAN kontrol edip tekrar deneyiniz.',
			'features.buildings.list.buildingCount' => 'Bina',
			'features.buildings.list.unitCount' => 'Daire',
			'features.buildings.list.overdueShort' => 'Geciken',
			'features.buildings.list.collectionShort' => 'Tahsilat',
			'features.buildings.list.sort' => 'Sırala',
			'features.buildings.list.sortByOverdue' => 'Gecikmişe Göre',
			'features.buildings.list.sortByCollectionRate' => 'Tahsilat Oranına Göre',
			'features.buildings.list.sortByName' => 'İsme Göre',
			'features.buildings.list.paidUnitsProgress' => '{paid} / {total} daire ödedi',
			'features.buildings.list.perUnitDues' => '{amount} / daire',
			'features.buildings.list.unitsOverdue' => '{count} daire gecikmiş',
			'features.buildings.list.unitsWaiting' => '{count} daire bekliyor',
			'features.buildings.list.allPaymentsComplete' => 'Tüm ödemeler tamam',
			'features.buildings.list.monthlyDuesShort' => 'Aylık Aidat',
			'features.auth.register' => 'Kaydol',
			'features.auth.login' => 'Giriş Yap',
			'features.auth.join' => 'Katıl',
			'features.auth.passwordRequired' => 'Şifre gerekli',
			'features.auth.errorOccurred' => 'Bir hata oluştu',
			'features.auth.registrationSuccess' => 'Hesabınız oluşturuldu. Giriş yapabilirsiniz.',
			'features.auth.loginSuccess' => 'Giriş başarılı. Hoş geldiniz.',
			'features.auth.appTitle' => 'AidatPanel',
			'features.auth.appSubtitle' => 'Apartman Yönetim Sistemi',
			'features.auth.splashConnectionError' => 'Sunucuya bağlanılamadı',
			'features.auth.splashConnectionHint' => 'İnternet bağlantını kontrol edip tekrar dene.',
			'features.auth.skipToLogin' => 'Giriş ekranına git',
			'features.auth.phone' => 'Telefon',
			'features.auth.email' => 'Email',
			'features.auth.phoneHint' => '5XX XXX XX XX',
			'features.auth.emailHint' => 'ornek@email.com',
			'features.auth.password' => 'Şifre',
			'features.auth.passwordHint' => '••••••••',
			'features.auth.emailLogin' => 'Email ile Giriş Yap',
			'features.auth.phoneLogin' => 'Telefon ile Giriş Yap',
			'features.auth.or' => 'veya',
			'features.auth.noAccount' => 'Hesabınız yok mu? Kaydolun',
			'features.auth.joinWithCode' => 'Davet kodu ile katılın',
			'features.auth.signUp' => 'Üye ol',
			'features.auth.signUpTitle' => 'Üye Ol',
			'features.auth.signUpSubtitle' => 'Nasıl katılmak istiyorsunuz?',
			'features.auth.beManager' => 'Yönetici ol',
			'features.auth.beManagerHint' => 'Bina oluşturup yönetici hesabı açın',
			'features.auth.joinWithInvite' => 'Davet koduyla katıl',
			'features.auth.joinWithInviteHint' => 'Yöneticinizin verdiği kod ile sakin olun',
			'features.auth.copyright' => '© Vefa Yazılım',
			'features.auth.createAccount' => 'Yeni Hesap Oluştur',
			'features.auth.name' => 'Ad Soyad',
			'features.auth.nameHint' => 'Örn: Furkan Kaya',
			'features.auth.phoneOptional' => 'Telefon (Opsiyonel)',
			'features.auth.phoneHintOptional' => '5XX XXX XXXX',
			'features.auth.minLength' => 'En az 6 karakter',
			'features.auth.hasUpperCase' => 'En az 1 büyük harf',
			'features.auth.hasLowerCase' => 'En az 1 küçük harf',
			'features.auth.hasNumber' => 'En az 1 rakam',
			'features.auth.hasSpecialChar' => 'En az 1 özel karakter',
			'features.auth.confirmPassword' => 'Şifre Tekrar',
			'features.auth.passwordsDoNotMatch' => 'Şifreler eşleşmiyor',
			'features.auth.emailAndPasswordRequired' => 'Email ve şifre boş bırakılamaz',
			'features.auth.hasAccount' => 'Zaten hesabınız var mı? Giriş yapın',
			'features.auth.joinApartment' => 'Apartmana Katıl',
			'features.auth.inviteCode' => 'Davet Kodu',
			'features.auth.inviteCodeHint' => 'AP3-B12-A9F0',
			'features.auth.invalidInviteCodeFormat' => 'Geçersiz davet kodu formatı (Örn: AP3-B12-A9F0)',
			'features.auth.invalidPhoneFormat' => 'Geçerli bir telefon numarası giriniz (5XX XXX XX XX)',
			'features.auth.inviteCodeAndPasswordRequired' => 'Davet kodu, ad ve şifre boş bırakılamaz',
			'features.auth.invalidPhoneNumber' => 'Geçerli bir telefon numarası giriniz',
			'features.auth.areYouManager' => 'Yönetici misiniz? Kaydolun',
			'features.apartments.residentPanel' => 'Sakin',
			'features.tickets.myTickets' => 'Taleplerim',
			'features.tickets.newTicket' => 'Yeni Talep',
			'features.tickets.createTitle' => 'Arıza / Talep Bildir',
			'features.tickets.fieldTitle' => 'Başlık',
			'features.tickets.fieldTitleHint' => 'Örn: Asansör arızası',
			'features.tickets.fieldDescription' => 'Açıklama',
			'features.tickets.fieldDescriptionHint' => 'Sorunu kısaca anlatın',
			'features.tickets.fieldCategory' => 'Kategori',
			'features.tickets.categoryComplaint' => 'Şikayet',
			'features.tickets.categoryRequest' => 'Talep',
			'features.tickets.categoryMalfunction' => 'Arıza',
			'features.tickets.categoryOther' => 'Diğer',
			'features.tickets.submit' => 'Gönder',
			'features.tickets.createSuccess' => 'Talebiniz alındı',
			'features.tickets.createFailed' => 'Talep kaydedilemedi. Lütfen tekrar deneyin.',
			'features.tickets.createServiceUnavailable' => 'Talep servisi şu an hazır değil. Lütfen daha sonra tekrar deneyin.',
			'features.tickets.emptyTitle' => 'Henüz talep yok',
			'features.tickets.emptySubtitle' => 'Arıza veya talebinizi buradan bildirebilirsiniz',
			'features.tickets.titleTooShort' => 'Başlık en az 3 karakter olmalı',
			'features.tickets.descriptionTooShort' => 'Açıklama en az 10 karakter olmalı',
			_ => null,
		} ?? switch (path) {
			'features.tickets.statusOpen' => 'Açık',
			'features.tickets.statusInProgress' => 'İşlemde',
			'features.tickets.statusResolved' => 'Çözüldü',
			'features.tickets.statusClosed' => 'Kapalı',
			'features.tickets.statusTrackerTitle' => 'TALEP DURUMU',
			'features.tickets.statusStepWaiting' => 'Bekliyor',
			'features.tickets.statusStepInProgress' => 'İşlemde',
			'features.tickets.statusStepResolved' => 'Çözüldü',
			'features.tickets.statusStepClosed' => 'Kapalı',
			'features.tickets.statusHeadlineOpen' => 'Talebiniz beklemede',
			'features.tickets.statusHeadlineInProgress' => 'Talebiniz işlemde',
			'features.tickets.statusHeadlineResolved' => 'Talebiniz çözüldü',
			'features.tickets.statusHeadlineClosed' => 'Talebiniz kapatıldı',
			'features.tickets.detailTitle' => 'Talep Detayı',
			'features.tickets.managerTitle' => 'Bina Talepleri',
			'features.tickets.statusLabel' => 'Durum',
			'features.tickets.updatesTitle' => 'Güncellemeler',
			'features.tickets.changeStatus' => 'Durum değiştir',
			'features.tickets.managerNote' => 'Yönetici notu',
			'features.tickets.addNote' => 'Not ekle',
			'features.tickets.statusUpdated' => 'Durum güncellendi',
			'features.tickets.noteAdded' => 'Not eklendi',
			'features.tickets.loadError' => 'Talepler yüklenemedi',
			'features.tickets.noteDisabledClosed' => 'Kapalı talebe not eklenemez',
			'features.tickets.statusClosedHint' => 'Bu talep kapatıldı; durum değiştirilemez.',
			'features.tickets.apartmentRequired' => 'Daire bilgisi bulunamadı. Lütfen tekrar giriş yapın.',
			'features.dekont.makePaymentTitle' => 'Ödeme Yap',
			'features.dekont.myDekontsTitle' => 'Dekontlarım',
			'features.dekont.managerTitle' => 'Dekont İnceleme',
			'features.dekont.reviewAction' => 'Dekont İncele',
			'features.dekont.detailTitle' => 'Dekont Detayı',
			'features.dekont.paymentInfoTitle' => 'Havale bilgileri',
			'features.dekont.collectionNotConfigured' => 'Yöneticiniz henüz tahsilat IBAN bilgisini tanımlamadı. Yine de dekont yükleyebilirsiniz.',
			'features.dekont.ibanLabel' => 'IBAN',
			'features.dekont.accountTitleLabel' => 'Alıcı unvanı',
			'features.dekont.referenceLabel' => 'Havale açıklaması',
			'features.dekont.copy' => 'Kopyala',
			'features.dekont.copied' => 'Panoya kopyalandı',
			'features.dekont.selectDue' => 'Aidat seçin',
			'features.dekont.selectDueHint' => 'Ödeme yaptığınız aidatı seçin',
			'features.dekont.noPendingDues' => 'Bekleyen aidat bulunmuyor',
			'features.dekont.uploadSectionTitle' => 'Dekont yükle',
			'features.dekont.uploadHint' => 'PDF belgesi veya fotoğraf (JPEG, PNG) (Maks. 10 MB)',
			'features.dekont.pickFile' => 'Dosya seç',
			'features.dekont.upload' => 'Dekontu yükle',
			'features.dekont.uploadSuccess' => 'Dekont yüklendi',
			'features.dekont.uploadRecoveredExisting' => 'Bu dekont zaten kayıtlı; mevcut kaydınız açıldı.',
			'features.dekont.uploadFailed' => 'Dekont yüklenemedi',
			'features.dekont.errorUploadDuplicate' => 'Bu dekontu daha önce yüklemişsiniz. Dekontlarım bölümünden kontrol edebilirsiniz.',
			'features.dekont.errorUploadRateLimit' => 'Kısa sürede çok fazla dekont yüklediniz. Lütfen bir süre bekleyin.',
			'features.dekont.errorUploadServer' => 'Dekont sunucuya kaydedilemedi. Lütfen biraz sonra tekrar deneyin.',
			'features.dekont.errorUploadFileRequired' => 'Lütfen bir dosya seçin.',
			'features.dekont.errorPaymentInfo' => 'Havale bilgileri alınamadı. Lütfen tekrar deneyin.',
			'features.dekont.errorListLoad' => 'Dekont listesi yüklenemedi. Lütfen tekrar deneyin.',
			'features.dekont.errorDetailLoad' => 'Dekont detayı yüklenemedi. Lütfen tekrar deneyin.',
			'features.dekont.errorFileDownload' => 'Dekont dosyası açılamadı. Lütfen tekrar deneyin.',
			'features.dekont.errorReviewPaymentDone' => 'Bu dekont için ödeme zaten işlenmiş.',
			'features.dekont.errorReviewRejected' => 'Reddedilmiş bir dekont tekrar onaylanamaz.',
			'features.dekont.errorReviewNeedDue' => 'Onaylamak için bir aidat seçmelisiniz.',
			'features.dekont.errorReviewStatus' => 'Bu dekont şu an onaylanamaz veya reddedilemez. Biraz sonra tekrar deneyin.',
			'features.dekont.errorNoFileSelected' => 'Lütfen önce bir dekont dosyası seçin.',
			'features.dekont.fileTooLarge' => 'Dosya en fazla 10 MB olabilir',
			'features.dekont.fileEmpty' => 'Seçilen dosya boş',
			'features.dekont.fileNotFound' => 'Dosya bulunamadı',
			'features.dekont.invalidExtension' => 'Yalnızca PDF, JPEG veya PNG yükleyebilirsiniz',
			'features.dekont.processing' => 'Dekont işleniyor…',
			'features.dekont.viewDekonts' => 'Dekontlarım',
			'features.dekont.breakdownDetails' => 'Detaylar',
			'features.dekont.breakdownBaseDue' => 'Baz aidat',
			'features.dekont.breakdownTotal' => 'Toplam',
			'features.dekont.emptyTitle' => 'Henüz dekont yok',
			'features.dekont.emptySubtitleResident' => 'Henüz bir dekontunuz bulunmuyor. Yeni dekont eklemek için sağ üst köşedeki yükleme butonunu kullanabilirsiniz.',
			'features.dekont.emptySubtitleManager' => 'Kullanıcılar tarafından yüklenmiş herhangi bir dekont bulunmamaktadır.',
			'features.dekont.filterAll' => 'Tümü',
			'features.dekont.filterPending' => 'İncelemede',
			'features.dekont.filterApproved' => 'Onaylandı',
			'features.dekont.filterRejected' => 'Reddedildi',
			'features.dekont.statusReceived' => 'Alındı',
			'features.dekont.statusExtracting' => 'Okunuyor',
			'features.dekont.statusExtractFailed' => 'Okunamadı',
			'features.dekont.statusParsed' => 'Okundu',
			'features.dekont.statusParseLowConfidence' => 'Düşük güven',
			'features.dekont.statusMatching' => 'Eşleştiriliyor',
			'features.dekont.statusMatched' => 'Eşleşti',
			'features.dekont.statusMatchAmbiguous' => 'Belirsiz eşleşme',
			'features.dekont.statusUnmatched' => 'Eşleşmedi',
			'features.dekont.statusPaymentApplied' => 'Ödeme uygulandı',
			'features.dekont.statusPaymentPartial' => 'Kısmi ödeme',
			'features.dekont.statusRejected' => 'Reddedildi',
			'features.dekont.statusRecipientMismatch' => 'Alıcı uyuşmuyor',
			'features.dekont.statusNeedsManagerReview' => 'Yönetici incelemesi',
			'features.dekont.reupload' => 'Yeniden yükle',
			'features.dekont.rejectionReason' => 'Red nedeni',
			'features.dekont.parsedAmount' => 'Okunan tutar',
			'features.dekont.paymentDetailsSection' => 'Ödeme bilgileri',
			'features.dekont.fileSection' => 'Dosya',
			'features.dekont.filePreview' => 'Dosya önizleme',
			'features.dekont.pdfPreviewHint' => 'İki parmakla yakınlaştırıp kaydırabilirsiniz.',
			'features.dekont.pdfPreviewUnavailable' => 'PDF bu cihazda açılamadı. Aşağıdaki «Dosyayı paylaş» ile başka bir uygulamada açabilirsiniz.',
			'features.dekont.shareFile' => 'Dosyayı paylaş',
			'features.dekont.approve' => 'Onayla',
			'features.dekont.reject' => 'Reddet',
			'features.dekont.reviewNote' => 'Not (opsiyonel)',
			'features.dekont.reviewSuccess' => 'İnceleme kaydedildi',
			'features.dekont.reviewFailed' => 'İnceleme kaydedilemedi',
			'features.dekont.selectDueForApprove' => 'Onay için aidat seçin',
			'features.dekont.uploadedBy' => 'Yükleyen',
			'features.dekont.apartment' => 'Daire',
			'features.dekont.amount' => 'Tutar',
			'features.dekont.loadError' => 'Dekontlar yüklenemedi',
			'features.dekont.systemInfoTitle' => 'Sistem bilgileri',
			'features.dekont.systemInfoSubtitle' => 'Dekontunuzdan okuduğumuz bilgiler aşağıdadır. Ödeme otomatik onaylanmaz; yönetici hesabını kontrol ederek onaylar.',
			'features.dekont.systemReadLabel' => 'Dekonttan okunanlar',
			'features.dekont.systemInfoProcessing' => 'Dekontunuz işleniyor. Okunan tutar, tarih ve banka bilgileri birkaç dakika içinde burada görünecek.',
			'features.dekont.systemInfoNoData' => 'Okunan bilgi',
			'features.dekont.systemInfoNoDataHint' => 'Dekonttan henüz tutar veya tarih okunamadı. Yine de yönetici onayına sunulacaktır.',
			'features.dekont.transactionDateLabel' => 'İşlem tarihi',
			'features.dekont.bankLabel' => 'Banka',
			'features.dekont.receiverIbanLabel' => 'Alıcı IBAN',
			'features.dekont.receiverNameLabel' => 'Alıcı unvanı',
			'features.dekont.referenceNumberLabel' => 'Referans no',
			'features.dekont.ibanUnreadableNotice' => 'Yüklediğiniz aidat ödeme dekontunda alıcı IBAN bilgisi okunamamıştır. Bu haliyle yönetici onayına sunulacaktır.',
			'features.dekont.ibanMismatchNotice' => 'Dekonttaki alıcı IBAN, binanızın tahsilat hesabıyla eşleşmiyor. Yönetici hesabını kontrol ederek karar verecektir.',
			'features.dekont.ibanVerifiedNotice' => 'Alıcı IBAN, binanızın tahsilat hesabıyla eşleşiyor. Yine de ödeme yönetici onayı olmadan işlenmez.',
			'features.dekont.residentPendingReviewNotice' => 'Dekontunuz yönetici onayına sunuldu. Ödeme otomatik onaylanmaz; yöneticiniz hesabını kontrol ederek onaylayacaktır.',
			'features.dekont.managerApprovalHint' => 'Hesabınıza gelen tutarı kontrol ederek onaylayın veya gerekirse reddedin.',
			'features.dekont.managerPaymentSummary' => '{resident}, {date} tarihinde {bank} aracılığıyla {amount} aidat gönderdi. Hesabınızı kontrol ederek onaylayınız.',
			'features.dekont.residentWithApartment' => '{name} (Daire {apartment})',
			'features.dekont.apartmentOnly' => 'Daire {apartment}',
			'features.dekont.residentUnknown' => 'Sakin',
			'features.dekont.amountUnknown' => 'belirtilen tutarda',
			'features.dekont.receiptPhotoTitle' => 'Dekont görüntüsü',
			'features.dekont.receiptPhotoHint' => 'Önce yukarıdaki sistem bilgilerini inceleyin. Dekont dosyasını istediğiniz zaman açabilirsiniz.',
			'features.dekont.viewDekont' => 'Dekontu görüntüle',
			'features.dekont.bankKuveytTurk' => 'Kuveyt Türk',
			'features.dekont.bankZiraat' => 'Ziraat Bankası',
			'features.dekont.bankIsbank' => 'İş Bankası',
			'features.dekont.bankGaranti' => 'Garanti BBVA',
			'features.dekont.bankHalkbank' => 'Halkbank',
			'features.dekont.bankVakifbank' => 'VakıfBank',
			'features.dekont.bankYapiKredi' => 'Yapı Kredi',
			'features.dekont.bankAkbank' => 'Akbank',
			'features.dekont.bankQnb' => 'QNB Finansbank',
			'features.dekont.bankGeneric' => 'Banka (genel)',
			'features.dekont.bankUnknown' => 'Banka bilgisi okunamadı',
			'features.expenses.title' => 'Giderler',
			'features.expenses.createTitle' => 'Gider Ekle',
			'features.expenses.fieldTitle' => 'Başlık',
			'features.expenses.fieldAmount' => 'Tutar (₺)',
			'features.expenses.fieldCategory' => 'Kategori',
			'features.expenses.fieldNote' => 'Not (opsiyonel)',
			'features.expenses.submit' => 'Kaydet',
			'features.expenses.required' => 'Zorunlu alan',
			'features.expenses.amountInvalid' => 'Geçerli tutar girin',
			'features.expenses.amountFromReceiptsHint' => 'Tutar makbuzlardan otomatik okunur.',
			'features.expenses.receiptRequired' => 'En az bir makbuz fotoğrafı ekleyin',
			'features.expenses.amountOcrPending' => 'Makbuz tutarları okunuyor. Birkaç saniye sonra listede görünür.',
			'features.expenses.total' => 'Toplam',
			'features.expenses.createSuccess' => 'Gider kaydedildi',
			'features.expenses.categoryCleaning' => 'Temizlik',
			'features.expenses.categoryElevator' => 'Asansör',
			'features.expenses.categoryElectricity' => 'Elektrik',
			'features.expenses.categoryWater' => 'Su',
			'features.expenses.categoryInsurance' => 'Sigorta',
			'features.expenses.categoryRepair' => 'Onarım',
			'features.expenses.categoryGarden' => 'Bahçe',
			'features.expenses.categoryOther' => 'Diğer',
			'features.expenses.fieldDate' => 'Gider tarihi',
			'features.expenses.fieldDateHint' => 'Makbuz veya fatura üzerindeki tarih',
			'features.expenses.fieldMonth' => 'Ay',
			'features.expenses.fieldYear' => 'Yıl',
			'features.expenses.editTitle' => 'Gideri Düzenle',
			'features.expenses.editAction' => 'Düzenle',
			'features.expenses.deleteTitle' => 'Gideri sil',
			'features.expenses.deleteAction' => 'Sil',
			'features.expenses.deleteConfirm' => 'Bu gider kaydını silmek istediğinize emin misiniz?',
			'features.expenses.deleteSuccess' => 'Gider silindi',
			'features.expenses.updateSuccess' => 'Gider güncellendi',
			'features.expenses.loadError' => 'Giderler yüklenemedi',
			'features.expenses.emptyTitle' => 'Bu dönemde gider yok',
			'features.expenses.emptySubtitle' => 'Sağ üstten yeni gider ekleyebilirsiniz',
			'features.expenses.receiptUrlLabel' => 'Makbuz bağlantısı (HTTPS)',
			'features.expenses.receiptUrlHint' => 'Opsiyonel — internetteki makbuz dosyası adresi',
			'features.expenses.receiptUrlInvalid' => 'Adres https:// ile başlamalıdır',
			'features.expenses.receiptTitle' => 'Makbuz fotoğrafı',
			'features.expenses.receiptHint' => 'PDF veya fotoğraf (JPEG, PNG). Tutar makbuzlardan otomatik okunur (Maks. 10 MB)',
			'features.expenses.receiptAdd' => 'Fotoğraf ekle',
			'features.expenses.receiptChange' => 'Fotoğrafı değiştir',
			'features.expenses.receiptRemove' => 'Fotoğrafı kaldır',
			'features.expenses.receiptPendingBackend' => 'Gider kaydedildi. Makbuz sunucuya yüklenecek (API hazır olunca).',
			'features.expenses.receiptUploadFailed' => 'Makbuz yüklenemedi. Gider kaydı oluşturuldu.',
			'features.expenses.receiptPickFailed' => 'Fotoğraf seçilemedi',
			'features.expenses.detailTitle' => 'Gider Detayı',
			'features.expenses.fieldCreatedAt' => 'Eklenme zamanı',
			'features.expenses.viewReceipt' => 'Makbuzu gör',
			'features.expenses.receiptMissing' => 'Makbuz yüklenmemiş',
			'features.expenses.targetMonthLabel' => 'Aidata yansıyacağı ay',
			'features.expenses.targetThisMonth' => 'Bu ay',
			'features.expenses.targetNextMonth' => 'Sonraki ay',
			'features.expenses.targetSpecificMonth' => 'Belirli ay',
			'features.expenses.targetPeriodSummary' => '{month} {year} aidatına yansır',
			'features.expenses.pastMonthWarning' => 'Geçmiş aya gider eklendiğinde aidat tutarları güncellenir.',
			'features.expenses.splitMonthsEnable' => 'Birden fazla aya böl',
			'features.expenses.splitMonthsHint' => 'Toplam tutar seçilen aylara eşit dağıtılır',
			'features.expenses.splitMonthsCount' => 'Ay sayısı',
			'features.expenses.splitMonthsUnit' => 'ay',
			'features.expenses.carryForwardDialogTitle' => 'Ödenmiş aidatlar',
			'features.expenses.carryForwardAuto' => 'Farkı sonraki aya ekle',
			'features.expenses.carryForwardManual' => 'Manuel halledeceğim',
			'features.notifications.markAllRead' => 'Tümünü oku',
			'features.notifications.markAllReadLong' => 'Tümünü okundu işaretle',
			'features.notifications.viewRelated' => 'İlgili kayda git',
			'features.notifications.unreadBadge' => 'Yeni',
			'features.notifications.emptyTitle' => 'Bildirim yok',
			'features.notifications.emptySubtitle' => 'Yeni bildirimler burada görünecek',
			'features.notifications.emptyUnreadTitle' => 'Okunmamış bildirim yok',
			'features.notifications.emptyUnreadSubtitle' => 'Tüm bildirimleri okudunuz',
			'features.notifications.loadError' => 'Bildirimler yüklenemedi',
			'features.notifications.filterAll' => 'Tümü',
			'features.notifications.filterUnread' => 'Okunmamış',
			'features.notifications.sectionToday' => 'Bugün',
			'features.notifications.sectionYesterday' => 'Dün',
			'features.notifications.sectionThisWeek' => 'Bu hafta',
			'features.notifications.sectionEarlier' => 'Daha eski',
			'features.notifications.timeNow' => 'Az önce',
			'features.notifications.timeMinuteShort' => 'dk önce',
			'features.notifications.timeHourShort' => 'saat önce',
			'features.notifications.detailLoadError' => 'Detay yüklenemedi',
			'features.notifications.fieldStatus' => 'Durum',
			'features.notifications.fieldCategory' => 'Kategori',
			'features.notifications.fieldApartment' => 'Daire',
			'features.notifications.fieldAmount' => 'Tutar',
			'features.notifications.fieldUploadedBy' => 'Yükleyen',
			'features.notifications.fieldDescription' => 'Açıklama',
			'features.notifications.fieldManagerNote' => 'Yönetici notu',
			'features.notifications.fieldRejectionReason' => 'Red nedeni',
			'features.notifications.fieldLatestUpdate' => 'Son güncelleme',
			'features.notifications.fieldCreatedAt' => 'Oluşturulma',
			'features.notifications.fieldPeriod' => 'Dönem',
			'features.notifications.actionViewTicket' => 'Talebi Görüntüle',
			'features.notifications.actionViewDekont' => 'Dekontu İncele',
			'features.notifications.actionViewDue' => 'Aidatı Gör',
			'features.notifications.typeDueReminder' => 'Aidat hatırlatma',
			'features.notifications.typeDuePaid' => 'Aidat ödendi',
			'features.notifications.typeTicketCreated' => 'Yeni talep',
			'features.notifications.typeTicketUpdate' => 'Talep güncellendi',
			'features.notifications.typeAnnouncement' => 'Duyuru',
			'features.notifications.typeDekontReceived' => 'Yeni dekont',
			'features.notifications.typeDekontNeedsReview' => 'Dekont inceleme',
			'features.notifications.typeDekontMatched' => 'Dekont eşleşti',
			'features.notifications.typeDekontPaymentApplied' => 'Dekont onaylandı',
			'features.notifications.typeExpenseAdded' => 'Yeni gider',
			'features.notifications.typeSystem' => 'Sistem',
			'features.notifications.typeOther' => 'Bildirim',
			'features.notifications.sendTitle' => 'Sakinlere Duyuru',
			'features.notifications.fieldTitle' => 'Başlık',
			'features.notifications.fieldBody' => 'Mesaj',
			'features.notifications.sendButton' => 'Gönder',
			'features.notifications.sendSuccess' => 'Duyuru gönderildi',
			'features.notifications.sendFailed' => 'Duyuru gönderilemedi',
			'features.notifications.fieldRequired' => 'Zorunlu alan',
			'features.notifications.titleTooLong' => 'Başlık en fazla 120 karakter olabilir',
			'features.notifications.bodyTooLong' => 'Mesaj en fazla 2000 karakter olabilir',
			'features.notifications.noBuilding' => 'Önce bir bina ekleyin',
			'features.profile.title' => 'Profil Bilgileri',
			'features.profile.fullName' => 'Ad Soyad',
			'features.profile.email' => 'E-posta',
			'features.profile.phone' => 'Telefon',
			'features.profile.role' => 'Rol',
			'features.profile.languagePref' => 'Dil tercihi',
			'features.profile.notProvided' => 'Belirtilmemiş',
			'features.profile.editHint' => 'Profil düzenleme yakında eklenecek.',
			'features.profile.sectionPersonal' => 'Kişisel Bilgiler',
			'features.profile.sectionAccount' => 'Hesap Bilgileri',
			'features.profile.editPhotoHint' => 'Fotoğrafı değiştirmek için dokunun',
			'features.profile.editTitle' => 'Profili Düzenle',
			'features.profile.phoneOptionalHint' => 'Boş bırakılabilir',
			'features.profile.profileUpdated' => 'Profil bilgileriniz güncellendi.',
			'features.profile.profileUpdateFailed' => 'Profil güncellenemedi. Lütfen tekrar deneyin.',
			'features.profile.profileLoadFailed' => 'Profil bilgileri yüklenemedi.',
			'features.profile.readOnlySection' => 'Buradan düzenlenemez',
			'features.profile.editSheetHint' => 'Yalnızca ad ve telefon güncellenir. Diğer bilgiler yukarıdaki profil ekranında görünür.',
			'features.profile.photoSaved' => 'Profil fotoğrafı bu hesap için kaydedildi.',
			'features.profile.photoRemoved' => 'Profil fotoğrafı kaldırıldı.',
			'features.profile.removePhoto' => 'Profil fotoğrafını kaldır',
			'features.profile.accountCreatedAt' => 'Hesap oluşturulma: {date}',
			'features.subscription.title' => 'Abonelik',
			'features.subscription.statusActive' => 'Aktif',
			'features.subscription.statusExpired' => 'Süresi doldu',
			'features.subscription.statusCancelled' => 'İptal edildi',
			'features.subscription.statusTrial' => 'Deneme',
			'features.subscription.statusUnknown' => 'Bilinmiyor',
			'features.subscription.planMonthly' => 'Aylık plan',
			'features.subscription.planAnnual' => 'Yıllık plan',
			'features.subscription.planUnknown' => 'Plan',
			'features.subscription.renewsOn' => 'Yenileme: {date}',
			'features.subscription.noSubscription' => 'Henüz abonelik kaydı yok.',
			'features.subscription.backendPending' => 'Abonelik sunucuya henüz bağlanmadı. Satın alma yakında açılacak.',
			'features.subscription.purchaseComingSoon' => 'Satın alma yakında',
			'features.subscription.purchaseMonthly' => 'Aylık abone ol',
			'features.subscription.purchaseAnnual' => 'Yıllık abone ol',
			'features.subscription.purchaseSuccess' => 'Satın alma tamamlandı. Abonelik birkaç dakika içinde güncellenir.',
			'features.subscription.purchaseCancelled' => 'Satın alma iptal edildi.',
			'features.subscription.purchasesUnavailable' => 'Satın alma bu sürümde henüz etkin değil.',
			'features.subscription.loadFailed' => 'Abonelik bilgisi alınamadı.',
			'features.subscription.purchaseProductNotFound' => 'Abonelik ürünü bulunamadı. Uygulamayı Play Store test linkinden yükleyin ve birkaç saat bekleyin.',
			'features.subscription.purchaseStoreError' => 'Google Play ödeme şu an kullanılamıyor. Test hesabınızı kontrol edin.',
			'features.subscription.purchaseFailed' => 'Satın alma tamamlanamadı. Lütfen tekrar deneyin.',
			'features.subscription.sectionSelectPlan' => 'Plan seç ve satın al',
			'features.subscription.cycleMonthly' => 'Her ay yenilenir',
			'features.subscription.cycleAnnual' => 'Her yıl yenilenir',
			'features.subscription.featureUnlimitedUnits' => 'Sınırsız daire',
			'features.subscription.featureDuesTracking' => 'Aidat takibi',
			'features.subscription.featureAdvancedReports' => 'Gelişmiş raporlar',
			'features.subscription.featurePrioritySupport' => 'Öncelikli destek',
			'features.subscription.trialActive' => 'Deneme süresi aktif',
			'features.subscription.subscriptionActive' => 'Abonelik aktif',
			'features.subscription.subscriptionCancelled' => 'Abonelik iptal edildi',
			'features.subscription.subscriptionExpired' => 'Abonelik süresi doldu',
			'features.subscription.noActiveSubscription' => 'Aktif abonelik yok',
			'features.subscription.daysLeft' => '{count} gün kaldı',
			'features.subscription.planLabel' => 'PLAN',
			'features.subscription.statusLabel' => 'DURUM',
			'features.subscription.renewalLabel' => 'YENİLEME',
			'features.subscription.planAnnualShort' => 'Yıllık',
			'features.subscription.planMonthlyShort' => 'Aylık',
			'features.subscription.priceExclVatMonth' => 'KDV hariç / ay',
			'features.subscription.priceExclVatYear' => 'KDV hariç / yıl',
			'features.subscription.savingBadge' => '{amount} tasarruf',
			'features.subscription.bestValueBadge' => 'En avantajlı',
			'features.subscription.purchaseMonthlyCta' => 'Aylık aboneliği satın al',
			'features.subscription.purchaseAnnualCta' => 'Yıllık aboneliği satın al',
			'features.subscription.kdvNote' => 'Fiyatlara KDV dahil değildir · İstediğin zaman iptal edebilirsin',
			'features.subscription.guestUser' => 'Kullanıcı',
			'features.subscription.priceUnavailable' => '—',
			'features.subscription.loadingPlans' => 'Planlar yükleniyor…',
			'features.subscription.purchasesDisabledHint' => 'Satın alma bu sürümde henüz etkin değil.',
			'features.reports.menuDownload' => 'Rapor indir',
			'features.reports.sheetTitle' => 'PDF rapor',
			'features.reports.reportTypeLabel' => 'Rapor türü',
			'features.reports.typeMonthly' => 'Aylık özet',
			'features.reports.typeAnnual' => 'Yıllık özet',
			'features.reports.periodHintMonthly' => '{month} {year} dönemi için rapor',
			'features.reports.periodHintAnnual' => '{year} yılı için yıllık rapor',
			'features.reports.fieldMonth' => 'Ay',
			'features.reports.fieldYear' => 'Yıl',
			'features.reports.selectMonthTitle' => 'Ay seçin',
			'features.reports.selectYearTitle' => 'Yıl seçin',
			'features.reports.download' => 'Raporu göster',
			'features.reports.downloading' => 'Rapor hazırlanıyor…',
			'features.reports.previewTitle' => 'Rapor önizleme',
			'features.reports.pdfPreviewHint' => 'İki parmakla yakınlaştırıp kaydırabilirsiniz.',
			'features.reports.pdfPreviewUnavailable' => 'PDF bu cihazda açılamadı. Alttaki «Raporu paylaş» ile başka bir uygulamada açabilirsiniz.',
			'features.reports.shareReport' => 'Raporu paylaş',
			'features.reports.shareFailed' => 'Rapor paylaşılamadı. Lütfen tekrar deneyin.',
			'features.reports.failed' => 'Rapor oluşturulamadı. Lütfen tekrar deneyin.',
			'features.dashboard.allBuildings' => 'Tüm Binalar',
			'features.dashboard.selectBuilding' => 'Bina seç',
			'features.dashboard.searchBuildings' => 'Bina adı veya adres ara',
			'features.dashboard.buildingPickerTapHint' => 'Dokunarak bina arayın ve seçin',
			'features.dashboard.allBuildingsSummary' => '{count} bina',
			'features.dashboard.buildingUnitsSummary' => '{apartments} daire',
			'features.dashboard.collectionRate' => 'Tahsilat Oranı',
			'features.dashboard.overduePayments' => 'Geciken Ödeme',
			'features.dashboard.openTicketRequests' => 'Açık Arıza Talebi',
			'features.dashboard.monthTotalExpense' => 'Bu Ay Toplam Gider',
			'features.dashboard.pendingDekonts' => 'Bekleyen Dekont',
			'features.dashboard.duesCollectionStatus' => 'Aidat Tahsilat Durumu',
			'features.dashboard.incomeExpenseComparison' => 'Gelir / Gider Karşılaştırması',
			'features.dashboard.last6Months' => 'Son 6 Ay',
			'features.dashboard.collectedDues' => 'Toplanan Aidat',
			'features.dashboard.totalExpense' => 'Toplam Gider',
			'features.dashboard.ticketStatusTitle' => 'Arıza Talepleri Durumu',
			'features.dashboard.ticketOpen' => 'Açık',
			'features.dashboard.ticketInProgress' => 'İşlemde',
			'features.dashboard.ticketResolved' => 'Çözüldü',
			'features.dashboard.overdueApartments' => 'Ödemesi Geciken Daireler',
			'features.dashboard.apartmentCountBadge' => '{count} daire',
			'features.dashboard.legendPaid' => 'Ödendi',
			'features.dashboard.legendOverdue' => 'Gecikmiş',
			'features.dashboard.legendPending' => 'Bekliyor',
			'features.dashboard.legendUnit' => '{count} aidat',
			'features.dashboard.remind' => 'Hatırlat',
			'features.dashboard.remindSent' => 'Hatırlatma gönderildi',
			'features.dashboard.remindNoRecipient' => 'Bu dairede hatırlatma gönderilecek sakin bulunamadı.',
			'features.dashboard.apartmentTitle' => 'Daire {number}',
			'features.dashboard.apartmentWithFloor' => 'Daire {number} · {floor}. Kat',
			'features.dashboard.noOverdueApartments' => 'Geciken ödeme bulunmuyor',
			'features.dashboard.noChartData' => 'Henüz yeterli veri yok',
			'features.dashboard.seeMoreOverdue' => 'Daha fazlası (+{count})',
			'features.dashboard.payNow' => 'Şimdi Öde',
			'features.dashboard.overduePaymentsBadge' => '{count} gecikmiş ödeme',
			'features.dashboard.featuredDuePeriod' => '{month} {year} aidatı',
			'features.faz2.sectionTitle' => 'Faz 2',
			'features.faz2.tickets' => 'Talepler',
			'features.faz2.expenses' => 'Giderler',
			'features.faz2.announcement' => 'Duyuru',
			'legal.companyName' => 'Vefa Yazılım',
			'legal.contactEmail' => 'store@vefayazilim.com',
			'legal.contactBlock' => 'Veri sorumlusu: Vefa Yazılım\nE-posta: store@vefayazilim.com',
			'legal.updatedLabel' => 'Son güncelleme',
			'legal.updatedDate' => 'Haziran 2026',
			'legal.privacyIntro' => 'Bu metin, Vefa Yazılım tarafından sunulan AidatPanel mobil uygulamasını kullanırken kişisel verilerinizin nasıl işlendiğini açıklar. Uygulamayı kullanmaya devam ederek bu politikayı okuduğunuzu kabul etmiş sayılırsınız.',
			'legal.privacyS1Title' => '1. Veri sorumlusu',
			'legal.privacyS1Body' => 'AidatPanel hizmeti kapsamında kişisel verileriniz, veri sorumlusu Vefa Yazılım tarafından 6698 sayılı Kişisel Verilerin Korunması Kanunu (KVKK) ve ilgili mevzuata uygun olarak işlenir. KVKK ve gizlilik talepleriniz için: store@vefayazilim.com',
			'legal.privacyS2Title' => '2. Toplanan veriler',
			'legal.privacyS2Body' => 'Hesap bilgileri (ad, e-posta, telefon, dil tercihi), apartman ve daire ilişkisi, aidat ve ödeme kayıtları, destek talepleri, duyuru ve bildirim tercihleri, dekont ve makbuz görselleri (yüklediğinizde), cihaz bildirim anahtarı (FCM) ve güvenli oturum bilgileri (şifrelenmiş token) işlenebilir.',
			'legal.privacyS3Title' => '3. İşleme amaçları',
			'legal.privacyS3Body' => 'Verileriniz; aidat ve gider yönetimi, tahsilat ve dekont süreçleri, apartman içi iletişim ve duyurular, kimlik doğrulama, hizmet güvenliği, yasal yükümlülükler ve size bildirim göndermek amacıyla işlenir.',
			'legal.privacyS4Title' => '4. Saklama ve güvenlik',
			'legal.privacyS4Body' => 'Veriler güvenli sunucularda saklanır; iletişim HTTPS ile şifrelenir. Oturum bilgileri cihazınızda güvenli depolamada tutulur. Yasal zorunluluklar dışında veriler, hizmet ilişkisi süresince ve mevzuattaki süreler boyunca muhafaza edilir.',
			'legal.privacyS5Title' => '5. Paylaşım',
			'legal.privacyS5Body' => 'Kişisel verileriniz üçüncü taraflara satılmaz. Yalnızca hizmetin sunulması için gerekli altyapı sağlayıcıları (barındırma, bildirim servisi vb.) ve kanunen yetkili kurumlarla, mevzuata uygun şekilde paylaşılabilir.',
			'legal.privacyS6Title' => '6. Haklarınız',
			'legal.privacyS6Body' => 'KVKK kapsamında verilerinize erişme, düzeltme, silme, işlemeyi kısıtlama ve itiraz etme haklarına sahipsiniz. Hesap kapatma (soft delete) Ayarlar üzerinden yapılabilir; yasal saklama gerektiren kayıtlar anonimleştirilerek tutulabilir. Başvurularınızı store@vefayazilim.com adresine iletebilirsiniz.',
			'legal.kvkkIntro' => '6698 sayılı Kanun uyarınca Vefa Yazılım tarafından işlenen kişisel verilerinize ilişkin aydınlatma metnidir.',
			'legal.kvkkS1Title' => 'Veri sorumlusu ve iletişim',
			'legal.kvkkS1Body' => 'AidatPanel kapsamındaki kişisel veri işleme faaliyetleri için veri sorumlusu Vefa Yazılım’dır. KVKK taleplerinizi store@vefayazilim.com adresine veya uygulamada kayıtlı e-posta adresinizle iletebilirsiniz.',
			'legal.kvkkS2Title' => 'İşlenen veri kategorileri',
			'legal.kvkkS2Body' => 'Kimlik ve iletişim, müşteri işlem (aidat, ödeme, gider), görsel kayıt (dekont), işlem güvenliği (log, token) ve pazarlama/iletişim (bildirim izni) kategorilerinde veri işlenebilir.',
			'legal.kvkkS3Title' => 'İşleme amaçları ve hukuki sebepler',
			'legal.kvkkS3Body' => 'Verileriniz; sözleşmenin kurulması ve ifası, hukuki yükümlülük, meşru menfaat ve açık rızanız (bildirimler gibi) kapsamında işlenir.',
			'legal.kvkkS4Title' => 'Aktarım',
			'legal.kvkkS4Body' => 'Veriler, yurt içinde barındırma ve teknik hizmet sağlayıcılarına, hizmetin gerektirdiği ölçüde aktarılabilir. Aktarım yapılan taraflarla gerekli güvenlik önlemleri alınır.',
			'legal.kvkkS5Title' => 'Toplama yöntemi',
			'legal.kvkkS5Body' => 'Veriler; uygulama formları, otomatik kayıtlar, yüklediğiniz belgeler ve bildirim altyapısı aracılığıyla elektronik ortamda toplanır.',
			'legal.kvkkS6Title' => 'İlgili kişi hakları',
			'legal.kvkkS6Body' => 'Kanunun 11. maddesi kapsamındaki haklarınızı kullanmak için talebinizi Vefa Yazılım’a (store@vefayazilim.com) iletebilirsiniz; başvurularınız mevzuattaki sürelerde yanıtlanır.',
			'legal.helpIntro' => 'Yardım merkezi hazırlanıyor',
			'legal.helpBody' => 'Sık sorulan sorular, adım adım rehberler ve destek kanalları yakında bu bölümde yer alacak. Uygulama desteği için: store@vefayazilim.com (Vefa Yazılım). Acil apartman işleri için yöneticiniz veya site yönetiminizle iletişime geçebilirsiniz.',
			'db_context.user_entry' => 'Kayıt: {value}',
			'db_context.building_name' => 'Bina: {value}',
			'db_context.apartment_label' => 'Daire: {value}',
			'db_context.code_value' => 'Kod: {value}',
			'db_context.expiry_date' => 'Son kullanma: {value}',
			_ => null,
		};
	}
}
