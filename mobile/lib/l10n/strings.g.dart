/// Generated file. Do not edit.
///
/// Original: lib/l10n
/// To regenerate, run: `dart run slang`
///
/// Locales: 2
/// Strings: 1408 (704 per locale)
///
/// Built on 2026-06-02 at 16:10 UTC

// coverage:ignore-file
// ignore_for_file: type=lint

import 'package:flutter/widgets.dart';
import 'package:slang/builder/model/node.dart';
import 'package:slang_flutter/slang_flutter.dart';
export 'package:slang_flutter/slang_flutter.dart';

const AppLocale _baseLocale = AppLocale.en;

/// Supported locales, see extension methods below.
///
/// Usage:
/// - LocaleSettings.setLocale(AppLocale.en) // set locale
/// - Locale locale = AppLocale.en.flutterLocale // get flutter locale from enum
/// - if (LocaleSettings.currentLocale == AppLocale.en) // locale check
enum AppLocale with BaseAppLocale<AppLocale, Translations> {
	en(languageCode: 'en', build: Translations.build),
	tr(languageCode: 'tr', build: _StringsTr.build);

	const AppLocale({required this.languageCode, this.scriptCode, this.countryCode, required this.build}); // ignore: unused_element

	@override final String languageCode;
	@override final String? scriptCode;
	@override final String? countryCode;
	@override final TranslationBuilder<AppLocale, Translations> build;

	/// Gets current instance managed by [LocaleSettings].
	Translations get translations => LocaleSettings.instance.translationMap[this]!;
}

/// Method A: Simple
///
/// No rebuild after locale change.
/// Translation happens during initialization of the widget (call of t).
/// Configurable via 'translate_var'.
///
/// Usage:
/// String a = t.someKey.anotherKey;
/// String b = t['someKey.anotherKey']; // Only for edge cases!
Translations get t => LocaleSettings.instance.currentTranslations;

/// Method B: Advanced
///
/// All widgets using this method will trigger a rebuild when locale changes.
/// Use this if you have e.g. a settings page where the user can select the locale during runtime.
///
/// Step 1:
/// wrap your App with
/// TranslationProvider(
/// 	child: MyApp()
/// );
///
/// Step 2:
/// final t = Translations.of(context); // Get t variable.
/// String a = t.someKey.anotherKey; // Use t variable.
/// String b = t['someKey.anotherKey']; // Only for edge cases!
class TranslationProvider extends BaseTranslationProvider<AppLocale, Translations> {
	TranslationProvider({required super.child}) : super(settings: LocaleSettings.instance);

	static InheritedLocaleData<AppLocale, Translations> of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context);
}

/// Method B shorthand via [BuildContext] extension method.
/// Configurable via 'translate_var'.
///
/// Usage (e.g. in a widget's build method):
/// context.t.someKey.anotherKey
extension BuildContextTranslationsExtension on BuildContext {
	Translations get t => TranslationProvider.of(this).translations;
}

/// Manages all translation instances and the current locale
class LocaleSettings extends BaseFlutterLocaleSettings<AppLocale, Translations> {
	LocaleSettings._() : super(utils: AppLocaleUtils.instance);

	static final instance = LocaleSettings._();

	// static aliases (checkout base methods for documentation)
	static AppLocale get currentLocale => instance.currentLocale;
	static Stream<AppLocale> getLocaleStream() => instance.getLocaleStream();
	static AppLocale setLocale(AppLocale locale, {bool? listenToDeviceLocale = false}) => instance.setLocale(locale, listenToDeviceLocale: listenToDeviceLocale);
	static AppLocale setLocaleRaw(String rawLocale, {bool? listenToDeviceLocale = false}) => instance.setLocaleRaw(rawLocale, listenToDeviceLocale: listenToDeviceLocale);
	static AppLocale useDeviceLocale() => instance.useDeviceLocale();
	@Deprecated('Use [AppLocaleUtils.supportedLocales]') static List<Locale> get supportedLocales => instance.supportedLocales;
	@Deprecated('Use [AppLocaleUtils.supportedLocalesRaw]') static List<String> get supportedLocalesRaw => instance.supportedLocalesRaw;
	static void setPluralResolver({String? language, AppLocale? locale, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver}) => instance.setPluralResolver(
		language: language,
		locale: locale,
		cardinalResolver: cardinalResolver,
		ordinalResolver: ordinalResolver,
	);
}

/// Provides utility functions without any side effects.
class AppLocaleUtils extends BaseAppLocaleUtils<AppLocale, Translations> {
	AppLocaleUtils._() : super(baseLocale: _baseLocale, locales: AppLocale.values);

	static final instance = AppLocaleUtils._();

	// static aliases (checkout base methods for documentation)
	static AppLocale parse(String rawLocale) => instance.parse(rawLocale);
	static AppLocale parseLocaleParts({required String languageCode, String? scriptCode, String? countryCode}) => instance.parseLocaleParts(languageCode: languageCode, scriptCode: scriptCode, countryCode: countryCode);
	static AppLocale findDeviceLocale() => instance.findDeviceLocale();
	static List<Locale> get supportedLocales => instance.supportedLocales;
	static List<String> get supportedLocalesRaw => instance.supportedLocalesRaw;
}

// translations

// Path: <root>
class Translations implements BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations.build({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	// Translations
	late final _StringsCommonEn common = _StringsCommonEn._(_root);
	late final _StringsValidationEn validation = _StringsValidationEn._(_root);
	late final _StringsFeaturesEn features = _StringsFeaturesEn._(_root);
	late final _StringsLegalEn legal = _StringsLegalEn._(_root);
	late final _StringsDbContextEn db_context = _StringsDbContextEn._(_root);
}

// Path: common
class _StringsCommonEn {
	_StringsCommonEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get logout => 'Logout';
	String get cancel => 'Cancel';
	String get confirm => 'Confirm';
	String get save => 'Save';
	String get delete => 'Delete';
	String get edit => 'Edit';
	String get close => 'Close';
	String get yes => 'Yes';
	String get no => 'No';
	String get register => 'Register';
	String get login => 'Login';
	String get join => 'Join';
	String get confirmMessage => 'Are you sure?';
	String get logoutConfirm => 'Are you sure you want to logout?';
	String get logoutSuccess => 'Signed out successfully.';
	String get logoutAllDevices => 'Sign out other devices';
	String get logoutAllDevicesConfirm => 'Sessions on your other phones and tablets will end. You will stay signed in on this device.';
	String get logoutAllDevicesSuccess => 'Other devices have been signed out.';
	String get logoutAllDevicesFailed => 'Could not complete this action. Please try again.';
	String get account => 'Account';
	String get editProfile => 'Edit Profile';
	String get changePassword => 'Change Password';
	String get language => 'Language';
	String get turkish => 'Turkish';
	String get notifications => 'Notifications';
	String get info => 'Info';
	String get privacyPolicy => 'Privacy Policy';
	String get kvkk => 'KVKK';
	String get helpSupport => 'Help & Support';
	String get about => 'About';
	String get comingSoon => 'This feature will be added soon';
	String get multiLanguageComingSoon => 'Multi-language support coming soon';
	String get copyright => ' 2026 AidatPanel\nAll rights reserved.';
	String get aboutDescription => 'Dues management platform for Turkish apartment and site managers.';
	String get manager => 'Manager';
	String get resident => 'Resident';
	String get tokenExpiryTest => 'Token Expiry Check (Test)';
	String get tokenExpired => 'Token EXPIRED! Redirecting to login screen.';
	String get tokenActive => 'Token active! Remaining time';
	String get pressBackAgainToExit => 'Press back again to exit';
	String get loading => 'Loading…';
	String get loadingBuildings => 'Loading buildings…';
	String get loadFailed => 'Failed to load';
	String get unexpectedError => 'Something went wrong. Please try again.';
	String get rateLimitHint => 'The server is currently busy. We\'ll retry shortly.';
	String get tryAgain => 'Try Again';
	String get home => 'Home';
	String get buildings => 'Buildings';
	String get dues => 'Dues';
	String get settings => 'Settings';
	String get user => 'User';
	String get welcome => 'Welcome';
	String get managedBuildings => 'Managed Buildings';
	String get issues => 'Issues';
	String get issuesTab => 'Issues Tab';
	String get apartment => 'Apartment';
	String get addBuilding => 'Add Building';
	String get inviteCode => 'Invite Code';
	String get myBuildings => 'My Buildings';
	String get apartments => 'Apartments';
	String get collection => 'Collection';
	String get monthlyDues => 'Monthly Dues';
	String get duesTab => 'Dues Tab';
	String get totalApartments => 'Total Apartments';
	String get occupiedApartments => 'Occupied Apartments';
	String get duesCollection => 'Dues Collection';
	String get totalDues => 'Total Dues';
	String get recentTransactions => 'Recent Transactions';
	String get paid => 'Paid';
	String get pending => 'Pending';
	String get overdue => 'Overdue';
	String get balance => 'Balance';
	String get amountDue => 'Amount Due';
	String get lastPayment => 'Last Payment';
	String get makePayment => 'Make Payment';
	String get bills => 'Bills';
	String get support => 'Support';
	String get quickActions => 'Quick actions';
	String get residentName => 'Resident Name';
	String get addBuildingNew => 'Add New Building';
	String get basicInfo => 'Basic Info';
	String get buildingName => 'Building Name';
	String get buildingNameHint => 'Ex: Güneş Apartmanı';
	String get location => 'Location';
	String get streetAddress => 'Street Address';
	String get streetAddressHint => 'Ex: Bağdat Cad. No: 123';
	String get details => 'Details';
	String get floorCount => 'Floor Count';
	String get floorCountHint => 'Between 1 and 200';
	String get apartmentsPerFloor => 'Apartments Per Floor';
	String get apartmentsPerFloorHint => 'Between 1 and 50';
	String get floorRangeError => 'Floor count must be between 1 and 200';
	String get apartmentsPerFloorRangeError => 'Apartments per floor must be between 1 and 50';
	String get buildingAddFailed => 'Could not add building. Please try again.';
	String get monthlyDuesLabel => 'Monthly Dues (₺)';
	String get monthlyDuesHint => 'Ex: 1000';
	String get createBuilding => 'Create Building';
	String get cancelBtn => 'Cancel';
	String get cityRequired => 'City *';
	String get selectCity => 'Select City';
	String get districtRequired => 'District *';
	String get selectDistrict => 'Select District';
	String get selectCityFirst => 'Select city first';
	String get selectCityTitle => 'Select City';
	String get selectDistrictTitle => 'Select District';
	String get search => 'Search...';
	String get noResults => 'No results found';
	String get fieldRequired => 'cannot be empty';
	String get fillRequiredFields => 'Please fill required fields';
	String get selectCityAndDistrict => 'You must select city and district';
	String get floorApartmentMustBePositive => 'Floor count and apartment count must be greater than 0';
	String get buildingAddedSuccess => 'Building added successfully';
	String get createInviteCode => 'Create Invite Code';
	String get whichBuildingForCode => 'Which building to generate code for?';
	String get whichApartmentForCode => 'Which apartment to generate code for?';
	String get noApartmentsInBuilding => 'No apartments added to this building yet';
	String get activeCodeBadge => 'Active Code';
	String get occupiedBadge => 'Occupied';
	String get emptyBadge => 'Empty';
	String get activeCodePrefix => 'Active code';
	String get residentPrefix => 'Resident';
	String get emptyApartment => 'Empty apartment';
	String get codeRevoked => 'Code revoked';
	String get codeCopied => 'Code copied';
	String get clipboardCopied => 'Message copied to clipboard';
	String get expiresAtPrefix => 'Expires at';
	String get remainingPrefix => 'Remaining';
	String get buildingDetail => 'Building Detail';
	String get residents => 'Residents';
	String get apartmentsBadge => 'Apartments';
	String get emptyApartmentText => 'Empty Apartment';
	String get vacantBadge => 'Vacant';
	String get phoneNotShared => 'Phone not shared';
	String get residentDetailsLink => 'Details..';
	String get residentDetailsSheetTitle => 'Resident information';
	String get apartmentDetailsSheetTitle => 'Apartment information';
	String get noResidentAssigned => 'No resident assigned';
	String get noApartmentsYet => 'No apartments added yet';
	String get paidStatus => 'Paid';
	String get pendingStatus => 'Pending';
	String get overdueStatus => 'Overdue';
	String get waivedStatus => 'Waived';
	String get all => 'All';
	String get status => 'Status';
	String get month => 'Month';
	String get monthJanuary => 'January';
	String get monthFebruary => 'February';
	String get monthMarch => 'March';
	String get monthApril => 'April';
	String get monthMay => 'May';
	String get monthJune => 'June';
	String get monthJuly => 'July';
	String get monthAugust => 'August';
	String get monthSeptember => 'September';
	String get monthOctober => 'October';
	String get monthNovember => 'November';
	String get monthDecember => 'December';
	String get allMonths => 'All months';
	String get year => 'Year';
	String get allYears => 'All years';
	String get note => 'Note';
	String get myDuesHistory => 'My Dues History';
	String get currentPeriodDue => 'Current due';
	String get myPastDues => 'My past dues';
	String get buildingDues => 'Building Dues';
	String get noDuesYet => 'No dues records yet';
	String get duesUpdated => 'Dues status updated';
	String get amount => 'Amount';
	String get updateDueAmount => 'Update Due Amount';
	String get dueAmountUpdated => 'Due amount updated';
	String get dueAmountUpdateFailed => 'Could not update due amount';
	String get dueDay => 'Due Day (1-28)';
	String get selectDueDay => 'Select day';
	String get affectCurrentDues => 'Apply to pending dues';
	String get affectCurrentDuesHint => 'When enabled, current PENDING due amounts are updated to the new amount.';
	String get dueUpdateNeedAmountOrDay => 'Enter an amount or select a due day to update.';
	String get dueUpdateNeedStoredAmount => 'This building has no saved amount yet. Enter an amount before updating the due day only.';
	String get dueAmountInvalidPositive => 'Enter a valid amount.';
	String get dueDayOutOfRange => 'Due day must be between 1 and 28.';
	String get update => 'Update';
	String get overdueDays => 'days overdue';
	String get dueDateLabel => 'Due date';
	String get perMonth => '/ month';
	String get floorLabel => 'FLOOR';
	String get apartmentLabel => 'APT';
	String get turkishLanguage => 'Türkçe';
	String get englishLanguage => 'English';
	String get stepBuilding => 'Building';
	String get stepApartment => 'Apartment';
	String get stepCode => 'Code';
	String get editBuilding => 'Edit Building';
	String get deleteBuilding => 'Delete Building';
	String get buildingUpdated => 'Building updated';
	String get buildingDeleted => 'Building deleted';
	String get buildingUpdateFailed => 'Could not update building';
	String get buildingDeleteFailed => 'Could not delete building';
	String get buildingDeleteFailedFK => 'Cannot delete this building: apartments, residents, or dues records still exist. Clean up apartments/dues first.';
	String get deleteBuildingHeader => 'This action cannot be undone.';
	String get deleteBuildingTypeHint => 'To confirm, type the building name below exactly:';
	String get deleteBuildingTypeFieldLabel => 'Building name';
	String get buildingNameMismatch => 'What you typed does not match the building name.';
	String get editApartment => 'Edit Apartment';
	String get deleteApartment => 'Delete Apartment';
	String get apartmentUpdated => 'Apartment updated';
	String get apartmentDeleted => 'Apartment deleted';
	String get apartmentUpdateFailed => 'Could not update apartment';
	String get apartmentDeleteFailed => 'Could not delete apartment';
	String get apartmentDeleteFailedFK => 'Cannot delete this apartment: resident or dues records exist. Wait for the resident to close their account and clean up dues.';
	String get deleteApartmentConfirm => 'Are you sure you want to delete this apartment?';
	String get apartmentNumberLabel => 'Apt No (e.g. 5A)';
	String get floorLabel2 => 'Floor (optional)';
	String get floorOptional => 'Floor (-5 to 200)';
	String get buildingNameField => 'Building name';
	String get buildingAddressField => 'Address';
	String get buildingCityField => 'City';
	String get monthlyDuesPerApartment => 'Monthly dues / apt';
	String get remove => 'Remove';
	String get removeResident => 'Remove Resident';
	String get removeResidentConfirm => 'Are you sure you want to remove this resident from the apartment?';
	String get removeResidentNote => 'The resident\'s account will not be deleted; only their link to this apartment is removed. Past dues records are kept. The resident can join another apartment later using an invite code.';
	String get residentRemoved => 'Resident removed from apartment';
	String get residentRemoveFailed => 'Could not remove resident';
	String get residentRemoveForbidden => 'You are not allowed to perform this action. Only the building manager can remove residents.';
	String get residentRemoveNotFound => 'No resident to remove from this apartment.';
	String get multiSelectResidents => 'Select multiple';
	String get multiSelectTapHint => 'Tap the card to select or clear';
	String get selectTriggerShort => 'Select';
	String get selectedCountLabel => 'selected';
	String get selectionRemoveHint => 'Pick the residents you want to remove';
	String get selectionDeleteIbanHint => 'Pick the IBANs you want to delete';
	String get removeSelectedResidents => 'Remove selected';
	String get removeSelectedResidentsTitle => 'Remove selected residents';
	String get removeSelectedResidentsMessage => 'Residents in the apartments listed below will be unlinked from their apartments. Accounts are not deleted—only the connection to this building is removed. Past dues records are kept.';
	String get removeSelectedResidentsAffectedListTitle => 'Apartments affected';
	String get removeSelectedResidentsListUnavailable => 'The apartment list could not be loaded. The count is shown below. If you confirm, removals will still proceed.';
	String get pickResidentsFirst => 'Select at least one occupied apartment from the list first';
	String get removeSelectedProgress => 'Working…';
	String get removeSelectedSuccess => 'Selected residents were removed from their apartments';
	String get removeSelectedFailed => 'Could not finish removing the selected residents';
	String get currentPassword => 'Current Password';
	String get newPassword => 'New Password';
	String get newPasswordConfirm => 'New Password (Repeat)';
	String get currentPasswordRequired => 'Enter your current password';
	String get passwordsMustDiffer => 'New password cannot be the same as the old one';
	String get changePasswordTitle => 'Change Password';
	String get changePasswordSubtitle => 'Update your password regularly to keep your account secure.';
	String get changePasswordSuccess => 'Your password has been changed. Please sign in again with your new password.';
	String get changePasswordFailed => 'Could not change password. Please try again.';
	String get changePasswordWrongCurrent => 'Current password is incorrect.';
	String get deleteAccount => 'Close My Account';
	String get deleteAccountTitle => 'Do you want to close your account?';
	String get deleteAccountWarning => 'This action cannot be undone. Your personal data will be removed, but for legal reasons some records (such as dues history) are kept anonymously.';
	String get deleteAccountTypeHint => 'To confirm, type "CLOSE MY ACCOUNT" below:';
	String get deleteAccountTypePhrase => 'CLOSE MY ACCOUNT';
	String get deleteAccountTypeMismatch => 'What you typed does not match.';
	String get deleteAccountConfirmButton => 'Close My Account';
	String get deleteAccountSuccess => 'Your account has been closed. Thank you for using AidatPanel.';
	String get deleteAccountFailed => 'Could not close account. Please try again.';
	String get deleteAccountFailedManager => 'You first need to delete the buildings you manage or transfer them to another manager.';
	String get dangerZone => 'Danger Zone';
	String get forgotPassword => 'Forgot Password';
	String get forgotPasswordTitle => 'Forgot Password';
	String get forgotPasswordSubtitle => 'Enter your registered email and we\'ll send you a reset code.';
	String get forgotPasswordSuccess => 'If this email is registered, a reset code has been sent. Please check your inbox.';
	String get sendResetCode => 'Send Code';
	String get iHaveACode => 'I already have a code';
	String get resetPasswordTitle => 'Set New Password';
	String get resetPasswordSubtitle => 'Enter the 6-character code from your email and a new password.';
	String get resetCode => 'Reset Code';
	String get resetCodeHint => 'ABC123';
	String get resetCodeRequired => 'Reset code required';
	String get resetCodeInvalid => 'Code must be 6 characters';
	String get resetPasswordSuccess => 'Your password has been reset. You can sign in with your new password.';
	String get resetPasswordFailed => 'Could not reset password. The code may be invalid or expired.';
	String get resetPasswordSubmit => 'Reset Password';
	String get backToLogin => 'Back to login';
}

// Path: validation
class _StringsValidationEn {
	_StringsValidationEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get emailRequired => 'Email address cannot be empty';
	String get emailInvalid => 'Please enter a valid email address';
	String get emailTooLong => 'Email address is too long';
	String get phoneRequired => 'Phone number cannot be empty';
	String get phoneInvalid => 'Phone number must be 10 digits';
	String get passwordRequired => 'Password cannot be empty';
	String get passwordTooShort => 'Password must be at least 6 characters';
	String get passwordTooLong => 'Password is too long';
	String get passwordUppercaseRequired => 'Password must contain at least 1 uppercase letter';
	String get passwordLowercaseRequired => 'Password must contain at least 1 lowercase letter';
	String get passwordNumberRequired => 'Password must contain at least 1 number';
	String get passwordSpecialCharRequired => 'Password must contain at least 1 special character';
}

// Path: features
class _StringsFeaturesEn {
	_StringsFeaturesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _StringsFeaturesBuildingsEn buildings = _StringsFeaturesBuildingsEn._(_root);
	late final _StringsFeaturesAuthEn auth = _StringsFeaturesAuthEn._(_root);
	late final _StringsFeaturesApartmentsEn apartments = _StringsFeaturesApartmentsEn._(_root);
	late final _StringsFeaturesTicketsEn tickets = _StringsFeaturesTicketsEn._(_root);
	late final _StringsFeaturesDekontEn dekont = _StringsFeaturesDekontEn._(_root);
	late final _StringsFeaturesExpensesEn expenses = _StringsFeaturesExpensesEn._(_root);
	late final _StringsFeaturesNotificationsEn notifications = _StringsFeaturesNotificationsEn._(_root);
	late final _StringsFeaturesProfileEn profile = _StringsFeaturesProfileEn._(_root);
	late final _StringsFeaturesSubscriptionEn subscription = _StringsFeaturesSubscriptionEn._(_root);
	late final _StringsFeaturesFaz2En faz2 = _StringsFeaturesFaz2En._(_root);
}

// Path: legal
class _StringsLegalEn {
	_StringsLegalEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get companyName => 'Vefa Yazılım';
	String get contactEmail => 'store@vefayazilim.com';
	String get contactBlock => 'Data controller: Vefa Yazılım\nEmail: store@vefayazilim.com';
	String get updatedLabel => 'Last updated';
	String get updatedDate => 'June 2026';
	String get privacyIntro => 'This policy explains how Vefa Yazılım processes your personal data when you use the AidatPanel mobile app. By continuing to use the app, you acknowledge that you have read this policy.';
	String get privacyS1Title => '1. Data controller';
	String get privacyS1Body => 'Your personal data is processed by Vefa Yazılım as the data controller for AidatPanel, in compliance with applicable data protection laws, including Turkish KVKK where applicable. For privacy and KVKK requests: store@vefayazilim.com';
	String get privacyS2Title => '2. Data we collect';
	String get privacyS2Body => 'We may process account details (name, email, phone, language), building and apartment association, dues and payment records, support tickets, announcements and notification preferences, receipt images you upload, device push token (FCM), and secure session tokens.';
	String get privacyS3Title => '3. Purposes';
	String get privacyS3Body => 'Data is used for dues and expense management, payment and receipt workflows, in-building communication, authentication, service security, legal obligations, and sending notifications you enable.';
	String get privacyS4Title => '4. Retention and security';
	String get privacyS4Body => 'Data is stored on secure servers; communication uses HTTPS. Session data is kept in secure device storage. Data is retained for the service relationship and as required by law.';
	String get privacyS5Title => '5. Sharing';
	String get privacyS5Body => 'We do not sell your data. It may be shared only with infrastructure providers necessary to run the service (hosting, push notifications, etc.) and authorities when legally required.';
	String get privacyS6Title => '6. Your rights';
	String get privacyS6Body => 'You may request access, correction, deletion, or restriction of processing. Account closure (soft delete) is available in Settings; records that must be kept by law may be stored in anonymized form. Submit requests to store@vefayazilim.com.';
	String get kvkkIntro => 'This notice is provided under Turkish Personal Data Protection Law No. 6698 (KVKK) for processing by Vefa Yazılım.';
	String get kvkkS1Title => 'Data controller and contact';
	String get kvkkS1Body => 'The data controller for AidatPanel is Vefa Yazılım. You may submit KVKK requests to store@vefayazilim.com or using your registered email in the app.';
	String get kvkkS2Title => 'Data categories';
	String get kvkkS2Body => 'Categories may include identity and contact, customer transaction (dues, payments, expenses), visual records (receipts), security (logs, tokens), and communication (notification consent).';
	String get kvkkS3Title => 'Purposes and legal bases';
	String get kvkkS3Body => 'Processing is based on contract performance, legal obligation, legitimate interest, and your explicit consent where required (e.g. notifications).';
	String get kvkkS4Title => 'Transfers';
	String get kvkkS4Body => 'Data may be transferred to hosting and technical providers within Türkiye as needed to provide the service, with appropriate safeguards.';
	String get kvkkS5Title => 'Collection method';
	String get kvkkS5Body => 'Data is collected electronically via app forms, automated logs, files you upload, and the notification infrastructure.';
	String get kvkkS6Title => 'Data subject rights';
	String get kvkkS6Body => 'You may exercise your rights under Article 11 of KVKK by contacting Vefa Yazılım at store@vefayazilim.com; requests are answered within statutory time limits.';
	String get helpIntro => 'Help center coming soon';
	String get helpBody => 'FAQs, step-by-step guides, and support channels will be added here soon. For app support: store@vefayazilim.com (Vefa Yazılım). For urgent building matters, contact your building manager or site administration.';
}

// Path: db_context
class _StringsDbContextEn {
	_StringsDbContextEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get user_entry => 'Record: {value}';
	String get building_name => 'Building: {value}';
	String get apartment_label => 'Apartment: {value}';
	String get code_value => 'Code: {value}';
	String get expiry_date => 'Expires at: {value}';
}

// Path: features.buildings
class _StringsFeaturesBuildingsEn {
	_StringsFeaturesBuildingsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get managerPanel => 'Manager';
	String get buildingDetail => 'Building Detail';
	String get addBuilding => 'Add Building';
	String get newBuilding => 'Add New Building';
	String get inviteCode => 'Invite Code';
	String get createInviteCode => 'Create Invite Code';
	String get cancelCode => 'Cancel Code';
	String get apartmentOccupied => 'Apartment Occupied';
	String get copy => 'Copy';
	String get share => 'Share';
	String get anotherApartment => 'Another Apartment';
	String get codeRevoked => 'Code revoked';
	String get occupiedDialog => 'If you generate a new code, the old user will be removed. Are you sure?';
	String get revokeDialog => 'The current code will become invalid. Are you sure?';
	String get produceAnyway => 'Produce Anyway';
	String get newCodePrefix => 'If you generate a new code, ';
	String get oldUserRemoved => 'the old user will be removed';
	String get currentCodePrefix => 'The current code ';
	String get codeInvalid => 'will become invalid';
	String get codeReady => 'Invite Code Ready';
	String get code => 'CODE';
	String get validFor7Days => 'Valid for 7 days';
	String get expiresAt => 'Expires at:';
	String get remaining => 'Remaining:';
	String get activeCodeNote => 'While this code is active, you cannot generate a new code for the same apartment. You must revoke the current code first.';
	String get backToMainMenu => 'Back to Main Menu';
	String get tekrarDene => 'Try Again';
	late final _StringsFeaturesBuildingsCollectionEn collection = _StringsFeaturesBuildingsCollectionEn._(_root);
}

// Path: features.auth
class _StringsFeaturesAuthEn {
	_StringsFeaturesAuthEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get register => 'Register';
	String get login => 'Login';
	String get join => 'Join';
	String get passwordRequired => 'Password required';
	String get errorOccurred => 'An error occurred';
	String get registrationSuccess => 'Account created. You can now log in.';
	String get loginSuccess => 'Signed in successfully. Welcome.';
	String get appTitle => 'AidatPanel';
	String get appSubtitle => 'Apartment Management System';
	String get splashConnectionError => 'Could not connect to server';
	String get splashConnectionHint => 'Check your connection and try again.';
	String get skipToLogin => 'Go to login';
	String get phone => 'Phone';
	String get email => 'Email';
	String get phoneHint => '5XX XXX XX XX';
	String get emailHint => 'example@email.com';
	String get password => 'Password';
	String get passwordHint => '••••••••';
	String get emailLogin => 'Login with Email';
	String get phoneLogin => 'Login with Phone';
	String get or => 'or';
	String get noAccount => 'Don\'t have an account? Register';
	String get joinWithCode => 'Join with Invite Code';
	String get signUp => 'Sign up';
	String get signUpTitle => 'Sign Up';
	String get signUpSubtitle => 'How would you like to join?';
	String get beManager => 'Become a manager';
	String get beManagerHint => 'Create a building and open a manager account';
	String get joinWithInvite => 'Join with invite code';
	String get joinWithInviteHint => 'Join as a resident with your manager\'s code';
	String get copyright => '© Vefa Yazılım';
	String get createAccount => 'Create New Account';
	String get name => 'Full Name';
	String get nameHint => 'Ex: Furkan Kaya';
	String get phoneOptional => 'Phone (Optional)';
	String get phoneHintOptional => '5XX XXX XXXX';
	String get minLength => 'At least 6 characters';
	String get hasUpperCase => 'At least 1 uppercase letter';
	String get hasLowerCase => 'At least 1 lowercase letter';
	String get hasNumber => 'At least 1 number';
	String get hasSpecialChar => 'At least 1 special character';
	String get confirmPassword => 'Confirm Password';
	String get passwordsDoNotMatch => 'Passwords do not match';
	String get emailAndPasswordRequired => 'Email and password cannot be empty';
	String get hasAccount => 'Already have an account? Login';
	String get joinApartment => 'Join Apartment';
	String get inviteCode => 'Invite Code';
	String get inviteCodeHint => 'AP3-B12-A9F0';
	String get invalidInviteCodeFormat => 'Invalid invite code format (Ex: AP3-B12-A9F0)';
	String get invalidPhoneFormat => 'Enter a valid phone number (5XX XXX XX XX)';
	String get inviteCodeAndPasswordRequired => 'Invite code, name and password cannot be empty';
	String get invalidPhoneNumber => 'Enter a valid phone number';
	String get areYouManager => 'Are you a manager? Register';
}

// Path: features.apartments
class _StringsFeaturesApartmentsEn {
	_StringsFeaturesApartmentsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get residentPanel => 'Resident';
}

// Path: features.tickets
class _StringsFeaturesTicketsEn {
	_StringsFeaturesTicketsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get myTickets => 'My requests';
	String get newTicket => 'New request';
	String get createTitle => 'Report issue / request';
	String get fieldTitle => 'Title';
	String get fieldTitleHint => 'e.g. Elevator malfunction';
	String get fieldDescription => 'Description';
	String get fieldDescriptionHint => 'Briefly describe the issue';
	String get fieldCategory => 'Category';
	String get categoryComplaint => 'Complaint';
	String get categoryRequest => 'Request';
	String get categoryMalfunction => 'Malfunction';
	String get categoryOther => 'Other';
	String get submit => 'Submit';
	String get createSuccess => 'Your request has been submitted';
	String get createFailed => 'Could not save your request. Please try again.';
	String get createServiceUnavailable => 'The request service is not available right now. Please try again later.';
	String get emptyTitle => 'No requests yet';
	String get emptySubtitle => 'Report an issue or request from here';
	String get titleTooShort => 'Title must be at least 3 characters';
	String get descriptionTooShort => 'Description must be at least 10 characters';
	String get statusOpen => 'Open';
	String get statusInProgress => 'In progress';
	String get statusResolved => 'Resolved';
	String get statusClosed => 'Closed';
	String get statusTrackerTitle => 'REQUEST STATUS';
	String get statusStepWaiting => 'Waiting';
	String get statusStepInProgress => 'In progress';
	String get statusStepResolved => 'Resolved';
	String get statusStepClosed => 'Closed';
	String get statusHeadlineOpen => 'Your request is waiting';
	String get statusHeadlineInProgress => 'Your request is in progress';
	String get statusHeadlineResolved => 'Your request is resolved';
	String get statusHeadlineClosed => 'Your request is closed';
	String get detailTitle => 'Request details';
	String get managerTitle => 'Building requests';
	String get statusLabel => 'Status';
	String get updatesTitle => 'Updates';
	String get changeStatus => 'Change status';
	String get managerNote => 'Manager note';
	String get addNote => 'Add note';
	String get statusUpdated => 'Status updated';
	String get noteAdded => 'Note added';
	String get loadError => 'Could not load requests';
	String get noteDisabledClosed => 'Cannot add notes to a closed request';
	String get statusClosedHint => 'This request is closed; status cannot be changed.';
	String get apartmentRequired => 'Apartment not linked. Please sign in again.';
}

// Path: features.dekont
class _StringsFeaturesDekontEn {
	_StringsFeaturesDekontEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get makePaymentTitle => 'Make Payment';
	String get myDekontsTitle => 'My Receipts';
	String get managerTitle => 'Receipt Review';
	String get reviewAction => 'Review receipt';
	String get detailTitle => 'Receipt Detail';
	String get paymentInfoTitle => 'Transfer details';
	String get collectionNotConfigured => 'Your manager has not set up collection IBAN yet. You can still upload a receipt.';
	String get ibanLabel => 'IBAN';
	String get accountTitleLabel => 'Account title';
	String get referenceLabel => 'Transfer reference';
	String get copy => 'Copy';
	String get copied => 'Copied to clipboard';
	String get selectDue => 'Select due';
	String get selectDueHint => 'Select the due you paid';
	String get noPendingDues => 'No pending dues';
	String get uploadSectionTitle => 'Upload receipt';
	String get uploadHint => 'PDF or photo (JPEG, PNG)';
	String get pickFile => 'Choose file';
	String get upload => 'Upload receipt';
	String get uploadSuccess => 'Receipt uploaded';
	String get uploadFailed => 'Upload failed';
	String get fileTooLarge => 'File must be 10 MB or smaller';
	String get fileEmpty => 'The selected file is empty';
	String get fileNotFound => 'File not found';
	String get invalidExtension => 'Only PDF, JPEG, or PNG files are allowed';
	String get processing => 'Processing receipt…';
	String get viewDekonts => 'My receipts';
	String get emptyTitle => 'No receipts yet';
	String get emptySubtitle => 'After paying, upload your bank receipt here';
	String get filterAll => 'All';
	String get filterPending => 'Under review';
	String get filterApproved => 'Approved';
	String get filterRejected => 'Rejected';
	String get statusReceived => 'Received';
	String get statusExtracting => 'Reading';
	String get statusExtractFailed => 'Read failed';
	String get statusParsed => 'Parsed';
	String get statusParseLowConfidence => 'Low confidence';
	String get statusMatching => 'Matching';
	String get statusMatched => 'Matched';
	String get statusMatchAmbiguous => 'Ambiguous match';
	String get statusUnmatched => 'Unmatched';
	String get statusPaymentApplied => 'Payment applied';
	String get statusPaymentPartial => 'Partial payment';
	String get statusRejected => 'Rejected';
	String get statusRecipientMismatch => 'Recipient mismatch';
	String get statusNeedsManagerReview => 'Manager review';
	String get reupload => 'Upload again';
	String get rejectionReason => 'Rejection reason';
	String get parsedAmount => 'Parsed amount';
	String get filePreview => 'File preview';
	String get shareFile => 'Share file';
	String get approve => 'Approve';
	String get reject => 'Reject';
	String get reviewNote => 'Note (optional)';
	String get reviewSuccess => 'Review saved';
	String get reviewFailed => 'Review failed';
	String get selectDueForApprove => 'Select due to approve';
	String get uploadedBy => 'Uploaded by';
	String get apartment => 'Apartment';
	String get amount => 'Amount';
	String get loadError => 'Could not load receipts';
}

// Path: features.expenses
class _StringsFeaturesExpensesEn {
	_StringsFeaturesExpensesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Expenses';
	String get createTitle => 'Add expense';
	String get fieldTitle => 'Title';
	String get fieldAmount => 'Amount';
	String get fieldCategory => 'Category';
	String get fieldNote => 'Note (optional)';
	String get submit => 'Save';
	String get required => 'Required field';
	String get amountInvalid => 'Enter a valid amount';
	String get total => 'Total';
	String get createSuccess => 'Expense saved';
	String get categoryCleaning => 'Cleaning';
	String get categoryElevator => 'Elevator';
	String get categoryElectricity => 'Electricity';
	String get categoryWater => 'Water';
	String get categoryInsurance => 'Insurance';
	String get categoryRepair => 'Repair';
	String get categoryGarden => 'Garden';
	String get categoryOther => 'Other';
	String get fieldDate => 'Date';
	String get fieldMonth => 'Month';
	String get fieldYear => 'Year';
	String get editTitle => 'Edit expense';
	String get editAction => 'Edit';
	String get deleteTitle => 'Delete expense';
	String get deleteAction => 'Delete';
	String get deleteConfirm => 'Are you sure you want to delete this expense?';
	String get deleteSuccess => 'Expense deleted';
	String get updateSuccess => 'Expense updated';
	String get loadError => 'Could not load expenses';
	String get emptyTitle => 'No expenses this period';
	String get emptySubtitle => 'Add a new expense from the top-right button';
	String get receiptUrlLabel => 'Receipt link (HTTPS)';
	String get receiptUrlHint => 'Optional — public URL to the receipt file';
	String get receiptUrlInvalid => 'URL must start with https://';
	String get receiptTitle => 'Receipt photo';
	String get receiptHint => 'Optional — gallery (file upload not on live API yet)';
	String get receiptAdd => 'Add photo';
	String get receiptChange => 'Change photo';
	String get receiptRemove => 'Remove photo';
	String get receiptPendingBackend => 'Expense saved. Receipt will upload when the API is live.';
	String get receiptUploadFailed => 'Receipt upload failed. The expense was saved.';
	String get receiptPickFailed => 'Could not pick a photo';
}

// Path: features.notifications
class _StringsFeaturesNotificationsEn {
	_StringsFeaturesNotificationsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get markAllRead => 'Mark all read';
	String get markAllReadLong => 'Mark all as read';
	String get viewRelated => 'Open related item';
	String get unreadBadge => 'New';
	String get emptyTitle => 'No notifications';
	String get emptySubtitle => 'New notifications will appear here';
	String get emptyUnreadTitle => 'No unread notifications';
	String get emptyUnreadSubtitle => 'You\'re all caught up';
	String get loadError => 'Could not load notifications';
	String get filterAll => 'All';
	String get filterUnread => 'Unread';
	String get sectionToday => 'Today';
	String get sectionYesterday => 'Yesterday';
	String get sectionThisWeek => 'This week';
	String get sectionEarlier => 'Earlier';
	String get timeNow => 'Just now';
	String get timeMinuteShort => 'min ago';
	String get timeHourShort => 'h ago';
	String get detailLoadError => 'Could not load details';
	String get fieldStatus => 'Status';
	String get fieldCategory => 'Category';
	String get fieldApartment => 'Apartment';
	String get fieldAmount => 'Amount';
	String get fieldUploadedBy => 'Uploaded by';
	String get fieldDescription => 'Description';
	String get fieldManagerNote => 'Manager note';
	String get fieldRejectionReason => 'Rejection reason';
	String get fieldLatestUpdate => 'Latest update';
	String get fieldCreatedAt => 'Created';
	String get fieldPeriod => 'Period';
	String get actionViewTicket => 'View request';
	String get actionViewDekont => 'Review receipt';
	String get actionViewDue => 'View due';
	String get typeDueReminder => 'Due reminder';
	String get typeDuePaid => 'Due paid';
	String get typeTicketCreated => 'New request';
	String get typeTicketUpdate => 'Request updated';
	String get typeAnnouncement => 'Announcement';
	String get typeDekontReceived => 'New receipt';
	String get typeDekontNeedsReview => 'Receipt review';
	String get typeDekontMatched => 'Receipt matched';
	String get typeDekontPaymentApplied => 'Receipt approved';
	String get typeSystem => 'System';
	String get typeOther => 'Notification';
	String get sendTitle => 'Announcement to residents';
	String get fieldTitle => 'Title';
	String get fieldBody => 'Message';
	String get sendButton => 'Send';
	String get sendSuccess => 'Announcement sent';
	String get sendFailed => 'Could not send announcement';
	String get fieldRequired => 'Required field';
	String get titleTooLong => 'Title must be at most 120 characters';
	String get bodyTooLong => 'Message must be at most 2000 characters';
	String get noBuilding => 'Add a building first';
}

// Path: features.profile
class _StringsFeaturesProfileEn {
	_StringsFeaturesProfileEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Profile Details';
	String get fullName => 'Full name';
	String get email => 'Email';
	String get phone => 'Phone';
	String get role => 'Role';
	String get languagePref => 'Language preference';
	String get notProvided => 'Not provided';
	String get editHint => 'Profile editing will be available soon.';
	String get sectionPersonal => 'Personal Information';
	String get sectionAccount => 'Account Information';
	String get editPhotoHint => 'Tap to change photo';
	String get editTitle => 'Edit Profile';
	String get phoneOptionalHint => 'Optional';
	String get profileUpdated => 'Your profile has been updated.';
	String get profileUpdateFailed => 'Could not update profile. Please try again.';
	String get profileLoadFailed => 'Could not load profile.';
	String get readOnlySection => 'Cannot be edited here';
	String get editSheetHint => 'Only name and phone can be updated. Other details are shown on the profile screen above.';
	String get photoSaved => 'Profile photo saved for this account.';
	String get photoRemoved => 'Profile photo removed.';
	String get removePhoto => 'Remove profile photo';
}

// Path: features.subscription
class _StringsFeaturesSubscriptionEn {
	_StringsFeaturesSubscriptionEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Subscription';
	String get statusActive => 'Active';
	String get statusExpired => 'Expired';
	String get statusCancelled => 'Cancelled';
	String get statusTrial => 'Trial';
	String get statusUnknown => 'Unknown';
	String get planMonthly => 'Monthly plan';
	String get planAnnual => 'Annual plan';
	String get planUnknown => 'Plan';
	String get renewsOn => 'Renews: {date}';
	String get noSubscription => 'No subscription on file yet.';
	String get backendPending => 'Subscription is not connected to the server yet. Purchases coming soon.';
	String get purchaseComingSoon => 'Purchase coming soon';
	String get loadFailed => 'Could not load subscription.';
}

// Path: features.faz2
class _StringsFeaturesFaz2En {
	_StringsFeaturesFaz2En._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get sectionTitle => 'Phase 2';
	String get tickets => 'Requests';
	String get expenses => 'Expenses';
	String get announcement => 'Announce';
}

// Path: features.buildings.collection
class _StringsFeaturesBuildingsCollectionEn {
	_StringsFeaturesBuildingsCollectionEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get sectionTitle => 'Collection details';
	String get sectionHint => 'IBAN for resident bank transfers. Optional; you can add it later.';
	String get modeSaved => 'Saved IBAN';
	String get modeNew => 'New IBAN';
	String get savedListTitle => 'Previously used';
	String get pickSavedIban => 'Choose saved IBAN';
	String get changeSavedIban => 'Tap to choose another IBAN';
	String get searchSavedIban => 'Search IBAN or account name';
	String get detailAccountHolder => 'Account holder';
	String get detailReference => 'Payment reference';
	String get detailReferenceAuto => 'Apartment number is added to the transfer reference automatically';
	String get detailReferenceDaireOnly => 'Transfer reference: Apartment number';
	String get detailReferenceDaireAidat => 'Transfer reference: Apt. no + dues';
	String get detailReferenceAidat => 'Transfer reference: Dues (apt. no added automatically)';
	String get detailReferenceHavale => 'Transfer reference: Apartment number on transfer';
	String get detailUsedInBuildings => 'Used in {count} buildings';
	String get ibanLabel => 'IBAN';
	String get ibanHint => 'TR33 0006 1005 1978 6457 8413 26';
	String get ibanInvalid => 'Enter a valid Turkish IBAN (TR + 24 digits)';
	String get ibanRequiredIfOtherFilled => 'You entered account title or reference; enter a valid IBAN';
	String get accountTitleLabel => 'Account holder name';
	String get accountTitleHint => 'e.g. Building Management';
	String get referenceTemplateLabel => 'Payment reference template';
	String get referenceTemplateHint => 'e.g. Apt {{number}}';
	String get presetsEmpty => 'No saved collection details yet';
	String get presetsLoadFailed => 'Could not load suggestions';
	String get presetBuildingCount => '{count} buildings';
	String get menuEdit => 'Collection / IBAN';
	String get editSheetTitle => 'Collection details';
	String get saveSuccess => 'Collection details saved';
	String get savedIbansTitle => 'My saved IBANs';
	String get savedIbansEmpty => 'No saved IBAN yet. You can add collection details when creating a building.';
	String get savedIbansNoBuildingMatch => 'No building linked to this set';
	String get savedIbansBuildingNames => 'Buildings: {names}';
	String get savedIbansUpdateSuccess => 'Collection updated for {count} building(s)';
	String get savedIbansUpdateHint => 'Will update: {names}';
	String get editSavedIbanTitle => 'Edit IBAN';
	String get savedIbansOrphanHint => 'This set is not linked to a building yet. Changes are stored in your saved list only.';
	String get savedIbansAddTitle => 'Add IBAN';
	String get savedIbansAddHint => 'You can reuse these details when adding a building or editing collection settings.';
	String get savedIbansAddSuccess => 'IBAN saved';
	String get savedIbansSelectMode => 'Select multiple';
	String get savedIbansSelectedLabel => 'selected';
	String get savedIbansDeleteSelected => 'Delete selected';
	String get savedIbansPickFirst => 'Select the IBANs you want to delete first';
	String get savedIbansDeleteTitle => 'Delete this IBAN?';
	String get savedIbansDeleteMessage => 'This saved IBAN will be removed from your list.';
	String get savedIbansDeleteBulkTitle => 'Delete selected IBANs?';
	String get savedIbansDeleteBulkMessage => '{count} saved IBAN(s) will be deleted.';
	String get savedIbansDeleteBuildingWarning => 'Collection details will also be cleared on {count} building(s).';
	String get savedIbansDeleteSuccess => 'IBAN deleted';
	String get savedIbansDeleteBulkSuccess => '{count} IBAN(s) deleted';
	String get ibanNotConfigured => 'Collection IBAN not configured';
}

// Path: <root>
class _StringsTr implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	_StringsTr.build({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = TranslationMetadata(
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

	@override late final _StringsTr _root = this; // ignore: unused_field

	// Translations
	@override late final _StringsCommonTr common = _StringsCommonTr._(_root);
	@override late final _StringsValidationTr validation = _StringsValidationTr._(_root);
	@override late final _StringsFeaturesTr features = _StringsFeaturesTr._(_root);
	@override late final _StringsLegalTr legal = _StringsLegalTr._(_root);
	@override late final _StringsDbContextTr db_context = _StringsDbContextTr._(_root);
}

// Path: common
class _StringsCommonTr implements _StringsCommonEn {
	_StringsCommonTr._(this._root);

	@override final _StringsTr _root; // ignore: unused_field

	// Translations
	@override String get logout => 'Çıkış Yap';
	@override String get cancel => 'İptal';
	@override String get confirm => 'Onayla';
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
	@override String get rateLimitHint => 'Sunucu şu an yoğun görünüyor. Kısa süre sonra yeniden denenecek.';
	@override String get tryAgain => 'Tekrar Dene';
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
	@override String get residentDetailsLink => 'Detaylar..';
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
class _StringsValidationTr implements _StringsValidationEn {
	_StringsValidationTr._(this._root);

	@override final _StringsTr _root; // ignore: unused_field

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
class _StringsFeaturesTr implements _StringsFeaturesEn {
	_StringsFeaturesTr._(this._root);

	@override final _StringsTr _root; // ignore: unused_field

	// Translations
	@override late final _StringsFeaturesBuildingsTr buildings = _StringsFeaturesBuildingsTr._(_root);
	@override late final _StringsFeaturesAuthTr auth = _StringsFeaturesAuthTr._(_root);
	@override late final _StringsFeaturesApartmentsTr apartments = _StringsFeaturesApartmentsTr._(_root);
	@override late final _StringsFeaturesTicketsTr tickets = _StringsFeaturesTicketsTr._(_root);
	@override late final _StringsFeaturesDekontTr dekont = _StringsFeaturesDekontTr._(_root);
	@override late final _StringsFeaturesExpensesTr expenses = _StringsFeaturesExpensesTr._(_root);
	@override late final _StringsFeaturesNotificationsTr notifications = _StringsFeaturesNotificationsTr._(_root);
	@override late final _StringsFeaturesProfileTr profile = _StringsFeaturesProfileTr._(_root);
	@override late final _StringsFeaturesSubscriptionTr subscription = _StringsFeaturesSubscriptionTr._(_root);
	@override late final _StringsFeaturesFaz2Tr faz2 = _StringsFeaturesFaz2Tr._(_root);
}

// Path: legal
class _StringsLegalTr implements _StringsLegalEn {
	_StringsLegalTr._(this._root);

	@override final _StringsTr _root; // ignore: unused_field

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
class _StringsDbContextTr implements _StringsDbContextEn {
	_StringsDbContextTr._(this._root);

	@override final _StringsTr _root; // ignore: unused_field

	// Translations
	@override String get user_entry => 'Kayıt: {value}';
	@override String get building_name => 'Bina: {value}';
	@override String get apartment_label => 'Daire: {value}';
	@override String get code_value => 'Kod: {value}';
	@override String get expiry_date => 'Son kullanma: {value}';
}

// Path: features.buildings
class _StringsFeaturesBuildingsTr implements _StringsFeaturesBuildingsEn {
	_StringsFeaturesBuildingsTr._(this._root);

	@override final _StringsTr _root; // ignore: unused_field

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
	@override late final _StringsFeaturesBuildingsCollectionTr collection = _StringsFeaturesBuildingsCollectionTr._(_root);
}

// Path: features.auth
class _StringsFeaturesAuthTr implements _StringsFeaturesAuthEn {
	_StringsFeaturesAuthTr._(this._root);

	@override final _StringsTr _root; // ignore: unused_field

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
class _StringsFeaturesApartmentsTr implements _StringsFeaturesApartmentsEn {
	_StringsFeaturesApartmentsTr._(this._root);

	@override final _StringsTr _root; // ignore: unused_field

	// Translations
	@override String get residentPanel => 'Sakin';
}

// Path: features.tickets
class _StringsFeaturesTicketsTr implements _StringsFeaturesTicketsEn {
	_StringsFeaturesTicketsTr._(this._root);

	@override final _StringsTr _root; // ignore: unused_field

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
class _StringsFeaturesDekontTr implements _StringsFeaturesDekontEn {
	_StringsFeaturesDekontTr._(this._root);

	@override final _StringsTr _root; // ignore: unused_field

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
	@override String get uploadHint => 'PDF veya fotoğraf (JPEG, PNG)';
	@override String get pickFile => 'Dosya seç';
	@override String get upload => 'Dekontu yükle';
	@override String get uploadSuccess => 'Dekont yüklendi';
	@override String get uploadFailed => 'Dekont yüklenemedi';
	@override String get fileTooLarge => 'Dosya en fazla 10 MB olabilir';
	@override String get fileEmpty => 'Seçilen dosya boş';
	@override String get fileNotFound => 'Dosya bulunamadı';
	@override String get invalidExtension => 'Yalnızca PDF, JPEG veya PNG yükleyebilirsiniz';
	@override String get processing => 'Dekont işleniyor…';
	@override String get viewDekonts => 'Dekontlarım';
	@override String get emptyTitle => 'Henüz dekont yok';
	@override String get emptySubtitle => 'Ödeme yaptıktan sonra dekontunuzu buradan yükleyebilirsiniz';
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
	@override String get filePreview => 'Dosya önizleme';
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
}

// Path: features.expenses
class _StringsFeaturesExpensesTr implements _StringsFeaturesExpensesEn {
	_StringsFeaturesExpensesTr._(this._root);

	@override final _StringsTr _root; // ignore: unused_field

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
	@override String get fieldDate => 'Tarih';
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
	@override String get receiptHint => 'Opsiyonel — galeriden seçin (canlı sunucuda dosya yükleme henüz yok)';
	@override String get receiptAdd => 'Fotoğraf ekle';
	@override String get receiptChange => 'Fotoğrafı değiştir';
	@override String get receiptRemove => 'Fotoğrafı kaldır';
	@override String get receiptPendingBackend => 'Gider kaydedildi. Makbuz sunucuya yüklenecek (API hazır olunca).';
	@override String get receiptUploadFailed => 'Makbuz yüklenemedi. Gider kaydı oluşturuldu.';
	@override String get receiptPickFailed => 'Fotoğraf seçilemedi';
}

// Path: features.notifications
class _StringsFeaturesNotificationsTr implements _StringsFeaturesNotificationsEn {
	_StringsFeaturesNotificationsTr._(this._root);

	@override final _StringsTr _root; // ignore: unused_field

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
class _StringsFeaturesProfileTr implements _StringsFeaturesProfileEn {
	_StringsFeaturesProfileTr._(this._root);

	@override final _StringsTr _root; // ignore: unused_field

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
}

// Path: features.subscription
class _StringsFeaturesSubscriptionTr implements _StringsFeaturesSubscriptionEn {
	_StringsFeaturesSubscriptionTr._(this._root);

	@override final _StringsTr _root; // ignore: unused_field

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
	@override String get loadFailed => 'Abonelik bilgisi alınamadı.';
}

// Path: features.faz2
class _StringsFeaturesFaz2Tr implements _StringsFeaturesFaz2En {
	_StringsFeaturesFaz2Tr._(this._root);

	@override final _StringsTr _root; // ignore: unused_field

	// Translations
	@override String get sectionTitle => 'Faz 2';
	@override String get tickets => 'Talepler';
	@override String get expenses => 'Giderler';
	@override String get announcement => 'Duyuru';
}

// Path: features.buildings.collection
class _StringsFeaturesBuildingsCollectionTr implements _StringsFeaturesBuildingsCollectionEn {
	_StringsFeaturesBuildingsCollectionTr._(this._root);

	@override final _StringsTr _root; // ignore: unused_field

	// Translations
	@override String get sectionTitle => 'Tahsilat bilgileri';
	@override String get sectionHint => 'Sakinlerin havale yapacağı IBAN. Boş bırakılabilir; sonradan da ekleyebilirsiniz.';
	@override String get modeSaved => 'Kayıtlı IBAN';
	@override String get modeNew => 'Yeni IBAN';
	@override String get savedListTitle => 'Daha önce kullandıklarınız';
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
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.

extension on Translations {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'common.logout': return 'Logout';
			case 'common.cancel': return 'Cancel';
			case 'common.confirm': return 'Confirm';
			case 'common.save': return 'Save';
			case 'common.delete': return 'Delete';
			case 'common.edit': return 'Edit';
			case 'common.close': return 'Close';
			case 'common.yes': return 'Yes';
			case 'common.no': return 'No';
			case 'common.register': return 'Register';
			case 'common.login': return 'Login';
			case 'common.join': return 'Join';
			case 'common.confirmMessage': return 'Are you sure?';
			case 'common.logoutConfirm': return 'Are you sure you want to logout?';
			case 'common.logoutSuccess': return 'Signed out successfully.';
			case 'common.logoutAllDevices': return 'Sign out other devices';
			case 'common.logoutAllDevicesConfirm': return 'Sessions on your other phones and tablets will end. You will stay signed in on this device.';
			case 'common.logoutAllDevicesSuccess': return 'Other devices have been signed out.';
			case 'common.logoutAllDevicesFailed': return 'Could not complete this action. Please try again.';
			case 'common.account': return 'Account';
			case 'common.editProfile': return 'Edit Profile';
			case 'common.changePassword': return 'Change Password';
			case 'common.language': return 'Language';
			case 'common.turkish': return 'Turkish';
			case 'common.notifications': return 'Notifications';
			case 'common.info': return 'Info';
			case 'common.privacyPolicy': return 'Privacy Policy';
			case 'common.kvkk': return 'KVKK';
			case 'common.helpSupport': return 'Help & Support';
			case 'common.about': return 'About';
			case 'common.comingSoon': return 'This feature will be added soon';
			case 'common.multiLanguageComingSoon': return 'Multi-language support coming soon';
			case 'common.copyright': return ' 2026 AidatPanel\nAll rights reserved.';
			case 'common.aboutDescription': return 'Dues management platform for Turkish apartment and site managers.';
			case 'common.manager': return 'Manager';
			case 'common.resident': return 'Resident';
			case 'common.tokenExpiryTest': return 'Token Expiry Check (Test)';
			case 'common.tokenExpired': return 'Token EXPIRED! Redirecting to login screen.';
			case 'common.tokenActive': return 'Token active! Remaining time';
			case 'common.pressBackAgainToExit': return 'Press back again to exit';
			case 'common.loading': return 'Loading…';
			case 'common.loadingBuildings': return 'Loading buildings…';
			case 'common.loadFailed': return 'Failed to load';
			case 'common.unexpectedError': return 'Something went wrong. Please try again.';
			case 'common.rateLimitHint': return 'The server is currently busy. We\'ll retry shortly.';
			case 'common.tryAgain': return 'Try Again';
			case 'common.home': return 'Home';
			case 'common.buildings': return 'Buildings';
			case 'common.dues': return 'Dues';
			case 'common.settings': return 'Settings';
			case 'common.user': return 'User';
			case 'common.welcome': return 'Welcome';
			case 'common.managedBuildings': return 'Managed Buildings';
			case 'common.issues': return 'Issues';
			case 'common.issuesTab': return 'Issues Tab';
			case 'common.apartment': return 'Apartment';
			case 'common.addBuilding': return 'Add Building';
			case 'common.inviteCode': return 'Invite Code';
			case 'common.myBuildings': return 'My Buildings';
			case 'common.apartments': return 'Apartments';
			case 'common.collection': return 'Collection';
			case 'common.monthlyDues': return 'Monthly Dues';
			case 'common.duesTab': return 'Dues Tab';
			case 'common.totalApartments': return 'Total Apartments';
			case 'common.occupiedApartments': return 'Occupied Apartments';
			case 'common.duesCollection': return 'Dues Collection';
			case 'common.totalDues': return 'Total Dues';
			case 'common.recentTransactions': return 'Recent Transactions';
			case 'common.paid': return 'Paid';
			case 'common.pending': return 'Pending';
			case 'common.overdue': return 'Overdue';
			case 'common.balance': return 'Balance';
			case 'common.amountDue': return 'Amount Due';
			case 'common.lastPayment': return 'Last Payment';
			case 'common.makePayment': return 'Make Payment';
			case 'common.bills': return 'Bills';
			case 'common.support': return 'Support';
			case 'common.quickActions': return 'Quick actions';
			case 'common.residentName': return 'Resident Name';
			case 'common.addBuildingNew': return 'Add New Building';
			case 'common.basicInfo': return 'Basic Info';
			case 'common.buildingName': return 'Building Name';
			case 'common.buildingNameHint': return 'Ex: Güneş Apartmanı';
			case 'common.location': return 'Location';
			case 'common.streetAddress': return 'Street Address';
			case 'common.streetAddressHint': return 'Ex: Bağdat Cad. No: 123';
			case 'common.details': return 'Details';
			case 'common.floorCount': return 'Floor Count';
			case 'common.floorCountHint': return 'Between 1 and 200';
			case 'common.apartmentsPerFloor': return 'Apartments Per Floor';
			case 'common.apartmentsPerFloorHint': return 'Between 1 and 50';
			case 'common.floorRangeError': return 'Floor count must be between 1 and 200';
			case 'common.apartmentsPerFloorRangeError': return 'Apartments per floor must be between 1 and 50';
			case 'common.buildingAddFailed': return 'Could not add building. Please try again.';
			case 'common.monthlyDuesLabel': return 'Monthly Dues (₺)';
			case 'common.monthlyDuesHint': return 'Ex: 1000';
			case 'common.createBuilding': return 'Create Building';
			case 'common.cancelBtn': return 'Cancel';
			case 'common.cityRequired': return 'City *';
			case 'common.selectCity': return 'Select City';
			case 'common.districtRequired': return 'District *';
			case 'common.selectDistrict': return 'Select District';
			case 'common.selectCityFirst': return 'Select city first';
			case 'common.selectCityTitle': return 'Select City';
			case 'common.selectDistrictTitle': return 'Select District';
			case 'common.search': return 'Search...';
			case 'common.noResults': return 'No results found';
			case 'common.fieldRequired': return 'cannot be empty';
			case 'common.fillRequiredFields': return 'Please fill required fields';
			case 'common.selectCityAndDistrict': return 'You must select city and district';
			case 'common.floorApartmentMustBePositive': return 'Floor count and apartment count must be greater than 0';
			case 'common.buildingAddedSuccess': return 'Building added successfully';
			case 'common.createInviteCode': return 'Create Invite Code';
			case 'common.whichBuildingForCode': return 'Which building to generate code for?';
			case 'common.whichApartmentForCode': return 'Which apartment to generate code for?';
			case 'common.noApartmentsInBuilding': return 'No apartments added to this building yet';
			case 'common.activeCodeBadge': return 'Active Code';
			case 'common.occupiedBadge': return 'Occupied';
			case 'common.emptyBadge': return 'Empty';
			case 'common.activeCodePrefix': return 'Active code';
			case 'common.residentPrefix': return 'Resident';
			case 'common.emptyApartment': return 'Empty apartment';
			case 'common.codeRevoked': return 'Code revoked';
			case 'common.codeCopied': return 'Code copied';
			case 'common.clipboardCopied': return 'Message copied to clipboard';
			case 'common.expiresAtPrefix': return 'Expires at';
			case 'common.remainingPrefix': return 'Remaining';
			case 'common.buildingDetail': return 'Building Detail';
			case 'common.residents': return 'Residents';
			case 'common.apartmentsBadge': return 'Apartments';
			case 'common.emptyApartmentText': return 'Empty Apartment';
			case 'common.vacantBadge': return 'Vacant';
			case 'common.phoneNotShared': return 'Phone not shared';
			case 'common.residentDetailsLink': return 'Details..';
			case 'common.residentDetailsSheetTitle': return 'Resident information';
			case 'common.apartmentDetailsSheetTitle': return 'Apartment information';
			case 'common.noResidentAssigned': return 'No resident assigned';
			case 'common.noApartmentsYet': return 'No apartments added yet';
			case 'common.paidStatus': return 'Paid';
			case 'common.pendingStatus': return 'Pending';
			case 'common.overdueStatus': return 'Overdue';
			case 'common.waivedStatus': return 'Waived';
			case 'common.all': return 'All';
			case 'common.status': return 'Status';
			case 'common.month': return 'Month';
			case 'common.monthJanuary': return 'January';
			case 'common.monthFebruary': return 'February';
			case 'common.monthMarch': return 'March';
			case 'common.monthApril': return 'April';
			case 'common.monthMay': return 'May';
			case 'common.monthJune': return 'June';
			case 'common.monthJuly': return 'July';
			case 'common.monthAugust': return 'August';
			case 'common.monthSeptember': return 'September';
			case 'common.monthOctober': return 'October';
			case 'common.monthNovember': return 'November';
			case 'common.monthDecember': return 'December';
			case 'common.allMonths': return 'All months';
			case 'common.year': return 'Year';
			case 'common.allYears': return 'All years';
			case 'common.note': return 'Note';
			case 'common.myDuesHistory': return 'My Dues History';
			case 'common.currentPeriodDue': return 'Current due';
			case 'common.myPastDues': return 'My past dues';
			case 'common.buildingDues': return 'Building Dues';
			case 'common.noDuesYet': return 'No dues records yet';
			case 'common.duesUpdated': return 'Dues status updated';
			case 'common.amount': return 'Amount';
			case 'common.updateDueAmount': return 'Update Due Amount';
			case 'common.dueAmountUpdated': return 'Due amount updated';
			case 'common.dueAmountUpdateFailed': return 'Could not update due amount';
			case 'common.dueDay': return 'Due Day (1-28)';
			case 'common.selectDueDay': return 'Select day';
			case 'common.affectCurrentDues': return 'Apply to pending dues';
			case 'common.affectCurrentDuesHint': return 'When enabled, current PENDING due amounts are updated to the new amount.';
			case 'common.dueUpdateNeedAmountOrDay': return 'Enter an amount or select a due day to update.';
			case 'common.dueUpdateNeedStoredAmount': return 'This building has no saved amount yet. Enter an amount before updating the due day only.';
			case 'common.dueAmountInvalidPositive': return 'Enter a valid amount.';
			case 'common.dueDayOutOfRange': return 'Due day must be between 1 and 28.';
			case 'common.update': return 'Update';
			case 'common.overdueDays': return 'days overdue';
			case 'common.dueDateLabel': return 'Due date';
			case 'common.perMonth': return '/ month';
			case 'common.floorLabel': return 'FLOOR';
			case 'common.apartmentLabel': return 'APT';
			case 'common.turkishLanguage': return 'Türkçe';
			case 'common.englishLanguage': return 'English';
			case 'common.stepBuilding': return 'Building';
			case 'common.stepApartment': return 'Apartment';
			case 'common.stepCode': return 'Code';
			case 'common.editBuilding': return 'Edit Building';
			case 'common.deleteBuilding': return 'Delete Building';
			case 'common.buildingUpdated': return 'Building updated';
			case 'common.buildingDeleted': return 'Building deleted';
			case 'common.buildingUpdateFailed': return 'Could not update building';
			case 'common.buildingDeleteFailed': return 'Could not delete building';
			case 'common.buildingDeleteFailedFK': return 'Cannot delete this building: apartments, residents, or dues records still exist. Clean up apartments/dues first.';
			case 'common.deleteBuildingHeader': return 'This action cannot be undone.';
			case 'common.deleteBuildingTypeHint': return 'To confirm, type the building name below exactly:';
			case 'common.deleteBuildingTypeFieldLabel': return 'Building name';
			case 'common.buildingNameMismatch': return 'What you typed does not match the building name.';
			case 'common.editApartment': return 'Edit Apartment';
			case 'common.deleteApartment': return 'Delete Apartment';
			case 'common.apartmentUpdated': return 'Apartment updated';
			case 'common.apartmentDeleted': return 'Apartment deleted';
			case 'common.apartmentUpdateFailed': return 'Could not update apartment';
			case 'common.apartmentDeleteFailed': return 'Could not delete apartment';
			case 'common.apartmentDeleteFailedFK': return 'Cannot delete this apartment: resident or dues records exist. Wait for the resident to close their account and clean up dues.';
			case 'common.deleteApartmentConfirm': return 'Are you sure you want to delete this apartment?';
			case 'common.apartmentNumberLabel': return 'Apt No (e.g. 5A)';
			case 'common.floorLabel2': return 'Floor (optional)';
			case 'common.floorOptional': return 'Floor (-5 to 200)';
			case 'common.buildingNameField': return 'Building name';
			case 'common.buildingAddressField': return 'Address';
			case 'common.buildingCityField': return 'City';
			case 'common.monthlyDuesPerApartment': return 'Monthly dues / apt';
			case 'common.remove': return 'Remove';
			case 'common.removeResident': return 'Remove Resident';
			case 'common.removeResidentConfirm': return 'Are you sure you want to remove this resident from the apartment?';
			case 'common.removeResidentNote': return 'The resident\'s account will not be deleted; only their link to this apartment is removed. Past dues records are kept. The resident can join another apartment later using an invite code.';
			case 'common.residentRemoved': return 'Resident removed from apartment';
			case 'common.residentRemoveFailed': return 'Could not remove resident';
			case 'common.residentRemoveForbidden': return 'You are not allowed to perform this action. Only the building manager can remove residents.';
			case 'common.residentRemoveNotFound': return 'No resident to remove from this apartment.';
			case 'common.multiSelectResidents': return 'Select multiple';
			case 'common.multiSelectTapHint': return 'Tap the card to select or clear';
			case 'common.selectTriggerShort': return 'Select';
			case 'common.selectedCountLabel': return 'selected';
			case 'common.selectionRemoveHint': return 'Pick the residents you want to remove';
			case 'common.selectionDeleteIbanHint': return 'Pick the IBANs you want to delete';
			case 'common.removeSelectedResidents': return 'Remove selected';
			case 'common.removeSelectedResidentsTitle': return 'Remove selected residents';
			case 'common.removeSelectedResidentsMessage': return 'Residents in the apartments listed below will be unlinked from their apartments. Accounts are not deleted—only the connection to this building is removed. Past dues records are kept.';
			case 'common.removeSelectedResidentsAffectedListTitle': return 'Apartments affected';
			case 'common.removeSelectedResidentsListUnavailable': return 'The apartment list could not be loaded. The count is shown below. If you confirm, removals will still proceed.';
			case 'common.pickResidentsFirst': return 'Select at least one occupied apartment from the list first';
			case 'common.removeSelectedProgress': return 'Working…';
			case 'common.removeSelectedSuccess': return 'Selected residents were removed from their apartments';
			case 'common.removeSelectedFailed': return 'Could not finish removing the selected residents';
			case 'common.currentPassword': return 'Current Password';
			case 'common.newPassword': return 'New Password';
			case 'common.newPasswordConfirm': return 'New Password (Repeat)';
			case 'common.currentPasswordRequired': return 'Enter your current password';
			case 'common.passwordsMustDiffer': return 'New password cannot be the same as the old one';
			case 'common.changePasswordTitle': return 'Change Password';
			case 'common.changePasswordSubtitle': return 'Update your password regularly to keep your account secure.';
			case 'common.changePasswordSuccess': return 'Your password has been changed. Please sign in again with your new password.';
			case 'common.changePasswordFailed': return 'Could not change password. Please try again.';
			case 'common.changePasswordWrongCurrent': return 'Current password is incorrect.';
			case 'common.deleteAccount': return 'Close My Account';
			case 'common.deleteAccountTitle': return 'Do you want to close your account?';
			case 'common.deleteAccountWarning': return 'This action cannot be undone. Your personal data will be removed, but for legal reasons some records (such as dues history) are kept anonymously.';
			case 'common.deleteAccountTypeHint': return 'To confirm, type "CLOSE MY ACCOUNT" below:';
			case 'common.deleteAccountTypePhrase': return 'CLOSE MY ACCOUNT';
			case 'common.deleteAccountTypeMismatch': return 'What you typed does not match.';
			case 'common.deleteAccountConfirmButton': return 'Close My Account';
			case 'common.deleteAccountSuccess': return 'Your account has been closed. Thank you for using AidatPanel.';
			case 'common.deleteAccountFailed': return 'Could not close account. Please try again.';
			case 'common.deleteAccountFailedManager': return 'You first need to delete the buildings you manage or transfer them to another manager.';
			case 'common.dangerZone': return 'Danger Zone';
			case 'common.forgotPassword': return 'Forgot Password';
			case 'common.forgotPasswordTitle': return 'Forgot Password';
			case 'common.forgotPasswordSubtitle': return 'Enter your registered email and we\'ll send you a reset code.';
			case 'common.forgotPasswordSuccess': return 'If this email is registered, a reset code has been sent. Please check your inbox.';
			case 'common.sendResetCode': return 'Send Code';
			case 'common.iHaveACode': return 'I already have a code';
			case 'common.resetPasswordTitle': return 'Set New Password';
			case 'common.resetPasswordSubtitle': return 'Enter the 6-character code from your email and a new password.';
			case 'common.resetCode': return 'Reset Code';
			case 'common.resetCodeHint': return 'ABC123';
			case 'common.resetCodeRequired': return 'Reset code required';
			case 'common.resetCodeInvalid': return 'Code must be 6 characters';
			case 'common.resetPasswordSuccess': return 'Your password has been reset. You can sign in with your new password.';
			case 'common.resetPasswordFailed': return 'Could not reset password. The code may be invalid or expired.';
			case 'common.resetPasswordSubmit': return 'Reset Password';
			case 'common.backToLogin': return 'Back to login';
			case 'validation.emailRequired': return 'Email address cannot be empty';
			case 'validation.emailInvalid': return 'Please enter a valid email address';
			case 'validation.emailTooLong': return 'Email address is too long';
			case 'validation.phoneRequired': return 'Phone number cannot be empty';
			case 'validation.phoneInvalid': return 'Phone number must be 10 digits';
			case 'validation.passwordRequired': return 'Password cannot be empty';
			case 'validation.passwordTooShort': return 'Password must be at least 6 characters';
			case 'validation.passwordTooLong': return 'Password is too long';
			case 'validation.passwordUppercaseRequired': return 'Password must contain at least 1 uppercase letter';
			case 'validation.passwordLowercaseRequired': return 'Password must contain at least 1 lowercase letter';
			case 'validation.passwordNumberRequired': return 'Password must contain at least 1 number';
			case 'validation.passwordSpecialCharRequired': return 'Password must contain at least 1 special character';
			case 'features.buildings.managerPanel': return 'Manager';
			case 'features.buildings.buildingDetail': return 'Building Detail';
			case 'features.buildings.addBuilding': return 'Add Building';
			case 'features.buildings.newBuilding': return 'Add New Building';
			case 'features.buildings.inviteCode': return 'Invite Code';
			case 'features.buildings.createInviteCode': return 'Create Invite Code';
			case 'features.buildings.cancelCode': return 'Cancel Code';
			case 'features.buildings.apartmentOccupied': return 'Apartment Occupied';
			case 'features.buildings.copy': return 'Copy';
			case 'features.buildings.share': return 'Share';
			case 'features.buildings.anotherApartment': return 'Another Apartment';
			case 'features.buildings.codeRevoked': return 'Code revoked';
			case 'features.buildings.occupiedDialog': return 'If you generate a new code, the old user will be removed. Are you sure?';
			case 'features.buildings.revokeDialog': return 'The current code will become invalid. Are you sure?';
			case 'features.buildings.produceAnyway': return 'Produce Anyway';
			case 'features.buildings.newCodePrefix': return 'If you generate a new code, ';
			case 'features.buildings.oldUserRemoved': return 'the old user will be removed';
			case 'features.buildings.currentCodePrefix': return 'The current code ';
			case 'features.buildings.codeInvalid': return 'will become invalid';
			case 'features.buildings.codeReady': return 'Invite Code Ready';
			case 'features.buildings.code': return 'CODE';
			case 'features.buildings.validFor7Days': return 'Valid for 7 days';
			case 'features.buildings.expiresAt': return 'Expires at:';
			case 'features.buildings.remaining': return 'Remaining:';
			case 'features.buildings.activeCodeNote': return 'While this code is active, you cannot generate a new code for the same apartment. You must revoke the current code first.';
			case 'features.buildings.backToMainMenu': return 'Back to Main Menu';
			case 'features.buildings.tekrarDene': return 'Try Again';
			case 'features.buildings.collection.sectionTitle': return 'Collection details';
			case 'features.buildings.collection.sectionHint': return 'IBAN for resident bank transfers. Optional; you can add it later.';
			case 'features.buildings.collection.modeSaved': return 'Saved IBAN';
			case 'features.buildings.collection.modeNew': return 'New IBAN';
			case 'features.buildings.collection.savedListTitle': return 'Previously used';
			case 'features.buildings.collection.pickSavedIban': return 'Choose saved IBAN';
			case 'features.buildings.collection.changeSavedIban': return 'Tap to choose another IBAN';
			case 'features.buildings.collection.searchSavedIban': return 'Search IBAN or account name';
			case 'features.buildings.collection.detailAccountHolder': return 'Account holder';
			case 'features.buildings.collection.detailReference': return 'Payment reference';
			case 'features.buildings.collection.detailReferenceAuto': return 'Apartment number is added to the transfer reference automatically';
			case 'features.buildings.collection.detailReferenceDaireOnly': return 'Transfer reference: Apartment number';
			case 'features.buildings.collection.detailReferenceDaireAidat': return 'Transfer reference: Apt. no + dues';
			case 'features.buildings.collection.detailReferenceAidat': return 'Transfer reference: Dues (apt. no added automatically)';
			case 'features.buildings.collection.detailReferenceHavale': return 'Transfer reference: Apartment number on transfer';
			case 'features.buildings.collection.detailUsedInBuildings': return 'Used in {count} buildings';
			case 'features.buildings.collection.ibanLabel': return 'IBAN';
			case 'features.buildings.collection.ibanHint': return 'TR33 0006 1005 1978 6457 8413 26';
			case 'features.buildings.collection.ibanInvalid': return 'Enter a valid Turkish IBAN (TR + 24 digits)';
			case 'features.buildings.collection.ibanRequiredIfOtherFilled': return 'You entered account title or reference; enter a valid IBAN';
			case 'features.buildings.collection.accountTitleLabel': return 'Account holder name';
			case 'features.buildings.collection.accountTitleHint': return 'e.g. Building Management';
			case 'features.buildings.collection.referenceTemplateLabel': return 'Payment reference template';
			case 'features.buildings.collection.referenceTemplateHint': return 'e.g. Apt {{number}}';
			case 'features.buildings.collection.presetsEmpty': return 'No saved collection details yet';
			case 'features.buildings.collection.presetsLoadFailed': return 'Could not load suggestions';
			case 'features.buildings.collection.presetBuildingCount': return '{count} buildings';
			case 'features.buildings.collection.menuEdit': return 'Collection / IBAN';
			case 'features.buildings.collection.editSheetTitle': return 'Collection details';
			case 'features.buildings.collection.saveSuccess': return 'Collection details saved';
			case 'features.buildings.collection.savedIbansTitle': return 'My saved IBANs';
			case 'features.buildings.collection.savedIbansEmpty': return 'No saved IBAN yet. You can add collection details when creating a building.';
			case 'features.buildings.collection.savedIbansNoBuildingMatch': return 'No building linked to this set';
			case 'features.buildings.collection.savedIbansBuildingNames': return 'Buildings: {names}';
			case 'features.buildings.collection.savedIbansUpdateSuccess': return 'Collection updated for {count} building(s)';
			case 'features.buildings.collection.savedIbansUpdateHint': return 'Will update: {names}';
			case 'features.buildings.collection.editSavedIbanTitle': return 'Edit IBAN';
			case 'features.buildings.collection.savedIbansOrphanHint': return 'This set is not linked to a building yet. Changes are stored in your saved list only.';
			case 'features.buildings.collection.savedIbansAddTitle': return 'Add IBAN';
			case 'features.buildings.collection.savedIbansAddHint': return 'You can reuse these details when adding a building or editing collection settings.';
			case 'features.buildings.collection.savedIbansAddSuccess': return 'IBAN saved';
			case 'features.buildings.collection.savedIbansSelectMode': return 'Select multiple';
			case 'features.buildings.collection.savedIbansSelectedLabel': return 'selected';
			case 'features.buildings.collection.savedIbansDeleteSelected': return 'Delete selected';
			case 'features.buildings.collection.savedIbansPickFirst': return 'Select the IBANs you want to delete first';
			case 'features.buildings.collection.savedIbansDeleteTitle': return 'Delete this IBAN?';
			case 'features.buildings.collection.savedIbansDeleteMessage': return 'This saved IBAN will be removed from your list.';
			case 'features.buildings.collection.savedIbansDeleteBulkTitle': return 'Delete selected IBANs?';
			case 'features.buildings.collection.savedIbansDeleteBulkMessage': return '{count} saved IBAN(s) will be deleted.';
			case 'features.buildings.collection.savedIbansDeleteBuildingWarning': return 'Collection details will also be cleared on {count} building(s).';
			case 'features.buildings.collection.savedIbansDeleteSuccess': return 'IBAN deleted';
			case 'features.buildings.collection.savedIbansDeleteBulkSuccess': return '{count} IBAN(s) deleted';
			case 'features.buildings.collection.ibanNotConfigured': return 'Collection IBAN not configured';
			case 'features.auth.register': return 'Register';
			case 'features.auth.login': return 'Login';
			case 'features.auth.join': return 'Join';
			case 'features.auth.passwordRequired': return 'Password required';
			case 'features.auth.errorOccurred': return 'An error occurred';
			case 'features.auth.registrationSuccess': return 'Account created. You can now log in.';
			case 'features.auth.loginSuccess': return 'Signed in successfully. Welcome.';
			case 'features.auth.appTitle': return 'AidatPanel';
			case 'features.auth.appSubtitle': return 'Apartment Management System';
			case 'features.auth.splashConnectionError': return 'Could not connect to server';
			case 'features.auth.splashConnectionHint': return 'Check your connection and try again.';
			case 'features.auth.skipToLogin': return 'Go to login';
			case 'features.auth.phone': return 'Phone';
			case 'features.auth.email': return 'Email';
			case 'features.auth.phoneHint': return '5XX XXX XX XX';
			case 'features.auth.emailHint': return 'example@email.com';
			case 'features.auth.password': return 'Password';
			case 'features.auth.passwordHint': return '••••••••';
			case 'features.auth.emailLogin': return 'Login with Email';
			case 'features.auth.phoneLogin': return 'Login with Phone';
			case 'features.auth.or': return 'or';
			case 'features.auth.noAccount': return 'Don\'t have an account? Register';
			case 'features.auth.joinWithCode': return 'Join with Invite Code';
			case 'features.auth.signUp': return 'Sign up';
			case 'features.auth.signUpTitle': return 'Sign Up';
			case 'features.auth.signUpSubtitle': return 'How would you like to join?';
			case 'features.auth.beManager': return 'Become a manager';
			case 'features.auth.beManagerHint': return 'Create a building and open a manager account';
			case 'features.auth.joinWithInvite': return 'Join with invite code';
			case 'features.auth.joinWithInviteHint': return 'Join as a resident with your manager\'s code';
			case 'features.auth.copyright': return '© Vefa Yazılım';
			case 'features.auth.createAccount': return 'Create New Account';
			case 'features.auth.name': return 'Full Name';
			case 'features.auth.nameHint': return 'Ex: Furkan Kaya';
			case 'features.auth.phoneOptional': return 'Phone (Optional)';
			case 'features.auth.phoneHintOptional': return '5XX XXX XXXX';
			case 'features.auth.minLength': return 'At least 6 characters';
			case 'features.auth.hasUpperCase': return 'At least 1 uppercase letter';
			case 'features.auth.hasLowerCase': return 'At least 1 lowercase letter';
			case 'features.auth.hasNumber': return 'At least 1 number';
			case 'features.auth.hasSpecialChar': return 'At least 1 special character';
			case 'features.auth.confirmPassword': return 'Confirm Password';
			case 'features.auth.passwordsDoNotMatch': return 'Passwords do not match';
			case 'features.auth.emailAndPasswordRequired': return 'Email and password cannot be empty';
			case 'features.auth.hasAccount': return 'Already have an account? Login';
			case 'features.auth.joinApartment': return 'Join Apartment';
			case 'features.auth.inviteCode': return 'Invite Code';
			case 'features.auth.inviteCodeHint': return 'AP3-B12-A9F0';
			case 'features.auth.invalidInviteCodeFormat': return 'Invalid invite code format (Ex: AP3-B12-A9F0)';
			case 'features.auth.invalidPhoneFormat': return 'Enter a valid phone number (5XX XXX XX XX)';
			case 'features.auth.inviteCodeAndPasswordRequired': return 'Invite code, name and password cannot be empty';
			case 'features.auth.invalidPhoneNumber': return 'Enter a valid phone number';
			case 'features.auth.areYouManager': return 'Are you a manager? Register';
			case 'features.apartments.residentPanel': return 'Resident';
			case 'features.tickets.myTickets': return 'My requests';
			case 'features.tickets.newTicket': return 'New request';
			case 'features.tickets.createTitle': return 'Report issue / request';
			case 'features.tickets.fieldTitle': return 'Title';
			case 'features.tickets.fieldTitleHint': return 'e.g. Elevator malfunction';
			case 'features.tickets.fieldDescription': return 'Description';
			case 'features.tickets.fieldDescriptionHint': return 'Briefly describe the issue';
			case 'features.tickets.fieldCategory': return 'Category';
			case 'features.tickets.categoryComplaint': return 'Complaint';
			case 'features.tickets.categoryRequest': return 'Request';
			case 'features.tickets.categoryMalfunction': return 'Malfunction';
			case 'features.tickets.categoryOther': return 'Other';
			case 'features.tickets.submit': return 'Submit';
			case 'features.tickets.createSuccess': return 'Your request has been submitted';
			case 'features.tickets.createFailed': return 'Could not save your request. Please try again.';
			case 'features.tickets.createServiceUnavailable': return 'The request service is not available right now. Please try again later.';
			case 'features.tickets.emptyTitle': return 'No requests yet';
			case 'features.tickets.emptySubtitle': return 'Report an issue or request from here';
			case 'features.tickets.titleTooShort': return 'Title must be at least 3 characters';
			case 'features.tickets.descriptionTooShort': return 'Description must be at least 10 characters';
			case 'features.tickets.statusOpen': return 'Open';
			case 'features.tickets.statusInProgress': return 'In progress';
			case 'features.tickets.statusResolved': return 'Resolved';
			case 'features.tickets.statusClosed': return 'Closed';
			case 'features.tickets.statusTrackerTitle': return 'REQUEST STATUS';
			case 'features.tickets.statusStepWaiting': return 'Waiting';
			case 'features.tickets.statusStepInProgress': return 'In progress';
			case 'features.tickets.statusStepResolved': return 'Resolved';
			case 'features.tickets.statusStepClosed': return 'Closed';
			case 'features.tickets.statusHeadlineOpen': return 'Your request is waiting';
			case 'features.tickets.statusHeadlineInProgress': return 'Your request is in progress';
			case 'features.tickets.statusHeadlineResolved': return 'Your request is resolved';
			case 'features.tickets.statusHeadlineClosed': return 'Your request is closed';
			case 'features.tickets.detailTitle': return 'Request details';
			case 'features.tickets.managerTitle': return 'Building requests';
			case 'features.tickets.statusLabel': return 'Status';
			case 'features.tickets.updatesTitle': return 'Updates';
			case 'features.tickets.changeStatus': return 'Change status';
			case 'features.tickets.managerNote': return 'Manager note';
			case 'features.tickets.addNote': return 'Add note';
			case 'features.tickets.statusUpdated': return 'Status updated';
			case 'features.tickets.noteAdded': return 'Note added';
			case 'features.tickets.loadError': return 'Could not load requests';
			case 'features.tickets.noteDisabledClosed': return 'Cannot add notes to a closed request';
			case 'features.tickets.statusClosedHint': return 'This request is closed; status cannot be changed.';
			case 'features.tickets.apartmentRequired': return 'Apartment not linked. Please sign in again.';
			case 'features.dekont.makePaymentTitle': return 'Make Payment';
			case 'features.dekont.myDekontsTitle': return 'My Receipts';
			case 'features.dekont.managerTitle': return 'Receipt Review';
			case 'features.dekont.reviewAction': return 'Review receipt';
			case 'features.dekont.detailTitle': return 'Receipt Detail';
			case 'features.dekont.paymentInfoTitle': return 'Transfer details';
			case 'features.dekont.collectionNotConfigured': return 'Your manager has not set up collection IBAN yet. You can still upload a receipt.';
			case 'features.dekont.ibanLabel': return 'IBAN';
			case 'features.dekont.accountTitleLabel': return 'Account title';
			case 'features.dekont.referenceLabel': return 'Transfer reference';
			case 'features.dekont.copy': return 'Copy';
			case 'features.dekont.copied': return 'Copied to clipboard';
			case 'features.dekont.selectDue': return 'Select due';
			case 'features.dekont.selectDueHint': return 'Select the due you paid';
			case 'features.dekont.noPendingDues': return 'No pending dues';
			case 'features.dekont.uploadSectionTitle': return 'Upload receipt';
			case 'features.dekont.uploadHint': return 'PDF or photo (JPEG, PNG)';
			case 'features.dekont.pickFile': return 'Choose file';
			case 'features.dekont.upload': return 'Upload receipt';
			case 'features.dekont.uploadSuccess': return 'Receipt uploaded';
			case 'features.dekont.uploadFailed': return 'Upload failed';
			case 'features.dekont.fileTooLarge': return 'File must be 10 MB or smaller';
			case 'features.dekont.fileEmpty': return 'The selected file is empty';
			case 'features.dekont.fileNotFound': return 'File not found';
			case 'features.dekont.invalidExtension': return 'Only PDF, JPEG, or PNG files are allowed';
			case 'features.dekont.processing': return 'Processing receipt…';
			case 'features.dekont.viewDekonts': return 'My receipts';
			case 'features.dekont.emptyTitle': return 'No receipts yet';
			case 'features.dekont.emptySubtitle': return 'After paying, upload your bank receipt here';
			case 'features.dekont.filterAll': return 'All';
			case 'features.dekont.filterPending': return 'Under review';
			case 'features.dekont.filterApproved': return 'Approved';
			case 'features.dekont.filterRejected': return 'Rejected';
			case 'features.dekont.statusReceived': return 'Received';
			case 'features.dekont.statusExtracting': return 'Reading';
			case 'features.dekont.statusExtractFailed': return 'Read failed';
			case 'features.dekont.statusParsed': return 'Parsed';
			case 'features.dekont.statusParseLowConfidence': return 'Low confidence';
			case 'features.dekont.statusMatching': return 'Matching';
			case 'features.dekont.statusMatched': return 'Matched';
			case 'features.dekont.statusMatchAmbiguous': return 'Ambiguous match';
			case 'features.dekont.statusUnmatched': return 'Unmatched';
			case 'features.dekont.statusPaymentApplied': return 'Payment applied';
			case 'features.dekont.statusPaymentPartial': return 'Partial payment';
			case 'features.dekont.statusRejected': return 'Rejected';
			case 'features.dekont.statusRecipientMismatch': return 'Recipient mismatch';
			case 'features.dekont.statusNeedsManagerReview': return 'Manager review';
			case 'features.dekont.reupload': return 'Upload again';
			case 'features.dekont.rejectionReason': return 'Rejection reason';
			case 'features.dekont.parsedAmount': return 'Parsed amount';
			case 'features.dekont.filePreview': return 'File preview';
			case 'features.dekont.shareFile': return 'Share file';
			case 'features.dekont.approve': return 'Approve';
			case 'features.dekont.reject': return 'Reject';
			case 'features.dekont.reviewNote': return 'Note (optional)';
			case 'features.dekont.reviewSuccess': return 'Review saved';
			case 'features.dekont.reviewFailed': return 'Review failed';
			case 'features.dekont.selectDueForApprove': return 'Select due to approve';
			case 'features.dekont.uploadedBy': return 'Uploaded by';
			case 'features.dekont.apartment': return 'Apartment';
			case 'features.dekont.amount': return 'Amount';
			case 'features.dekont.loadError': return 'Could not load receipts';
			case 'features.expenses.title': return 'Expenses';
			case 'features.expenses.createTitle': return 'Add expense';
			case 'features.expenses.fieldTitle': return 'Title';
			case 'features.expenses.fieldAmount': return 'Amount';
			case 'features.expenses.fieldCategory': return 'Category';
			case 'features.expenses.fieldNote': return 'Note (optional)';
			case 'features.expenses.submit': return 'Save';
			case 'features.expenses.required': return 'Required field';
			case 'features.expenses.amountInvalid': return 'Enter a valid amount';
			case 'features.expenses.total': return 'Total';
			case 'features.expenses.createSuccess': return 'Expense saved';
			case 'features.expenses.categoryCleaning': return 'Cleaning';
			case 'features.expenses.categoryElevator': return 'Elevator';
			case 'features.expenses.categoryElectricity': return 'Electricity';
			case 'features.expenses.categoryWater': return 'Water';
			case 'features.expenses.categoryInsurance': return 'Insurance';
			case 'features.expenses.categoryRepair': return 'Repair';
			case 'features.expenses.categoryGarden': return 'Garden';
			case 'features.expenses.categoryOther': return 'Other';
			case 'features.expenses.fieldDate': return 'Date';
			case 'features.expenses.fieldMonth': return 'Month';
			case 'features.expenses.fieldYear': return 'Year';
			case 'features.expenses.editTitle': return 'Edit expense';
			case 'features.expenses.editAction': return 'Edit';
			case 'features.expenses.deleteTitle': return 'Delete expense';
			case 'features.expenses.deleteAction': return 'Delete';
			case 'features.expenses.deleteConfirm': return 'Are you sure you want to delete this expense?';
			case 'features.expenses.deleteSuccess': return 'Expense deleted';
			case 'features.expenses.updateSuccess': return 'Expense updated';
			case 'features.expenses.loadError': return 'Could not load expenses';
			case 'features.expenses.emptyTitle': return 'No expenses this period';
			case 'features.expenses.emptySubtitle': return 'Add a new expense from the top-right button';
			case 'features.expenses.receiptUrlLabel': return 'Receipt link (HTTPS)';
			case 'features.expenses.receiptUrlHint': return 'Optional — public URL to the receipt file';
			case 'features.expenses.receiptUrlInvalid': return 'URL must start with https://';
			case 'features.expenses.receiptTitle': return 'Receipt photo';
			case 'features.expenses.receiptHint': return 'Optional — gallery (file upload not on live API yet)';
			case 'features.expenses.receiptAdd': return 'Add photo';
			case 'features.expenses.receiptChange': return 'Change photo';
			case 'features.expenses.receiptRemove': return 'Remove photo';
			case 'features.expenses.receiptPendingBackend': return 'Expense saved. Receipt will upload when the API is live.';
			case 'features.expenses.receiptUploadFailed': return 'Receipt upload failed. The expense was saved.';
			case 'features.expenses.receiptPickFailed': return 'Could not pick a photo';
			case 'features.notifications.markAllRead': return 'Mark all read';
			case 'features.notifications.markAllReadLong': return 'Mark all as read';
			case 'features.notifications.viewRelated': return 'Open related item';
			case 'features.notifications.unreadBadge': return 'New';
			case 'features.notifications.emptyTitle': return 'No notifications';
			case 'features.notifications.emptySubtitle': return 'New notifications will appear here';
			case 'features.notifications.emptyUnreadTitle': return 'No unread notifications';
			case 'features.notifications.emptyUnreadSubtitle': return 'You\'re all caught up';
			case 'features.notifications.loadError': return 'Could not load notifications';
			case 'features.notifications.filterAll': return 'All';
			case 'features.notifications.filterUnread': return 'Unread';
			case 'features.notifications.sectionToday': return 'Today';
			case 'features.notifications.sectionYesterday': return 'Yesterday';
			case 'features.notifications.sectionThisWeek': return 'This week';
			case 'features.notifications.sectionEarlier': return 'Earlier';
			case 'features.notifications.timeNow': return 'Just now';
			case 'features.notifications.timeMinuteShort': return 'min ago';
			case 'features.notifications.timeHourShort': return 'h ago';
			case 'features.notifications.detailLoadError': return 'Could not load details';
			case 'features.notifications.fieldStatus': return 'Status';
			case 'features.notifications.fieldCategory': return 'Category';
			case 'features.notifications.fieldApartment': return 'Apartment';
			case 'features.notifications.fieldAmount': return 'Amount';
			case 'features.notifications.fieldUploadedBy': return 'Uploaded by';
			case 'features.notifications.fieldDescription': return 'Description';
			case 'features.notifications.fieldManagerNote': return 'Manager note';
			case 'features.notifications.fieldRejectionReason': return 'Rejection reason';
			case 'features.notifications.fieldLatestUpdate': return 'Latest update';
			case 'features.notifications.fieldCreatedAt': return 'Created';
			case 'features.notifications.fieldPeriod': return 'Period';
			case 'features.notifications.actionViewTicket': return 'View request';
			case 'features.notifications.actionViewDekont': return 'Review receipt';
			case 'features.notifications.actionViewDue': return 'View due';
			case 'features.notifications.typeDueReminder': return 'Due reminder';
			case 'features.notifications.typeDuePaid': return 'Due paid';
			case 'features.notifications.typeTicketCreated': return 'New request';
			case 'features.notifications.typeTicketUpdate': return 'Request updated';
			case 'features.notifications.typeAnnouncement': return 'Announcement';
			case 'features.notifications.typeDekontReceived': return 'New receipt';
			case 'features.notifications.typeDekontNeedsReview': return 'Receipt review';
			case 'features.notifications.typeDekontMatched': return 'Receipt matched';
			case 'features.notifications.typeDekontPaymentApplied': return 'Receipt approved';
			case 'features.notifications.typeSystem': return 'System';
			case 'features.notifications.typeOther': return 'Notification';
			case 'features.notifications.sendTitle': return 'Announcement to residents';
			case 'features.notifications.fieldTitle': return 'Title';
			case 'features.notifications.fieldBody': return 'Message';
			case 'features.notifications.sendButton': return 'Send';
			case 'features.notifications.sendSuccess': return 'Announcement sent';
			case 'features.notifications.sendFailed': return 'Could not send announcement';
			case 'features.notifications.fieldRequired': return 'Required field';
			case 'features.notifications.titleTooLong': return 'Title must be at most 120 characters';
			case 'features.notifications.bodyTooLong': return 'Message must be at most 2000 characters';
			case 'features.notifications.noBuilding': return 'Add a building first';
			case 'features.profile.title': return 'Profile Details';
			case 'features.profile.fullName': return 'Full name';
			case 'features.profile.email': return 'Email';
			case 'features.profile.phone': return 'Phone';
			case 'features.profile.role': return 'Role';
			case 'features.profile.languagePref': return 'Language preference';
			case 'features.profile.notProvided': return 'Not provided';
			case 'features.profile.editHint': return 'Profile editing will be available soon.';
			case 'features.profile.sectionPersonal': return 'Personal Information';
			case 'features.profile.sectionAccount': return 'Account Information';
			case 'features.profile.editPhotoHint': return 'Tap to change photo';
			case 'features.profile.editTitle': return 'Edit Profile';
			case 'features.profile.phoneOptionalHint': return 'Optional';
			case 'features.profile.profileUpdated': return 'Your profile has been updated.';
			case 'features.profile.profileUpdateFailed': return 'Could not update profile. Please try again.';
			case 'features.profile.profileLoadFailed': return 'Could not load profile.';
			case 'features.profile.readOnlySection': return 'Cannot be edited here';
			case 'features.profile.editSheetHint': return 'Only name and phone can be updated. Other details are shown on the profile screen above.';
			case 'features.profile.photoSaved': return 'Profile photo saved for this account.';
			case 'features.profile.photoRemoved': return 'Profile photo removed.';
			case 'features.profile.removePhoto': return 'Remove profile photo';
			case 'features.subscription.title': return 'Subscription';
			case 'features.subscription.statusActive': return 'Active';
			case 'features.subscription.statusExpired': return 'Expired';
			case 'features.subscription.statusCancelled': return 'Cancelled';
			case 'features.subscription.statusTrial': return 'Trial';
			case 'features.subscription.statusUnknown': return 'Unknown';
			case 'features.subscription.planMonthly': return 'Monthly plan';
			case 'features.subscription.planAnnual': return 'Annual plan';
			case 'features.subscription.planUnknown': return 'Plan';
			case 'features.subscription.renewsOn': return 'Renews: {date}';
			case 'features.subscription.noSubscription': return 'No subscription on file yet.';
			case 'features.subscription.backendPending': return 'Subscription is not connected to the server yet. Purchases coming soon.';
			case 'features.subscription.purchaseComingSoon': return 'Purchase coming soon';
			case 'features.subscription.loadFailed': return 'Could not load subscription.';
			case 'features.faz2.sectionTitle': return 'Phase 2';
			case 'features.faz2.tickets': return 'Requests';
			case 'features.faz2.expenses': return 'Expenses';
			case 'features.faz2.announcement': return 'Announce';
			case 'legal.companyName': return 'Vefa Yazılım';
			case 'legal.contactEmail': return 'store@vefayazilim.com';
			case 'legal.contactBlock': return 'Data controller: Vefa Yazılım\nEmail: store@vefayazilim.com';
			case 'legal.updatedLabel': return 'Last updated';
			case 'legal.updatedDate': return 'June 2026';
			case 'legal.privacyIntro': return 'This policy explains how Vefa Yazılım processes your personal data when you use the AidatPanel mobile app. By continuing to use the app, you acknowledge that you have read this policy.';
			case 'legal.privacyS1Title': return '1. Data controller';
			case 'legal.privacyS1Body': return 'Your personal data is processed by Vefa Yazılım as the data controller for AidatPanel, in compliance with applicable data protection laws, including Turkish KVKK where applicable. For privacy and KVKK requests: store@vefayazilim.com';
			case 'legal.privacyS2Title': return '2. Data we collect';
			case 'legal.privacyS2Body': return 'We may process account details (name, email, phone, language), building and apartment association, dues and payment records, support tickets, announcements and notification preferences, receipt images you upload, device push token (FCM), and secure session tokens.';
			case 'legal.privacyS3Title': return '3. Purposes';
			case 'legal.privacyS3Body': return 'Data is used for dues and expense management, payment and receipt workflows, in-building communication, authentication, service security, legal obligations, and sending notifications you enable.';
			case 'legal.privacyS4Title': return '4. Retention and security';
			case 'legal.privacyS4Body': return 'Data is stored on secure servers; communication uses HTTPS. Session data is kept in secure device storage. Data is retained for the service relationship and as required by law.';
			case 'legal.privacyS5Title': return '5. Sharing';
			case 'legal.privacyS5Body': return 'We do not sell your data. It may be shared only with infrastructure providers necessary to run the service (hosting, push notifications, etc.) and authorities when legally required.';
			case 'legal.privacyS6Title': return '6. Your rights';
			case 'legal.privacyS6Body': return 'You may request access, correction, deletion, or restriction of processing. Account closure (soft delete) is available in Settings; records that must be kept by law may be stored in anonymized form. Submit requests to store@vefayazilim.com.';
			case 'legal.kvkkIntro': return 'This notice is provided under Turkish Personal Data Protection Law No. 6698 (KVKK) for processing by Vefa Yazılım.';
			case 'legal.kvkkS1Title': return 'Data controller and contact';
			case 'legal.kvkkS1Body': return 'The data controller for AidatPanel is Vefa Yazılım. You may submit KVKK requests to store@vefayazilim.com or using your registered email in the app.';
			case 'legal.kvkkS2Title': return 'Data categories';
			case 'legal.kvkkS2Body': return 'Categories may include identity and contact, customer transaction (dues, payments, expenses), visual records (receipts), security (logs, tokens), and communication (notification consent).';
			case 'legal.kvkkS3Title': return 'Purposes and legal bases';
			case 'legal.kvkkS3Body': return 'Processing is based on contract performance, legal obligation, legitimate interest, and your explicit consent where required (e.g. notifications).';
			case 'legal.kvkkS4Title': return 'Transfers';
			case 'legal.kvkkS4Body': return 'Data may be transferred to hosting and technical providers within Türkiye as needed to provide the service, with appropriate safeguards.';
			case 'legal.kvkkS5Title': return 'Collection method';
			case 'legal.kvkkS5Body': return 'Data is collected electronically via app forms, automated logs, files you upload, and the notification infrastructure.';
			case 'legal.kvkkS6Title': return 'Data subject rights';
			case 'legal.kvkkS6Body': return 'You may exercise your rights under Article 11 of KVKK by contacting Vefa Yazılım at store@vefayazilim.com; requests are answered within statutory time limits.';
			case 'legal.helpIntro': return 'Help center coming soon';
			case 'legal.helpBody': return 'FAQs, step-by-step guides, and support channels will be added here soon. For app support: store@vefayazilim.com (Vefa Yazılım). For urgent building matters, contact your building manager or site administration.';
			case 'db_context.user_entry': return 'Record: {value}';
			case 'db_context.building_name': return 'Building: {value}';
			case 'db_context.apartment_label': return 'Apartment: {value}';
			case 'db_context.code_value': return 'Code: {value}';
			case 'db_context.expiry_date': return 'Expires at: {value}';
			default: return null;
		}
	}
}

extension on _StringsTr {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'common.logout': return 'Çıkış Yap';
			case 'common.cancel': return 'İptal';
			case 'common.confirm': return 'Onayla';
			case 'common.save': return 'Kaydet';
			case 'common.delete': return 'Sil';
			case 'common.edit': return 'Düzenle';
			case 'common.close': return 'Kapat';
			case 'common.yes': return 'Evet';
			case 'common.no': return 'Hayır';
			case 'common.register': return 'Kaydol';
			case 'common.login': return 'Giriş Yap';
			case 'common.join': return 'Katıl';
			case 'common.confirmMessage': return 'Emin misiniz?';
			case 'common.logoutConfirm': return 'Çıkış yapmak istediğinize emin misiniz?';
			case 'common.logoutSuccess': return 'Başarıyla çıkış yaptınız.';
			case 'common.logoutAllDevices': return 'Diğer cihazlardan çıkış';
			case 'common.logoutAllDevicesConfirm': return 'Diğer telefon ve tabletlerdeki oturumlar kapanır. Bu cihazda girişiniz devam eder.';
			case 'common.logoutAllDevicesSuccess': return 'Diğer cihazlardaki oturumlar kapatıldı.';
			case 'common.logoutAllDevicesFailed': return 'İşlem tamamlanamadı. Lütfen tekrar deneyin.';
			case 'common.account': return 'Hesap';
			case 'common.editProfile': return 'Profili Düzenle';
			case 'common.changePassword': return 'Şifre Değiştir';
			case 'common.language': return 'Dil';
			case 'common.turkish': return 'Türkçe';
			case 'common.notifications': return 'Bildirimler';
			case 'common.info': return 'Bilgi';
			case 'common.privacyPolicy': return 'Gizlilik Politikası';
			case 'common.kvkk': return 'KVKK';
			case 'common.helpSupport': return 'Yardım ve Destek';
			case 'common.about': return 'Hakkında';
			case 'common.comingSoon': return 'Bu özellik yakında eklenecek';
			case 'common.multiLanguageComingSoon': return 'Çoklu dil desteği yakında eklenecek';
			case 'common.copyright': return ' 2026 AidatPanel\nTüm hakları saklıdır.';
			case 'common.aboutDescription': return 'Türk apartman ve site yöneticileri için aidat yönetim platformu.';
			case 'common.manager': return 'Yönetici';
			case 'common.resident': return 'Sakin';
			case 'common.tokenExpiryTest': return 'Token Süresi Kontrol (Test)';
			case 'common.tokenExpired': return 'Token süresi DOLMUŞ! Login ekranına atılıyorsunuz.';
			case 'common.tokenActive': return 'Token aktif! Kalan süre';
			case 'common.pressBackAgainToExit': return 'Çıkmak için geri tuşuna tekrar basın';
			case 'common.loading': return 'Yükleniyor…';
			case 'common.loadingBuildings': return 'Binalar yükleniyor…';
			case 'common.loadFailed': return 'Yüklenemedi';
			case 'common.unexpectedError': return 'İşlem tamamlanamadı. Lütfen tekrar deneyin.';
			case 'common.rateLimitHint': return 'Sunucu şu an yoğun görünüyor. Kısa süre sonra yeniden denenecek.';
			case 'common.tryAgain': return 'Tekrar Dene';
			case 'common.home': return 'Ana Sayfa';
			case 'common.buildings': return 'Binalar';
			case 'common.dues': return 'Aidatlar';
			case 'common.settings': return 'Ayarlar';
			case 'common.user': return 'Kullanıcı';
			case 'common.welcome': return 'Hoş Geldiniz';
			case 'common.managedBuildings': return 'Yönetilen Binalar';
			case 'common.issues': return 'Arızalar';
			case 'common.issuesTab': return 'Arızalar Sekmesi';
			case 'common.apartment': return 'Daire';
			case 'common.addBuilding': return 'Bina Ekle';
			case 'common.inviteCode': return 'Davet Kodu';
			case 'common.myBuildings': return 'Binalarım';
			case 'common.apartments': return 'Daireler';
			case 'common.collection': return 'Tahsilat';
			case 'common.duesTab': return 'Aidatlar Sekmesi';
			case 'common.totalApartments': return 'Toplam Daire';
			case 'common.occupiedApartments': return 'Dolu Daire';
			case 'common.duesCollection': return 'Aidat Tahsilatı';
			case 'common.totalDues': return 'Toplam Aidat';
			case 'common.recentTransactions': return 'Son İşlemler';
			case 'common.paid': return 'Ödendi';
			case 'common.pending': return 'Beklemede';
			case 'common.overdue': return 'Gecikmiş';
			case 'common.balance': return 'Bakiye';
			case 'common.amountDue': return 'Ödenmesi Gereken';
			case 'common.lastPayment': return 'Son Ödeme';
			case 'common.makePayment': return 'Ödeme Yap';
			case 'common.bills': return 'Faturalar';
			case 'common.support': return 'Destek';
			case 'common.quickActions': return 'Hızlı işlemler';
			case 'common.residentName': return 'Sakin Adı';
			case 'common.addBuildingNew': return 'Yeni Bina Ekle';
			case 'common.basicInfo': return 'Temel Bilgiler';
			case 'common.buildingName': return 'Bina Adı';
			case 'common.buildingNameHint': return 'Örn: Güneş Apartmanı';
			case 'common.location': return 'Konum';
			case 'common.streetAddress': return 'Sokak / Cadde Adresi';
			case 'common.streetAddressHint': return 'Örn: Bağdat Cad. No: 123';
			case 'common.details': return 'Detaylar';
			case 'common.floorCount': return 'Kat Sayısı';
			case 'common.floorCountHint': return '1 ile 200 arası';
			case 'common.apartmentsPerFloor': return 'Kattaki Daire';
			case 'common.apartmentsPerFloorHint': return '1 ile 50 arası';
			case 'common.floorRangeError': return 'Kat sayısı 1 ile 200 arasında olmalı';
			case 'common.apartmentsPerFloorRangeError': return 'Kat başına daire 1 ile 50 arasında olmalı';
			case 'common.buildingAddFailed': return 'Bina eklenemedi. Lütfen tekrar deneyin.';
			case 'common.monthlyDues': return 'Aylık Aidat';
			case 'common.monthlyDuesLabel': return 'Aylık Aidat (₺)';
			case 'common.monthlyDuesHint': return 'Örn: 1000';
			case 'common.createBuilding': return 'Bina Oluştur';
			case 'common.cancelBtn': return 'Vazgeç';
			case 'common.cityRequired': return 'Şehir *';
			case 'common.selectCity': return 'Şehir seçin';
			case 'common.districtRequired': return 'İlçe *';
			case 'common.selectDistrict': return 'İlçe seçin';
			case 'common.selectCityFirst': return 'Önce şehir seçin';
			case 'common.selectCityTitle': return 'Şehir Seçin';
			case 'common.selectDistrictTitle': return 'İlçe Seçin';
			case 'common.search': return 'Ara...';
			case 'common.noResults': return 'Sonuç bulunamadı';
			case 'common.fieldRequired': return 'boş bırakılamaz';
			case 'common.fillRequiredFields': return 'Lütfen zorunlu alanları doldurun';
			case 'common.selectCityAndDistrict': return 'Şehir ve ilçe seçmelisiniz';
			case 'common.floorApartmentMustBePositive': return 'Kat sayısı ve daire sayısı 0\'dan büyük olmalı';
			case 'common.buildingAddedSuccess': return 'Bina başarıyla eklendi';
			case 'common.createInviteCode': return 'Davet Kodu Oluştur';
			case 'common.whichBuildingForCode': return 'Hangi binadan kod üretilecek?';
			case 'common.whichApartmentForCode': return 'Hangi daire için kod üretilecek?';
			case 'common.noApartmentsInBuilding': return 'Bu binaya henüz daire eklenmemiş';
			case 'common.activeCodeBadge': return 'Aktif Kod';
			case 'common.occupiedBadge': return 'Dolu';
			case 'common.emptyBadge': return 'Boş';
			case 'common.activeCodePrefix': return 'Aktif kod';
			case 'common.residentPrefix': return 'Sakin';
			case 'common.emptyApartment': return 'Boş daire';
			case 'common.codeRevoked': return 'Kod iptal edildi';
			case 'common.codeCopied': return 'Kod kopyalandı';
			case 'common.clipboardCopied': return 'Mesaj panoya kopyalandı';
			case 'common.expiresAtPrefix': return 'Son kullanma';
			case 'common.remainingPrefix': return 'Kalan';
			case 'common.buildingDetail': return 'Bina Detayı';
			case 'common.residents': return 'Sakinler';
			case 'common.apartmentsBadge': return 'Daire';
			case 'common.emptyApartmentText': return 'Boş Daire';
			case 'common.vacantBadge': return 'Boş';
			case 'common.phoneNotShared': return 'Telefon paylaşılmadı';
			case 'common.residentDetailsLink': return 'Detaylar..';
			case 'common.residentDetailsSheetTitle': return 'Sakin bilgileri';
			case 'common.apartmentDetailsSheetTitle': return 'Daire bilgileri';
			case 'common.noResidentAssigned': return 'Sakin atanmamış';
			case 'common.noApartmentsYet': return 'Henüz daire eklenmemiş';
			case 'common.paidStatus': return 'Ödendi';
			case 'common.pendingStatus': return 'Bekliyor';
			case 'common.overdueStatus': return 'Gecikmiş';
			case 'common.waivedStatus': return 'Muaf';
			case 'common.all': return 'Tümü';
			case 'common.status': return 'Durum';
			case 'common.month': return 'Ay';
			case 'common.monthJanuary': return 'Ocak';
			case 'common.monthFebruary': return 'Şubat';
			case 'common.monthMarch': return 'Mart';
			case 'common.monthApril': return 'Nisan';
			case 'common.monthMay': return 'Mayıs';
			case 'common.monthJune': return 'Haziran';
			case 'common.monthJuly': return 'Temmuz';
			case 'common.monthAugust': return 'Ağustos';
			case 'common.monthSeptember': return 'Eylül';
			case 'common.monthOctober': return 'Ekim';
			case 'common.monthNovember': return 'Kasım';
			case 'common.monthDecember': return 'Aralık';
			case 'common.allMonths': return 'Tüm aylar';
			case 'common.year': return 'Yıl';
			case 'common.allYears': return 'Tüm yıllar';
			case 'common.note': return 'Not';
			case 'common.myDuesHistory': return 'Aidat Geçmişim';
			case 'common.currentPeriodDue': return 'Güncel aidat';
			case 'common.myPastDues': return 'Geçmiş aidatlarım';
			case 'common.buildingDues': return 'Bina Aidatları';
			case 'common.noDuesYet': return 'Henüz aidat kaydı yok';
			case 'common.duesUpdated': return 'Aidat durumu güncellendi';
			case 'common.amount': return 'Tutar';
			case 'common.updateDueAmount': return 'Aidat Tutarını Güncelle';
			case 'common.dueAmountUpdated': return 'Aidat tutarı güncellendi';
			case 'common.dueAmountUpdateFailed': return 'Aidat tutarı güncellenemedi';
			case 'common.dueDay': return 'Aidat Günü (1-28)';
			case 'common.selectDueDay': return 'Gün seçin';
			case 'common.affectCurrentDues': return 'Bekleyen aidatlara da uygula';
			case 'common.affectCurrentDuesHint': return 'Açık olduğunda mevcut bekleyen (PENDING) aidat tutarları da yeni tutara güncellenir.';
			case 'common.dueUpdateNeedAmountOrDay': return 'Güncellemek için tutar girin veya aidat günü seçin.';
			case 'common.dueUpdateNeedStoredAmount': return 'Bu bina için kayıtlı tutar yok. Aidat gününü güncellemek için önce tutar yazın.';
			case 'common.dueAmountInvalidPositive': return 'Geçerli bir tutar yazın.';
			case 'common.dueDayOutOfRange': return 'Aidat günü 1 ile 28 arasında olmalıdır.';
			case 'common.update': return 'Güncelle';
			case 'common.overdueDays': return 'gün gecikmiş';
			case 'common.dueDateLabel': return 'Son ödeme';
			case 'common.perMonth': return '/ ay';
			case 'common.floorLabel': return 'KAT';
			case 'common.apartmentLabel': return 'DAİRE';
			case 'common.turkishLanguage': return 'Türkçe';
			case 'common.englishLanguage': return 'English';
			case 'common.stepBuilding': return 'Bina';
			case 'common.stepApartment': return 'Daire';
			case 'common.stepCode': return 'Kod';
			case 'common.editBuilding': return 'Binayı Düzenle';
			case 'common.deleteBuilding': return 'Binayı Sil';
			case 'common.buildingUpdated': return 'Bina güncellendi';
			case 'common.buildingDeleted': return 'Bina silindi';
			case 'common.buildingUpdateFailed': return 'Bina güncellenemedi';
			case 'common.buildingDeleteFailed': return 'Bina silinemedi';
			case 'common.buildingDeleteFailedFK': return 'Bu binayı silemezsiniz: hâlâ daire, sakin veya aidat kayıtları var. Önce daireleri/aidatları temizleyip tekrar deneyin.';
			case 'common.deleteBuildingHeader': return 'Bu işlem geri alınamaz.';
			case 'common.deleteBuildingTypeHint': return 'Onaylamak için aşağıya bina adını aynen yazın:';
			case 'common.deleteBuildingTypeFieldLabel': return 'Bina adı';
			case 'common.buildingNameMismatch': return 'Yazdığınız metin bina adıyla aynı değil.';
			case 'common.editApartment': return 'Daireyi Düzenle';
			case 'common.deleteApartment': return 'Daireyi Sil';
			case 'common.apartmentUpdated': return 'Daire güncellendi';
			case 'common.apartmentDeleted': return 'Daire silindi';
			case 'common.apartmentUpdateFailed': return 'Daire güncellenemedi';
			case 'common.apartmentDeleteFailed': return 'Daire silinemedi';
			case 'common.apartmentDeleteFailedFK': return 'Bu daireyi silemezsiniz: sakin veya aidat kayıtları var. Önce sakinin hesap kapatmasını bekleyip aidatları temizleyin.';
			case 'common.deleteApartmentConfirm': return 'Daireyi silmek istediğinize emin misiniz?';
			case 'common.apartmentNumberLabel': return 'Daire No (örn. 5A)';
			case 'common.floorLabel2': return 'Kat (opsiyonel)';
			case 'common.floorOptional': return 'Kat (-5 ile 200 arası)';
			case 'common.buildingNameField': return 'Bina adı';
			case 'common.buildingAddressField': return 'Adres';
			case 'common.buildingCityField': return 'Şehir';
			case 'common.monthlyDuesPerApartment': return 'Aylık aidat / daire';
			case 'common.remove': return 'Çıkar';
			case 'common.removeResident': return 'Sakini Çıkar';
			case 'common.removeResidentConfirm': return 'Bu sakini daireden çıkarmak istediğinize emin misiniz?';
			case 'common.removeResidentNote': return 'Sakinin hesabı silinmez, sadece bu daireden bağlantısı kopar. Geçmiş aidat kayıtları korunur. Sakin başka bir daireye davet kodu ile tekrar katılabilir.';
			case 'common.residentRemoved': return 'Sakin daireden çıkarıldı';
			case 'common.residentRemoveFailed': return 'Sakin çıkarılamadı';
			case 'common.residentRemoveForbidden': return 'Bu işlem için yetkiniz yok. Yalnızca binanın yöneticisi sakin çıkarabilir.';
			case 'common.residentRemoveNotFound': return 'Bu dairede çıkarılacak sakin bulunamadı.';
			case 'common.multiSelectResidents': return 'Çoklu seç';
			case 'common.multiSelectTapHint': return 'Seçmek için karta dokunun';
			case 'common.selectTriggerShort': return 'Seç';
			case 'common.selectedCountLabel': return 'seçili';
			case 'common.selectionRemoveHint': return 'Çıkarmak istediğiniz sakinleri seçin';
			case 'common.selectionDeleteIbanHint': return 'Silmek istediğiniz IBAN\'ları seçin';
			case 'common.removeSelectedResidents': return 'Seçilenleri çıkar';
			case 'common.removeSelectedResidentsTitle': return 'Seçilen sakinleri çıkar';
			case 'common.removeSelectedResidentsMessage': return 'Aşağıda listelenen dairelerde oturan sakinler daireden çıkarılır. Hesapları silinmez; yalnızca bu binadaki bağlantıları kalkar. Geçmiş aidat kayıtları korunur.';
			case 'common.removeSelectedResidentsAffectedListTitle': return 'Etkilenecek daireler';
			case 'common.removeSelectedResidentsListUnavailable': return 'Daire listesi şu an gösterilemiyor. Seçilen daire sayısı aşağıda; onaylarsanız işlem yine de uygulanır.';
			case 'common.pickResidentsFirst': return 'Önce listeden en az bir dolu daire seçin';
			case 'common.removeSelectedProgress': return 'İşlem yapılıyor…';
			case 'common.removeSelectedSuccess': return 'Seçilen sakinler dairelerden çıkarıldı';
			case 'common.removeSelectedFailed': return 'Seçilenleri çıkarma tamamlanamadı';
			case 'common.currentPassword': return 'Mevcut Şifre';
			case 'common.newPassword': return 'Yeni Şifre';
			case 'common.newPasswordConfirm': return 'Yeni Şifre (Tekrar)';
			case 'common.currentPasswordRequired': return 'Mevcut şifrenizi girin';
			case 'common.passwordsMustDiffer': return 'Yeni şifre eski şifre ile aynı olamaz';
			case 'common.changePasswordTitle': return 'Şifre Değiştir';
			case 'common.changePasswordSubtitle': return 'Güvenliğiniz için şifrenizi düzenli olarak değiştirin.';
			case 'common.changePasswordSuccess': return 'Şifreniz değiştirildi. Lütfen yeni şifrenizle tekrar giriş yapın.';
			case 'common.changePasswordFailed': return 'Şifre değiştirilemedi. Lütfen tekrar deneyin.';
			case 'common.changePasswordWrongCurrent': return 'Mevcut şifre hatalı.';
			case 'common.deleteAccount': return 'Hesabımı Kapat';
			case 'common.deleteAccountTitle': return 'Hesabınızı kapatmak istiyor musunuz?';
			case 'common.deleteAccountWarning': return 'Bu işlem geri alınamaz. Kişisel bilgileriniz silinir, ancak yasal nedenlerle bazı kayıtlar (aidat geçmişi gibi) anonim olarak saklanır.';
			case 'common.deleteAccountTypeHint': return 'Onaylamak için aşağıya "HESABIMI KAPAT" yazın:';
			case 'common.deleteAccountTypePhrase': return 'HESABIMI KAPAT';
			case 'common.deleteAccountTypeMismatch': return 'Yazdığınız metin eşleşmiyor.';
			case 'common.deleteAccountConfirmButton': return 'Hesabımı Kapat';
			case 'common.deleteAccountSuccess': return 'Hesabınız kapatıldı. Bizi tercih ettiğiniz için teşekkürler.';
			case 'common.deleteAccountFailed': return 'Hesap kapatılamadı. Lütfen tekrar deneyin.';
			case 'common.deleteAccountFailedManager': return 'Önce yönettiğiniz binaları silmeniz veya başka bir yöneticiye devretmeniz gerekiyor.';
			case 'common.dangerZone': return 'Tehlikeli Bölge';
			case 'common.forgotPassword': return 'Şifremi Unuttum';
			case 'common.forgotPasswordTitle': return 'Şifremi Unuttum';
			case 'common.forgotPasswordSubtitle': return 'Kayıtlı e-posta adresinizi girin, size bir sıfırlama kodu gönderelim.';
			case 'common.forgotPasswordSuccess': return 'Eğer bu e-posta sistemimizde kayıtlıysa, sıfırlama kodu gönderildi. Lütfen e-postanızı kontrol edin.';
			case 'common.sendResetCode': return 'Kodu Gönder';
			case 'common.iHaveACode': return 'Zaten kodum var';
			case 'common.resetPasswordTitle': return 'Yeni Şifre Belirle';
			case 'common.resetPasswordSubtitle': return 'E-postanıza gelen 6 haneli kodu ve yeni şifrenizi girin.';
			case 'common.resetCode': return 'Sıfırlama Kodu';
			case 'common.resetCodeHint': return 'ABC123';
			case 'common.resetCodeRequired': return 'Sıfırlama kodu gerekli';
			case 'common.resetCodeInvalid': return 'Kod 6 karakter olmalı';
			case 'common.resetPasswordSuccess': return 'Şifreniz sıfırlandı. Yeni şifrenizle giriş yapabilirsiniz.';
			case 'common.resetPasswordFailed': return 'Şifre sıfırlanamadı. Kod hatalı veya süresi dolmuş olabilir.';
			case 'common.resetPasswordSubmit': return 'Şifreyi Sıfırla';
			case 'common.backToLogin': return 'Giriş ekranına dön';
			case 'validation.emailRequired': return 'Email adresi boş bırakılamaz';
			case 'validation.emailInvalid': return 'Geçerli bir email adresi giriniz';
			case 'validation.emailTooLong': return 'Email adresi çok uzun';
			case 'validation.phoneRequired': return 'Telefon numarası boş bırakılamaz';
			case 'validation.phoneInvalid': return 'Telefon numarası 10 haneli olmalıdır';
			case 'validation.passwordRequired': return 'Şifre boş bırakılamaz';
			case 'validation.passwordTooShort': return 'Şifre en az 6 karakter olmalıdır';
			case 'validation.passwordTooLong': return 'Şifre çok uzun';
			case 'validation.passwordUppercaseRequired': return 'Şifrede en az 1 büyük harf olmalıdır';
			case 'validation.passwordLowercaseRequired': return 'Şifrede en az 1 küçük harf olmalıdır';
			case 'validation.passwordNumberRequired': return 'Şifrede en az 1 rakam olmalıdır';
			case 'validation.passwordSpecialCharRequired': return 'Şifrede en az 1 özel karakter olmalıdır';
			case 'features.buildings.managerPanel': return 'Yönetici';
			case 'features.buildings.buildingDetail': return 'Bina Detayı';
			case 'features.buildings.addBuilding': return 'Bina Ekle';
			case 'features.buildings.newBuilding': return 'Yeni Bina Ekle';
			case 'features.buildings.inviteCode': return 'Davet Kodu';
			case 'features.buildings.createInviteCode': return 'Davet Kodu Oluştur';
			case 'features.buildings.cancelCode': return 'Kodu İptal Et';
			case 'features.buildings.apartmentOccupied': return 'Daire Dolu';
			case 'features.buildings.copy': return 'Kopyala';
			case 'features.buildings.share': return 'Paylaş';
			case 'features.buildings.anotherApartment': return 'Başka Daire';
			case 'features.buildings.codeRevoked': return 'Kod iptal edildi';
			case 'features.buildings.occupiedDialog': return 'Yeni kod üretirsen eski kullanıcı çıkarılır. Emin misiniz?';
			case 'features.buildings.revokeDialog': return 'Mevcut kod geçersiz hale gelir. Emin misiniz?';
			case 'features.buildings.produceAnyway': return 'Yine de Üret';
			case 'features.buildings.newCodePrefix': return 'Yeni kod üretirsen ';
			case 'features.buildings.oldUserRemoved': return 'eski kullanıcı çıkarılır';
			case 'features.buildings.currentCodePrefix': return 'Mevcut kod ';
			case 'features.buildings.codeInvalid': return 'geçersiz hale gelir';
			case 'features.buildings.codeReady': return 'Davet Kodu Hazır';
			case 'features.buildings.code': return 'KOD';
			case 'features.buildings.validFor7Days': return '7 gün geçerli';
			case 'features.buildings.expiresAt': return 'Son kullanma:';
			case 'features.buildings.remaining': return 'Kalan:';
			case 'features.buildings.activeCodeNote': return 'Bu kod aktifken aynı daireye yeni kod üretilemez. Yeni kod için önce mevcut kodu iptal etmelisin.';
			case 'features.buildings.backToMainMenu': return 'Ana Menüye Dön';
			case 'features.buildings.tekrarDene': return 'Tekrar Dene';
			case 'features.buildings.collection.sectionTitle': return 'Tahsilat bilgileri';
			case 'features.buildings.collection.sectionHint': return 'Sakinlerin havale yapacağı IBAN. Boş bırakılabilir; sonradan da ekleyebilirsiniz.';
			case 'features.buildings.collection.modeSaved': return 'Kayıtlı IBAN';
			case 'features.buildings.collection.modeNew': return 'Yeni IBAN';
			case 'features.buildings.collection.savedListTitle': return 'Daha önce kullandıklarınız';
			case 'features.buildings.collection.pickSavedIban': return 'Kayıtlı IBAN seçin';
			case 'features.buildings.collection.changeSavedIban': return 'Başka IBAN seçmek için dokunun';
			case 'features.buildings.collection.searchSavedIban': return 'IBAN veya unvan ara';
			case 'features.buildings.collection.detailAccountHolder': return 'Hesap sahibi';
			case 'features.buildings.collection.detailReference': return 'Havale açıklaması';
			case 'features.buildings.collection.detailReferenceAuto': return 'Havale açıklamasına daire numarası otomatik eklenir';
			case 'features.buildings.collection.detailReferenceDaireOnly': return 'Havale açıklaması: Daire numarası';
			case 'features.buildings.collection.detailReferenceDaireAidat': return 'Havale açıklaması: Daire no + aidat';
			case 'features.buildings.collection.detailReferenceAidat': return 'Havale açıklaması: Aidat (daire no otomatik)';
			case 'features.buildings.collection.detailReferenceHavale': return 'Havale açıklaması: Daire numarası ile havale';
			case 'features.buildings.collection.detailUsedInBuildings': return '{count} binada kullanılıyor';
			case 'features.buildings.collection.ibanLabel': return 'IBAN';
			case 'features.buildings.collection.ibanHint': return 'TR33 0006 1005 1978 6457 8413 26';
			case 'features.buildings.collection.ibanInvalid': return 'Geçerli bir Türkiye IBAN girin (TR + 24 rakam)';
			case 'features.buildings.collection.ibanRequiredIfOtherFilled': return 'Alıcı veya açıklama girdiniz; geçerli IBAN girin';
			case 'features.buildings.collection.accountTitleLabel': return 'Hesap sahibi / alıcı unvanı';
			case 'features.buildings.collection.accountTitleHint': return 'Örn: Site Yönetimi';
			case 'features.buildings.collection.referenceTemplateLabel': return 'Havale açıklama şablonu';
			case 'features.buildings.collection.referenceTemplateHint': return 'Örn: Daire {{number}}';
			case 'features.buildings.collection.presetsEmpty': return 'Henüz kayıtlı tahsilat bilgisi yok';
			case 'features.buildings.collection.presetsLoadFailed': return 'Öneriler yüklenemedi';
			case 'features.buildings.collection.presetBuildingCount': return '{count} bina';
			case 'features.buildings.collection.menuEdit': return 'Tahsilat / IBAN';
			case 'features.buildings.collection.editSheetTitle': return 'Tahsilat bilgileri';
			case 'features.buildings.collection.saveSuccess': return 'Tahsilat bilgileri kaydedildi';
			case 'features.buildings.collection.savedIbansTitle': return 'Kayıtlı IBAN\'larım';
			case 'features.buildings.collection.savedIbansEmpty': return 'Henüz kayıtlı IBAN yok. Bina eklerken tahsilat bilgisi tanımlayabilirsiniz.';
			case 'features.buildings.collection.savedIbansNoBuildingMatch': return 'Bu sete bağlı bina bulunamadı';
			case 'features.buildings.collection.savedIbansBuildingNames': return 'Binalar: {names}';
			case 'features.buildings.collection.savedIbansUpdateSuccess': return '{count} bina için tahsilat bilgisi güncellendi';
			case 'features.buildings.collection.savedIbansUpdateHint': return 'Güncellenecek binalar: {names}';
			case 'features.buildings.collection.editSavedIbanTitle': return 'IBAN düzenle';
			case 'features.buildings.collection.savedIbansOrphanHint': return 'Henüz bir binaya atanmamış kayıtlı set. Değişiklik yalnızca bu listede saklanır.';
			case 'features.buildings.collection.savedIbansAddTitle': return 'Yeni IBAN ekle';
			case 'features.buildings.collection.savedIbansAddHint': return 'Bu bilgileri bina eklerken veya tahsilat ayarlarında kullanabilirsiniz.';
			case 'features.buildings.collection.savedIbansAddSuccess': return 'IBAN kaydedildi';
			case 'features.buildings.collection.savedIbansSelectMode': return 'Çoklu seç';
			case 'features.buildings.collection.savedIbansSelectedLabel': return 'seçili';
			case 'features.buildings.collection.savedIbansDeleteSelected': return 'Seçilenleri sil';
			case 'features.buildings.collection.savedIbansPickFirst': return 'Önce silmek istediğiniz IBAN\'ları seçin';
			case 'features.buildings.collection.savedIbansDeleteTitle': return 'IBAN silinsin mi?';
			case 'features.buildings.collection.savedIbansDeleteMessage': return 'Bu kayıtlı IBAN listeden kaldırılacak.';
			case 'features.buildings.collection.savedIbansDeleteBulkTitle': return 'Seçilen IBAN\'lar silinsin mi?';
			case 'features.buildings.collection.savedIbansDeleteBulkMessage': return '{count} kayıtlı IBAN silinecek.';
			case 'features.buildings.collection.savedIbansDeleteBuildingWarning': return '{count} binanın tahsilat bilgisi de temizlenecek.';
			case 'features.buildings.collection.savedIbansDeleteSuccess': return 'IBAN silindi';
			case 'features.buildings.collection.savedIbansDeleteBulkSuccess': return '{count} IBAN silindi';
			case 'features.buildings.collection.ibanNotConfigured': return 'Tahsilat IBAN tanımlı değil';
			case 'features.auth.register': return 'Kaydol';
			case 'features.auth.login': return 'Giriş Yap';
			case 'features.auth.join': return 'Katıl';
			case 'features.auth.passwordRequired': return 'Şifre gerekli';
			case 'features.auth.errorOccurred': return 'Bir hata oluştu';
			case 'features.auth.registrationSuccess': return 'Hesabınız oluşturuldu. Giriş yapabilirsiniz.';
			case 'features.auth.loginSuccess': return 'Giriş başarılı. Hoş geldiniz.';
			case 'features.auth.appTitle': return 'AidatPanel';
			case 'features.auth.appSubtitle': return 'Apartman Yönetim Sistemi';
			case 'features.auth.splashConnectionError': return 'Sunucuya bağlanılamadı';
			case 'features.auth.splashConnectionHint': return 'İnternet bağlantını kontrol edip tekrar dene.';
			case 'features.auth.skipToLogin': return 'Giriş ekranına git';
			case 'features.auth.phone': return 'Telefon';
			case 'features.auth.email': return 'Email';
			case 'features.auth.phoneHint': return '5XX XXX XX XX';
			case 'features.auth.emailHint': return 'ornek@email.com';
			case 'features.auth.password': return 'Şifre';
			case 'features.auth.passwordHint': return '••••••••';
			case 'features.auth.emailLogin': return 'Email ile Giriş Yap';
			case 'features.auth.phoneLogin': return 'Telefon ile Giriş Yap';
			case 'features.auth.or': return 'veya';
			case 'features.auth.noAccount': return 'Hesabınız yok mu? Kaydolun';
			case 'features.auth.joinWithCode': return 'Davet kodu ile katılın';
			case 'features.auth.signUp': return 'Üye ol';
			case 'features.auth.signUpTitle': return 'Üye Ol';
			case 'features.auth.signUpSubtitle': return 'Nasıl katılmak istiyorsunuz?';
			case 'features.auth.beManager': return 'Yönetici ol';
			case 'features.auth.beManagerHint': return 'Bina oluşturup yönetici hesabı açın';
			case 'features.auth.joinWithInvite': return 'Davet koduyla katıl';
			case 'features.auth.joinWithInviteHint': return 'Yöneticinizin verdiği kod ile sakin olun';
			case 'features.auth.copyright': return '© Vefa Yazılım';
			case 'features.auth.createAccount': return 'Yeni Hesap Oluştur';
			case 'features.auth.name': return 'Ad Soyad';
			case 'features.auth.nameHint': return 'Örn: Furkan Kaya';
			case 'features.auth.phoneOptional': return 'Telefon (Opsiyonel)';
			case 'features.auth.phoneHintOptional': return '5XX XXX XXXX';
			case 'features.auth.minLength': return 'En az 6 karakter';
			case 'features.auth.hasUpperCase': return 'En az 1 büyük harf';
			case 'features.auth.hasLowerCase': return 'En az 1 küçük harf';
			case 'features.auth.hasNumber': return 'En az 1 rakam';
			case 'features.auth.hasSpecialChar': return 'En az 1 özel karakter';
			case 'features.auth.confirmPassword': return 'Şifre Tekrar';
			case 'features.auth.passwordsDoNotMatch': return 'Şifreler eşleşmiyor';
			case 'features.auth.emailAndPasswordRequired': return 'Email ve şifre boş bırakılamaz';
			case 'features.auth.hasAccount': return 'Zaten hesabınız var mı? Giriş yapın';
			case 'features.auth.joinApartment': return 'Apartmana Katıl';
			case 'features.auth.inviteCode': return 'Davet Kodu';
			case 'features.auth.inviteCodeHint': return 'AP3-B12-A9F0';
			case 'features.auth.invalidInviteCodeFormat': return 'Geçersiz davet kodu formatı (Örn: AP3-B12-A9F0)';
			case 'features.auth.invalidPhoneFormat': return 'Geçerli bir telefon numarası giriniz (5XX XXX XX XX)';
			case 'features.auth.inviteCodeAndPasswordRequired': return 'Davet kodu, ad ve şifre boş bırakılamaz';
			case 'features.auth.invalidPhoneNumber': return 'Geçerli bir telefon numarası giriniz';
			case 'features.auth.areYouManager': return 'Yönetici misiniz? Kaydolun';
			case 'features.apartments.residentPanel': return 'Sakin';
			case 'features.tickets.myTickets': return 'Taleplerim';
			case 'features.tickets.newTicket': return 'Yeni Talep';
			case 'features.tickets.createTitle': return 'Arıza / Talep Bildir';
			case 'features.tickets.fieldTitle': return 'Başlık';
			case 'features.tickets.fieldTitleHint': return 'Örn: Asansör arızası';
			case 'features.tickets.fieldDescription': return 'Açıklama';
			case 'features.tickets.fieldDescriptionHint': return 'Sorunu kısaca anlatın';
			case 'features.tickets.fieldCategory': return 'Kategori';
			case 'features.tickets.categoryComplaint': return 'Şikayet';
			case 'features.tickets.categoryRequest': return 'Talep';
			case 'features.tickets.categoryMalfunction': return 'Arıza';
			case 'features.tickets.categoryOther': return 'Diğer';
			case 'features.tickets.submit': return 'Gönder';
			case 'features.tickets.createSuccess': return 'Talebiniz alındı';
			case 'features.tickets.createFailed': return 'Talep kaydedilemedi. Lütfen tekrar deneyin.';
			case 'features.tickets.createServiceUnavailable': return 'Talep servisi şu an hazır değil. Lütfen daha sonra tekrar deneyin.';
			case 'features.tickets.emptyTitle': return 'Henüz talep yok';
			case 'features.tickets.emptySubtitle': return 'Arıza veya talebinizi buradan bildirebilirsiniz';
			case 'features.tickets.titleTooShort': return 'Başlık en az 3 karakter olmalı';
			case 'features.tickets.descriptionTooShort': return 'Açıklama en az 10 karakter olmalı';
			case 'features.tickets.statusOpen': return 'Açık';
			case 'features.tickets.statusInProgress': return 'İşlemde';
			case 'features.tickets.statusResolved': return 'Çözüldü';
			case 'features.tickets.statusClosed': return 'Kapalı';
			case 'features.tickets.statusTrackerTitle': return 'TALEP DURUMU';
			case 'features.tickets.statusStepWaiting': return 'Bekliyor';
			case 'features.tickets.statusStepInProgress': return 'İşlemde';
			case 'features.tickets.statusStepResolved': return 'Çözüldü';
			case 'features.tickets.statusStepClosed': return 'Kapalı';
			case 'features.tickets.statusHeadlineOpen': return 'Talebiniz beklemede';
			case 'features.tickets.statusHeadlineInProgress': return 'Talebiniz işlemde';
			case 'features.tickets.statusHeadlineResolved': return 'Talebiniz çözüldü';
			case 'features.tickets.statusHeadlineClosed': return 'Talebiniz kapatıldı';
			case 'features.tickets.detailTitle': return 'Talep Detayı';
			case 'features.tickets.managerTitle': return 'Bina Talepleri';
			case 'features.tickets.statusLabel': return 'Durum';
			case 'features.tickets.updatesTitle': return 'Güncellemeler';
			case 'features.tickets.changeStatus': return 'Durum değiştir';
			case 'features.tickets.managerNote': return 'Yönetici notu';
			case 'features.tickets.addNote': return 'Not ekle';
			case 'features.tickets.statusUpdated': return 'Durum güncellendi';
			case 'features.tickets.noteAdded': return 'Not eklendi';
			case 'features.tickets.loadError': return 'Talepler yüklenemedi';
			case 'features.tickets.noteDisabledClosed': return 'Kapalı talebe not eklenemez';
			case 'features.tickets.statusClosedHint': return 'Bu talep kapatıldı; durum değiştirilemez.';
			case 'features.tickets.apartmentRequired': return 'Daire bilgisi bulunamadı. Lütfen tekrar giriş yapın.';
			case 'features.dekont.makePaymentTitle': return 'Ödeme Yap';
			case 'features.dekont.myDekontsTitle': return 'Dekontlarım';
			case 'features.dekont.managerTitle': return 'Dekont İnceleme';
			case 'features.dekont.reviewAction': return 'Dekont İncele';
			case 'features.dekont.detailTitle': return 'Dekont Detayı';
			case 'features.dekont.paymentInfoTitle': return 'Havale bilgileri';
			case 'features.dekont.collectionNotConfigured': return 'Yöneticiniz henüz tahsilat IBAN bilgisini tanımlamadı. Yine de dekont yükleyebilirsiniz.';
			case 'features.dekont.ibanLabel': return 'IBAN';
			case 'features.dekont.accountTitleLabel': return 'Alıcı unvanı';
			case 'features.dekont.referenceLabel': return 'Havale açıklaması';
			case 'features.dekont.copy': return 'Kopyala';
			case 'features.dekont.copied': return 'Panoya kopyalandı';
			case 'features.dekont.selectDue': return 'Aidat seçin';
			case 'features.dekont.selectDueHint': return 'Ödeme yaptığınız aidatı seçin';
			case 'features.dekont.noPendingDues': return 'Bekleyen aidat bulunmuyor';
			case 'features.dekont.uploadSectionTitle': return 'Dekont yükle';
			case 'features.dekont.uploadHint': return 'PDF veya fotoğraf (JPEG, PNG)';
			case 'features.dekont.pickFile': return 'Dosya seç';
			case 'features.dekont.upload': return 'Dekontu yükle';
			case 'features.dekont.uploadSuccess': return 'Dekont yüklendi';
			case 'features.dekont.uploadFailed': return 'Dekont yüklenemedi';
			case 'features.dekont.fileTooLarge': return 'Dosya en fazla 10 MB olabilir';
			case 'features.dekont.fileEmpty': return 'Seçilen dosya boş';
			case 'features.dekont.fileNotFound': return 'Dosya bulunamadı';
			case 'features.dekont.invalidExtension': return 'Yalnızca PDF, JPEG veya PNG yükleyebilirsiniz';
			case 'features.dekont.processing': return 'Dekont işleniyor…';
			case 'features.dekont.viewDekonts': return 'Dekontlarım';
			case 'features.dekont.emptyTitle': return 'Henüz dekont yok';
			case 'features.dekont.emptySubtitle': return 'Ödeme yaptıktan sonra dekontunuzu buradan yükleyebilirsiniz';
			case 'features.dekont.filterAll': return 'Tümü';
			case 'features.dekont.filterPending': return 'İncelemede';
			case 'features.dekont.filterApproved': return 'Onaylandı';
			case 'features.dekont.filterRejected': return 'Reddedildi';
			case 'features.dekont.statusReceived': return 'Alındı';
			case 'features.dekont.statusExtracting': return 'Okunuyor';
			case 'features.dekont.statusExtractFailed': return 'Okunamadı';
			case 'features.dekont.statusParsed': return 'Okundu';
			case 'features.dekont.statusParseLowConfidence': return 'Düşük güven';
			case 'features.dekont.statusMatching': return 'Eşleştiriliyor';
			case 'features.dekont.statusMatched': return 'Eşleşti';
			case 'features.dekont.statusMatchAmbiguous': return 'Belirsiz eşleşme';
			case 'features.dekont.statusUnmatched': return 'Eşleşmedi';
			case 'features.dekont.statusPaymentApplied': return 'Ödeme uygulandı';
			case 'features.dekont.statusPaymentPartial': return 'Kısmi ödeme';
			case 'features.dekont.statusRejected': return 'Reddedildi';
			case 'features.dekont.statusRecipientMismatch': return 'Alıcı uyuşmuyor';
			case 'features.dekont.statusNeedsManagerReview': return 'Yönetici incelemesi';
			case 'features.dekont.reupload': return 'Yeniden yükle';
			case 'features.dekont.rejectionReason': return 'Red nedeni';
			case 'features.dekont.parsedAmount': return 'Okunan tutar';
			case 'features.dekont.filePreview': return 'Dosya önizleme';
			case 'features.dekont.shareFile': return 'Dosyayı paylaş';
			case 'features.dekont.approve': return 'Onayla';
			case 'features.dekont.reject': return 'Reddet';
			case 'features.dekont.reviewNote': return 'Not (opsiyonel)';
			case 'features.dekont.reviewSuccess': return 'İnceleme kaydedildi';
			case 'features.dekont.reviewFailed': return 'İnceleme kaydedilemedi';
			case 'features.dekont.selectDueForApprove': return 'Onay için aidat seçin';
			case 'features.dekont.uploadedBy': return 'Yükleyen';
			case 'features.dekont.apartment': return 'Daire';
			case 'features.dekont.amount': return 'Tutar';
			case 'features.dekont.loadError': return 'Dekontlar yüklenemedi';
			case 'features.expenses.title': return 'Giderler';
			case 'features.expenses.createTitle': return 'Gider Ekle';
			case 'features.expenses.fieldTitle': return 'Başlık';
			case 'features.expenses.fieldAmount': return 'Tutar (₺)';
			case 'features.expenses.fieldCategory': return 'Kategori';
			case 'features.expenses.fieldNote': return 'Not (opsiyonel)';
			case 'features.expenses.submit': return 'Kaydet';
			case 'features.expenses.required': return 'Zorunlu alan';
			case 'features.expenses.amountInvalid': return 'Geçerli tutar girin';
			case 'features.expenses.total': return 'Toplam';
			case 'features.expenses.createSuccess': return 'Gider kaydedildi';
			case 'features.expenses.categoryCleaning': return 'Temizlik';
			case 'features.expenses.categoryElevator': return 'Asansör';
			case 'features.expenses.categoryElectricity': return 'Elektrik';
			case 'features.expenses.categoryWater': return 'Su';
			case 'features.expenses.categoryInsurance': return 'Sigorta';
			case 'features.expenses.categoryRepair': return 'Onarım';
			case 'features.expenses.categoryGarden': return 'Bahçe';
			case 'features.expenses.categoryOther': return 'Diğer';
			case 'features.expenses.fieldDate': return 'Tarih';
			case 'features.expenses.fieldMonth': return 'Ay';
			case 'features.expenses.fieldYear': return 'Yıl';
			case 'features.expenses.editTitle': return 'Gideri Düzenle';
			case 'features.expenses.editAction': return 'Düzenle';
			case 'features.expenses.deleteTitle': return 'Gideri sil';
			case 'features.expenses.deleteAction': return 'Sil';
			case 'features.expenses.deleteConfirm': return 'Bu gider kaydını silmek istediğinize emin misiniz?';
			case 'features.expenses.deleteSuccess': return 'Gider silindi';
			case 'features.expenses.updateSuccess': return 'Gider güncellendi';
			case 'features.expenses.loadError': return 'Giderler yüklenemedi';
			case 'features.expenses.emptyTitle': return 'Bu dönemde gider yok';
			case 'features.expenses.emptySubtitle': return 'Sağ üstten yeni gider ekleyebilirsiniz';
			case 'features.expenses.receiptUrlLabel': return 'Makbuz bağlantısı (HTTPS)';
			case 'features.expenses.receiptUrlHint': return 'Opsiyonel — internetteki makbuz dosyası adresi';
			case 'features.expenses.receiptUrlInvalid': return 'Adres https:// ile başlamalıdır';
			case 'features.expenses.receiptTitle': return 'Makbuz fotoğrafı';
			case 'features.expenses.receiptHint': return 'Opsiyonel — galeriden seçin (canlı sunucuda dosya yükleme henüz yok)';
			case 'features.expenses.receiptAdd': return 'Fotoğraf ekle';
			case 'features.expenses.receiptChange': return 'Fotoğrafı değiştir';
			case 'features.expenses.receiptRemove': return 'Fotoğrafı kaldır';
			case 'features.expenses.receiptPendingBackend': return 'Gider kaydedildi. Makbuz sunucuya yüklenecek (API hazır olunca).';
			case 'features.expenses.receiptUploadFailed': return 'Makbuz yüklenemedi. Gider kaydı oluşturuldu.';
			case 'features.expenses.receiptPickFailed': return 'Fotoğraf seçilemedi';
			case 'features.notifications.markAllRead': return 'Tümünü oku';
			case 'features.notifications.markAllReadLong': return 'Tümünü okundu işaretle';
			case 'features.notifications.viewRelated': return 'İlgili kayda git';
			case 'features.notifications.unreadBadge': return 'Yeni';
			case 'features.notifications.emptyTitle': return 'Bildirim yok';
			case 'features.notifications.emptySubtitle': return 'Yeni bildirimler burada görünecek';
			case 'features.notifications.emptyUnreadTitle': return 'Okunmamış bildirim yok';
			case 'features.notifications.emptyUnreadSubtitle': return 'Tüm bildirimleri okudunuz';
			case 'features.notifications.loadError': return 'Bildirimler yüklenemedi';
			case 'features.notifications.filterAll': return 'Tümü';
			case 'features.notifications.filterUnread': return 'Okunmamış';
			case 'features.notifications.sectionToday': return 'Bugün';
			case 'features.notifications.sectionYesterday': return 'Dün';
			case 'features.notifications.sectionThisWeek': return 'Bu hafta';
			case 'features.notifications.sectionEarlier': return 'Daha eski';
			case 'features.notifications.timeNow': return 'Az önce';
			case 'features.notifications.timeMinuteShort': return 'dk önce';
			case 'features.notifications.timeHourShort': return 'saat önce';
			case 'features.notifications.detailLoadError': return 'Detay yüklenemedi';
			case 'features.notifications.fieldStatus': return 'Durum';
			case 'features.notifications.fieldCategory': return 'Kategori';
			case 'features.notifications.fieldApartment': return 'Daire';
			case 'features.notifications.fieldAmount': return 'Tutar';
			case 'features.notifications.fieldUploadedBy': return 'Yükleyen';
			case 'features.notifications.fieldDescription': return 'Açıklama';
			case 'features.notifications.fieldManagerNote': return 'Yönetici notu';
			case 'features.notifications.fieldRejectionReason': return 'Red nedeni';
			case 'features.notifications.fieldLatestUpdate': return 'Son güncelleme';
			case 'features.notifications.fieldCreatedAt': return 'Oluşturulma';
			case 'features.notifications.fieldPeriod': return 'Dönem';
			case 'features.notifications.actionViewTicket': return 'Talebi Görüntüle';
			case 'features.notifications.actionViewDekont': return 'Dekontu İncele';
			case 'features.notifications.actionViewDue': return 'Aidatı Gör';
			case 'features.notifications.typeDueReminder': return 'Aidat hatırlatma';
			case 'features.notifications.typeDuePaid': return 'Aidat ödendi';
			case 'features.notifications.typeTicketCreated': return 'Yeni talep';
			case 'features.notifications.typeTicketUpdate': return 'Talep güncellendi';
			case 'features.notifications.typeAnnouncement': return 'Duyuru';
			case 'features.notifications.typeDekontReceived': return 'Yeni dekont';
			case 'features.notifications.typeDekontNeedsReview': return 'Dekont inceleme';
			case 'features.notifications.typeDekontMatched': return 'Dekont eşleşti';
			case 'features.notifications.typeDekontPaymentApplied': return 'Dekont onaylandı';
			case 'features.notifications.typeSystem': return 'Sistem';
			case 'features.notifications.typeOther': return 'Bildirim';
			case 'features.notifications.sendTitle': return 'Sakinlere Duyuru';
			case 'features.notifications.fieldTitle': return 'Başlık';
			case 'features.notifications.fieldBody': return 'Mesaj';
			case 'features.notifications.sendButton': return 'Gönder';
			case 'features.notifications.sendSuccess': return 'Duyuru gönderildi';
			case 'features.notifications.sendFailed': return 'Duyuru gönderilemedi';
			case 'features.notifications.fieldRequired': return 'Zorunlu alan';
			case 'features.notifications.titleTooLong': return 'Başlık en fazla 120 karakter olabilir';
			case 'features.notifications.bodyTooLong': return 'Mesaj en fazla 2000 karakter olabilir';
			case 'features.notifications.noBuilding': return 'Önce bir bina ekleyin';
			case 'features.profile.title': return 'Profil Bilgileri';
			case 'features.profile.fullName': return 'Ad Soyad';
			case 'features.profile.email': return 'E-posta';
			case 'features.profile.phone': return 'Telefon';
			case 'features.profile.role': return 'Rol';
			case 'features.profile.languagePref': return 'Dil tercihi';
			case 'features.profile.notProvided': return 'Belirtilmemiş';
			case 'features.profile.editHint': return 'Profil düzenleme yakında eklenecek.';
			case 'features.profile.sectionPersonal': return 'Kişisel Bilgiler';
			case 'features.profile.sectionAccount': return 'Hesap Bilgileri';
			case 'features.profile.editPhotoHint': return 'Fotoğrafı değiştirmek için dokunun';
			case 'features.profile.editTitle': return 'Profili Düzenle';
			case 'features.profile.phoneOptionalHint': return 'Boş bırakılabilir';
			case 'features.profile.profileUpdated': return 'Profil bilgileriniz güncellendi.';
			case 'features.profile.profileUpdateFailed': return 'Profil güncellenemedi. Lütfen tekrar deneyin.';
			case 'features.profile.profileLoadFailed': return 'Profil bilgileri yüklenemedi.';
			case 'features.profile.readOnlySection': return 'Buradan düzenlenemez';
			case 'features.profile.editSheetHint': return 'Yalnızca ad ve telefon güncellenir. Diğer bilgiler yukarıdaki profil ekranında görünür.';
			case 'features.profile.photoSaved': return 'Profil fotoğrafı bu hesap için kaydedildi.';
			case 'features.profile.photoRemoved': return 'Profil fotoğrafı kaldırıldı.';
			case 'features.profile.removePhoto': return 'Profil fotoğrafını kaldır';
			case 'features.subscription.title': return 'Abonelik';
			case 'features.subscription.statusActive': return 'Aktif';
			case 'features.subscription.statusExpired': return 'Süresi doldu';
			case 'features.subscription.statusCancelled': return 'İptal edildi';
			case 'features.subscription.statusTrial': return 'Deneme';
			case 'features.subscription.statusUnknown': return 'Bilinmiyor';
			case 'features.subscription.planMonthly': return 'Aylık plan';
			case 'features.subscription.planAnnual': return 'Yıllık plan';
			case 'features.subscription.planUnknown': return 'Plan';
			case 'features.subscription.renewsOn': return 'Yenileme: {date}';
			case 'features.subscription.noSubscription': return 'Henüz abonelik kaydı yok.';
			case 'features.subscription.backendPending': return 'Abonelik sunucuya henüz bağlanmadı. Satın alma yakında açılacak.';
			case 'features.subscription.purchaseComingSoon': return 'Satın alma yakında';
			case 'features.subscription.loadFailed': return 'Abonelik bilgisi alınamadı.';
			case 'features.faz2.sectionTitle': return 'Faz 2';
			case 'features.faz2.tickets': return 'Talepler';
			case 'features.faz2.expenses': return 'Giderler';
			case 'features.faz2.announcement': return 'Duyuru';
			case 'legal.companyName': return 'Vefa Yazılım';
			case 'legal.contactEmail': return 'store@vefayazilim.com';
			case 'legal.contactBlock': return 'Veri sorumlusu: Vefa Yazılım\nE-posta: store@vefayazilim.com';
			case 'legal.updatedLabel': return 'Son güncelleme';
			case 'legal.updatedDate': return 'Haziran 2026';
			case 'legal.privacyIntro': return 'Bu metin, Vefa Yazılım tarafından sunulan AidatPanel mobil uygulamasını kullanırken kişisel verilerinizin nasıl işlendiğini açıklar. Uygulamayı kullanmaya devam ederek bu politikayı okuduğunuzu kabul etmiş sayılırsınız.';
			case 'legal.privacyS1Title': return '1. Veri sorumlusu';
			case 'legal.privacyS1Body': return 'AidatPanel hizmeti kapsamında kişisel verileriniz, veri sorumlusu Vefa Yazılım tarafından 6698 sayılı Kişisel Verilerin Korunması Kanunu (KVKK) ve ilgili mevzuata uygun olarak işlenir. KVKK ve gizlilik talepleriniz için: store@vefayazilim.com';
			case 'legal.privacyS2Title': return '2. Toplanan veriler';
			case 'legal.privacyS2Body': return 'Hesap bilgileri (ad, e-posta, telefon, dil tercihi), apartman ve daire ilişkisi, aidat ve ödeme kayıtları, destek talepleri, duyuru ve bildirim tercihleri, dekont ve makbuz görselleri (yüklediğinizde), cihaz bildirim anahtarı (FCM) ve güvenli oturum bilgileri (şifrelenmiş token) işlenebilir.';
			case 'legal.privacyS3Title': return '3. İşleme amaçları';
			case 'legal.privacyS3Body': return 'Verileriniz; aidat ve gider yönetimi, tahsilat ve dekont süreçleri, apartman içi iletişim ve duyurular, kimlik doğrulama, hizmet güvenliği, yasal yükümlülükler ve size bildirim göndermek amacıyla işlenir.';
			case 'legal.privacyS4Title': return '4. Saklama ve güvenlik';
			case 'legal.privacyS4Body': return 'Veriler güvenli sunucularda saklanır; iletişim HTTPS ile şifrelenir. Oturum bilgileri cihazınızda güvenli depolamada tutulur. Yasal zorunluluklar dışında veriler, hizmet ilişkisi süresince ve mevzuattaki süreler boyunca muhafaza edilir.';
			case 'legal.privacyS5Title': return '5. Paylaşım';
			case 'legal.privacyS5Body': return 'Kişisel verileriniz üçüncü taraflara satılmaz. Yalnızca hizmetin sunulması için gerekli altyapı sağlayıcıları (barındırma, bildirim servisi vb.) ve kanunen yetkili kurumlarla, mevzuata uygun şekilde paylaşılabilir.';
			case 'legal.privacyS6Title': return '6. Haklarınız';
			case 'legal.privacyS6Body': return 'KVKK kapsamında verilerinize erişme, düzeltme, silme, işlemeyi kısıtlama ve itiraz etme haklarına sahipsiniz. Hesap kapatma (soft delete) Ayarlar üzerinden yapılabilir; yasal saklama gerektiren kayıtlar anonimleştirilerek tutulabilir. Başvurularınızı store@vefayazilim.com adresine iletebilirsiniz.';
			case 'legal.kvkkIntro': return '6698 sayılı Kanun uyarınca Vefa Yazılım tarafından işlenen kişisel verilerinize ilişkin aydınlatma metnidir.';
			case 'legal.kvkkS1Title': return 'Veri sorumlusu ve iletişim';
			case 'legal.kvkkS1Body': return 'AidatPanel kapsamındaki kişisel veri işleme faaliyetleri için veri sorumlusu Vefa Yazılım’dır. KVKK taleplerinizi store@vefayazilim.com adresine veya uygulamada kayıtlı e-posta adresinizle iletebilirsiniz.';
			case 'legal.kvkkS2Title': return 'İşlenen veri kategorileri';
			case 'legal.kvkkS2Body': return 'Kimlik ve iletişim, müşteri işlem (aidat, ödeme, gider), görsel kayıt (dekont), işlem güvenliği (log, token) ve pazarlama/iletişim (bildirim izni) kategorilerinde veri işlenebilir.';
			case 'legal.kvkkS3Title': return 'İşleme amaçları ve hukuki sebepler';
			case 'legal.kvkkS3Body': return 'Verileriniz; sözleşmenin kurulması ve ifası, hukuki yükümlülük, meşru menfaat ve açık rızanız (bildirimler gibi) kapsamında işlenir.';
			case 'legal.kvkkS4Title': return 'Aktarım';
			case 'legal.kvkkS4Body': return 'Veriler, yurt içinde barındırma ve teknik hizmet sağlayıcılarına, hizmetin gerektirdiği ölçüde aktarılabilir. Aktarım yapılan taraflarla gerekli güvenlik önlemleri alınır.';
			case 'legal.kvkkS5Title': return 'Toplama yöntemi';
			case 'legal.kvkkS5Body': return 'Veriler; uygulama formları, otomatik kayıtlar, yüklediğiniz belgeler ve bildirim altyapısı aracılığıyla elektronik ortamda toplanır.';
			case 'legal.kvkkS6Title': return 'İlgili kişi hakları';
			case 'legal.kvkkS6Body': return 'Kanunun 11. maddesi kapsamındaki haklarınızı kullanmak için talebinizi Vefa Yazılım’a (store@vefayazilim.com) iletebilirsiniz; başvurularınız mevzuattaki sürelerde yanıtlanır.';
			case 'legal.helpIntro': return 'Yardım merkezi hazırlanıyor';
			case 'legal.helpBody': return 'Sık sorulan sorular, adım adım rehberler ve destek kanalları yakında bu bölümde yer alacak. Uygulama desteği için: store@vefayazilim.com (Vefa Yazılım). Acil apartman işleri için yöneticiniz veya site yönetiminizle iletişime geçebilirsiniz.';
			case 'db_context.user_entry': return 'Kayıt: {value}';
			case 'db_context.building_name': return 'Bina: {value}';
			case 'db_context.apartment_label': return 'Daire: {value}';
			case 'db_context.code_value': return 'Kod: {value}';
			case 'db_context.expiry_date': return 'Son kullanma: {value}';
			default: return null;
		}
	}
}
