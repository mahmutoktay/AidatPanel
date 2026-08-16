///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
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

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final Translations$common$en common = Translations$common$en._(_root);
	late final Translations$validation$en validation = Translations$validation$en._(_root);
	late final Translations$features$en features = Translations$features$en._(_root);
	late final Translations$legal$en legal = Translations$legal$en._(_root);
	late final Translations$db_context$en db_context = Translations$db_context$en._(_root);
}

// Path: common
class Translations$common$en {
	Translations$common$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Logout'
	String get logout => 'Logout';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Confirm'
	String get confirm => 'Confirm';

	/// en: 'OK'
	String get ok => 'OK';

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'Delete'
	String get delete => 'Delete';

	/// en: 'Edit'
	String get edit => 'Edit';

	/// en: 'Close'
	String get close => 'Close';

	/// en: 'Yes'
	String get yes => 'Yes';

	/// en: 'No'
	String get no => 'No';

	/// en: 'Register'
	String get register => 'Register';

	/// en: 'Login'
	String get login => 'Login';

	/// en: 'Join'
	String get join => 'Join';

	/// en: 'Are you sure?'
	String get confirmMessage => 'Are you sure?';

	/// en: 'Are you sure you want to logout?'
	String get logoutConfirm => 'Are you sure you want to logout?';

	/// en: 'Signed out successfully.'
	String get logoutSuccess => 'Signed out successfully.';

	/// en: 'Sign out other devices'
	String get logoutAllDevices => 'Sign out other devices';

	/// en: 'Sessions on your other phones and tablets will end. You will stay signed in on this device.'
	String get logoutAllDevicesConfirm => 'Sessions on your other phones and tablets will end. You will stay signed in on this device.';

	/// en: 'Signed out of other devices successfully.'
	String get logoutAllDevicesSuccess => 'Signed out of other devices successfully.';

	/// en: 'Could not complete this action. Try again.'
	String get logoutAllDevicesFailed => 'Could not complete this action. Try again.';

	/// en: 'This device'
	String get thisDevice => 'This device';

	/// en: 'Signed in: $date'
	String signedInAt({required Object date}) => 'Signed in: ${date}';

	/// en: 'Remove'
	String get removeSession => 'Remove';

	/// en: 'This device will be signed out. Do you want to continue?'
	String get removeSessionConfirm => 'This device will be signed out. Do you want to continue?';

	/// en: 'Sign out all other devices'
	String get removeAllOtherSessions => 'Sign out all other devices';

	/// en: 'Sessions on your other phones and tablets will end. You will stay signed in on this device.'
	String get removeAllOtherSessionsConfirm => 'Sessions on your other phones and tablets will end. You will stay signed in on this device.';

	/// en: 'Session ended.'
	String get sessionRemoved => 'Session ended.';

	/// en: 'No other active device sessions.'
	String get noOtherSessions => 'No other active device sessions.';

	/// en: 'View devices signed in to your account and sign out any you do not recognize.'
	String get sessionsScreenHint => 'View devices signed in to your account and sign out any you do not recognize.';

	/// en: 'Your session on this device has been ended by another device.'
	String get sessionExpired => 'Your session on this device has been ended by another device.';

	/// en: 'Account'
	String get account => 'Account';

	/// en: 'Edit Profile'
	String get editProfile => 'Edit Profile';

	/// en: 'Change Password'
	String get changePassword => 'Change Password';

	/// en: 'Language'
	String get language => 'Language';

	/// en: 'Theme'
	String get theme => 'Theme';

	/// en: 'Light'
	String get themeLight => 'Light';

	/// en: 'Dark'
	String get themeDark => 'Dark';

	/// en: 'System'
	String get themeSystem => 'System';

	/// en: 'You can change the app appearance here.'
	String get themeSheetDescription => 'You can change the app appearance here.';

	/// en: 'Light'
	String get themeLightSubtitle => 'Light';

	/// en: 'Dark'
	String get themeDarkSubtitle => 'Dark';

	/// en: 'System'
	String get themeSystemSubtitle => 'System';

	/// en: 'Turkish'
	String get turkish => 'Turkish';

	/// en: 'Notifications'
	String get notifications => 'Notifications';

	/// en: 'Info'
	String get info => 'Info';

	/// en: 'Privacy Policy'
	String get privacyPolicy => 'Privacy Policy';

	/// en: 'KVKK'
	String get kvkk => 'KVKK';

	/// en: 'Help & Support'
	String get helpSupport => 'Help & Support';

	/// en: 'About'
	String get about => 'About';

	/// en: 'This feature will be added soon'
	String get comingSoon => 'This feature will be added soon';

	/// en: 'Multi-language support coming soon'
	String get multiLanguageComingSoon => 'Multi-language support coming soon';

	/// en: ' 2026 AidatPanel All rights reserved.'
	String get copyright => ' 2026 AidatPanel\nAll rights reserved.';

	/// en: 'Dues management platform for Turkish apartment and site managers.'
	String get aboutDescription => 'Dues management platform for Turkish apartment and site managers.';

	/// en: 'Manager'
	String get manager => 'Manager';

	/// en: 'Resident'
	String get resident => 'Resident';

	/// en: 'Token Expiry Check (Test)'
	String get tokenExpiryTest => 'Token Expiry Check (Test)';

	/// en: 'Token EXPIRED! Redirecting to login screen.'
	String get tokenExpired => 'Token EXPIRED! Redirecting to login screen.';

	/// en: 'Token active! Remaining time'
	String get tokenActive => 'Token active! Remaining time';

	/// en: 'Press back again to exit'
	String get pressBackAgainToExit => 'Press back again to exit';

	/// en: 'Loading…'
	String get loading => 'Loading…';

	/// en: 'Loading buildings…'
	String get loadingBuildings => 'Loading buildings…';

	/// en: 'Failed to load'
	String get loadFailed => 'Failed to load';

	/// en: 'Something went wrong. Try again.'
	String get unexpectedError => 'Something went wrong. Try again.';

	late final Translations$common$api$en api = Translations$common$api$en._(_root);

	/// en: 'The server is currently busy. We'll retry shortly.'
	String get rateLimitHint => 'The server is currently busy. We\'ll retry shortly.';

	/// en: 'Try Again'
	String get tryAgain => 'Try Again';

	late final Translations$common$documentPreview$en documentPreview = Translations$common$documentPreview$en._(_root);

	/// en: 'Home'
	String get home => 'Home';

	/// en: 'Buildings'
	String get buildings => 'Buildings';

	/// en: 'Dues'
	String get dues => 'Dues';

	/// en: 'Settings'
	String get settings => 'Settings';

	/// en: 'User'
	String get user => 'User';

	/// en: 'Welcome'
	String get welcome => 'Welcome';

	/// en: 'Welcome Back'
	String get welcomeBack => 'Welcome Back';

	/// en: 'Managed Buildings'
	String get managedBuildings => 'Managed Buildings';

	/// en: 'Requests'
	String get issues => 'Requests';

	/// en: 'Requests tab'
	String get issuesTab => 'Requests tab';

	/// en: 'Apartment'
	String get apartment => 'Apartment';

	/// en: 'Add Building'
	String get addBuilding => 'Add Building';

	/// en: 'Invite Code'
	String get inviteCode => 'Invite Code';

	/// en: 'My Buildings'
	String get myBuildings => 'My Buildings';

	/// en: 'Apartments'
	String get apartments => 'Apartments';

	/// en: 'Collection'
	String get collection => 'Collection';

	/// en: 'Monthly Dues'
	String get monthlyDues => 'Monthly Dues';

	/// en: 'Dues Tab'
	String get duesTab => 'Dues Tab';

	/// en: 'Total Apartments'
	String get totalApartments => 'Total Apartments';

	/// en: 'Occupied Apartments'
	String get occupiedApartments => 'Occupied Apartments';

	/// en: 'Dues Collection'
	String get duesCollection => 'Dues Collection';

	/// en: 'Total Dues'
	String get totalDues => 'Total Dues';

	/// en: 'Recent Transactions'
	String get recentTransactions => 'Recent Transactions';

	/// en: 'Recent Activity'
	String get recentMovements => 'Recent Activity';

	/// en: 'See all'
	String get seeAll => 'See all';

	/// en: 'Pay due'
	String get payDue => 'Pay due';

	/// en: 'You have no current balance due ✓'
	String get noCurrentDebt => 'You have no current balance due ✓';

	/// en: 'Announcements'
	String get announcements => 'Announcements';

	/// en: 'Paid'
	String get paid => 'Paid';

	/// en: 'Pending'
	String get pending => 'Pending';

	/// en: 'Overdue'
	String get overdue => 'Overdue';

	/// en: 'Balance'
	String get balance => 'Balance';

	/// en: 'Amount Due'
	String get amountDue => 'Amount Due';

	/// en: 'Last Payment'
	String get lastPayment => 'Last Payment';

	/// en: 'Make Payment'
	String get makePayment => 'Make Payment';

	/// en: 'Bills'
	String get bills => 'Bills';

	/// en: 'Support'
	String get support => 'Support';

	/// en: 'Quick Actions'
	String get quickActions => 'Quick Actions';

	/// en: 'My applications'
	String get myApplications => 'My applications';

	/// en: 'Announcements'
	String get myAnnouncements => 'Announcements';

	/// en: 'Debt & pay'
	String get debtAndPay => 'Debt & pay';

	/// en: 'Dues status'
	String get duesStatus => 'Dues status';

	/// en: 'Account summary'
	String get accountSummary => 'Account summary';

	/// en: 'Period summary and details'
	String get accountSummarySubtitle => 'Period summary and details';

	/// en: 'Your payment receipts'
	String get myReceiptsSubtitle => 'Your payment receipts';

	/// en: 'Create a payment request'
	String get myPaymentRequestSubtitle => 'Create a payment request';

	/// en: 'My settings'
	String get mySettings => 'My settings';

	/// en: 'My receipts'
	String get myReceipts => 'My receipts';

	/// en: 'Payment request'
	String get myPaymentRequest => 'Payment request';

	/// en: 'History'
	String get duesHistory => 'History';

	/// en: 'Create request'
	String get addRequest => 'Create request';

	/// en: 'Pay debt'
	String get payDebt => 'Pay debt';

	/// en: 'All'
	String get tabAll => 'All';

	/// en: 'Faults'
	String get tabFaults => 'Faults';

	/// en: 'Requests'
	String get tabRequests => 'Requests';

	/// en: 'Apartment no.'
	String get apartmentNo => 'Apartment no.';

	/// en: 'Full name'
	String get fullName => 'Full name';

	/// en: 'Debt'
	String get debtAmount => 'Debt';

	/// en: 'Due date'
	String get lastDueDate => 'Due date';

	/// en: 'Resident Name'
	String get residentName => 'Resident Name';

	/// en: 'Add New Building'
	String get addBuildingNew => 'Add New Building';

	/// en: 'Basic Info'
	String get basicInfo => 'Basic Info';

	/// en: 'Building Name'
	String get buildingName => 'Building Name';

	/// en: 'Ex: Güneş Apartmanı'
	String get buildingNameHint => 'Ex: Güneş Apartmanı';

	/// en: 'Location'
	String get location => 'Location';

	/// en: 'Street Address'
	String get streetAddress => 'Street Address';

	/// en: 'Ex: Bağdat Cad. No: 123'
	String get streetAddressHint => 'Ex: Bağdat Cad. No: 123';

	/// en: 'Details'
	String get details => 'Details';

	/// en: 'Floor Count'
	String get floorCount => 'Floor Count';

	/// en: '1–200'
	String get floorCountHint => '1–200';

	/// en: 'Units per Floor'
	String get apartmentsPerFloor => 'Units per Floor';

	/// en: '1–50'
	String get apartmentsPerFloorHint => '1–50';

	/// en: 'Floor count must be between 1 and 200'
	String get floorRangeError => 'Floor count must be between 1 and 200';

	/// en: 'Apartments per floor must be between 1 and 50'
	String get apartmentsPerFloorRangeError => 'Apartments per floor must be between 1 and 50';

	/// en: 'Could not add building. Try again.'
	String get buildingAddFailed => 'Could not add building. Try again.';

	/// en: 'Monthly Dues (₺)'
	String get monthlyDuesLabel => 'Monthly Dues (₺)';

	/// en: 'Ex: 1000'
	String get monthlyDuesHint => 'Ex: 1000';

	/// en: 'Create Building'
	String get createBuilding => 'Create Building';

	/// en: 'Cancel'
	String get cancelBtn => 'Cancel';

	/// en: 'City *'
	String get cityRequired => 'City *';

	/// en: 'Select City'
	String get selectCity => 'Select City';

	/// en: 'District *'
	String get districtRequired => 'District *';

	/// en: 'Select District'
	String get selectDistrict => 'Select District';

	/// en: 'Select city first'
	String get selectCityFirst => 'Select city first';

	/// en: 'Select City'
	String get selectCityTitle => 'Select City';

	/// en: 'Select District'
	String get selectDistrictTitle => 'Select District';

	/// en: 'Neighborhood *'
	String get neighborhoodRequired => 'Neighborhood *';

	/// en: 'Select neighborhood'
	String get selectNeighborhood => 'Select neighborhood';

	/// en: 'Select Neighborhood'
	String get selectNeighborhoodTitle => 'Select Neighborhood';

	/// en: 'Select district first'
	String get selectDistrictFirst => 'Select district first';

	/// en: 'Next'
	String get wizardNext => 'Next';

	/// en: 'Back'
	String get wizardBack => 'Back';

	/// en: 'More'
	String get wizardMore => 'More';

	/// en: 'Enter number'
	String get wizardEnterNumber => 'Enter number';

	/// en: 'Back to list'
	String get wizardBackToGrid => 'Back to list';

	/// en: 'Number must be between {min} and {max}'
	String get wizardNumberRangeError => 'Number must be between {min} and {max}';

	/// en: 'Could not load city and district list. Try again.'
	String get wizardLocationLoadFailed => 'Could not load city and district list. Try again.';

	/// en: 'Could not load neighborhoods. Check your connection and try again.'
	String get wizardNeighborhoodLoadFailed => 'Could not load neighborhoods. Check your connection and try again.';

	/// en: 'Name'
	String get wizardStepBuildingName => 'Name';

	/// en: 'Site'
	String get wizardStepSiteName => 'Site';

	/// en: 'Block'
	String get wizardStepBlockInfo => 'Block';

	/// en: 'City'
	String get wizardStepLocation => 'City';

	/// en: 'Area'
	String get wizardStepNeighborhoodAddress => 'Area';

	/// en: 'Floors'
	String get wizardStepFloors => 'Floors';

	/// en: 'Units'
	String get wizardStepApartments => 'Units';

	/// en: 'Dues'
	String get wizardStepDues => 'Dues';

	/// en: 'Recipient'
	String get wizardStepRecipient => 'Recipient';

	/// en: 'Settings'
	String get wizardStepSiteOverrides => 'Settings';

	/// en: 'Select number of floors'
	String get wizardPickFloorCount => 'Select number of floors';

	/// en: 'Select units per floor'
	String get wizardPickApartmentCount => 'Select units per floor';

	/// en: 'Search...'
	String get search => 'Search...';

	/// en: 'No results found'
	String get noResults => 'No results found';

	/// en: 'cannot be empty'
	String get fieldRequired => 'cannot be empty';

	/// en: 'Please fill required fields'
	String get fillRequiredFields => 'Please fill required fields';

	/// en: 'You must select city and district'
	String get selectCityAndDistrict => 'You must select city and district';

	/// en: 'Floor count and apartment count must be greater than 0'
	String get floorApartmentMustBePositive => 'Floor count and apartment count must be greater than 0';

	/// en: 'Building added successfully'
	String get buildingAddedSuccess => 'Building added successfully';

	/// en: 'Create Invite Code'
	String get createInviteCode => 'Create Invite Code';

	/// en: 'Which building to generate code for?'
	String get whichBuildingForCode => 'Which building to generate code for?';

	/// en: 'Which site should the code be for?'
	String get whichSiteForCode => 'Which site should the code be for?';

	/// en: 'Standalone buildings'
	String get inviteStandaloneBuildings => 'Standalone buildings';

	/// en: 'Which apartment to generate code for?'
	String get whichApartmentForCode => 'Which apartment to generate code for?';

	/// en: 'No apartments added to this building yet'
	String get noApartmentsInBuilding => 'No apartments added to this building yet';

	/// en: 'Active Code'
	String get activeCodeBadge => 'Active Code';

	/// en: 'Occupied'
	String get occupiedBadge => 'Occupied';

	/// en: 'Empty'
	String get emptyBadge => 'Empty';

	/// en: 'Active code'
	String get activeCodePrefix => 'Active code';

	/// en: 'Resident'
	String get residentPrefix => 'Resident';

	/// en: 'Empty apartment'
	String get emptyApartment => 'Empty apartment';

	/// en: 'Invite pending'
	String get pendingInviteStatus => 'Invite pending';

	/// en: 'View invite'
	String get viewInvite => 'View invite';

	/// en: 'Code revoked'
	String get codeRevoked => 'Code revoked';

	/// en: 'Code copied'
	String get codeCopied => 'Code copied';

	/// en: 'Message copied to clipboard'
	String get clipboardCopied => 'Message copied to clipboard';

	/// en: 'Expires at'
	String get expiresAtPrefix => 'Expires at';

	/// en: 'Remaining'
	String get remainingPrefix => 'Remaining';

	/// en: 'Building Detail'
	String get buildingDetail => 'Building Detail';

	/// en: 'Residents'
	String get residents => 'Residents';

	/// en: 'Apartments'
	String get apartmentsBadge => 'Apartments';

	/// en: 'Empty Apartment'
	String get emptyApartmentText => 'Empty Apartment';

	/// en: 'No resident has been assigned to this apartment yet'
	String get emptyApartmentAwaitingResident => 'No resident has been assigned to this apartment yet';

	/// en: 'Invite'
	String get inviteResident => 'Invite';

	/// en: 'Vacant'
	String get vacantBadge => 'Vacant';

	/// en: 'Phone not shared'
	String get phoneNotShared => 'Phone not shared';

	/// en: 'View Details'
	String get residentDetailsLink => 'View Details';

	/// en: 'Dues Paid'
	String get duesPaidStatus => 'Dues Paid';

	/// en: 'Dues Pending'
	String get duesPendingStatus => 'Dues Pending';

	/// en: 'Dues Overdue'
	String get duesOverdueStatus => 'Dues Overdue';

	/// en: 'No resident assigned'
	String get noResidentInApartment => 'No resident assigned';

	/// en: 'Resident information'
	String get residentDetailsSheetTitle => 'Resident information';

	/// en: 'Apartment information'
	String get apartmentDetailsSheetTitle => 'Apartment information';

	/// en: 'No resident assigned'
	String get noResidentAssigned => 'No resident assigned';

	/// en: 'No apartments added yet'
	String get noApartmentsYet => 'No apartments added yet';

	/// en: 'Paid'
	String get paidStatus => 'Paid';

	/// en: 'Pending'
	String get pendingStatus => 'Pending';

	/// en: 'Overdue'
	String get overdueStatus => 'Overdue';

	/// en: 'Waived'
	String get waivedStatus => 'Waived';

	/// en: 'All'
	String get all => 'All';

	/// en: 'Status'
	String get status => 'Status';

	/// en: 'Month'
	String get month => 'Month';

	/// en: 'Day'
	String get dayLabel => 'Day';

	/// en: 'Select date'
	String get pickDate => 'Select date';

	/// en: 'January'
	String get monthJanuary => 'January';

	/// en: 'February'
	String get monthFebruary => 'February';

	/// en: 'March'
	String get monthMarch => 'March';

	/// en: 'April'
	String get monthApril => 'April';

	/// en: 'May'
	String get monthMay => 'May';

	/// en: 'June'
	String get monthJune => 'June';

	/// en: 'July'
	String get monthJuly => 'July';

	/// en: 'August'
	String get monthAugust => 'August';

	/// en: 'September'
	String get monthSeptember => 'September';

	/// en: 'October'
	String get monthOctober => 'October';

	/// en: 'November'
	String get monthNovember => 'November';

	/// en: 'December'
	String get monthDecember => 'December';

	/// en: 'All months'
	String get allMonths => 'All months';

	/// en: 'Year'
	String get year => 'Year';

	/// en: 'All years'
	String get allYears => 'All years';

	/// en: 'Note'
	String get note => 'Note';

	/// en: 'My Dues History'
	String get myDuesHistory => 'My Dues History';

	/// en: 'Current due'
	String get currentPeriodDue => 'Current due';

	/// en: 'My past dues'
	String get myPastDues => 'My past dues';

	/// en: 'Building Dues'
	String get buildingDues => 'Building Dues';

	/// en: 'No dues records yet'
	String get noDuesYet => 'No dues records yet';

	/// en: 'No dues have been assigned to you yet'
	String get residentNoDuesYet => 'No dues have been assigned to you yet';

	/// en: 'Dues status updated'
	String get duesUpdated => 'Dues status updated';

	/// en: 'Amount'
	String get amount => 'Amount';

	/// en: 'Update Due Amount'
	String get updateDueAmount => 'Update Due Amount';

	/// en: 'Due Settings'
	String get dueSettings => 'Due Settings';

	/// en: '{days} days late'
	String get dueLatePaymentBadge => '{days} days late';

	/// en: 'View Payment History'
	String get viewPaymentHistory => 'View Payment History';

	/// en: 'Payment History'
	String get paymentHistoryTitle => 'Payment History';

	/// en: 'Due amount updated'
	String get dueAmountUpdated => 'Due amount updated';

	/// en: 'Could not update due amount'
	String get dueAmountUpdateFailed => 'Could not update due amount';

	/// en: 'Due Day (1-28)'
	String get dueDay => 'Due Day (1-28)';

	/// en: 'Select day'
	String get selectDueDay => 'Select day';

	/// en: 'Apply to pending dues'
	String get affectCurrentDues => 'Apply to pending dues';

	/// en: 'Open dues (pending and overdue) get updated amounts and due dates. If the new due date has not passed yet, overdue status is cleared.'
	String get affectCurrentDuesHint => 'Open dues (pending and overdue) get updated amounts and due dates. If the new due date has not passed yet, overdue status is cleared.';

	/// en: 'Enter an amount or select a due day to update.'
	String get dueUpdateNeedAmountOrDay => 'Enter an amount or select a due day to update.';

	/// en: 'This building has no saved amount yet. Enter an amount before updating the due day only.'
	String get dueUpdateNeedStoredAmount => 'This building has no saved amount yet. Enter an amount before updating the due day only.';

	/// en: 'Enter a valid amount.'
	String get dueAmountInvalidPositive => 'Enter a valid amount.';

	/// en: 'Due day must be between 1 and 28.'
	String get dueDayOutOfRange => 'Due day must be between 1 and 28.';

	/// en: 'Update'
	String get update => 'Update';

	/// en: 'Filter'
	String get filter => 'Filter';

	/// en: 'Apply'
	String get apply => 'Apply';

	/// en: 'days overdue'
	String get overdueDays => 'days overdue';

	/// en: '{days} days late'
	String get dueMetaOverdueDelay => '{days} days late';

	/// en: '{days} days late'
	String get dueStatusOverdueWithDays => '{days} days late';

	/// en: '{date} - {days} days late'
	String get duePaidSummaryLate => '{date} - {days} days late';

	/// en: 'due by {day} {month}'
	String get dueMetaPendingDueDate => 'due by {day} {month}';

	/// en: 'Pay'
	String get payShort => 'Pay';

	/// en: 'Receipt'
	String get dekontShort => 'Receipt';

	/// en: 'MONTH'
	String get monthChipLabel => 'MONTH';

	/// en: 'YEAR'
	String get yearChipLabel => 'YEAR';

	/// en: 'Due date'
	String get dueDateLabel => 'Due date';

	/// en: '/ month'
	String get perMonth => '/ month';

	/// en: 'FLOOR'
	String get floorLabel => 'FLOOR';

	/// en: 'APT'
	String get apartmentLabel => 'APT';

	/// en: 'Türkçe'
	String get turkishLanguage => 'Türkçe';

	/// en: 'English'
	String get englishLanguage => 'English';

	/// en: 'Turkish'
	String get turkishLanguageSubtitle => 'Turkish';

	/// en: 'İngilizce'
	String get englishLanguageSubtitle => 'İngilizce';

	/// en: 'Site'
	String get stepSite => 'Site';

	/// en: 'Building'
	String get stepBuilding => 'Building';

	/// en: 'Apartment'
	String get stepApartment => 'Apartment';

	/// en: 'Code'
	String get stepCode => 'Code';

	/// en: 'Edit Building'
	String get editBuilding => 'Edit Building';

	/// en: 'Delete Building'
	String get deleteBuilding => 'Delete Building';

	/// en: 'Building updated'
	String get buildingUpdated => 'Building updated';

	/// en: 'Building deleted'
	String get buildingDeleted => 'Building deleted';

	/// en: 'Could not update building'
	String get buildingUpdateFailed => 'Could not update building';

	/// en: 'Could not delete building'
	String get buildingDeleteFailed => 'Could not delete building';

	/// en: 'Cannot delete this building: apartments, residents, or dues still exist.'
	String get buildingDeleteFailedFK => 'Cannot delete this building: apartments, residents, or dues still exist.';

	/// en: 'This action cannot be undone.'
	String get deleteBuildingHeader => 'This action cannot be undone.';

	/// en: 'To confirm, type the building name below exactly:'
	String get deleteBuildingTypeHint => 'To confirm, type the building name below exactly:';

	/// en: 'Building name'
	String get deleteBuildingTypeFieldLabel => 'Building name';

	/// en: 'What you typed does not match the building name.'
	String get buildingNameMismatch => 'What you typed does not match the building name.';

	/// en: 'Delete Site'
	String get deleteSite => 'Delete Site';

	/// en: 'Site deleted'
	String get siteDeleted => 'Site deleted';

	/// en: 'Could not delete site'
	String get siteDeleteFailed => 'Could not delete site';

	/// en: 'This action cannot be undone. Blocks under the site are also affected.'
	String get deleteSiteHeader => 'This action cannot be undone. Blocks under the site are also affected.';

	/// en: 'To confirm, type the site name below exactly:'
	String get deleteSiteTypeHint => 'To confirm, type the site name below exactly:';

	/// en: 'Site name'
	String get deleteSiteTypeFieldLabel => 'Site name';

	/// en: 'What you typed does not match the site name.'
	String get siteNameMismatch => 'What you typed does not match the site name.';

	/// en: 'Edit Apartment'
	String get editApartment => 'Edit Apartment';

	/// en: 'Delete Apartment'
	String get deleteApartment => 'Delete Apartment';

	/// en: 'Add Apartment'
	String get addApartment => 'Add Apartment';

	/// en: 'Apartment updated'
	String get apartmentUpdated => 'Apartment updated';

	/// en: 'Apartment added'
	String get apartmentCreated => 'Apartment added';

	/// en: 'Apartment deleted'
	String get apartmentDeleted => 'Apartment deleted';

	/// en: 'Could not update apartment'
	String get apartmentUpdateFailed => 'Could not update apartment';

	/// en: 'Could not delete apartment'
	String get apartmentDeleteFailed => 'Could not delete apartment';

	/// en: 'Cannot delete this apartment: resident or dues records still exist.'
	String get apartmentDeleteFailedFK => 'Cannot delete this apartment: resident or dues records still exist.';

	/// en: 'Are you sure you want to delete this apartment?'
	String get deleteApartmentConfirm => 'Are you sure you want to delete this apartment?';

	/// en: 'Apt No (e.g. 5)'
	String get apartmentNumberLabel => 'Apt No (e.g. 5)';

	/// en: 'Floor (optional)'
	String get floorLabel2 => 'Floor (optional)';

	/// en: 'Floor (-5 to 200)'
	String get floorOptional => 'Floor (-5 to 200)';

	/// en: 'Building name'
	String get buildingNameField => 'Building name';

	/// en: 'Address'
	String get buildingAddressField => 'Address';

	/// en: 'City'
	String get buildingCityField => 'City';

	/// en: 'Monthly dues / apt'
	String get monthlyDuesPerApartment => 'Monthly dues / apt';

	/// en: 'Remove'
	String get remove => 'Remove';

	/// en: 'Remove Resident'
	String get removeResident => 'Remove Resident';

	/// en: 'Are you sure you want to remove this resident from the apartment?'
	String get removeResidentConfirm => 'Are you sure you want to remove this resident from the apartment?';

	/// en: 'The resident's account will not be deleted; only their link to this apartment is removed. Past dues records are kept. The resident can join another apartment later using an invite code.'
	String get removeResidentNote => 'The resident\'s account will not be deleted; only their link to this apartment is removed. Past dues records are kept. The resident can join another apartment later using an invite code.';

	/// en: 'Resident removed from apartment'
	String get residentRemoved => 'Resident removed from apartment';

	/// en: 'Could not remove resident'
	String get residentRemoveFailed => 'Could not remove resident';

	/// en: 'You are not allowed to perform this action. Only the building manager can remove residents.'
	String get residentRemoveForbidden => 'You are not allowed to perform this action. Only the building manager can remove residents.';

	/// en: 'No resident to remove from this apartment.'
	String get residentRemoveNotFound => 'No resident to remove from this apartment.';

	/// en: 'Select multiple'
	String get multiSelectResidents => 'Select multiple';

	/// en: 'Tap the card to select or clear'
	String get multiSelectTapHint => 'Tap the card to select or clear';

	/// en: 'Select'
	String get selectTriggerShort => 'Select';

	/// en: 'selected'
	String get selectedCountLabel => 'selected';

	/// en: 'Pick the residents you want to remove'
	String get selectionRemoveHint => 'Pick the residents you want to remove';

	/// en: 'Pick the IBANs you want to delete'
	String get selectionDeleteIbanHint => 'Pick the IBANs you want to delete';

	/// en: 'Remove selected'
	String get removeSelectedResidents => 'Remove selected';

	/// en: 'Remove selected residents'
	String get removeSelectedResidentsTitle => 'Remove selected residents';

	/// en: 'Residents in the apartments listed below will be unlinked from their apartments. Accounts are not deleted—only the connection to this building is removed. Past dues records are kept.'
	String get removeSelectedResidentsMessage => 'Residents in the apartments listed below will be unlinked from their apartments. Accounts are not deleted—only the connection to this building is removed. Past dues records are kept.';

	/// en: 'Apartments affected'
	String get removeSelectedResidentsAffectedListTitle => 'Apartments affected';

	/// en: 'The apartment list could not be loaded. The count is shown below. If you confirm, removals will still proceed.'
	String get removeSelectedResidentsListUnavailable => 'The apartment list could not be loaded. The count is shown below. If you confirm, removals will still proceed.';

	/// en: 'Select at least one occupied apartment from the list first'
	String get pickResidentsFirst => 'Select at least one occupied apartment from the list first';

	/// en: 'There are no residents to remove in this building.'
	String get noResidentsToRemoveInBuilding => 'There are no residents to remove in this building.';

	/// en: 'Working…'
	String get removeSelectedProgress => 'Working…';

	/// en: 'Selected residents were removed from their apartments'
	String get removeSelectedSuccess => 'Selected residents were removed from their apartments';

	/// en: 'Could not finish removing the selected residents'
	String get removeSelectedFailed => 'Could not finish removing the selected residents';

	/// en: 'Current Password'
	String get currentPassword => 'Current Password';

	/// en: 'New Password'
	String get newPassword => 'New Password';

	/// en: 'New Password (Repeat)'
	String get newPasswordConfirm => 'New Password (Repeat)';

	/// en: 'Enter your current password'
	String get currentPasswordRequired => 'Enter your current password';

	/// en: 'New password cannot be the same as the old one'
	String get passwordsMustDiffer => 'New password cannot be the same as the old one';

	/// en: 'Change Password'
	String get changePasswordTitle => 'Change Password';

	/// en: 'Update your password regularly to keep your account secure.'
	String get changePasswordSubtitle => 'Update your password regularly to keep your account secure.';

	/// en: 'Your password was changed successfully.'
	String get changePasswordSuccess => 'Your password was changed successfully.';

	/// en: 'Could not change password. Try again.'
	String get changePasswordFailed => 'Could not change password. Try again.';

	/// en: 'Current password is incorrect.'
	String get changePasswordWrongCurrent => 'Current password is incorrect.';

	/// en: 'You can change the application language here.'
	String get languageSheetDescription => 'You can change the application language here.';

	late final Translations$common$friendlyError$en friendlyError = Translations$common$friendlyError$en._(_root);

	/// en: 'Must include uppercase, lowercase, and a number'
	String get newPasswordHint => 'Must include uppercase, lowercase, and a number';

	/// en: 'Not specified'
	String get passwordStrengthUnspecified => 'Not specified';

	/// en: 'Weak'
	String get passwordStrengthWeak => 'Weak';

	/// en: 'Medium'
	String get passwordStrengthMedium => 'Medium';

	/// en: 'Strong'
	String get passwordStrengthStrong => 'Strong';

	/// en: 'New password strength: {level}'
	String get passwordStrengthLabel => 'New password strength: {level}';

	/// en: 'Close My Account'
	String get deleteAccount => 'Close My Account';

	/// en: 'Do you want to close your account?'
	String get deleteAccountTitle => 'Do you want to close your account?';

	/// en: 'This action cannot be undone. Your personal data will be removed, but for legal reasons some records (such as dues history) are kept anonymously.'
	String get deleteAccountWarning => 'This action cannot be undone. Your personal data will be removed, but for legal reasons some records (such as dues history) are kept anonymously.';

	/// en: 'To confirm, type "CLOSE MY ACCOUNT" below:'
	String get deleteAccountTypeHint => 'To confirm, type "CLOSE MY ACCOUNT" below:';

	/// en: 'CLOSE MY ACCOUNT'
	String get deleteAccountTypePhrase => 'CLOSE MY ACCOUNT';

	/// en: 'What you typed does not match.'
	String get deleteAccountTypeMismatch => 'What you typed does not match.';

	/// en: 'Close My Account'
	String get deleteAccountConfirmButton => 'Close My Account';

	/// en: 'Your account was closed successfully.'
	String get deleteAccountSuccess => 'Your account was closed successfully.';

	/// en: 'Could not close account. Try again.'
	String get deleteAccountFailed => 'Could not close account. Try again.';

	/// en: 'You first need to delete the buildings you manage or transfer them to another manager.'
	String get deleteAccountFailedManager => 'You first need to delete the buildings you manage or transfer them to another manager.';

	/// en: 'Danger Zone'
	String get dangerZone => 'Danger Zone';

	/// en: 'Forgot Password'
	String get forgotPassword => 'Forgot Password';

	/// en: 'Forgot Password'
	String get forgotPasswordTitle => 'Forgot Password';

	/// en: 'Enter your registered email or phone and we'll send you a reset code.'
	String get forgotPasswordSubtitle => 'Enter your registered email or phone and we\'ll send you a reset code.';

	/// en: 'Code sent successfully.'
	String get forgotPasswordSuccess => 'Code sent successfully.';

	/// en: 'Code sent successfully to your email.'
	String get forgotPasswordSuccessEmail => 'Code sent successfully to your email.';

	/// en: 'Code sent successfully by SMS.'
	String get forgotPasswordSuccessSms => 'Code sent successfully by SMS.';

	/// en: 'Didn't get the code? Send via SMS'
	String get forgotPasswordSmsFallback => 'Didn\'t get the code? Send via SMS';

	/// en: 'Code sent successfully by SMS.'
	String get forgotPasswordSmsFallbackSuccess => 'Code sent successfully by SMS.';

	/// en: 'Send Code'
	String get sendResetCode => 'Send Code';

	/// en: 'I already have a code'
	String get iHaveACode => 'I already have a code';

	/// en: 'Set New Password'
	String get resetPasswordTitle => 'Set New Password';

	/// en: 'Enter the 6-character code you received and a new password.'
	String get resetPasswordSubtitle => 'Enter the 6-character code you received and a new password.';

	/// en: 'Enter the 6-character code from your email and a new password.'
	String get resetPasswordSubtitleEmail => 'Enter the 6-character code from your email and a new password.';

	/// en: 'Enter the 6-character code from your SMS and a new password.'
	String get resetPasswordSubtitleSms => 'Enter the 6-character code from your SMS and a new password.';

	/// en: 'Reset Code'
	String get resetCode => 'Reset Code';

	/// en: 'ABC123'
	String get resetCodeHint => 'ABC123';

	/// en: 'Reset code required'
	String get resetCodeRequired => 'Reset code required';

	/// en: 'Code must be 6 characters'
	String get resetCodeInvalid => 'Code must be 6 characters';

	/// en: 'Your password was reset successfully.'
	String get resetPasswordSuccess => 'Your password was reset successfully.';

	/// en: 'Could not reset password. The code may be invalid or expired.'
	String get resetPasswordFailed => 'Could not reset password. The code may be invalid or expired.';

	/// en: 'Reset Password'
	String get resetPasswordSubmit => 'Reset Password';

	/// en: 'Back to login'
	String get backToLogin => 'Back to login';

	/// en: 'Select'
	String get select => 'Select';

	/// en: 'New'
	String get kNew => 'New';

	late final Translations$common$errorKeys$en errorKeys = Translations$common$errorKeys$en._(_root);
}

// Path: validation
class Translations$validation$en {
	Translations$validation$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Email address cannot be empty'
	String get emailRequired => 'Email address cannot be empty';

	/// en: 'Please enter a valid email address'
	String get emailInvalid => 'Please enter a valid email address';

	/// en: 'Email address is too long'
	String get emailTooLong => 'Email address is too long';

	/// en: 'Phone number cannot be empty'
	String get phoneRequired => 'Phone number cannot be empty';

	/// en: 'Phone number must be 10 digits'
	String get phoneInvalid => 'Phone number must be 10 digits';

	/// en: 'Password cannot be empty'
	String get passwordRequired => 'Password cannot be empty';

	/// en: 'Password must be at least 6 characters'
	String get passwordTooShort => 'Password must be at least 6 characters';

	/// en: 'Password is too long'
	String get passwordTooLong => 'Password is too long';

	/// en: 'Password must be at least 6 characters and contain only letters and numbers'
	String get passwordAlphanumericRequired => 'Password must be at least 6 characters and contain only letters and numbers';

	/// en: 'Password must contain at least 1 uppercase letter'
	String get passwordUppercaseRequired => 'Password must contain at least 1 uppercase letter';

	/// en: 'Password must contain at least 1 lowercase letter'
	String get passwordLowercaseRequired => 'Password must contain at least 1 lowercase letter';

	/// en: 'Password must contain at least 1 number'
	String get passwordNumberRequired => 'Password must contain at least 1 number';

	/// en: 'Password must contain at least 1 special character'
	String get passwordSpecialCharRequired => 'Password must contain at least 1 special character';

	/// en: 'This field is required'
	String get field_required => 'This field is required';

	/// en: 'Value is too short'
	String get field_too_short => 'Value is too short';

	/// en: 'Value is too long'
	String get field_too_long => 'Value is too long';

	/// en: 'Please enter a valid value'
	String get field_invalid => 'Please enter a valid value';
}

// Path: features
class Translations$features$en {
	Translations$features$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$features$buildings$en buildings = Translations$features$buildings$en._(_root);
	late final Translations$features$sites$en sites = Translations$features$sites$en._(_root);
	late final Translations$features$auth$en auth = Translations$features$auth$en._(_root);
	late final Translations$features$apartments$en apartments = Translations$features$apartments$en._(_root);
	late final Translations$features$tickets$en tickets = Translations$features$tickets$en._(_root);
	late final Translations$features$dekont$en dekont = Translations$features$dekont$en._(_root);
	late final Translations$features$expenses$en expenses = Translations$features$expenses$en._(_root);
	late final Translations$features$notifications$en notifications = Translations$features$notifications$en._(_root);
	late final Translations$features$profile$en profile = Translations$features$profile$en._(_root);
	late final Translations$features$subscription$en subscription = Translations$features$subscription$en._(_root);
	late final Translations$features$reports$en reports = Translations$features$reports$en._(_root);
	late final Translations$features$dashboard$en dashboard = Translations$features$dashboard$en._(_root);
	late final Translations$features$dues$en dues = Translations$features$dues$en._(_root);
	late final Translations$features$faz2$en faz2 = Translations$features$faz2$en._(_root);
	late final Translations$features$welcome$en welcome = Translations$features$welcome$en._(_root);
}

// Path: legal
class Translations$legal$en {
	Translations$legal$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Vefa Yazılım'
	String get companyName => 'Vefa Yazılım';

	/// en: 'store@vefayazilim.com'
	String get contactEmail => 'store@vefayazilim.com';

	/// en: 'Data controller: Vefa Yazılım Email: store@vefayazilim.com'
	String get contactBlock => 'Data controller: Vefa Yazılım\nEmail: store@vefayazilim.com';

	/// en: 'Last updated'
	String get updatedLabel => 'Last updated';

	/// en: 'June 2026'
	String get updatedDate => 'June 2026';

	/// en: 'This policy explains how Vefa Yazılım processes your personal data when you use the AidatPanel mobile app. By continuing to use the app, you acknowledge that you have read this policy.'
	String get privacyIntro => 'This policy explains how Vefa Yazılım processes your personal data when you use the AidatPanel mobile app. By continuing to use the app, you acknowledge that you have read this policy.';

	/// en: '1. Data controller'
	String get privacyS1Title => '1. Data controller';

	/// en: 'Your personal data is processed by Vefa Yazılım as the data controller for AidatPanel, in compliance with applicable data protection laws, including Turkish KVKK where applicable. For privacy and KVKK requests: store@vefayazilim.com'
	String get privacyS1Body => 'Your personal data is processed by Vefa Yazılım as the data controller for AidatPanel, in compliance with applicable data protection laws, including Turkish KVKK where applicable. For privacy and KVKK requests: store@vefayazilim.com';

	/// en: '2. Data we collect'
	String get privacyS2Title => '2. Data we collect';

	/// en: 'We may process account details (name, email, phone, language), building and apartment association, dues and payment records, support tickets, announcements and notification preferences, receipt images you upload, device push token (FCM), and secure session tokens.'
	String get privacyS2Body => 'We may process account details (name, email, phone, language), building and apartment association, dues and payment records, support tickets, announcements and notification preferences, receipt images you upload, device push token (FCM), and secure session tokens.';

	/// en: '3. Purposes'
	String get privacyS3Title => '3. Purposes';

	/// en: 'Data is used for dues and expense management, payment and receipt workflows, in-building communication, authentication, service security, legal obligations, and sending notifications you enable.'
	String get privacyS3Body => 'Data is used for dues and expense management, payment and receipt workflows, in-building communication, authentication, service security, legal obligations, and sending notifications you enable.';

	/// en: '4. Retention and security'
	String get privacyS4Title => '4. Retention and security';

	/// en: 'Data is stored on secure servers; communication uses HTTPS. Session data is kept in secure device storage. Data is retained for the service relationship and as required by law.'
	String get privacyS4Body => 'Data is stored on secure servers; communication uses HTTPS. Session data is kept in secure device storage. Data is retained for the service relationship and as required by law.';

	/// en: '5. Sharing'
	String get privacyS5Title => '5. Sharing';

	/// en: 'We do not sell your data. It may be shared only with infrastructure providers necessary to run the service (hosting, push notifications, etc.) and authorities when legally required.'
	String get privacyS5Body => 'We do not sell your data. It may be shared only with infrastructure providers necessary to run the service (hosting, push notifications, etc.) and authorities when legally required.';

	/// en: '6. Your rights'
	String get privacyS6Title => '6. Your rights';

	/// en: 'You may request access, correction, deletion, or restriction of processing. Account closure (soft delete) is available in Settings; records that must be kept by law may be stored in anonymized form. Submit requests to store@vefayazilim.com.'
	String get privacyS6Body => 'You may request access, correction, deletion, or restriction of processing. Account closure (soft delete) is available in Settings; records that must be kept by law may be stored in anonymized form. Submit requests to store@vefayazilim.com.';

	/// en: 'This notice is provided under Turkish Personal Data Protection Law No. 6698 (KVKK) for processing by Vefa Yazılım.'
	String get kvkkIntro => 'This notice is provided under Turkish Personal Data Protection Law No. 6698 (KVKK) for processing by Vefa Yazılım.';

	/// en: 'Data controller and contact'
	String get kvkkS1Title => 'Data controller and contact';

	/// en: 'The data controller for AidatPanel is Vefa Yazılım. You may submit KVKK requests to store@vefayazilim.com or using your registered email in the app.'
	String get kvkkS1Body => 'The data controller for AidatPanel is Vefa Yazılım. You may submit KVKK requests to store@vefayazilim.com or using your registered email in the app.';

	/// en: 'Data categories'
	String get kvkkS2Title => 'Data categories';

	/// en: 'Categories may include identity and contact, customer transaction (dues, payments, expenses), visual records (receipts), security (logs, tokens), and communication (notification consent).'
	String get kvkkS2Body => 'Categories may include identity and contact, customer transaction (dues, payments, expenses), visual records (receipts), security (logs, tokens), and communication (notification consent).';

	/// en: 'Purposes and legal bases'
	String get kvkkS3Title => 'Purposes and legal bases';

	/// en: 'Processing is based on contract performance, legal obligation, legitimate interest, and your explicit consent where required (e.g. notifications).'
	String get kvkkS3Body => 'Processing is based on contract performance, legal obligation, legitimate interest, and your explicit consent where required (e.g. notifications).';

	/// en: 'Transfers'
	String get kvkkS4Title => 'Transfers';

	/// en: 'Data may be transferred to hosting and technical providers within Türkiye as needed to provide the service, with appropriate safeguards.'
	String get kvkkS4Body => 'Data may be transferred to hosting and technical providers within Türkiye as needed to provide the service, with appropriate safeguards.';

	/// en: 'Collection method'
	String get kvkkS5Title => 'Collection method';

	/// en: 'Data is collected electronically via app forms, automated logs, files you upload, and the notification infrastructure.'
	String get kvkkS5Body => 'Data is collected electronically via app forms, automated logs, files you upload, and the notification infrastructure.';

	/// en: 'Data subject rights'
	String get kvkkS6Title => 'Data subject rights';

	/// en: 'You may exercise your rights under Article 11 of KVKK by contacting Vefa Yazılım at store@vefayazilim.com; requests are answered within statutory time limits.'
	String get kvkkS6Body => 'You may exercise your rights under Article 11 of KVKK by contacting Vefa Yazılım at store@vefayazilim.com; requests are answered within statutory time limits.';

	/// en: 'Help center coming soon'
	String get helpIntro => 'Help center coming soon';

	/// en: 'FAQs, step-by-step guides, and support channels will be added here soon. For app support: store@vefayazilim.com (Vefa Yazılım). For urgent building matters, contact your building manager or site administration.'
	String get helpBody => 'FAQs, step-by-step guides, and support channels will be added here soon. For app support: store@vefayazilim.com (Vefa Yazılım). For urgent building matters, contact your building manager or site administration.';
}

// Path: db_context
class Translations$db_context$en {
	Translations$db_context$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Record: {value}'
	String get user_entry => 'Record: {value}';

	/// en: 'Building: {value}'
	String get building_name => 'Building: {value}';

	/// en: 'Apartment: {value}'
	String get apartment_label => 'Apartment: {value}';

	/// en: 'Code: {value}'
	String get code_value => 'Code: {value}';

	/// en: 'Expires at: {value}'
	String get expiry_date => 'Expires at: {value}';
}

// Path: common.api
class Translations$common$api$en {
	Translations$common$api$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Check your internet connection and try again.'
	String get networkError => 'Check your internet connection and try again.';

	/// en: 'Could not reach the server. Try again later.'
	String get serverError => 'Could not reach the server. Try again later.';

	/// en: 'Please check the information you entered.'
	String get validationError => 'Please check the information you entered.';

	/// en: 'The requested record was not found.'
	String get notFound => 'The requested record was not found.';

	/// en: 'Your session has ended. Sign in again.'
	String get unauthorized => 'Your session has ended. Sign in again.';

	/// en: 'Too many attempts. Please wait a moment and try again.'
	String get rateLimit => 'Too many attempts. Please wait a moment and try again.';

	/// en: 'You do not have permission for this action.'
	String get forbidden => 'You do not have permission for this action.';

	/// en: 'Something went wrong. Try again.'
	String get genericError => 'Something went wrong. Try again.';

	/// en: 'Email, phone, or password is incorrect. Please check and try again.'
	String get invalidCredentials => 'Email, phone, or password is incorrect. Please check and try again.';

	/// en: 'This email is already registered. Try signing in.'
	String get duplicateEmail => 'This email is already registered. Try signing in.';

	/// en: 'This phone number is already registered.'
	String get duplicatePhone => 'This phone number is already registered.';

	/// en: 'No account found with this email. Check your details or sign up.'
	String get accountNotFoundEmail => 'No account found with this email. Check your details or sign up.';

	/// en: 'No account found with this phone number. Check your details or sign up.'
	String get accountNotFoundPhone => 'No account found with this phone number. Check your details or sign up.';

	/// en: 'Could not verify email or phone. Try again.'
	String get identifierCheckFailed => 'Could not verify email or phone. Try again.';

	/// en: 'Invite code is invalid. Check the code and try again.'
	String get invalidInviteCode => 'Invite code is invalid. Check the code and try again.';

	/// en: 'This invite code has already been used.'
	String get inviteCodeUsed => 'This invite code has already been used.';

	/// en: 'This invite code has expired. Ask your manager for a new one.'
	String get inviteCodeExpired => 'This invite code has expired. Ask your manager for a new one.';

	/// en: 'Code is invalid or expired. Request a new code and try again.'
	String get resetTokenInvalid => 'Code is invalid or expired. Request a new code and try again.';

	/// en: 'This record already exists.'
	String get recordConflict => 'This record already exists.';

	/// en: 'A related record required for this action was not found.'
	String get relatedRecordMissing => 'A related record required for this action was not found.';

	/// en: 'Building not found or you do not have access.'
	String get buildingAccessDenied => 'Building not found or you do not have access.';

	/// en: 'Invalid IBAN. Enter a 26-digit TR IBAN.'
	String get invalidIban => 'Invalid IBAN. Enter a 26-digit TR IBAN.';

	/// en: 'There is no resident to remove from this apartment.'
	String get apartmentNoResident => 'There is no resident to remove from this apartment.';

	/// en: 'Notes cannot be added to a closed or resolved ticket.'
	String get ticketClosedNote => 'Notes cannot be added to a closed or resolved ticket.';

	/// en: 'Status of a closed ticket cannot be changed.'
	String get ticketClosedStatus => 'Status of a closed ticket cannot be changed.';

	/// en: 'This status change is not allowed. Refresh the list and try again.'
	String get ticketInvalidStatus => 'This status change is not allowed. Refresh the list and try again.';

	/// en: 'This action is not available right now. Try again later.'
	String get serviceUnavailable => 'This action is not available right now. Try again later.';

	/// en: 'File could not be uploaded. Try again.'
	String get fileUploadError => 'File could not be uploaded. Try again.';

	/// en: 'File type does not match its contents. Choose another file.'
	String get fileContentMismatch => 'File type does not match its contents. Choose another file.';

	/// en: 'PDF could not be read or is corrupted. Try another file.'
	String get invalidPdf => 'PDF could not be read or is corrupted. Try another file.';

	/// en: 'Notification not found.'
	String get notificationNotFound => 'Notification not found.';

	/// en: 'List could not be refreshed. Reload the page and try again.'
	String get invalidCursor => 'List could not be refreshed. Reload the page and try again.';

	/// en: 'Expense record not found.'
	String get expenseNotFound => 'Expense record not found.';

	/// en: 'Due record not found.'
	String get dueNotFound => 'Due record not found.';

	/// en: 'Receipt not found.'
	String get dekontNotFound => 'Receipt not found.';

	/// en: 'You must be assigned to an apartment before viewing payment details.'
	String get noApartmentForPayment => 'You must be assigned to an apartment before viewing payment details.';
}

// Path: common.documentPreview
class Translations$common$documentPreview$en {
	Translations$common$documentPreview$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'View document'
	String get title => 'View document';

	/// en: 'Share'
	String get share => 'Share';

	/// en: 'PDF could not be opened on this device. Use Share to open it in another app.'
	String get pdfUnavailable => 'PDF could not be opened on this device. Use Share to open it in another app.';

	/// en: 'Pinch to zoom and drag to pan'
	String get pinchHint => 'Pinch to zoom and drag to pan';
}

// Path: common.friendlyError
class Translations$common$friendlyError$en {
	Translations$common$friendlyError$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'No internet connection'
	String get networkTitle => 'No internet connection';

	/// en: 'Please make sure your phone is connected to the internet and try again.'
	String get networkMessage => 'Please make sure your phone is connected to the internet and try again.';

	/// en: 'Session ended'
	String get unauthorizedTitle => 'Session ended';

	/// en: 'Please close the app and sign in again.'
	String get unauthorizedMessage => 'Please close the app and sign in again.';

	/// en: 'Cannot reach the server'
	String get serverTitle => 'Cannot reach the server';

	/// en: 'Please try again in a moment.'
	String get serverMessage => 'Please try again in a moment.';

	/// en: 'This page could not be opened'
	String get genericTitle => 'This page could not be opened';

	/// en: 'Please close and reopen the app.'
	String get genericMessage => 'Please close and reopen the app.';

	/// en: 'Visible to developers only (debug):'
	String get debugOnlyLabel => 'Visible to developers only (debug):';
}

// Path: common.errorKeys
class Translations$common$errorKeys$en {
	Translations$common$errorKeys$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'There was a problem signing in. Try again.'
	String get authLoginFailed => 'There was a problem signing in. Try again.';

	/// en: 'There was a problem creating your account. Try again.'
	String get authRegisterFailed => 'There was a problem creating your account. Try again.';

	/// en: 'There was a problem joining the apartment. Try again.'
	String get authJoinFailed => 'There was a problem joining the apartment. Try again.';

	/// en: 'Could not sign out other devices. Try again.'
	String get authLogoutAllDevicesFailed => 'Could not sign out other devices. Try again.';

	/// en: 'Could not send the request. Try again.'
	String get authForgotPasswordRequestFailed => 'Could not send the request. Try again.';

	/// en: 'Could not reset your password. Try again.'
	String get authResetPasswordFailed => 'Could not reset your password. Try again.';

	/// en: 'Could not load the summary. Try again.'
	String get dashboardSummaryFetchFailed => 'Could not load the summary. Try again.';

	/// en: 'Could not load the collection summary. Try again.'
	String get dashboardCollectionFetchFailed => 'Could not load the collection summary. Try again.';

	/// en: 'Could not load buildings. Try again.'
	String get buildingFetchFailed => 'Could not load buildings. Try again.';

	/// en: 'Could not load collection suggestions. Try again.'
	String get collectionPresetsFetchFailed => 'Could not load collection suggestions. Try again.';

	/// en: 'Could not add the building. Try again.'
	String get buildingCreateFailed => 'Could not add the building. Try again.';

	/// en: 'Could not update the building. Try again.'
	String get buildingUpdateFailed => 'Could not update the building. Try again.';

	/// en: 'Could not update collection details. Try again.'
	String get buildingCollectionUpdateFailed => 'Could not update collection details. Try again.';

	/// en: 'No IBAN record was found to update or delete.'
	String get collectionPresetNotFound => 'No IBAN record was found to update or delete.';

	/// en: 'Could not save the IBAN. Try again.'
	String get collectionPresetSaveFailed => 'Could not save the IBAN. Try again.';

	/// en: 'Could not delete the IBAN. Try again.'
	String get collectionPresetDeleteFailed => 'Could not delete the IBAN. Try again.';

	/// en: 'Could not delete the building. Try again.'
	String get buildingDeleteFailed => 'Could not delete the building. Try again.';

	/// en: 'Could not create the invite code. Try again.'
	String get inviteCodeCreateFailed => 'Could not create the invite code. Try again.';

	/// en: 'Could not load apartments. Try again.'
	String get apartmentsFetchFailed => 'Could not load apartments. Try again.';

	/// en: 'Could not add the apartment. Try again.'
	String get apartmentCreateFailed => 'Could not add the apartment. Try again.';

	/// en: 'Could not update the apartment. Try again.'
	String get apartmentUpdateFailed => 'Could not update the apartment. Try again.';

	/// en: 'Could not delete the apartment. Try again.'
	String get apartmentDeleteFailed => 'Could not delete the apartment. Try again.';

	/// en: 'Could not remove the resident. Try again.'
	String get residentRemoveFailed => 'Could not remove the resident. Try again.';

	/// en: 'Could not load the dues list. Try again.'
	String get buildingDuesFetchFailed => 'Could not load the dues list. Try again.';

	/// en: 'Could not load dues transaction history. Try again.'
	String get dueTransactionsFetchFailed => 'Could not load dues transaction history. Try again.';

	/// en: 'Could not load your dues. Try again.'
	String get myDuesFetchFailed => 'Could not load your dues. Try again.';

	/// en: 'Could not update the due status. Try again.'
	String get dueStatusUpdateFailed => 'Could not update the due status. Try again.';

	/// en: 'Could not update the due amount. Try again.'
	String get dueAmountUpdateFailed => 'Could not update the due amount. Try again.';

	/// en: 'Could not send the reminder. Try again.'
	String get dueReminderFailed => 'Could not send the reminder. Try again.';

	/// en: 'Could not load requests. Try again.'
	String get myTicketsFetchFailed => 'Could not load requests. Try again.';

	/// en: 'Could not load building requests. Try again.'
	String get buildingTicketsFetchFailed => 'Could not load building requests. Try again.';

	/// en: 'Could not load request details. Try again.'
	String get ticketDetailFetchFailed => 'Could not load request details. Try again.';

	/// en: 'Could not create the request. Try again.'
	String get ticketCreateFailed => 'Could not create the request. Try again.';

	/// en: 'Could not add the note. Try again.'
	String get ticketNoteAddFailed => 'Could not add the note. Try again.';

	/// en: 'Could not update the request status. Try again.'
	String get ticketStatusUpdateFailed => 'Could not update the request status. Try again.';

	/// en: 'Could not load expenses. Try again.'
	String get expensesFetchFailed => 'Could not load expenses. Try again.';

	/// en: 'Could not load the expense summary. Try again.'
	String get expenseSummaryFetchFailed => 'Could not load the expense summary. Try again.';

	/// en: 'Could not save the expense. Try again.'
	String get expenseCreateFailed => 'Could not save the expense. Try again.';

	/// en: 'Could not update the expense. Try again.'
	String get expenseUpdateFailed => 'Could not update the expense. Try again.';

	/// en: 'Could not delete the expense. Try again.'
	String get expenseDeleteFailed => 'Could not delete the expense. Try again.';

	/// en: 'Could not upload receipts. Try again.'
	String get expenseReceiptsUploadFailed => 'Could not upload receipts. Try again.';

	/// en: 'Could not load profile information. Try again.'
	String get profileFetchFailed => 'Could not load profile information. Try again.';

	/// en: 'Could not update the profile. Try again.'
	String get profileUpdateFailed => 'Could not update the profile. Try again.';

	/// en: 'Could not save the language preference. Try again.'
	String get languageUpdateFailed => 'Could not save the language preference. Try again.';

	/// en: 'Could not change the password. Try again.'
	String get passwordChangeFailed => 'Could not change the password. Try again.';

	/// en: 'Could not close the account. Try again.'
	String get accountDeleteFailed => 'Could not close the account. Try again.';

	/// en: 'Could not upload the profile photo. Try again.'
	String get profilePictureUploadFailed => 'Could not upload the profile photo. Try again.';

	/// en: 'Could not remove the profile photo. Try again.'
	String get profilePictureDeleteFailed => 'Could not remove the profile photo. Try again.';

	/// en: 'Could not load the notification count. Try again.'
	String get notificationCountFetchFailed => 'Could not load the notification count. Try again.';

	/// en: 'Could not load notifications. Try again.'
	String get notificationsFetchFailed => 'Could not load notifications. Try again.';

	/// en: 'Could not load the announcement count. Try again.'
	String get announcementCountFetchFailed => 'Could not load the announcement count. Try again.';

	/// en: 'Could not mark the notification as read. Try again.'
	String get notificationMarkReadFailed => 'Could not mark the notification as read. Try again.';

	/// en: 'Could not mark notifications as read. Try again.'
	String get notificationsMarkAllReadFailed => 'Could not mark notifications as read. Try again.';

	/// en: 'Could not send the announcement. Try again.'
	String get announcementSendFailed => 'Could not send the announcement. Try again.';

	/// en: 'Could not load sites. Try again.'
	String get sitesFetchFailed => 'Could not load sites. Try again.';

	/// en: 'Could not load site details. Try again.'
	String get siteDetailFetchFailed => 'Could not load site details. Try again.';

	/// en: 'Could not load blocks. Try again.'
	String get siteBuildingsFetchFailed => 'Could not load blocks. Try again.';

	/// en: 'Could not add the site. Try again.'
	String get siteCreateFailed => 'Could not add the site. Try again.';

	/// en: 'Could not update the site. Try again.'
	String get siteUpdateFailed => 'Could not update the site. Try again.';

	/// en: 'Could not update site collection details. Try again.'
	String get siteCollectionUpdateFailed => 'Could not update site collection details. Try again.';

	/// en: 'Could not delete the site. Try again.'
	String get siteDeleteFailed => 'Could not delete the site. Try again.';

	/// en: 'Could not add the block. Try again.'
	String get siteBuildingCreateFailed => 'Could not add the block. Try again.';

	/// en: 'Could not load site expenses. Try again.'
	String get siteExpensesFetchFailed => 'Could not load site expenses. Try again.';

	/// en: 'Could not load the site expense summary. Try again.'
	String get siteExpenseSummaryFetchFailed => 'Could not load the site expense summary. Try again.';

	/// en: 'Could not add the site expense. Try again.'
	String get siteExpenseCreateFailed => 'Could not add the site expense. Try again.';

	/// en: 'Could not update the site expense. Try again.'
	String get siteExpenseUpdateFailed => 'Could not update the site expense. Try again.';

	/// en: 'Could not delete the site expense. Try again.'
	String get siteExpenseDeleteFailed => 'Could not delete the site expense. Try again.';

	/// en: 'Could not load subscription information. Try again.'
	String get subscriptionFetchFailed => 'Could not load subscription information. Try again.';

	/// en: 'Enter a valid phone number.'
	String get firebasePhoneInvalid => 'Enter a valid phone number.';

	/// en: 'Too many attempts. Try again later.'
	String get firebasePhoneTooMany => 'Too many attempts. Try again later.';

	/// en: 'Verification timed out. Request a new code.'
	String get firebasePhoneTimeout => 'Verification timed out. Request a new code.';

	/// en: 'Verification session expired. Request a new code.'
	String get firebasePhoneSessionExpired => 'Verification session expired. Request a new code.';

	/// en: 'Incorrect code. Try again.'
	String get firebasePhoneCodeInvalid => 'Incorrect code. Try again.';

	/// en: 'Phone verification failed. Try again.'
	String get firebasePhoneFailed => 'Phone verification failed. Try again.';

	/// en: 'Verification could not finish. Update the app and try again.'
	String get firebasePhoneAppVerify => 'Verification could not finish. Update the app and try again.';

	/// en: 'Phone sign-in is unavailable right now.'
	String get firebasePhoneNotEnabled => 'Phone sign-in is unavailable right now.';

	/// en: 'SMS cannot be sent to this number. Try another number or try again later.'
	String get firebasePhoneCarrierBlocked => 'SMS cannot be sent to this number. Try another number or try again later.';

	/// en: 'Could not read expense information. Try again.'
	String get invalidExpenseResponse => 'Could not read expense information. Try again.';

	/// en: 'Could not read site expense information. Try again.'
	String get invalidSiteExpenseResponse => 'Could not read site expense information. Try again.';

	/// en: 'This file type is not supported.'
	String get unsupportedFileType => 'This file type is not supported.';

	/// en: 'Could not upload the receipt. Try again.'
	String get dekontUploadFailed => 'Could not upload the receipt. Try again.';

	/// en: 'Could not read the information. Try again.'
	String get serverResponseUnreadable => 'Could not read the information. Try again.';

	/// en: 'Could not read the information. Try again.'
	String get dekontResponseMissing => 'Could not read the information. Try again.';

	/// en: 'Could not read the information. Try again.'
	String get dekontResponseParseFailed => 'Could not read the information. Try again.';

	/// en: 'The report file was empty. Try again.'
	String get reportFileEmpty => 'The report file was empty. Try again.';

	/// en: 'Download started...'
	String get downloadStarted => 'Download started...';

	/// en: 'Image saved successfully.'
	String get downloadSavedToGallery => 'Image saved successfully.';

	/// en: 'Receipt saved successfully to Downloads.'
	String get downloadSavedToDownloads => 'Receipt saved successfully to Downloads.';

	/// en: 'Share screen opened.'
	String get downloadFallbackShare => 'Share screen opened.';

	/// en: 'An error occurred while downloading the file.'
	String get downloadError => 'An error occurred while downloading the file.';

	/// en: 'Gallery access permission was denied.'
	String get galleryPermissionDenied => 'Gallery access permission was denied.';
}

// Path: features.buildings
class Translations$features$buildings$en {
	Translations$features$buildings$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Manager'
	String get managerPanel => 'Manager';

	/// en: 'Building Detail'
	String get buildingDetail => 'Building Detail';

	/// en: 'Add Building'
	String get addBuilding => 'Add Building';

	/// en: 'Add New Building'
	String get newBuilding => 'Add New Building';

	/// en: 'Invite Code'
	String get inviteCode => 'Invite Code';

	/// en: 'Create Invite Code'
	String get createInviteCode => 'Create Invite Code';

	/// en: 'Cancel Code'
	String get cancelCode => 'Cancel Code';

	/// en: 'Apartment Occupied'
	String get apartmentOccupied => 'Apartment Occupied';

	/// en: 'Copy'
	String get copy => 'Copy';

	/// en: 'Copied'
	String get copyDone => 'Copied';

	/// en: 'Share'
	String get share => 'Share';

	/// en: 'Another Apartment'
	String get anotherApartment => 'Another Apartment';

	/// en: 'Code revoked'
	String get codeRevoked => 'Code revoked';

	/// en: 'If you generate a new code, the old user will be removed. Are you sure?'
	String get occupiedDialog => 'If you generate a new code, the old user will be removed. Are you sure?';

	/// en: 'The current code will become invalid. Are you sure?'
	String get revokeDialog => 'The current code will become invalid. Are you sure?';

	/// en: 'Produce Anyway'
	String get produceAnyway => 'Produce Anyway';

	/// en: 'If you generate a new code, '
	String get newCodePrefix => 'If you generate a new code, ';

	/// en: 'the old user will be removed'
	String get oldUserRemoved => 'the old user will be removed';

	/// en: 'The current code '
	String get currentCodePrefix => 'The current code ';

	/// en: 'will become invalid'
	String get codeInvalid => 'will become invalid';

	/// en: 'Invite Code Ready'
	String get codeReady => 'Invite Code Ready';

	/// en: 'CODE'
	String get code => 'CODE';

	/// en: 'Valid for 7 days'
	String get validFor7Days => 'Valid for 7 days';

	/// en: 'Expires at:'
	String get expiresAt => 'Expires at:';

	/// en: 'Remaining:'
	String get remaining => 'Remaining:';

	/// en: 'While this code is active, you cannot generate a new code for the same apartment. You must revoke the current code first.'
	String get activeCodeNote => 'While this code is active, you cannot generate a new code for the same apartment. You must revoke the current code first.';

	/// en: 'Back to Main Menu'
	String get backToMainMenu => 'Back to Main Menu';

	/// en: 'Try Again'
	String get tekrarDene => 'Try Again';

	late final Translations$features$buildings$collection$en collection = Translations$features$buildings$collection$en._(_root);
	late final Translations$features$buildings$list$en list = Translations$features$buildings$list$en._(_root);
}

// Path: features.sites
class Translations$features$sites$en {
	Translations$features$sites$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Add New Site'
	String get addSiteTitle => 'Add New Site';

	/// en: 'Create Site'
	String get createSite => 'Create Site';

	/// en: 'Site name'
	String get siteName => 'Site name';

	/// en: 'e.g. Sunny Residence'
	String get siteNameHint => 'e.g. Sunny Residence';

	/// en: 'Site created successfully'
	String get siteCreated => 'Site created successfully';

	/// en: 'Could not add site'
	String get siteCreateFailed => 'Could not add site';

	/// en: 'My Sites'
	String get mySites => 'My Sites';

	/// en: 'Search by site name or address'
	String get searchSites => 'Search by site name or address';

	/// en: 'Sites'
	String get tabSites => 'Sites';

	/// en: 'Buildings'
	String get tabBuildings => 'Buildings';

	/// en: '{count} site'
	String get siteCount => '{count} site';

	/// en: '{count} building'
	String get buildingCount => '{count} building';

	/// en: 'No sites added yet'
	String get emptySites => 'No sites added yet';

	/// en: 'New Site'
	String get newSite => 'New Site';

	/// en: 'New Building'
	String get newBuilding => 'New Building';

	/// en: 'Site Details'
	String get siteDetailTitle => 'Site Details';

	/// en: 'Add Block'
	String get addBlock => 'Add Block';

	/// en: 'Add Block to Site'
	String get addBlockTitle => 'Add Block to Site';

	/// en: 'Create Block'
	String get createBlock => 'Create Block';

	/// en: 'Block added successfully'
	String get blockCreated => 'Block added successfully';

	/// en: 'Block details'
	String get blockSection => 'Block details';

	/// en: 'Block label'
	String get blockLabel => 'Block label';

	/// en: 'e.g. Block A'
	String get blockLabelHint => 'e.g. Block A';

	/// en: 'Building name (optional)'
	String get blockNameOptional => 'Building name (optional)';

	/// en: 'Uses block label if left empty'
	String get blockNameHint => 'Uses block label if left empty';

	/// en: 'Extra address'
	String get addressExtra => 'Extra address';

	/// en: 'e.g. Rear entrance, Gate 2'
	String get addressExtraHint => 'e.g. Rear entrance, Gate 2';

	/// en: 'Override site default due amount'
	String get overrideDue => 'Override site default due amount';

	/// en: 'When off, site due applies'
	String get overrideDueHint => 'When off, site due applies';

	/// en: 'Override site default recipient details'
	String get overrideCollection => 'Override site default recipient details';

	/// en: 'When off, site recipient details apply'
	String get overrideCollectionHint => 'When off, site recipient details apply';

	/// en: 'Blocks'
	String get blocksTitle => 'Blocks';

	/// en: 'No blocks added yet'
	String get noBlocks => 'No blocks added yet';

	/// en: '{count} units'
	String get blockApartments => '{count} units';

	/// en: 'Blocks'
	String get blockCount => 'Blocks';

	/// en: 'Units'
	String get apartmentCount => 'Units';

	/// en: 'Collected'
	String get collectedAmount => 'Collected';

	/// en: 'Expected'
	String get expectedAmount => 'Expected';

	/// en: 'Collection'
	String get collectionRate => 'Collection';

	/// en: '{collected} / {expected}'
	String get collectedExpected => '{collected} / {expected}';

	/// en: 'Common Expenses'
	String get commonExpenses => 'Common Expenses';

	/// en: 'Report'
	String get report => 'Report';

	/// en: 'Site report'
	String get reportSheetTitle => 'Site report';

	/// en: 'Monthly report (PDF)'
	String get monthlyReport => 'Monthly report (PDF)';

	/// en: 'Annual report (PDF)'
	String get annualReport => 'Annual report (PDF)';

	/// en: 'Site Common Expenses'
	String get siteExpensesTitle => 'Site Common Expenses';

	/// en: 'Add Common Expense'
	String get addExpenseTitle => 'Add Common Expense';

	/// en: 'Edit Expense'
	String get editExpenseTitle => 'Edit Expense';

	/// en: 'Add Expense'
	String get addExpense => 'Add Expense';

	/// en: 'Site expense added'
	String get expenseCreated => 'Site expense added';

	/// en: 'Site expense updated'
	String get expenseUpdated => 'Site expense updated';

	/// en: 'Confirmation required'
	String get confirmExpenseTitle => 'Confirmation required';

	/// en: 'Delete expense?'
	String get deleteExpenseTitle => 'Delete expense?';

	/// en: 'This site expense will be permanently deleted.'
	String get deleteExpenseConfirm => 'This site expense will be permanently deleted.';

	/// en: 'Site expense deleted'
	String get deleteExpenseSuccess => 'Site expense deleted';

	/// en: 'No expenses'
	String get noExpenses => 'No expenses';

	/// en: 'No common expenses for this month.'
	String get noExpensesHint => 'No common expenses for this month.';

	/// en: 'Total: {amount}'
	String get totalExpenses => 'Total: {amount}';

	/// en: 'Per unit: {amount}'
	String get perUnitShare => 'Per unit: {amount}';
}

// Path: features.auth
class Translations$features$auth$en {
	Translations$features$auth$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Register'
	String get register => 'Register';

	/// en: 'Login'
	String get login => 'Login';

	/// en: 'Join'
	String get join => 'Join';

	/// en: 'Password required'
	String get passwordRequired => 'Password required';

	/// en: 'An error occurred'
	String get errorOccurred => 'An error occurred';

	/// en: 'Account created successfully.'
	String get registrationSuccess => 'Account created successfully.';

	/// en: 'Welcome!'
	String get loginSuccess => 'Welcome!';

	/// en: 'Welcome, {name}!'
	String get loginSuccessNamed => 'Welcome, {name}!';

	/// en: 'Welcome back!'
	String get loginSuccessWelcomeBack => 'Welcome back!';

	/// en: 'Welcome back, {name}!'
	String get loginSuccessWelcomeBackNamed => 'Welcome back, {name}!';

	/// en: 'AidatPanel'
	String get appTitle => 'AidatPanel';

	/// en: 'Apartment Management System'
	String get appSubtitle => 'Apartment Management System';

	/// en: 'Could not connect to server'
	String get splashConnectionError => 'Could not connect to server';

	/// en: 'Check your connection and try again.'
	String get splashConnectionHint => 'Check your connection and try again.';

	/// en: 'Go to login'
	String get skipToLogin => 'Go to login';

	/// en: 'Phone'
	String get phone => 'Phone';

	/// en: 'Email'
	String get email => 'Email';

	/// en: '5XX XXX XX XX'
	String get phoneHint => '5XX XXX XX XX';

	/// en: 'example@email.com'
	String get emailHint => 'example@email.com';

	/// en: 'Password'
	String get password => 'Password';

	/// en: '••••••••'
	String get passwordHint => '••••••••';

	/// en: 'Login with Email'
	String get emailLogin => 'Login with Email';

	/// en: 'Login with Phone'
	String get phoneLogin => 'Login with Phone';

	/// en: 'or'
	String get or => 'or';

	/// en: 'Don't have an account? Register'
	String get noAccount => 'Don\'t have an account? Register';

	/// en: 'Join with Invite Code'
	String get joinWithCode => 'Join with Invite Code';

	/// en: 'Sign up'
	String get signUp => 'Sign up';

	/// en: 'Sign Up'
	String get signUpTitle => 'Sign Up';

	/// en: 'How would you like to join?'
	String get signUpSubtitle => 'How would you like to join?';

	/// en: 'Become a manager'
	String get beManager => 'Become a manager';

	/// en: 'Create a building and open a manager account'
	String get beManagerHint => 'Create a building and open a manager account';

	/// en: 'Join with invite code'
	String get joinWithInvite => 'Join with invite code';

	/// en: 'Join as a resident with your manager's code'
	String get joinWithInviteHint => 'Join as a resident with your manager\'s code';

	/// en: '© Vefa Yazılım'
	String get copyright => '© Vefa Yazılım';

	/// en: 'Create New Account'
	String get createAccount => 'Create New Account';

	/// en: 'Full Name'
	String get name => 'Full Name';

	/// en: 'Ex: Furkan Kaya'
	String get nameHint => 'Ex: Furkan Kaya';

	/// en: 'Phone (Optional)'
	String get phoneOptional => 'Phone (Optional)';

	/// en: '5XX XXX XXXX'
	String get phoneHintOptional => '5XX XXX XXXX';

	/// en: 'At least 6 characters'
	String get minLength => 'At least 6 characters';

	/// en: 'At least 1 uppercase letter'
	String get hasUpperCase => 'At least 1 uppercase letter';

	/// en: 'At least 1 lowercase letter'
	String get hasLowerCase => 'At least 1 lowercase letter';

	/// en: 'At least 1 number'
	String get hasNumber => 'At least 1 number';

	/// en: 'At least 1 special character'
	String get hasSpecialChar => 'At least 1 special character';

	/// en: 'Confirm Password'
	String get confirmPassword => 'Confirm Password';

	/// en: 'Passwords do not match'
	String get passwordsDoNotMatch => 'Passwords do not match';

	/// en: 'Email and password cannot be empty'
	String get emailAndPasswordRequired => 'Email and password cannot be empty';

	/// en: 'Already have an account? Login'
	String get hasAccount => 'Already have an account? Login';

	/// en: 'Join Apartment'
	String get joinApartment => 'Join Apartment';

	/// en: 'Invite Code'
	String get inviteCode => 'Invite Code';

	/// en: 'AP3-B12-A9F0'
	String get inviteCodeHint => 'AP3-B12-A9F0';

	/// en: 'Invalid invite code format (Ex: AP3-B12-A9F0)'
	String get invalidInviteCodeFormat => 'Invalid invite code format (Ex: AP3-B12-A9F0)';

	/// en: 'Enter a valid phone number (5XX XXX XX XX)'
	String get invalidPhoneFormat => 'Enter a valid phone number (5XX XXX XX XX)';

	/// en: 'Invite code, name and password cannot be empty'
	String get inviteCodeAndPasswordRequired => 'Invite code, name and password cannot be empty';

	/// en: 'Enter a valid phone number'
	String get invalidPhoneNumber => 'Enter a valid phone number';

	/// en: 'Are you a manager? Register'
	String get areYouManager => 'Are you a manager? Register';

	late final Translations$features$auth$onboarding$en onboarding = Translations$features$auth$onboarding$en._(_root);
}

// Path: features.apartments
class Translations$features$apartments$en {
	Translations$features$apartments$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Resident'
	String get residentPanel => 'Resident';
}

// Path: features.tickets
class Translations$features$tickets$en {
	Translations$features$tickets$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'My requests'
	String get myTickets => 'My requests';

	/// en: 'New request'
	String get newTicket => 'New request';

	/// en: 'Create request'
	String get createTitle => 'Create request';

	/// en: 'New request'
	String get reportFaultTitle => 'New request';

	/// en: 'My requests'
	String get myApplicationsTitle => 'My requests';

	/// en: 'Subject'
	String get fieldTitle => 'Subject';

	/// en: 'Enter a short summary.'
	String get fieldTitleHint => 'Enter a short summary.';

	/// en: 'Details'
	String get fieldDetail => 'Details';

	/// en: 'Briefly describe the issue.'
	String get fieldDetailHint => 'Briefly describe the issue.';

	/// en: 'Description'
	String get fieldDescription => 'Description';

	/// en: 'Write a detailed explanation…'
	String get fieldDescriptionHint => 'Write a detailed explanation…';

	/// en: 'Add photo, video or document… PNG, JPG — max 5 MB.'
	String get attachmentHint => 'Add photo, video or document… PNG, JPG — max 5 MB.';

	/// en: 'File attachments coming soon.'
	String get attachmentComingSoon => 'File attachments coming soon.';

	/// en: 'Could not select the image. Try again.'
	String get attachmentPickFailed => 'Could not select the image. Try again.';

	/// en: 'Category'
	String get fieldCategory => 'Category';

	/// en: 'Complaint'
	String get categoryComplaint => 'Complaint';

	/// en: 'Request'
	String get categoryRequest => 'Request';

	/// en: 'Malfunction'
	String get categoryMalfunction => 'Malfunction';

	/// en: 'Other'
	String get categoryOther => 'Other';

	/// en: 'Submit'
	String get submit => 'Submit';

	/// en: 'Your request has been submitted'
	String get createSuccess => 'Your request has been submitted';

	/// en: 'Could not save your request. Try again.'
	String get createFailed => 'Could not save your request. Try again.';

	/// en: 'The request service is not available right now. Try again later.'
	String get createServiceUnavailable => 'The request service is not available right now. Try again later.';

	/// en: 'No requests yet'
	String get emptyTitle => 'No requests yet';

	/// en: 'You can create your request here'
	String get emptySubtitle => 'You can create your request here';

	/// en: 'You have no requests yet'
	String get residentEmptyTitle => 'You have no requests yet';

	/// en: 'Create a request here to reach your building manager.'
	String get residentEmptySubtitle => 'Create a request here to reach your building manager.';

	/// en: 'You have no buildings yet'
	String get managerNoBuildingsTitle => 'You have no buildings yet';

	/// en: 'Add a building first to see requests.'
	String get managerNoBuildingsSubtitle => 'Add a building first to see requests.';

	/// en: 'Select a building'
	String get managerSelectBuildingTitle => 'Select a building';

	/// en: 'Choose a building to view its requests.'
	String get managerSelectBuildingSubtitle => 'Choose a building to view its requests.';

	/// en: 'No requests match these criteria'
	String get managerNoMatchingTicketsTitle => 'No requests match these criteria';

	/// en: 'Try changing filters or selecting another building.'
	String get managerNoMatchingTicketsSubtitle => 'Try changing filters or selecting another building.';

	/// en: 'Title must be at least 3 characters'
	String get titleTooShort => 'Title must be at least 3 characters';

	/// en: 'Description must be at least 10 characters'
	String get descriptionTooShort => 'Description must be at least 10 characters';

	/// en: 'Open'
	String get statusOpen => 'Open';

	/// en: 'Approved'
	String get statusInProgress => 'Approved';

	/// en: 'Done'
	String get statusResolved => 'Done';

	/// en: 'Rejected'
	String get statusClosed => 'Rejected';

	/// en: 'REQUEST STATUS'
	String get statusTrackerTitle => 'REQUEST STATUS';

	/// en: 'Awaiting review'
	String get statusStepWaiting => 'Awaiting review';

	/// en: 'Approved'
	String get statusStepInProgress => 'Approved';

	/// en: 'Done'
	String get statusStepResolved => 'Done';

	/// en: 'Rejected'
	String get statusStepClosed => 'Rejected';

	/// en: 'Your request is waiting'
	String get statusHeadlineOpen => 'Your request is waiting';

	/// en: 'Your request was approved'
	String get statusHeadlineInProgress => 'Your request was approved';

	/// en: 'Your request is done'
	String get statusHeadlineResolved => 'Your request is done';

	/// en: 'Your request was rejected'
	String get statusHeadlineClosed => 'Your request was rejected';

	/// en: 'Request details'
	String get detailTitle => 'Request details';

	/// en: 'Building requests'
	String get managerTitle => 'Building requests';

	/// en: 'Status'
	String get statusLabel => 'Status';

	/// en: 'Updates'
	String get updatesTitle => 'Updates';

	/// en: 'Change status'
	String get changeStatus => 'Change status';

	/// en: 'Manager note'
	String get managerNote => 'Manager note';

	/// en: 'Add note'
	String get addNote => 'Add note';

	/// en: 'Status updated'
	String get statusUpdated => 'Status updated';

	/// en: 'Note added'
	String get noteAdded => 'Note added';

	/// en: 'Undo'
	String get undo => 'Undo';

	/// en: 'Approve'
	String get actionApprove => 'Approve';

	/// en: 'Reject'
	String get actionReject => 'Reject';

	/// en: 'Mark as done'
	String get actionMarkDone => 'Mark as done';

	/// en: 'Could not load requests'
	String get loadError => 'Could not load requests';

	/// en: 'Cannot add notes to a rejected or completed request'
	String get noteDisabledClosed => 'Cannot add notes to a rejected or completed request';

	/// en: 'This request was rejected; status cannot be changed.'
	String get statusClosedHint => 'This request was rejected; status cannot be changed.';

	/// en: 'Apartment not linked. Sign in again.'
	String get apartmentRequired => 'Apartment not linked. Sign in again.';

	/// en: 'Manager update'
	String get managerUpdateLabel => 'Manager update';

	/// en: 'Your update'
	String get residentUpdateLabel => 'Your update';

	/// en: 'Update from management'
	String get managerUpdateForResident => 'Update from management';

	/// en: 'Quick reply templates'
	String get quickReplyTemplatesTitle => 'Quick reply templates';

	/// en: 'Confirm'
	String get confirmChanges => 'Confirm';

	/// en: 'Resident details'
	String get residentInfoTitle => 'Resident details';

	/// en: 'Resident'
	String get defaultResidentName => 'Resident';

	/// en: 'Apt {number}'
	String get apartmentNumberTag => 'Apt {number}';

	/// en: 'No apartment info'
	String get apartmentInfoMissing => 'No apartment info';

	/// en: 'Manager note (optional)'
	String get managerNoteOptional => 'Manager note (optional)';

	/// en: 'Team dispatched'
	String get templateTeamDispatched => 'Team dispatched';

	/// en: 'Issue inspected on site; technical team dispatched.'
	String get templateTeamDispatchedText => 'Issue inspected on site; technical team dispatched.';

	/// en: 'Waiting for parts'
	String get templateWaitingPart => 'Waiting for parts';

	/// en: 'Required materials ordered; waiting for delivery.'
	String get templateWaitingPartText => 'Required materials ordered; waiting for delivery.';

	/// en: 'Appointment set'
	String get templateAppointmentSet => 'Appointment set';

	/// en: 'Spoke with resident; appointment scheduled.'
	String get templateAppointmentSetText => 'Spoke with resident; appointment scheduled.';

	/// en: 'Resolved / verified'
	String get templateResolvedCheck => 'Resolved / verified';

	/// en: 'Issue fixed; verification completed.'
	String get templateResolvedCheckText => 'Issue fixed; verification completed.';
}

// Path: features.dekont
class Translations$features$dekont$en {
	Translations$features$dekont$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Make Payment'
	String get makePaymentTitle => 'Make Payment';

	/// en: 'Pay debt'
	String get payDebtTitle => 'Pay debt';

	/// en: 'Payment method'
	String get paymentMethodTitle => 'Payment method';

	/// en: 'Credit / debit card'
	String get paymentMethodCard => 'Credit / debit card';

	/// en: 'Bank transfer'
	String get paymentMethodEft => 'Bank transfer';

	/// en: 'Upload receipt'
	String get paymentMethodDekont => 'Upload receipt';

	/// en: 'Card payments coming soon.'
	String get paymentCardComingSoon => 'Card payments coming soon.';

	/// en: 'Upload receipt (jpg, png, webp, PDF — max 5 MB).'
	String get uploadReceiptHint => 'Upload receipt (jpg, png, webp, PDF — max 5 MB).';

	/// en: 'My Receipts'
	String get myDekontsTitle => 'My Receipts';

	/// en: 'Receipt Review'
	String get managerTitle => 'Receipt Review';

	/// en: 'Review receipt'
	String get reviewAction => 'Review receipt';

	/// en: 'Receipt Detail'
	String get detailTitle => 'Receipt Detail';

	/// en: 'Transfer details'
	String get paymentInfoTitle => 'Transfer details';

	/// en: 'Your manager has not set up collection IBAN yet. You can still upload a receipt.'
	String get collectionNotConfigured => 'Your manager has not set up collection IBAN yet. You can still upload a receipt.';

	/// en: 'IBAN'
	String get ibanLabel => 'IBAN';

	/// en: 'Recipient name'
	String get accountTitleLabel => 'Recipient name';

	/// en: 'Transfer reference'
	String get referenceLabel => 'Transfer reference';

	/// en: 'Copy'
	String get copy => 'Copy';

	/// en: 'Copied to clipboard'
	String get copied => 'Copied to clipboard';

	/// en: 'Select dues'
	String get selectDue => 'Select dues';

	/// en: 'Select the dues you paid (you can select more than one)'
	String get selectDueHint => 'Select the dues you paid (you can select more than one)';

	/// en: 'Selected total: {amount}'
	String get selectedTotal => 'Selected total: {amount}';

	/// en: 'Recipient details'
	String get recipientSection => 'Recipient details';

	/// en: 'No pending dues'
	String get noPendingDues => 'No pending dues';

	/// en: 'Upload receipt'
	String get uploadSectionTitle => 'Upload receipt';

	/// en: 'PDF document or photo (JPEG, PNG) (Max 10 MB)'
	String get uploadHint => 'PDF document or photo (JPEG, PNG) (Max 10 MB)';

	/// en: 'Choose file'
	String get pickFile => 'Choose file';

	/// en: 'Upload receipt'
	String get upload => 'Upload receipt';

	/// en: 'Receipt uploaded'
	String get uploadSuccess => 'Receipt uploaded';

	/// en: 'This receipt was already on file; your existing record was opened.'
	String get uploadRecoveredExisting => 'This receipt was already on file; your existing record was opened.';

	/// en: 'Upload failed'
	String get uploadFailed => 'Upload failed';

	/// en: 'You have already uploaded this receipt. Check My Receipts.'
	String get errorUploadDuplicate => 'You have already uploaded this receipt. Check My Receipts.';

	/// en: 'You uploaded too many receipts in a short time. Please wait.'
	String get errorUploadRateLimit => 'You uploaded too many receipts in a short time. Please wait.';

	/// en: 'Receipt could not be saved on the server. Try again later.'
	String get errorUploadServer => 'Receipt could not be saved on the server. Try again later.';

	/// en: 'Please select a file.'
	String get errorUploadFileRequired => 'Please select a file.';

	/// en: 'Payment details could not be loaded. Try again.'
	String get errorPaymentInfo => 'Payment details could not be loaded. Try again.';

	/// en: 'Receipt list could not be loaded. Try again.'
	String get errorListLoad => 'Receipt list could not be loaded. Try again.';

	/// en: 'Receipt details could not be loaded. Try again.'
	String get errorDetailLoad => 'Receipt details could not be loaded. Try again.';

	/// en: 'Receipt file could not be opened. Try again.'
	String get errorFileDownload => 'Receipt file could not be opened. Try again.';

	/// en: 'Payment for this receipt has already been processed.'
	String get errorReviewPaymentDone => 'Payment for this receipt has already been processed.';

	/// en: 'A rejected receipt cannot be approved again.'
	String get errorReviewRejected => 'A rejected receipt cannot be approved again.';

	/// en: 'Select a due to approve.'
	String get errorReviewNeedDue => 'Select a due to approve.';

	/// en: 'Receipt amount could not be read. Enter the amount to approve.'
	String get errorReviewNeedAmount => 'Receipt amount could not be read. Enter the amount to approve.';

	/// en: 'Amount to approve (₺)'
	String get reviewAmountLabel => 'Amount to approve (₺)';

	/// en: 'No amount was read from this receipt. Enter the amount manually — do not approve without an amount or the remaining balance will not be applied correctly.'
	String get reviewAmountRequiredHint => 'No amount was read from this receipt. Enter the amount manually — do not approve without an amount or the remaining balance will not be applied correctly.';

	/// en: 'Amount to apply: {amount}'
	String get reviewApplyAmount => 'Amount to apply: {amount}';

	/// en: 'Remaining after approval: {amount}'
	String get reviewRemainingAmount => 'Remaining after approval: {amount}';

	/// en: 'This receipt cannot be approved or rejected right now. Try again later.'
	String get errorReviewStatus => 'This receipt cannot be approved or rejected right now. Try again later.';

	/// en: 'Please select a receipt file first.'
	String get errorNoFileSelected => 'Please select a receipt file first.';

	/// en: 'Please select at least one due.'
	String get errorNoDueSelected => 'Please select at least one due.';

	/// en: 'File must be 10 MB or smaller'
	String get fileTooLarge => 'File must be 10 MB or smaller';

	/// en: 'The selected file is empty'
	String get fileEmpty => 'The selected file is empty';

	/// en: 'File not found'
	String get fileNotFound => 'File not found';

	/// en: 'Only PDF, JPEG, or PNG files are allowed'
	String get invalidExtension => 'Only PDF, JPEG, or PNG files are allowed';

	/// en: 'Processing receipt…'
	String get processing => 'Processing receipt…';

	/// en: 'My receipts'
	String get viewDekonts => 'My receipts';

	/// en: 'Details'
	String get breakdownDetails => 'Details';

	/// en: 'Monthly due'
	String get breakdownBaseDue => 'Monthly due';

	/// en: 'Total'
	String get breakdownTotal => 'Total';

	/// en: 'No receipts yet'
	String get emptyTitle => 'No receipts yet';

	/// en: 'You don't have any receipts yet. You can use the upload button on the top right to add a new receipt.'
	String get emptySubtitleResident => 'You don\'t have any receipts yet. You can use the upload button on the top right to add a new receipt.';

	/// en: 'There are no receipts uploaded by users.'
	String get emptySubtitleManager => 'There are no receipts uploaded by users.';

	/// en: 'All'
	String get filterAll => 'All';

	/// en: 'Under review'
	String get filterPending => 'Under review';

	/// en: 'Approved'
	String get filterApproved => 'Approved';

	/// en: 'Rejected'
	String get filterRejected => 'Rejected';

	late final Translations$features$dekont$resident$en resident = Translations$features$dekont$resident$en._(_root);
	late final Translations$features$dekont$manager$en manager = Translations$features$dekont$manager$en._(_root);

	/// en: 'Received'
	String get statusReceived => 'Received';

	/// en: 'Reading'
	String get statusExtracting => 'Reading';

	/// en: 'Read failed'
	String get statusExtractFailed => 'Read failed';

	/// en: 'Parsed'
	String get statusParsed => 'Parsed';

	/// en: 'Low confidence'
	String get statusParseLowConfidence => 'Low confidence';

	/// en: 'Matching'
	String get statusMatching => 'Matching';

	/// en: 'Matched'
	String get statusMatched => 'Matched';

	/// en: 'Ambiguous match'
	String get statusMatchAmbiguous => 'Ambiguous match';

	/// en: 'Unmatched'
	String get statusUnmatched => 'Unmatched';

	/// en: 'Payment applied'
	String get statusPaymentApplied => 'Payment applied';

	/// en: 'Partial payment'
	String get statusPaymentPartial => 'Partial payment';

	/// en: 'Rejected'
	String get statusRejected => 'Rejected';

	/// en: 'Recipient mismatch'
	String get statusRecipientMismatch => 'Recipient mismatch';

	/// en: 'Manager review'
	String get statusNeedsManagerReview => 'Manager review';

	/// en: 'Upload again'
	String get reupload => 'Upload again';

	/// en: 'Rejection reason'
	String get rejectionReason => 'Rejection reason';

	/// en: 'Parsed amount'
	String get parsedAmount => 'Parsed amount';

	/// en: 'Payment details'
	String get paymentDetailsSection => 'Payment details';

	/// en: 'File'
	String get fileSection => 'File';

	/// en: 'File preview'
	String get filePreview => 'File preview';

	/// en: 'Pinch to zoom and scroll to view pages.'
	String get pdfPreviewHint => 'Pinch to zoom and scroll to view pages.';

	/// en: 'PDF could not be opened on this device. Use «Share file» below to open it in another app.'
	String get pdfPreviewUnavailable => 'PDF could not be opened on this device. Use «Share file» below to open it in another app.';

	/// en: 'Share file'
	String get shareFile => 'Share file';

	/// en: 'Approve'
	String get approve => 'Approve';

	/// en: 'Reject'
	String get reject => 'Reject';

	/// en: 'Note (optional)'
	String get reviewNote => 'Note (optional)';

	/// en: 'Review saved'
	String get reviewSuccess => 'Review saved';

	/// en: 'Review failed'
	String get reviewFailed => 'Review failed';

	/// en: 'Select due to approve'
	String get selectDueForApprove => 'Select due to approve';

	/// en: 'Uploaded by'
	String get uploadedBy => 'Uploaded by';

	/// en: 'Apartment'
	String get apartment => 'Apartment';

	/// en: 'Amount'
	String get amount => 'Amount';

	/// en: 'Could not load receipts'
	String get loadError => 'Could not load receipts';

	/// en: 'System information'
	String get systemInfoTitle => 'System information';

	/// en: 'Below is what we read from your receipt. Payment is not approved automatically; your manager will verify the bank account and approve.'
	String get systemInfoSubtitle => 'Below is what we read from your receipt. Payment is not approved automatically; your manager will verify the bank account and approve.';

	/// en: 'Read from receipt'
	String get systemReadLabel => 'Read from receipt';

	/// en: 'Your receipt is being processed. Amount, date and bank details will appear here shortly.'
	String get systemInfoProcessing => 'Your receipt is being processed. Amount, date and bank details will appear here shortly.';

	/// en: 'Read data'
	String get systemInfoNoData => 'Read data';

	/// en: 'Amount or date could not be read yet. It will still be sent for manager approval.'
	String get systemInfoNoDataHint => 'Amount or date could not be read yet. It will still be sent for manager approval.';

	/// en: 'Transaction date'
	String get transactionDateLabel => 'Transaction date';

	/// en: 'Bank'
	String get bankLabel => 'Bank';

	/// en: 'Recipient IBAN'
	String get receiverIbanLabel => 'Recipient IBAN';

	/// en: 'Recipient name'
	String get receiverNameLabel => 'Recipient name';

	/// en: 'Reference no.'
	String get referenceNumberLabel => 'Reference no.';

	/// en: 'The recipient IBAN could not be read from your dues payment receipt. It will be submitted for manager approval as is.'
	String get ibanUnreadableNotice => 'The recipient IBAN could not be read from your dues payment receipt. It will be submitted for manager approval as is.';

	/// en: 'The recipient IBAN on the receipt does not match your building's collection account. Your manager will verify the account and decide.'
	String get ibanMismatchNotice => 'The recipient IBAN on the receipt does not match your building\'s collection account. Your manager will verify the account and decide.';

	/// en: 'The recipient IBAN matches your building's collection account. Payment still requires manager approval.'
	String get ibanVerifiedNotice => 'The recipient IBAN matches your building\'s collection account. Payment still requires manager approval.';

	/// en: 'Your receipt has been submitted for manager approval. Payment is not approved automatically; your manager will verify the account.'
	String get residentPendingReviewNotice => 'Your receipt has been submitted for manager approval. Payment is not approved automatically; your manager will verify the account.';

	/// en: 'Check the amount in your account, then approve. The amount is applied to the resident's selected dues oldest-first; a shortfall leaves remaining balance open.'
	String get managerApprovalHint => 'Check the amount in your account, then approve. The amount is applied to the resident\'s selected dues oldest-first; a shortfall leaves remaining balance open.';

	/// en: 'Dues selected by resident'
	String get residentSelectedDues => 'Dues selected by resident';

	/// en: 'The resident marked these periods when uploading. On approval the amount is applied to these dues.'
	String get residentSelectedDuesHint => 'The resident marked these periods when uploading. On approval the amount is applied to these dues.';

	/// en: '{resident} sent {amount} in dues on {date} via {bank}. Please check your account and approve.'
	String get managerPaymentSummary => '{resident} sent {amount} in dues on {date} via {bank}. Please check your account and approve.';

	/// en: '{name} (Apt. {apartment})'
	String get residentWithApartment => '{name} (Apt. {apartment})';

	/// en: 'Apt. {apartment}'
	String get apartmentOnly => 'Apt. {apartment}';

	/// en: 'Resident'
	String get residentUnknown => 'Resident';

	/// en: 'the stated amount'
	String get amountUnknown => 'the stated amount';

	/// en: 'Receipt image'
	String get receiptPhotoTitle => 'Receipt image';

	/// en: 'Review the system information above first. Open the receipt file whenever you need to.'
	String get receiptPhotoHint => 'Review the system information above first. Open the receipt file whenever you need to.';

	/// en: 'View receipt'
	String get viewDekont => 'View receipt';

	/// en: 'Kuveyt Türk'
	String get bankKuveytTurk => 'Kuveyt Türk';

	/// en: 'Ziraat Bankası'
	String get bankZiraat => 'Ziraat Bankası';

	/// en: 'İş Bankası'
	String get bankIsbank => 'İş Bankası';

	/// en: 'Garanti BBVA'
	String get bankGaranti => 'Garanti BBVA';

	/// en: 'Halkbank'
	String get bankHalkbank => 'Halkbank';

	/// en: 'VakıfBank'
	String get bankVakifbank => 'VakıfBank';

	/// en: 'Yapı Kredi'
	String get bankYapiKredi => 'Yapı Kredi';

	/// en: 'Akbank'
	String get bankAkbank => 'Akbank';

	/// en: 'QNB Finansbank'
	String get bankQnb => 'QNB Finansbank';

	/// en: 'Bank (generic)'
	String get bankGeneric => 'Bank (generic)';

	/// en: 'Bank could not be read'
	String get bankUnknown => 'Bank could not be read';
}

// Path: features.expenses
class Translations$features$expenses$en {
	Translations$features$expenses$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Expenses'
	String get title => 'Expenses';

	/// en: 'Add expense'
	String get createTitle => 'Add expense';

	/// en: 'Title'
	String get fieldTitle => 'Title';

	/// en: 'Amount'
	String get fieldAmount => 'Amount';

	/// en: 'Category'
	String get fieldCategory => 'Category';

	/// en: 'Note (optional)'
	String get fieldNote => 'Note (optional)';

	/// en: 'Save'
	String get submit => 'Save';

	/// en: 'Required field'
	String get required => 'Required field';

	/// en: 'Enter a valid amount'
	String get amountInvalid => 'Enter a valid amount';

	/// en: 'Amount is read automatically from the receipt or bank statement.'
	String get amountFromReceiptsHint => 'Amount is read automatically from the receipt or bank statement.';

	/// en: 'Add at least one receipt or bank statement (PDF/photo)'
	String get receiptRequired => 'Add at least one receipt or bank statement (PDF/photo)';

	/// en: 'Reading receipt/statement amounts. They will appear in the list shortly.'
	String get amountOcrPending => 'Reading receipt/statement amounts. They will appear in the list shortly.';

	/// en: 'Reading amount…'
	String get amountPending => 'Reading amount…';

	/// en: 'Total'
	String get total => 'Total';

	/// en: 'Expense saved'
	String get createSuccess => 'Expense saved';

	/// en: 'Cleaning'
	String get categoryCleaning => 'Cleaning';

	/// en: 'Elevator'
	String get categoryElevator => 'Elevator';

	/// en: 'Electricity'
	String get categoryElectricity => 'Electricity';

	/// en: 'Water'
	String get categoryWater => 'Water';

	/// en: 'Insurance'
	String get categoryInsurance => 'Insurance';

	/// en: 'Repair'
	String get categoryRepair => 'Repair';

	/// en: 'Garden'
	String get categoryGarden => 'Garden';

	/// en: 'Other'
	String get categoryOther => 'Other';

	/// en: 'Expense date'
	String get fieldDate => 'Expense date';

	/// en: 'Date on the receipt or invoice'
	String get fieldDateHint => 'Date on the receipt or invoice';

	/// en: 'Month'
	String get fieldMonth => 'Month';

	/// en: 'Year'
	String get fieldYear => 'Year';

	/// en: 'Edit expense'
	String get editTitle => 'Edit expense';

	/// en: 'Edit'
	String get editAction => 'Edit';

	/// en: 'Delete expense'
	String get deleteTitle => 'Delete expense';

	/// en: 'Delete'
	String get deleteAction => 'Delete';

	/// en: 'Are you sure you want to delete this expense?'
	String get deleteConfirm => 'Are you sure you want to delete this expense?';

	/// en: 'Expense deleted'
	String get deleteSuccess => 'Expense deleted';

	/// en: 'Expense updated'
	String get updateSuccess => 'Expense updated';

	/// en: 'Could not load expenses'
	String get loadError => 'Could not load expenses';

	/// en: 'No expenses this period'
	String get emptyTitle => 'No expenses this period';

	/// en: 'Add a new expense from the top-right button'
	String get emptySubtitle => 'Add a new expense from the top-right button';

	/// en: 'Building Expenses'
	String get residentTitle => 'Building Expenses';

	/// en: 'Your manager has not added expenses for this period yet'
	String get residentEmptySubtitle => 'Your manager has not added expenses for this period yet';

	/// en: 'Building Expenses'
	String get quickActionLabel => 'Building Expenses';

	/// en: 'Receipt link (HTTPS)'
	String get receiptUrlLabel => 'Receipt link (HTTPS)';

	/// en: 'Optional — public URL to the receipt file'
	String get receiptUrlHint => 'Optional — public URL to the receipt file';

	/// en: 'URL must start with https://'
	String get receiptUrlInvalid => 'URL must start with https://';

	/// en: 'Receipt / bank statement'
	String get receiptTitle => 'Receipt / bank statement';

	/// en: 'Bank statement (PDF) or receipt photo (JPEG, PNG). Amount is read automatically (Max 10 MB)'
	String get receiptHint => 'Bank statement (PDF) or receipt photo (JPEG, PNG). Amount is read automatically (Max 10 MB)';

	/// en: 'Add file'
	String get receiptAdd => 'Add file';

	/// en: 'Change file'
	String get receiptChange => 'Change file';

	/// en: 'Remove file'
	String get receiptRemove => 'Remove file';

	/// en: 'Receipt will upload later.'
	String get receiptPendingBackend => 'Receipt will upload later.';

	/// en: 'File upload failed. The expense was saved.'
	String get receiptUploadFailed => 'File upload failed. The expense was saved.';

	/// en: 'Could not pick a file'
	String get receiptPickFailed => 'Could not pick a file';

	/// en: 'File stored on server'
	String get receiptStoredOnServer => 'File stored on server';

	/// en: 'Expense Detail'
	String get detailTitle => 'Expense Detail';

	/// en: 'Created at'
	String get fieldCreatedAt => 'Created at';

	/// en: 'View file'
	String get viewReceipt => 'View file';

	/// en: 'No receipt or statement uploaded'
	String get receiptMissing => 'No receipt or statement uploaded';

	/// en: 'Month applied to dues'
	String get targetMonthLabel => 'Month applied to dues';

	/// en: 'This month'
	String get targetThisMonth => 'This month';

	/// en: 'Next month'
	String get targetNextMonth => 'Next month';

	/// en: 'Pick month'
	String get targetSpecificMonth => 'Pick month';

	/// en: 'Applies to {month} {year} dues'
	String get targetPeriodSummary => 'Applies to {month} {year} dues';

	/// en: 'Adding an expense to a past month will update due amounts.'
	String get pastMonthWarning => 'Adding an expense to a past month will update due amounts.';

	/// en: 'Split across months'
	String get splitMonthsEnable => 'Split across months';

	/// en: 'Total is divided equally across selected months'
	String get splitMonthsHint => 'Total is divided equally across selected months';

	/// en: 'Number of months'
	String get splitMonthsCount => 'Number of months';

	/// en: 'months'
	String get splitMonthsUnit => 'months';

	/// en: 'Already paid dues'
	String get carryForwardDialogTitle => 'Already paid dues';

	/// en: 'Add difference to next month'
	String get carryForwardAuto => 'Add difference to next month';

	/// en: 'I'll handle it manually'
	String get carryForwardManual => 'I\'ll handle it manually';
}

// Path: features.notifications
class Translations$features$notifications$en {
	Translations$features$notifications$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Mark all read'
	String get markAllRead => 'Mark all read';

	/// en: 'Mark all as read'
	String get markAllReadLong => 'Mark all as read';

	/// en: 'Open related item'
	String get viewRelated => 'Open related item';

	/// en: 'New'
	String get unreadBadge => 'New';

	/// en: 'No notifications'
	String get emptyTitle => 'No notifications';

	/// en: 'New notifications will appear here'
	String get emptySubtitle => 'New notifications will appear here';

	/// en: 'No unread notifications'
	String get emptyUnreadTitle => 'No unread notifications';

	/// en: 'You're all caught up'
	String get emptyUnreadSubtitle => 'You\'re all caught up';

	/// en: 'Could not load notifications'
	String get loadError => 'Could not load notifications';

	/// en: 'All'
	String get filterAll => 'All';

	/// en: 'Unread'
	String get filterUnread => 'Unread';

	/// en: 'Read'
	String get filterRead => 'Read';

	/// en: 'No read notifications'
	String get emptyReadTitle => 'No read notifications';

	/// en: 'Notifications you have read will appear here'
	String get emptyReadSubtitle => 'Notifications you have read will appear here';

	/// en: 'Today'
	String get sectionToday => 'Today';

	/// en: 'Yesterday'
	String get sectionYesterday => 'Yesterday';

	/// en: 'This week'
	String get sectionThisWeek => 'This week';

	/// en: 'Earlier'
	String get sectionEarlier => 'Earlier';

	/// en: 'Just now'
	String get timeNow => 'Just now';

	/// en: 'min ago'
	String get timeMinuteShort => 'min ago';

	/// en: 'h ago'
	String get timeHourShort => 'h ago';

	/// en: 'Could not load details'
	String get detailLoadError => 'Could not load details';

	/// en: 'Status'
	String get fieldStatus => 'Status';

	/// en: 'Category'
	String get fieldCategory => 'Category';

	/// en: 'Apartment'
	String get fieldApartment => 'Apartment';

	/// en: 'Amount'
	String get fieldAmount => 'Amount';

	/// en: 'Uploaded by'
	String get fieldUploadedBy => 'Uploaded by';

	/// en: 'Description'
	String get fieldDescription => 'Description';

	/// en: 'Manager note'
	String get fieldManagerNote => 'Manager note';

	/// en: 'Rejection reason'
	String get fieldRejectionReason => 'Rejection reason';

	/// en: 'Latest update'
	String get fieldLatestUpdate => 'Latest update';

	/// en: 'Created'
	String get fieldCreatedAt => 'Created';

	/// en: 'Period'
	String get fieldPeriod => 'Period';

	/// en: 'View request'
	String get actionViewTicket => 'View request';

	/// en: 'Review receipt'
	String get actionViewDekont => 'Review receipt';

	/// en: 'View due'
	String get actionViewDue => 'View due';

	/// en: 'Due reminder'
	String get typeDueReminder => 'Due reminder';

	/// en: 'Due paid'
	String get typeDuePaid => 'Due paid';

	/// en: 'New request'
	String get typeTicketCreated => 'New request';

	/// en: 'Request updated'
	String get typeTicketUpdate => 'Request updated';

	/// en: 'Announcement'
	String get typeAnnouncement => 'Announcement';

	/// en: 'New receipt'
	String get typeDekontReceived => 'New receipt';

	/// en: 'Receipt review'
	String get typeDekontNeedsReview => 'Receipt review';

	/// en: 'Receipt matched'
	String get typeDekontMatched => 'Receipt matched';

	/// en: 'Receipt approved'
	String get typeDekontPaymentApplied => 'Receipt approved';

	/// en: 'New expense'
	String get typeExpenseAdded => 'New expense';

	/// en: 'System'
	String get typeSystem => 'System';

	/// en: 'AidatPanel Team'
	String get typeAidatPanelTeam => 'AidatPanel Team';

	/// en: 'Notification'
	String get typeOther => 'Notification';

	late final Translations$features$notifications$resident$en resident = Translations$features$notifications$resident$en._(_root);

	/// en: 'All apartments'
	String get allApartmentsTag => 'All apartments';

	/// en: 'Announcement to residents'
	String get sendTitle => 'Announcement to residents';

	/// en: 'Title'
	String get fieldTitle => 'Title';

	/// en: 'Message'
	String get fieldBody => 'Message';

	/// en: 'Send'
	String get sendButton => 'Send';

	/// en: 'Announcement sent'
	String get sendSuccess => 'Announcement sent';

	/// en: 'Announcement sent to all buildings'
	String get sendSuccessAll => 'Announcement sent to all buildings';

	/// en: 'Announcement sent to {ok}/{total} buildings'
	String get sendPartialFailed => 'Announcement sent to {ok}/{total} buildings';

	/// en: 'Could not send announcement'
	String get sendFailed => 'Could not send announcement';

	/// en: 'Required field'
	String get fieldRequired => 'Required field';

	late final Translations$features$notifications$permissionPrompt$en permissionPrompt = Translations$features$notifications$permissionPrompt$en._(_root);

	/// en: 'Title must be at most 120 characters'
	String get titleTooLong => 'Title must be at most 120 characters';

	/// en: 'Message must be at most 2000 characters'
	String get bodyTooLong => 'Message must be at most 2000 characters';

	/// en: 'Add a building first'
	String get noBuilding => 'Add a building first';
}

// Path: features.profile
class Translations$features$profile$en {
	Translations$features$profile$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Profile Details'
	String get title => 'Profile Details';

	/// en: 'Full name'
	String get fullName => 'Full name';

	/// en: 'Email'
	String get email => 'Email';

	/// en: 'Phone'
	String get phone => 'Phone';

	/// en: 'Role'
	String get role => 'Role';

	/// en: 'Language preference'
	String get languagePref => 'Language preference';

	/// en: 'Not provided'
	String get notProvided => 'Not provided';

	/// en: 'Profile editing will be available soon.'
	String get editHint => 'Profile editing will be available soon.';

	/// en: 'Personal Information'
	String get sectionPersonal => 'Personal Information';

	/// en: 'Account Information'
	String get sectionAccount => 'Account Information';

	/// en: 'Tap to change photo'
	String get editPhotoHint => 'Tap to change photo';

	/// en: 'Edit Profile'
	String get editTitle => 'Edit Profile';

	/// en: 'Optional'
	String get phoneOptionalHint => 'Optional';

	/// en: 'Phone number is required'
	String get phoneRequired => 'Phone number is required';

	/// en: 'Phone verification'
	String get phoneOtpTitle => 'Phone verification';

	/// en: 'Enter the 6-digit code sent to {phone}.'
	String get phoneOtpMessage => 'Enter the 6-digit code sent to {phone}.';

	/// en: 'Verify and save'
	String get phoneOtpConfirm => 'Verify and save';

	/// en: 'Could not send the verification code. Try again.'
	String get phoneOtpSendFailed => 'Could not send the verification code. Try again.';

	/// en: 'Your profile has been updated.'
	String get profileUpdated => 'Your profile has been updated.';

	/// en: 'Could not update profile. Try again.'
	String get profileUpdateFailed => 'Could not update profile. Try again.';

	/// en: 'Could not load profile.'
	String get profileLoadFailed => 'Could not load profile.';

	/// en: 'Cannot be edited here'
	String get readOnlySection => 'Cannot be edited here';

	/// en: 'At least one contact channel (Email or Phone) must be registered.'
	String get contactRequired => 'At least one contact channel (Email or Phone) must be registered.';

	/// en: 'Security Verification'
	String get securityVerificationTitle => 'Security Verification';

	/// en: 'You must enter your current password to change your email or phone number.'
	String get securityVerificationMessage => 'You must enter your current password to change your email or phone number.';

	/// en: 'You must enter your current password to change your email or phone number.'
	String get securityVerificationMessageManager => 'You must enter your current password to change your email or phone number.';

	/// en: 'Only name and phone can be updated. Other details are shown on the profile screen above.'
	String get editSheetHint => 'Only name and phone can be updated. Other details are shown on the profile screen above.';

	/// en: 'Profile photo saved for this account.'
	String get photoSaved => 'Profile photo saved for this account.';

	/// en: 'Profile photo removed.'
	String get photoRemoved => 'Profile photo removed.';

	/// en: 'Remove profile photo'
	String get removePhoto => 'Remove profile photo';

	/// en: 'Choose photo'
	String get avatarChooseSource => 'Choose photo';

	/// en: 'Camera'
	String get avatarCamera => 'Camera';

	/// en: 'Gallery'
	String get avatarGallery => 'Gallery';

	/// en: 'Save'
	String get avatarSave => 'Save';

	/// en: 'Remove Photo'
	String get avatarRemove => 'Remove Photo';

	/// en: 'Could not load the photo.'
	String get avatarPhotoLoadError => 'Could not load the photo.';

	/// en: 'Could not process the photo.'
	String get avatarPhotoProcessError => 'Could not process the photo.';

	/// en: 'Could not open the camera.'
	String get avatarCameraError => 'Could not open the camera.';

	/// en: 'Could not open the gallery.'
	String get avatarGalleryError => 'Could not open the gallery.';

	/// en: 'Could not decode the image.'
	String get avatarDecodeError => 'Could not decode the image.';

	/// en: 'Could not save the photo.'
	String get avatarSaveError => 'Could not save the photo.';

	/// en: 'Unsupported file type. Please select a JPG, PNG, or GIF.'
	String get avatarUnsupportedFormat => 'Unsupported file type. Please select a JPG, PNG, or GIF.';

	/// en: 'Account created: {date}'
	String get accountCreatedAt => 'Account created: {date}';
}

// Path: features.subscription
class Translations$features$subscription$en {
	Translations$features$subscription$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Subscription'
	String get title => 'Subscription';

	/// en: 'Active'
	String get statusActive => 'Active';

	/// en: 'Expired'
	String get statusExpired => 'Expired';

	/// en: 'Cancelled'
	String get statusCancelled => 'Cancelled';

	/// en: 'Trial'
	String get statusTrial => 'Trial';

	/// en: 'Unknown'
	String get statusUnknown => 'Unknown';

	/// en: 'Monthly plan'
	String get planMonthly => 'Monthly plan';

	/// en: 'Annual plan'
	String get planAnnual => 'Annual plan';

	/// en: 'Plan'
	String get planUnknown => 'Plan';

	/// en: 'Renews: {date}'
	String get renewsOn => 'Renews: {date}';

	/// en: 'No subscription on file yet.'
	String get noSubscription => 'No subscription on file yet.';

	/// en: 'Purchases coming soon.'
	String get backendPending => 'Purchases coming soon.';

	/// en: 'Purchase coming soon'
	String get purchaseComingSoon => 'Purchase coming soon';

	/// en: 'Subscribe monthly'
	String get purchaseMonthly => 'Subscribe monthly';

	/// en: 'Subscribe annually'
	String get purchaseAnnual => 'Subscribe annually';

	/// en: 'Purchase completed successfully.'
	String get purchaseSuccess => 'Purchase completed successfully.';

	/// en: 'Purchase was cancelled.'
	String get purchaseCancelled => 'Purchase was cancelled.';

	/// en: 'Purchases are not enabled in this build yet.'
	String get purchasesUnavailable => 'Purchases are not enabled in this build yet.';

	/// en: 'Could not load subscription.'
	String get loadFailed => 'Could not load subscription.';

	/// en: 'Subscription product not found. Try again later.'
	String get purchaseProductNotFound => 'Subscription product not found. Try again later.';

	/// en: 'Payment is unavailable right now. Try again.'
	String get purchaseStoreError => 'Payment is unavailable right now. Try again.';

	/// en: 'Purchase could not be completed. Try again.'
	String get purchaseFailed => 'Purchase could not be completed. Try again.';

	/// en: 'Choose a plan and subscribe'
	String get sectionSelectPlan => 'Choose a plan and subscribe';

	/// en: 'Renews every month'
	String get cycleMonthly => 'Renews every month';

	/// en: 'Renews every year'
	String get cycleAnnual => 'Renews every year';

	/// en: 'Unlimited units'
	String get featureUnlimitedUnits => 'Unlimited units';

	/// en: 'Managed buildings: {used}'
	String get buildingUsageSummary => 'Managed buildings: {used}';

	/// en: 'Managed buildings: {used} / {limit}'
	String get buildingUsageWithLimit => 'Managed buildings: {used} / {limit}';

	/// en: 'Dues and collections in one place'
	String get featureDuesTracking => 'Dues and collections in one place';

	/// en: 'Instant PDF reports'
	String get featureAdvancedReports => 'Instant PDF reports';

	/// en: 'Priority support line'
	String get featurePrioritySupport => 'Priority support line';

	/// en: 'Trial period active'
	String get trialActive => 'Trial period active';

	/// en: 'Subscription active'
	String get subscriptionActive => 'Subscription active';

	/// en: 'Subscription cancelled'
	String get subscriptionCancelled => 'Subscription cancelled';

	/// en: 'Subscription expired'
	String get subscriptionExpired => 'Subscription expired';

	/// en: 'No active subscription'
	String get noActiveSubscription => 'No active subscription';

	/// en: '{count} days left'
	String get daysLeft => '{count} days left';

	/// en: 'PLAN'
	String get planLabel => 'PLAN';

	/// en: 'STATUS'
	String get statusLabel => 'STATUS';

	/// en: 'RENEWAL'
	String get renewalLabel => 'RENEWAL';

	/// en: 'Annual'
	String get planAnnualShort => 'Annual';

	/// en: 'Monthly'
	String get planMonthlyShort => 'Monthly';

	/// en: 'Excl. VAT / month'
	String get priceExclVatMonth => 'Excl. VAT / month';

	/// en: 'Excl. VAT / year'
	String get priceExclVatYear => 'Excl. VAT / year';

	/// en: 'Save {amount}'
	String get savingBadge => 'Save {amount}';

	/// en: 'Best value'
	String get bestValueBadge => 'Best value';

	/// en: 'Subscribe monthly'
	String get purchaseMonthlyCta => 'Subscribe monthly';

	/// en: 'Subscribe annually'
	String get purchaseAnnualCta => 'Subscribe annually';

	/// en: 'Prices exclude VAT · Cancel anytime'
	String get kdvNote => 'Prices exclude VAT · Cancel anytime';

	/// en: 'User'
	String get guestUser => 'User';

	/// en: '—'
	String get priceUnavailable => '—';

	/// en: 'Loading plans…'
	String get loadingPlans => 'Loading plans…';

	/// en: 'Purchases are not enabled in this build yet.'
	String get purchasesDisabledHint => 'Purchases are not enabled in this build yet.';

	/// en: '1-5 Buildings Plan'
	String get plan1To5 => '1-5 Buildings Plan';

	/// en: '5-20 Buildings Plan'
	String get plan5To20 => '5-20 Buildings Plan';

	/// en: '20-50 Buildings Plan'
	String get plan20To50 => '20-50 Buildings Plan';

	/// en: '50+ Buildings (Custom)'
	String get plan50Plus => '50+ Buildings (Custom)';

	/// en: 'Business'
	String get planBusiness => 'Business';

	/// en: 'Coming Soon'
	String get comingSoon => 'Coming Soon';

	/// en: 'Contact Us'
	String get contactUs => 'Contact Us';

	/// en: 'Contact us for custom pricing.'
	String get contactUsDesc => 'Contact us for custom pricing.';

	/// en: 'Plans'
	String get sectionPlans => 'Plans';

	/// en: 'Manage 1-5 Buildings'
	String get feature1To5 => 'Manage 1-5 Buildings';

	/// en: 'Manage 5-20 Buildings'
	String get feature5To20 => 'Manage 5-20 Buildings';

	/// en: 'Manage 20-50 Buildings'
	String get feature20To50 => 'Manage 20-50 Buildings';

	/// en: 'Unlimited Building Management'
	String get feature50Plus => 'Unlimited Building Management';

	/// en: 'Full control for up to 20 buildings'
	String get featureBasicUpTo20 => 'Full control for up to 20 buildings';

	/// en: 'Unlimited buildings · unlimited sites'
	String get featureBusinessUnlimited => 'Unlimited buildings · unlimited sites';

	/// en: 'Dedicated Account Manager'
	String get featureCustomSupport => 'Dedicated Account Manager';

	/// en: 'Managed buildings: {used} · ∞'
	String get buildingUsageUnlimited => 'Managed buildings: {used} · ∞';

	/// en: '{used} / ∞'
	String get buildingUsageUnlimitedShort => '{used} / ∞';

	/// en: 'Managed buildings: {used} · Subscription required'
	String get buildingUsageNeedSubscription => 'Managed buildings: {used} · Subscription required';

	/// en: 'Without a subscription you can view existing data; subscribe to Basic or Business to add buildings.'
	String get noSubCannotAddBuilding => 'Without a subscription you can view existing data; subscribe to Basic or Business to add buildings.';

	/// en: 'Basic plan quota is full. Upgrade to Business for more buildings.'
	String get upgradeToBusinessHint => 'Basic plan quota is full. Upgrade to Business for more buildings.';

	/// en: 'Subscribe to Business monthly'
	String get purchaseBusinessMonthlyCta => 'Subscribe to Business monthly';

	/// en: 'Subscribe to Business annually'
	String get purchaseBusinessAnnualCta => 'Subscribe to Business annually';

	/// en: 'Monthly'
	String get toggleMonthly => 'Monthly';

	/// en: 'Annual'
	String get toggleAnnual => 'Annual';

	/// en: 'Your Current Plan'
	String get currentPlanBadge => 'Your Current Plan';

	/// en: 'Building Usage'
	String get buildingProgress => 'Building Usage';

	/// en: 'Basic'
	String get planBasic => 'Basic';

	/// en: 'Up to 20 buildings'
	String get featureBasicBuildings => 'Up to 20 buildings';

	/// en: 'Basic Reports'
	String get featureBasicReports => 'Basic Reports';

	/// en: 'Lifetime'
	String get statusUnlimited => 'Lifetime';

	/// en: 'Basic or Business — pick by your total building count.'
	String get compareIntro => 'Basic or Business — pick by your total building count.';

	/// en: 'For small and mid-size portfolios'
	String get planBasicSubtitle => 'For small and mid-size portfolios';

	/// en: 'For growing portfolios'
	String get planBusinessSubtitle => 'For growing portfolios';

	/// en: 'Sites and blocks included'
	String get featureSitesIncluded => 'Sites and blocks included';

	/// en: 'Upload receipts — we read them'
	String get featureDekontOcr => 'Upload receipts — we read them';

	/// en: 'PDF reports in one tap'
	String get featurePdfReports => 'PDF reports in one tap';

	/// en: '₺199.99'
	String get priceFallbackBasicMonthly => '₺199.99';

	/// en: '₺1,999.99'
	String get priceFallbackBasicAnnual => '₺1,999.99';

	/// en: '₺399.99'
	String get priceFallbackBusinessMonthly => '₺399.99';

	/// en: '₺3,999.99'
	String get priceFallbackBusinessAnnual => '₺3,999.99';

	/// en: 'Recommended'
	String get recommendedBadge => 'Recommended';

	/// en: 'Your current plan'
	String get ctaCurrentPlan => 'Your current plan';

	/// en: 'Subscribe'
	String get ctaSubscribe => 'Subscribe';

	/// en: 'Upgrade to Business'
	String get ctaUpgrade => 'Upgrade to Business';

	/// en: 'You are already on Business'
	String get ctaAlreadyBusiness => 'You are already on Business';

	/// en: 'Complimentary subscription active'
	String get giftBannerTitle => 'Complimentary subscription active';

	/// en: 'Free access until {date}. If you purchase, your complimentary period is kept.'
	String get giftBannerBody => 'Free access until {date}. If you purchase, your complimentary period is kept.';

	/// en: 'Gift'
	String get sourceGift => 'Gift';

	/// en: 'Store'
	String get sourceStore => 'Store';

	/// en: 'Valid until'
	String get validUntilLabel => 'Valid until';

	/// en: 'Better value with annual billing'
	String get annualSaveHint => 'Better value with annual billing';

	/// en: 'You are nearing your building quota. Continue unlimited with Business.'
	String get quotaNearHint => 'You are nearing your building quota. Continue unlimited with Business.';
}

// Path: features.reports
class Translations$features$reports$en {
	Translations$features$reports$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Download report'
	String get menuDownload => 'Download report';

	/// en: 'PDF report'
	String get sheetTitle => 'PDF report';

	/// en: 'Report type'
	String get reportTypeLabel => 'Report type';

	/// en: 'Monthly summary'
	String get typeMonthly => 'Monthly summary';

	/// en: 'Annual summary'
	String get typeAnnual => 'Annual summary';

	/// en: 'Report for {month} {year}'
	String get periodHintMonthly => 'Report for {month} {year}';

	/// en: 'Annual report for {year}'
	String get periodHintAnnual => 'Annual report for {year}';

	/// en: 'Month'
	String get fieldMonth => 'Month';

	/// en: 'Year'
	String get fieldYear => 'Year';

	/// en: 'Select month'
	String get selectMonthTitle => 'Select month';

	/// en: 'Select year'
	String get selectYearTitle => 'Select year';

	/// en: 'Show report'
	String get download => 'Show report';

	/// en: 'Preparing report…'
	String get downloading => 'Preparing report…';

	/// en: 'Report preview'
	String get previewTitle => 'Report preview';

	/// en: 'Pinch to zoom and scroll to view pages.'
	String get pdfPreviewHint => 'Pinch to zoom and scroll to view pages.';

	/// en: 'PDF could not be opened on this device. Use «Share report» below to open it in another app.'
	String get pdfPreviewUnavailable => 'PDF could not be opened on this device. Use «Share report» below to open it in another app.';

	/// en: 'Share report'
	String get shareReport => 'Share report';

	/// en: 'Could not share the report. Try again.'
	String get shareFailed => 'Could not share the report. Try again.';

	/// en: 'Could not generate the report. Try again.'
	String get failed => 'Could not generate the report. Try again.';
}

// Path: features.dashboard
class Translations$features$dashboard$en {
	Translations$features$dashboard$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'All Buildings'
	String get allBuildings => 'All Buildings';

	/// en: 'Buildings'
	String get properties => 'Buildings';

	/// en: 'Select building'
	String get selectBuilding => 'Select building';

	/// en: 'Search by name or address'
	String get searchBuildings => 'Search by name or address';

	/// en: 'Tap to search and select a building'
	String get buildingPickerTapHint => 'Tap to search and select a building';

	/// en: '{count} buildings'
	String get allBuildingsSummary => '{count} buildings';

	/// en: '{apartments} units'
	String get buildingUnitsSummary => '{apartments} units';

	/// en: 'Collection Rate'
	String get collectionRate => 'Collection Rate';

	/// en: 'Overdue Payments'
	String get overduePayments => 'Overdue Payments';

	/// en: 'Open Requests'
	String get openTicketRequests => 'Open Requests';

	/// en: 'This Month's Expenses'
	String get monthTotalExpense => 'This Month\'s Expenses';

	/// en: 'Pending Receipts'
	String get pendingDekonts => 'Pending Receipts';

	/// en: 'Dues Collection Status'
	String get duesCollectionStatus => 'Dues Collection Status';

	/// en: 'Last 6 Months'
	String get financeTrendTitle => 'Last 6 Months';

	/// en: 'Income / Expense Comparison'
	String get incomeExpenseComparison => 'Income / Expense Comparison';

	/// en: 'Last 6 Months'
	String get last6Months => 'Last 6 Months';

	/// en: 'Collected Dues'
	String get collectedDues => 'Collected Dues';

	/// en: 'Total Expenses'
	String get totalExpense => 'Total Expenses';

	/// en: 'Request Status'
	String get ticketStatusTitle => 'Request Status';

	/// en: 'Open'
	String get ticketOpen => 'Open';

	/// en: 'Approved'
	String get ticketInProgress => 'Approved';

	/// en: 'Done'
	String get ticketResolved => 'Done';

	/// en: 'Apartments with Overdue Payments'
	String get overdueApartments => 'Apartments with Overdue Payments';

	/// en: '{count} apartments'
	String get apartmentCountBadge => '{count} apartments';

	/// en: 'Paid'
	String get legendPaid => 'Paid';

	/// en: 'Overdue'
	String get legendOverdue => 'Overdue';

	/// en: 'Pending'
	String get legendPending => 'Pending';

	/// en: '{count} due(s)'
	String get legendUnit => '{count} due(s)';

	/// en: 'Remind'
	String get remind => 'Remind';

	/// en: 'Remind all'
	String get remindAll => 'Remind all';

	/// en: 'Reminder sent'
	String get remindSent => 'Reminder sent';

	/// en: 'Reminders sent to {count} residents.'
	String get remindAllSent => 'Reminders sent to {count} residents.';

	/// en: 'A reminder was already sent for this due within the last 24 hours.'
	String get remindCooldown => 'A reminder was already sent for this due within the last 24 hours.';

	/// en: 'No resident found to send a reminder for this apartment.'
	String get remindNoRecipient => 'No resident found to send a reminder for this apartment.';

	/// en: 'Apt. {number}'
	String get apartmentTitle => 'Apt. {number}';

	/// en: 'A{number}'
	String get apartmentShortLabel => 'A{number}';

	/// en: 'Apt. {number} · Floor {floor}'
	String get apartmentWithFloor => 'Apt. {number} · Floor {floor}';

	/// en: 'No overdue payments'
	String get noOverdueApartments => 'No overdue payments';

	/// en: 'Not enough data yet'
	String get noChartData => 'Not enough data yet';

	/// en: 'You don't have a site or building yet. Add your first one to start managing.'
	String get noBuildingsEmptyMessage => 'You don\'t have a site or building yet. Add your first one to start managing.';

	/// en: 'Add Building'
	String get noBuildingsEmptyCta => 'Add Building';

	/// en: 'Add Site'
	String get noBuildingsEmptyCtaSite => 'Add Site';

	/// en: 'No residents have been assigned to the apartments in this building yet. Invite residents to get started.'
	String get noResidentsInviteMessage => 'No residents have been assigned to the apartments in this building yet. Invite residents to get started.';

	/// en: 'Invite New Resident'
	String get noResidentsInviteCta => 'Invite New Resident';

	/// en: '{count} pending invite(s)'
	String get pendingInvitesCount => '{count} pending invite(s)';

	/// en: 'This site has no buildings yet. Add the first block to get started.'
	String get noBlocksInviteMessage => 'This site has no buildings yet. Add the first block to get started.';

	/// en: 'Add Building to Site'
	String get noBlocksInviteCta => 'Add Building to Site';

	/// en: 'See more (+{count})'
	String get seeMoreOverdue => 'See more (+{count})';

	/// en: 'Pay Now'
	String get payNow => 'Pay Now';

	/// en: '{count} overdue payment(s)'
	String get overduePaymentsBadge => '{count} overdue payment(s)';

	/// en: '{count} of your dues are overdue'
	String get residentOverduePaymentsBadge => '{count} of your dues are overdue';

	/// en: '{month} {year} dues'
	String get featuredDuePeriod => '{month} {year} dues';

	/// en: 'Your {month} {year} dues'
	String get residentFeaturedDuePeriod => 'Your {month} {year} dues';

	/// en: 'View and pay your dues here.'
	String get residentDebtAndPaySubtitle => 'View and pay your dues here.';

	/// en: 'Dues Status'
	String get duesStatusAction => 'Dues Status';

	/// en: '{count} overdue dues'
	String get overdueDuesBadge => '{count} overdue dues';

	/// en: '{count} sections failed to load. Pull down to retry.'
	String get dataWarningBanner => '{count} sections failed to load. Pull down to retry.';

	/// en: 'Sites'
	String get sitesSection => 'Sites';

	/// en: 'Independent Buildings'
	String get independentBuildingsSection => 'Independent Buildings';

	/// en: '{name} · {count} buildings'
	String get sitePickerSummary => '{name} · {count} buildings';

	/// en: '{count} buildings'
	String get siteScopeSummary => '{count} buildings';

	late final Translations$features$dashboard$activityHistory$en activityHistory = Translations$features$dashboard$activityHistory$en._(_root);
}

// Path: features.dues
class Translations$features$dues$en {
	Translations$features$dues$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Due Details'
	String get detailTitle => 'Due Details';

	/// en: 'Collect Payment'
	String get collectPayment => 'Collect Payment';

	/// en: 'Record cash payment?'
	String get collectPaymentConfirmTitle => 'Record cash payment?';

	/// en: '{apartment} — remaining {amount} for {period} will be marked as paid.'
	String get collectPaymentConfirmBody => '{apartment} — remaining {amount} for {period} will be marked as paid.';

	/// en: 'Review Receipt'
	String get reviewDekont => 'Review Receipt';

	/// en: 'Payment Details'
	String get paymentDetail => 'Payment Details';

	/// en: 'Amount'
	String get amountLabel => 'Amount';

	/// en: 'Period'
	String get periodLabel => 'Period';

	late final Translations$features$dues$resident$en resident = Translations$features$dues$resident$en._(_root);
	late final Translations$features$dues$transactions$en transactions = Translations$features$dues$transactions$en._(_root);
}

// Path: features.faz2
class Translations$features$faz2$en {
	Translations$features$faz2$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Phase 2'
	String get sectionTitle => 'Phase 2';

	/// en: 'Requests'
	String get tickets => 'Requests';

	/// en: 'Expenses'
	String get expenses => 'Expenses';

	/// en: 'Announce'
	String get announcement => 'Announce';
}

// Path: features.welcome
class Translations$features$welcome$en {
	Translations$features$welcome$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Skip'
	String get skip => 'Skip';

	/// en: 'Next'
	String get next => 'Next';

	/// en: 'Get started'
	String get start => 'Get started';

	/// en: 'Skip introduction'
	String get skipSemantics => 'Skip introduction';

	/// en: 'Next page'
	String get nextSemantics => 'Next page';

	/// en: 'Finish introduction and continue'
	String get startSemantics => 'Finish introduction and continue';

	/// en: 'Introduction page {current} of {total}'
	String get pageSemantics => 'Introduction page {current} of {total}';

	/// en: 'Page {current} of {total}'
	String get dotsSemantics => 'Page {current} of {total}';

	/// en: 'Welcome to AidatPanel'
	String get page1Title => 'Welcome to AidatPanel';

	/// en: 'Manage your building or complex from your phone. Setup takes just a few minutes.'
	String get page1Body => 'Manage your building or complex from your phone. Setup takes just a few minutes.';

	/// en: 'One account, full control'
	String get page2Title => 'One account, full control';

	/// en: 'Whether you manage a single building or a multi-block complex — all from the same account and screen.'
	String get page2Body => 'Whether you manage a single building or a multi-block complex — all from the same account and screen.';

	/// en: 'Upload a receipt, we handle the rest'
	String get page3Title => 'Upload a receipt, we handle the rest';

	/// en: 'Residents upload receipts; the system reads amount and date. You just review and approve.'
	String get page3Body => 'Residents upload receipts; the system reads amount and date. You just review and approve.';

	/// en: 'Everyone stays in the loop'
	String get page4Title => 'Everyone stays in the loop';

	/// en: 'Payments, announcements, and request updates reach everyone with instant notifications.'
	String get page4Body => 'Payments, announcements, and request updates reach everyone with instant notifications.';

	/// en: 'Clear and organized'
	String get page5Title => 'Clear and organized';

	/// en: 'Expenses stay on record and requests live in one place. Everyone knows where things stand.'
	String get page5Body => 'Expenses stay on record and requests live in one place. Everyone knows where things stand.';
}

// Path: features.buildings.collection
class Translations$features$buildings$collection$en {
	Translations$features$buildings$collection$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Recipient details'
	String get sectionTitle => 'Recipient details';

	/// en: 'IBAN for resident bank transfers. Optional; you can add it later.'
	String get sectionHint => 'IBAN for resident bank transfers. Optional; you can add it later.';

	/// en: 'Saved IBAN'
	String get modeSaved => 'Saved IBAN';

	/// en: 'New IBAN'
	String get modeNew => 'New IBAN';

	/// en: 'Previously used'
	String get savedListTitle => 'Previously used';

	/// en: 'Saved IBANs'
	String get savedListSectionLabel => 'Saved IBANs';

	/// en: 'Choose saved IBAN'
	String get pickSavedIban => 'Choose saved IBAN';

	/// en: 'Tap to choose another IBAN'
	String get changeSavedIban => 'Tap to choose another IBAN';

	/// en: 'Search IBAN or recipient name'
	String get searchSavedIban => 'Search IBAN or recipient name';

	/// en: 'Recipient name'
	String get detailAccountHolder => 'Recipient name';

	/// en: 'Payment reference'
	String get detailReference => 'Payment reference';

	/// en: 'Apartment number is added to the transfer reference automatically'
	String get detailReferenceAuto => 'Apartment number is added to the transfer reference automatically';

	/// en: 'Transfer reference: Apartment number'
	String get detailReferenceDaireOnly => 'Transfer reference: Apartment number';

	/// en: 'Transfer reference: Apt. no + dues'
	String get detailReferenceDaireAidat => 'Transfer reference: Apt. no + dues';

	/// en: 'Transfer reference: Dues (apt. no added automatically)'
	String get detailReferenceAidat => 'Transfer reference: Dues (apt. no added automatically)';

	/// en: 'Transfer reference: Apartment number on transfer'
	String get detailReferenceHavale => 'Transfer reference: Apartment number on transfer';

	/// en: 'Used in {count} buildings'
	String get detailUsedInBuildings => 'Used in {count} buildings';

	/// en: 'Used in {count} sites'
	String get detailUsedInSites => 'Used in {count} sites';

	/// en: 'Used in {buildingCount} buildings, {siteCount} sites'
	String get detailUsedInBuildingsAndSites => 'Used in {buildingCount} buildings, {siteCount} sites';

	/// en: 'IBAN'
	String get ibanLabel => 'IBAN';

	/// en: 'TR33 0006 1005 1978 6457 8413 26'
	String get ibanHint => 'TR33 0006 1005 1978 6457 8413 26';

	/// en: 'Enter a valid Turkish IBAN (TR + 24 digits)'
	String get ibanInvalid => 'Enter a valid Turkish IBAN (TR + 24 digits)';

	/// en: 'You entered account title or reference; enter a valid IBAN'
	String get ibanRequiredIfOtherFilled => 'You entered account title or reference; enter a valid IBAN';

	/// en: 'IBAN name'
	String get ibanNameLabel => 'IBAN name';

	/// en: 'e.g. My Ziraat account, Kuveyt Turk IBAN'
	String get ibanNameHint => 'e.g. My Ziraat account, Kuveyt Turk IBAN';

	/// en: 'You can name your IBAN later from Settings > My saved IBANs.'
	String get ibanNameLaterHint => 'You can name your IBAN later from Settings > My saved IBANs.';

	/// en: 'Recipient name'
	String get accountTitleLabel => 'Recipient name';

	/// en: 'e.g. Ahmet Yilmaz or Building Management'
	String get accountTitleHint => 'e.g. Ahmet Yilmaz or Building Management';

	/// en: 'Payment reference'
	String get referenceTemplateLabel => 'Payment reference';

	/// en: 'e.g. Dues payment'
	String get referenceTemplateHint => 'e.g. Dues payment';

	/// en: 'This reference is shown the same way to all your residents'
	String get referenceTemplateHelper => 'This reference is shown the same way to all your residents';

	/// en: 'No saved collection details yet'
	String get presetsEmpty => 'No saved collection details yet';

	/// en: 'Could not load suggestions'
	String get presetsLoadFailed => 'Could not load suggestions';

	/// en: '{count} buildings'
	String get presetBuildingCount => '{count} buildings';

	/// en: 'Collection / IBAN'
	String get menuEdit => 'Collection / IBAN';

	/// en: 'Collection details'
	String get editSheetTitle => 'Collection details';

	/// en: 'Collection details saved'
	String get saveSuccess => 'Collection details saved';

	/// en: 'My saved IBANs'
	String get savedIbansTitle => 'My saved IBANs';

	/// en: 'No saved IBAN yet. You can add collection details when creating a building.'
	String get savedIbansEmpty => 'No saved IBAN yet. You can add collection details when creating a building.';

	/// en: 'No building or site linked to this set'
	String get savedIbansNoBuildingMatch => 'No building or site linked to this set';

	/// en: 'Buildings: {names}'
	String get savedIbansBuildingNames => 'Buildings: {names}';

	/// en: 'Sites: {names}'
	String get savedIbansSiteNames => 'Sites: {names}';

	/// en: 'Collection updated for {count} place(s)'
	String get savedIbansUpdateSuccess => 'Collection updated for {count} place(s)';

	/// en: 'Places to update: {names}'
	String get savedIbansUpdateHint => 'Places to update: {names}';

	/// en: 'Edit IBAN'
	String get editSavedIbanTitle => 'Edit IBAN';

	/// en: 'This set is not linked to a building or site yet. Changes are stored in your saved list only.'
	String get savedIbansOrphanHint => 'This set is not linked to a building or site yet. Changes are stored in your saved list only.';

	/// en: 'Add IBAN'
	String get savedIbansAddTitle => 'Add IBAN';

	/// en: 'You can reuse these details when adding a building or editing collection settings.'
	String get savedIbansAddHint => 'You can reuse these details when adding a building or editing collection settings.';

	/// en: 'IBAN saved'
	String get savedIbansAddSuccess => 'IBAN saved';

	/// en: 'Select multiple'
	String get savedIbansSelectMode => 'Select multiple';

	/// en: 'selected'
	String get savedIbansSelectedLabel => 'selected';

	/// en: 'Delete selected'
	String get savedIbansDeleteSelected => 'Delete selected';

	/// en: 'Select the IBANs you want to delete first'
	String get savedIbansPickFirst => 'Select the IBANs you want to delete first';

	/// en: 'Delete this IBAN?'
	String get savedIbansDeleteTitle => 'Delete this IBAN?';

	/// en: 'This saved IBAN will be removed from your list.'
	String get savedIbansDeleteMessage => 'This saved IBAN will be removed from your list.';

	/// en: 'Delete selected IBANs?'
	String get savedIbansDeleteBulkTitle => 'Delete selected IBANs?';

	/// en: '{count} saved IBAN(s) will be deleted.'
	String get savedIbansDeleteBulkMessage => '{count} saved IBAN(s) will be deleted.';

	/// en: 'Collection details will also be cleared on {count} place(s).'
	String get savedIbansDeleteBuildingWarning => 'Collection details will also be cleared on {count} place(s).';

	/// en: 'This IBAN is used here: {names}. Deleting it will clear collection details for those places. This cannot be undone.'
	String get savedIbansDeleteMultiUsageWarning => 'This IBAN is used here: {names}. Deleting it will clear collection details for those places. This cannot be undone.';

	/// en: 'IBAN deleted'
	String get savedIbansDeleteSuccess => 'IBAN deleted';

	/// en: '{count} IBAN(s) deleted'
	String get savedIbansDeleteBulkSuccess => '{count} IBAN(s) deleted';

	/// en: 'Collection IBAN not configured'
	String get ibanNotConfigured => 'Collection IBAN not configured';

	/// en: 'This IBAN is already registered in the system. Please check and try a different IBAN.'
	String get ibanAlreadyExists => 'This IBAN is already registered in the system. Please check and try a different IBAN.';
}

// Path: features.buildings.list
class Translations$features$buildings$list$en {
	Translations$features$buildings$list$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Building'
	String get buildingCount => 'Building';

	/// en: 'Unit'
	String get unitCount => 'Unit';

	/// en: 'Overdue'
	String get overdueShort => 'Overdue';

	/// en: 'Collected'
	String get collectionShort => 'Collected';

	/// en: 'Sort'
	String get sort => 'Sort';

	/// en: 'By Overdue'
	String get sortByOverdue => 'By Overdue';

	/// en: 'By Collection Rate'
	String get sortByCollectionRate => 'By Collection Rate';

	/// en: 'By Name'
	String get sortByName => 'By Name';

	/// en: '{paid} / {total} units paid'
	String get paidUnitsProgress => '{paid} / {total} units paid';

	/// en: '{amount} / unit'
	String get perUnitDues => '{amount} / unit';

	/// en: '{count} units overdue'
	String get unitsOverdue => '{count} units overdue';

	/// en: '{count} units waiting'
	String get unitsWaiting => '{count} units waiting';

	/// en: 'All payments complete'
	String get allPaymentsComplete => 'All payments complete';

	/// en: 'Monthly Dues'
	String get monthlyDuesShort => 'Monthly Dues';
}

// Path: features.auth.onboarding
class Translations$features$auth$onboarding$en {
	Translations$features$auth$onboarding$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Step {current} / {total}'
	String get stepProgress => 'Step {current} / {total}';

	/// en: 'Continue'
	String get continueButton => 'Continue';

	/// en: 'Go to panel'
	String get goToPanel => 'Go to panel';

	/// en: 'Your information is securely protected.'
	String get secureNote => 'Your information is securely protected.';

	/// en: 'Who will you use the app as?'
	String get step1Title => 'Who will you use the app as?';

	/// en: 'Select your role to continue.'
	String get step1Subtitle => 'Select your role to continue.';

	/// en: 'I am an apartment manager'
	String get step1ManagerOption => 'I am an apartment manager';

	/// en: 'I am an apartment resident'
	String get step1ResidentOption => 'I am an apartment resident';

	/// en: 'Select this if you manage an apartment or site.'
	String get step1ManagerHint => 'Select this if you manage an apartment or site.';

	/// en: 'I am a resident signing in to my unit.'
	String get step1ResidentHint => 'I am a resident signing in to my unit.';

	/// en: 'I have signed in before'
	String get step1ReturningLogin => 'I have signed in before';

	/// en: 'I signed in before as manager'
	String get step1ReturningLoginManager => 'I signed in before as manager';

	/// en: 'I signed in before as resident'
	String get step1ReturningLoginResident => 'I signed in before as resident';

	/// en: '{name} · {contact}'
	String get step1ReturningLoginHint => '{name} · {contact}';

	/// en: 'Sign in with email and password'
	String get step1LegacyEmailLogin => 'Sign in with email and password';

	/// en: 'Back'
	String get backButton => 'Back';

	/// en: 'Welcome to AidatPanel'
	String get managerExperienceTitle => 'Welcome to AidatPanel';

	/// en: 'Have you registered before?'
	String get managerExperienceSubtitle => 'Have you registered before?';

	/// en: 'I have registered before'
	String get managerReturningOption => 'I have registered before';

	/// en: 'I am using the app for the first time'
	String get managerFirstTimeOption => 'I am using the app for the first time';

	/// en: 'Creating your account'
	String get managerNameEyebrow => 'Creating your account';

	/// en: 'Let's get to know you — what's your name?'
	String get managerNameTitle => 'Let\'s get to know you — what\'s your name?';

	/// en: 'How should we address you?'
	String get managerNameSubtitle => 'How should we address you?';

	/// en: 'Enter your email or phone'
	String get managerIdentifierTitle => 'Enter your email or phone';

	/// en: 'This will be used for sign-in.'
	String get managerIdentifierSubtitle => 'This will be used for sign-in.';

	/// en: 'Email or phone'
	String get managerIdentifierLabel => 'Email or phone';

	/// en: 'example@mail.com or 05321234567'
	String get managerIdentifierHint => 'example@mail.com or 05321234567';

	/// en: 'For phone, enter 11 digits starting with 0.'
	String get managerIdentifierPhoneNote => 'For phone, enter 11 digits starting with 0.';

	/// en: 'Enter your email or phone'
	String get identifierRequired => 'Enter your email or phone';

	/// en: 'Enter an 11-digit phone number starting with 0'
	String get phoneInvalidElevenDigits => 'Enter an 11-digit phone number starting with 0';

	/// en: 'Enter your password'
	String get managerLoginPasswordTitle => 'Enter your password';

	/// en: 'Welcome back!'
	String get managerLoginWelcomeTitle => 'Welcome back!';

	/// en: 'Welcome back, {name}!'
	String get managerLoginWelcomeNamedTitle => 'Welcome back, {name}!';

	/// en: 'Enter your password to continue'
	String get managerLoginWelcomeSubtitle => 'Enter your password to continue';

	/// en: 'Set your password'
	String get managerRegisterPasswordTitle => 'Set your password';

	/// en: 'At least 6 characters; letters and numbers only.'
	String get managerRegisterPasswordSubtitle => 'At least 6 characters; letters and numbers only.';

	/// en: 'Create Account'
	String get managerCreateAccountButton => 'Create Account';

	/// en: 'Sign In'
	String get managerLoginButton => 'Sign In';

	/// en: 'Welcome to AidatPanel'
	String get residentExperienceTitle => 'Welcome to AidatPanel';

	/// en: 'How would you like to continue?'
	String get residentExperienceSubtitle => 'How would you like to continue?';

	/// en: 'I have signed in before'
	String get residentReturningOption => 'I have signed in before';

	/// en: 'I have an invite code'
	String get residentInviteOption => 'I have an invite code';

	/// en: 'Your phone number'
	String get residentPhoneTitle => 'Your phone number';

	/// en: 'We will send you a one-time sign-in password.'
	String get residentPhoneSubtitle => 'We will send you a one-time sign-in password.';

	/// en: 'Country code +90 is fixed. Enter your number as (5XX) XXX XX XX.'
	String get residentPhoneNote => 'Country code +90 is fixed. Enter your number as (5XX) XXX XX XX.';

	/// en: 'What is your name?'
	String get residentWelcomeTitle => 'What is your name?';

	/// en: 'Your phone is verified. How should we address you?'
	String get residentWelcomeSubtitle => 'Your phone is verified. How should we address you?';

	/// en: 'Go to Dashboard'
	String get residentCompleteJoinButton => 'Go to Dashboard';

	/// en: 'Enter Your Contact Information'
	String get step2Title => 'Enter Your Contact Information';

	/// en: 'Enter your phone number or email address to continue.'
	String get step2Subtitle => 'Enter your phone number or email address to continue.';

	/// en: 'We will send you a verification code.'
	String get step2SubtitlePhone => 'We will send you a verification code.';

	/// en: 'We will send a verification code to your email.'
	String get step2SubtitleEmail => 'We will send a verification code to your email.';

	/// en: 'Verification Code'
	String get step3OtpTitle => 'Verification Code';

	/// en: 'Enter the 6-digit code sent to {phone}.'
	String get step3OtpSubtitlePhone => 'Enter the 6-digit code sent to {phone}.';

	/// en: 'Enter the 6-digit code sent to {email}.'
	String get step3OtpSubtitleEmail => 'Enter the 6-digit code sent to {email}.';

	/// en: 'Enter the 6-digit code below.'
	String get step3OtpSubtitle => 'Enter the 6-digit code below.';

	/// en: 'Code sent to {phone}.'
	String get step3OtpSentTo => 'Code sent to {phone}.';

	/// en: 'Resend code ({time})'
	String get step3ResendOtp => 'Resend code ({time})';

	/// en: 'Resend code'
	String get step3ResendOtpReady => 'Resend code';

	/// en: 'Enter your password'
	String get step3PasswordTitle => 'Enter your password';

	/// en: 'Create your password'
	String get step3RegisterPasswordTitle => 'Create your password';

	/// en: 'We protect your account with secure verification.'
	String get step3SecureVerify => 'We protect your account with secure verification.';

	/// en: 'If using a test number, enter the one-time password from Firebase Console.'
	String get step3DevOtpHint => 'If using a test number, enter the one-time password from Firebase Console.';

	/// en: 'Your one-time password'
	String get residentOtpTitle => 'Your one-time password';

	/// en: 'Enter the 6-digit one-time password sent to {phone}.'
	String get residentOtpSubtitlePhone => 'Enter the 6-digit one-time password sent to {phone}.';

	/// en: 'Enter Your Invite Code'
	String get step4InviteTitle => 'Enter Your Invite Code';

	/// en: 'Enter the code from your manager.'
	String get step4InviteSubtitle => 'Enter the code from your manager.';

	/// en: 'You can get your invite code from management or your manager.'
	String get step4InviteHint => 'You can get your invite code from management or your manager.';

	/// en: 'Enter Your Invite Code'
	String get step4ManagerInviteTitle => 'Enter Your Invite Code';

	/// en: 'Enter your invite code to link your manager account to the site or building.'
	String get step4ManagerInviteSubtitle => 'Enter your invite code to link your manager account to the site or building.';

	/// en: 'You can get your invite code from management or your manager.'
	String get step4ManagerInviteInfo => 'You can get your invite code from management or your manager.';

	/// en: 'No, I am the manager'
	String get step4ManagerPrimaryLink => 'No, I am the manager';

	/// en: 'Choose this if you will manage the building yourself.'
	String get step4ManagerPrimaryHint => 'Choose this if you will manage the building yourself.';

	/// en: 'Valid invite: {label}'
	String get step4InviteValidated => 'Valid invite: {label}';

	/// en: 'What You Can Do as a Manager'
	String get step5Title => 'What You Can Do as a Manager';

	/// en: 'Manage your site easily with AidatPanel and serve your residents better.'
	String get step5ManagerSubtitle => 'Manage your site easily with AidatPanel and serve your residents better.';

	/// en: 'What You Can Do as a Resident'
	String get step5ResidentTitle => 'What You Can Do as a Resident';

	/// en: 'Track your dues and payments here.'
	String get step5ResidentSubtitle => 'Track your dues and payments here.';

	/// en: 'Manage announcements'
	String get step5ManagerAnnounceTitle => 'Manage announcements';

	/// en: 'Send announcements to all residents quickly.'
	String get step5ManagerAnnounceBody => 'Send announcements to all residents quickly.';

	/// en: 'Dues tracking'
	String get step5ManagerDuesTitle => 'Dues tracking';

	/// en: 'Track collections and view payments.'
	String get step5ManagerDuesBody => 'Track collections and view payments.';

	/// en: 'Resident management'
	String get step5ManagerResidentsTitle => 'Resident management';

	/// en: 'Manage resident information and simplify communication.'
	String get step5ManagerResidentsBody => 'Manage resident information and simplify communication.';

	/// en: 'Reporting'
	String get step5ManagerReportsTitle => 'Reporting';

	/// en: 'Monitor site finances with detailed reports.'
	String get step5ManagerReportsBody => 'Monitor site finances with detailed reports.';

	/// en: 'View your dues'
	String get step5ResidentDuesTitle => 'View your dues';

	/// en: 'Track your current balance and payment history.'
	String get step5ResidentDuesBody => 'Track your current balance and payment history.';

	/// en: 'Upload receipts'
	String get step5ResidentDekontTitle => 'Upload receipts';

	/// en: 'Send your payment receipt as a photo or PDF.'
	String get step5ResidentDekontBody => 'Send your payment receipt as a photo or PDF.';

	/// en: 'Create requests'
	String get step5ResidentTicketsTitle => 'Create requests';

	/// en: 'Easily notify management about matters you want to report.'
	String get step5ResidentTicketsBody => 'Easily notify management about matters you want to report.';

	/// en: 'Get notifications'
	String get step5ResidentNotifyTitle => 'Get notifications';

	/// en: 'Stay informed about announcements and due reminders.'
	String get step5ResidentNotifyBody => 'Stay informed about announcements and due reminders.';

	/// en: 'Setup complete'
	String get step6ManagerTitle => 'Setup complete';

	/// en: 'Welcome to the manager panel! You can now start managing your site and serving your residents better.'
	String get step6ManagerSubtitle => 'Welcome to the manager panel! You can now start managing your site and serving your residents better.';

	/// en: 'Sign-in complete'
	String get step6ResidentTitle => 'Sign-in complete';

	/// en: 'Track your dues and payments from here.'
	String get step6ResidentSubtitle => 'Track your dues and payments from here.';

	/// en: 'Wrong one-time password. Try again.'
	String get otpInvalid => 'Wrong one-time password. Try again.';

	/// en: 'One-time password expired. Request a new one.'
	String get otpExpired => 'One-time password expired. Request a new one.';

	/// en: 'Enter a valid phone number (5XX XXX XX XX).'
	String get phoneInvalid => 'Enter a valid phone number (5XX XXX XX XX).';

	/// en: 'Invite code is invalid or expired.'
	String get inviteInvalid => 'Invite code is invalid or expired.';

	/// en: 'Could not send the one-time password. Try again.'
	String get otpSendFailed => 'Could not send the one-time password. Try again.';

	/// en: 'Phone sign-in coming soon. You can use email for now.'
	String get phoneOtpDisabledHint => 'Phone sign-in coming soon. You can use email for now.';

	/// en: 'Resident Sign In'
	String get residentLoginTitle => 'Resident Sign In';

	/// en: 'Enter your details to continue.'
	String get residentLoginSubtitle => 'Enter your details to continue.';

	/// en: 'Welcome back!'
	String get residentLoginWelcomeTitle => 'Welcome back!';

	/// en: 'Welcome back, {name}!'
	String get residentLoginWelcomeNamedTitle => 'Welcome back, {name}!';

	/// en: 'Enter your one-time password to continue'
	String get residentLoginWelcomeSubtitle => 'Enter your one-time password to continue';

	/// en: 'Send Password'
	String get residentSendCodeButton => 'Send Password';

	/// en: 'A one-time password will be sent to your phone number.'
	String get residentPhoneVerifyNote => 'A one-time password will be sent to your phone number.';

	/// en: 'Enter the 6-digit one-time password sent to your phone.'
	String get residentOtpSubtitle => 'Enter the 6-digit one-time password sent to your phone.';

	/// en: 'Didn't get the password?'
	String get residentResendPrompt => 'Didn\'t get the password?';

	/// en: 'Resend password'
	String get residentResendLink => 'Resend password';

	/// en: 'Resend password ({time})'
	String get residentResendOtp => 'Resend password ({time})';

	/// en: 'Please enter the invitation code you received from your manager to continue.'
	String get residentInviteSubtitle => 'Please enter the invitation code you received from your manager to continue.';

	/// en: 'Join Apartment'
	String get residentJoinButton => 'Join Apartment';

	/// en: 'Invitation Code'
	String get residentInviteCodeLabel => 'Invitation Code';

	/// en: 'e.g. APF-45532'
	String get residentInviteCodeHint => 'e.g. APF-45532';

	/// en: 'Please enter your full name.'
	String get residentNameRequired => 'Please enter your full name.';
}

// Path: features.dekont.resident
class Translations$features$dekont$resident$en {
	Translations$features$dekont$resident$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Processing'
	String get statusProcessing => 'Processing';

	/// en: 'Awaiting approval'
	String get statusAwaitingApproval => 'Awaiting approval';

	/// en: 'Approved'
	String get statusApproved => 'Approved';

	/// en: 'Partially approved'
	String get statusPartiallyApproved => 'Partially approved';

	/// en: 'Rejected'
	String get statusRejected => 'Rejected';

	/// en: 'Manual review needed'
	String get statusCouldNotMatch => 'Manual review needed';

	/// en: 'Your receipt is being reviewed. The amount will appear shortly.'
	String get statusDetailProcessing => 'Your receipt is being reviewed. The amount will appear shortly.';

	/// en: 'Waiting for the manager's approval.'
	String get statusDetailAwaitingApproval => 'Waiting for the manager\'s approval.';

	/// en: 'Recipient details matched. Waiting for the manager's approval.'
	String get statusDetailAwaitingIbanOk => 'Recipient details matched. Waiting for the manager\'s approval.';

	/// en: 'Recipient details unclear. Waiting for the manager's approval.'
	String get statusDetailAwaitingIbanIssue => 'Recipient details unclear. Waiting for the manager\'s approval.';

	/// en: 'Your payment was approved.'
	String get statusDetailApproved => 'Your payment was approved.';

	/// en: 'Your payment was partially approved.'
	String get statusDetailPartiallyApproved => 'Your payment was partially approved.';

	/// en: 'Your receipt was rejected.'
	String get statusDetailRejected => 'Your receipt was rejected.';

	/// en: 'All your receipts'
	String get filterAll => 'All your receipts';

	/// en: 'Awaiting approval'
	String get filterPending => 'Awaiting approval';

	/// en: 'Approved'
	String get filterApproved => 'Approved';

	/// en: 'Rejected'
	String get filterRejected => 'Rejected';

	/// en: 'This due is overdue'
	String get dueOverdueHint => 'This due is overdue';
}

// Path: features.dekont.manager
class Translations$features$dekont$manager$en {
	Translations$features$dekont$manager$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Processing'
	String get statusProcessing => 'Processing';

	/// en: 'Awaiting approval'
	String get statusAwaitingApproval => 'Awaiting approval';

	/// en: 'Approved'
	String get statusApproved => 'Approved';

	/// en: 'Partially approved'
	String get statusPartiallyApproved => 'Partially approved';

	/// en: 'Rejected'
	String get statusRejected => 'Rejected';

	/// en: 'Receipt is being processed. Details will appear shortly.'
	String get statusDetailProcessing => 'Receipt is being processed. Details will appear shortly.';

	/// en: 'Your approval is needed.'
	String get statusDetailAwaitingApproval => 'Your approval is needed.';

	/// en: 'Recipient details matched. Your approval is needed.'
	String get statusDetailAwaitingIbanOk => 'Recipient details matched. Your approval is needed.';

	/// en: 'Recipient details unclear. Check and decide.'
	String get statusDetailAwaitingIbanIssue => 'Recipient details unclear. Check and decide.';

	/// en: 'Payment approved.'
	String get statusDetailApproved => 'Payment approved.';

	/// en: 'Payment partially approved.'
	String get statusDetailPartiallyApproved => 'Payment partially approved.';

	/// en: 'Receipt rejected.'
	String get statusDetailRejected => 'Receipt rejected.';
}

// Path: features.notifications.resident
class Translations$features$notifications$resident$en {
	Translations$features$notifications$resident$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'You have a due reminder'
	String get typeDueReminder => 'You have a due reminder';

	/// en: 'Your due was paid'
	String get typeDuePaid => 'Your due was paid';

	/// en: 'Your request was created'
	String get typeTicketCreated => 'Your request was created';

	/// en: 'Your request was updated'
	String get typeTicketUpdate => 'Your request was updated';

	/// en: 'You received an announcement'
	String get typeAnnouncement => 'You received an announcement';

	/// en: 'Your receipt was received'
	String get typeDekontReceived => 'Your receipt was received';

	/// en: 'Your receipt is under review'
	String get typeDekontNeedsReview => 'Your receipt is under review';

	/// en: 'Your receipt was matched'
	String get typeDekontMatched => 'Your receipt was matched';

	/// en: 'Your receipt was approved'
	String get typeDekontPaymentApplied => 'Your receipt was approved';

	/// en: 'A new expense was added'
	String get typeExpenseAdded => 'A new expense was added';

	/// en: 'System notification'
	String get typeSystem => 'System notification';

	/// en: 'Your notification'
	String get typeOther => 'Your notification';

	/// en: 'Announcement for you'
	String get allApartmentsTag => 'Announcement for you';

	/// en: 'Announcement from management'
	String get announcementFeedLabel => 'Announcement from management';

	/// en: 'No announcements yet'
	String get announcementsEmptyTitle => 'No announcements yet';

	/// en: 'Announcements from management will appear here.'
	String get announcementsEmptySubtitle => 'Announcements from management will appear here.';
}

// Path: features.notifications.permissionPrompt
class Translations$features$notifications$permissionPrompt$en {
	Translations$features$notifications$permissionPrompt$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Enable notifications'
	String get residentTitle => 'Enable notifications';

	/// en: 'We recommend allowing notifications so you can get due reminders, announcements, and receipt updates right away.'
	String get residentBody => 'We recommend allowing notifications so you can get due reminders, announcements, and receipt updates right away.';

	/// en: 'Enable notifications'
	String get managerTitle => 'Enable notifications';

	/// en: 'We recommend allowing notifications so you can get receipt reviews, resident requests, and due activity right away.'
	String get managerBody => 'We recommend allowing notifications so you can get receipt reviews, resident requests, and due activity right away.';

	/// en: 'Allow'
	String get allow => 'Allow';

	/// en: 'Not now'
	String get notNow => 'Not now';
}

// Path: features.dashboard.activityHistory
class Translations$features$dashboard$activityHistory$en {
	Translations$features$dashboard$activityHistory$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Recent Activity'
	String get title => 'Recent Activity';

	/// en: 'Today'
	String get rangeToday => 'Today';

	/// en: 'This Week'
	String get rangeThisWeek => 'This Week';

	/// en: 'This Month'
	String get rangeThisMonth => 'This Month';

	/// en: '3 Months'
	String get rangeThreeMonths => '3 Months';

	/// en: '6 Months'
	String get rangeSixMonths => '6 Months';

	/// en: 'No activity in this period'
	String get emptyTitle => 'No activity in this period';

	/// en: 'No payments or announcements in the range you selected.'
	String get emptySubtitle => 'No payments or announcements in the range you selected.';
}

// Path: features.dues.resident
class Translations$features$dues$resident$en {
	Translations$features$dues$resident$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Paid'
	String get paidStatus => 'Paid';

	/// en: 'Your due is overdue'
	String get overdueStatus => 'Your due is overdue';

	/// en: 'Payment pending'
	String get pendingStatus => 'Payment pending';

	/// en: 'You are waived this period'
	String get waivedStatus => 'You are waived this period';

	/// en: 'Your due is {days} days overdue'
	String get overdueDetail => 'Your due is {days} days overdue';

	/// en: 'Due by {day} {month}'
	String get pendingDetail => 'Due by {day} {month}';

	/// en: 'You paid on {date} · {days} days late'
	String get paidLateSummary => 'You paid on {date} · {days} days late';

	/// en: 'You paid on {date}'
	String get paidOnTimeSummary => 'You paid on {date}';

	/// en: 'Your dues are up to date'
	String get duesUpToDate => 'Your dues are up to date';

	/// en: '{count} overdue due · {amount}'
	String get debtBannerOverdue => '{count} overdue due · {amount}';

	/// en: '{count} due pending · {amount}'
	String get debtBannerPending => '{count} due pending · {amount}';

	/// en: 'Payment records'
	String get paymentRecordsLabel => 'Payment records';

	/// en: 'Paid on {date}'
	String get ledgerPaidSubtitle => 'Paid on {date}';

	/// en: '{days} days overdue'
	String get ledgerOverdueSubtitle => '{days} days overdue';

	/// en: 'Due by: {date}'
	String get ledgerPendingSubtitle => 'Due by: {date}';

	/// en: 'Paid'
	String get badgePaid => 'Paid';

	/// en: 'Pending'
	String get badgePending => 'Pending';

	/// en: 'Overdue'
	String get badgeOverdue => 'Overdue';

	/// en: 'Waived'
	String get badgeWaived => 'Waived';
}

// Path: features.dues.transactions
class Translations$features$dues$transactions$en {
	Translations$features$dues$transactions$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Dues Status Summary'
	String get title => 'Dues Status Summary';

	/// en: 'Your Transaction History'
	String get residentTitle => 'Your Transaction History';

	/// en: 'No transactions yet'
	String get emptyTitle => 'No transactions yet';

	/// en: 'Receipt approvals and manual payments appear here.'
	String get emptySubtitle => 'Receipt approvals and manual payments appear here.';

	/// en: 'No transactions yet'
	String get residentEmptyTitle => 'No transactions yet';

	/// en: 'Your payments and receipts will appear here.'
	String get residentEmptySubtitle => 'Your payments and receipts will appear here.';

	/// en: 'Receipt'
	String get sourceReceipt => 'Receipt';

	/// en: 'Manual'
	String get sourceManual => 'Manual';

	/// en: 'Approved'
	String get statusApproved => 'Approved';

	/// en: 'Pending'
	String get statusPending => 'Pending';

	/// en: 'Rejected'
	String get statusRejected => 'Rejected';

	/// en: 'No apartment info'
	String get unknownApartment => 'No apartment info';

	/// en: 'You paid your due in person'
	String get residentPaidByManual => 'You paid your due in person';

	/// en: 'You paid your due with a receipt'
	String get residentPaidByReceipt => 'You paid your due with a receipt';

	/// en: 'Your receipt is awaiting approval'
	String get residentDekontPending => 'Your receipt is awaiting approval';

	/// en: 'Your receipt was rejected'
	String get residentDekontRejected => 'Your receipt was rejected';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'common.logout' => 'Logout',
			'common.cancel' => 'Cancel',
			'common.confirm' => 'Confirm',
			'common.ok' => 'OK',
			'common.save' => 'Save',
			'common.delete' => 'Delete',
			'common.edit' => 'Edit',
			'common.close' => 'Close',
			'common.yes' => 'Yes',
			'common.no' => 'No',
			'common.register' => 'Register',
			'common.login' => 'Login',
			'common.join' => 'Join',
			'common.confirmMessage' => 'Are you sure?',
			'common.logoutConfirm' => 'Are you sure you want to logout?',
			'common.logoutSuccess' => 'Signed out successfully.',
			'common.logoutAllDevices' => 'Sign out other devices',
			'common.logoutAllDevicesConfirm' => 'Sessions on your other phones and tablets will end. You will stay signed in on this device.',
			'common.logoutAllDevicesSuccess' => 'Signed out of other devices successfully.',
			'common.logoutAllDevicesFailed' => 'Could not complete this action. Try again.',
			'common.thisDevice' => 'This device',
			'common.signedInAt' => ({required Object date}) => 'Signed in: ${date}',
			'common.removeSession' => 'Remove',
			'common.removeSessionConfirm' => 'This device will be signed out. Do you want to continue?',
			'common.removeAllOtherSessions' => 'Sign out all other devices',
			'common.removeAllOtherSessionsConfirm' => 'Sessions on your other phones and tablets will end. You will stay signed in on this device.',
			'common.sessionRemoved' => 'Session ended.',
			'common.noOtherSessions' => 'No other active device sessions.',
			'common.sessionsScreenHint' => 'View devices signed in to your account and sign out any you do not recognize.',
			'common.sessionExpired' => 'Your session on this device has been ended by another device.',
			'common.account' => 'Account',
			'common.editProfile' => 'Edit Profile',
			'common.changePassword' => 'Change Password',
			'common.language' => 'Language',
			'common.theme' => 'Theme',
			'common.themeLight' => 'Light',
			'common.themeDark' => 'Dark',
			'common.themeSystem' => 'System',
			'common.themeSheetDescription' => 'You can change the app appearance here.',
			'common.themeLightSubtitle' => 'Light',
			'common.themeDarkSubtitle' => 'Dark',
			'common.themeSystemSubtitle' => 'System',
			'common.turkish' => 'Turkish',
			'common.notifications' => 'Notifications',
			'common.info' => 'Info',
			'common.privacyPolicy' => 'Privacy Policy',
			'common.kvkk' => 'KVKK',
			'common.helpSupport' => 'Help & Support',
			'common.about' => 'About',
			'common.comingSoon' => 'This feature will be added soon',
			'common.multiLanguageComingSoon' => 'Multi-language support coming soon',
			'common.copyright' => ' 2026 AidatPanel\nAll rights reserved.',
			'common.aboutDescription' => 'Dues management platform for Turkish apartment and site managers.',
			'common.manager' => 'Manager',
			'common.resident' => 'Resident',
			'common.tokenExpiryTest' => 'Token Expiry Check (Test)',
			'common.tokenExpired' => 'Token EXPIRED! Redirecting to login screen.',
			'common.tokenActive' => 'Token active! Remaining time',
			'common.pressBackAgainToExit' => 'Press back again to exit',
			'common.loading' => 'Loading…',
			'common.loadingBuildings' => 'Loading buildings…',
			'common.loadFailed' => 'Failed to load',
			'common.unexpectedError' => 'Something went wrong. Try again.',
			'common.api.networkError' => 'Check your internet connection and try again.',
			'common.api.serverError' => 'Could not reach the server. Try again later.',
			'common.api.validationError' => 'Please check the information you entered.',
			'common.api.notFound' => 'The requested record was not found.',
			'common.api.unauthorized' => 'Your session has ended. Sign in again.',
			'common.api.rateLimit' => 'Too many attempts. Please wait a moment and try again.',
			'common.api.forbidden' => 'You do not have permission for this action.',
			'common.api.genericError' => 'Something went wrong. Try again.',
			'common.api.invalidCredentials' => 'Email, phone, or password is incorrect. Please check and try again.',
			'common.api.duplicateEmail' => 'This email is already registered. Try signing in.',
			'common.api.duplicatePhone' => 'This phone number is already registered.',
			'common.api.accountNotFoundEmail' => 'No account found with this email. Check your details or sign up.',
			'common.api.accountNotFoundPhone' => 'No account found with this phone number. Check your details or sign up.',
			'common.api.identifierCheckFailed' => 'Could not verify email or phone. Try again.',
			'common.api.invalidInviteCode' => 'Invite code is invalid. Check the code and try again.',
			'common.api.inviteCodeUsed' => 'This invite code has already been used.',
			'common.api.inviteCodeExpired' => 'This invite code has expired. Ask your manager for a new one.',
			'common.api.resetTokenInvalid' => 'Code is invalid or expired. Request a new code and try again.',
			'common.api.recordConflict' => 'This record already exists.',
			'common.api.relatedRecordMissing' => 'A related record required for this action was not found.',
			'common.api.buildingAccessDenied' => 'Building not found or you do not have access.',
			'common.api.invalidIban' => 'Invalid IBAN. Enter a 26-digit TR IBAN.',
			'common.api.apartmentNoResident' => 'There is no resident to remove from this apartment.',
			'common.api.ticketClosedNote' => 'Notes cannot be added to a closed or resolved ticket.',
			'common.api.ticketClosedStatus' => 'Status of a closed ticket cannot be changed.',
			'common.api.ticketInvalidStatus' => 'This status change is not allowed. Refresh the list and try again.',
			'common.api.serviceUnavailable' => 'This action is not available right now. Try again later.',
			'common.api.fileUploadError' => 'File could not be uploaded. Try again.',
			'common.api.fileContentMismatch' => 'File type does not match its contents. Choose another file.',
			'common.api.invalidPdf' => 'PDF could not be read or is corrupted. Try another file.',
			'common.api.notificationNotFound' => 'Notification not found.',
			'common.api.invalidCursor' => 'List could not be refreshed. Reload the page and try again.',
			'common.api.expenseNotFound' => 'Expense record not found.',
			'common.api.dueNotFound' => 'Due record not found.',
			'common.api.dekontNotFound' => 'Receipt not found.',
			'common.api.noApartmentForPayment' => 'You must be assigned to an apartment before viewing payment details.',
			'common.rateLimitHint' => 'The server is currently busy. We\'ll retry shortly.',
			'common.tryAgain' => 'Try Again',
			'common.documentPreview.title' => 'View document',
			'common.documentPreview.share' => 'Share',
			'common.documentPreview.pdfUnavailable' => 'PDF could not be opened on this device. Use Share to open it in another app.',
			'common.documentPreview.pinchHint' => 'Pinch to zoom and drag to pan',
			'common.home' => 'Home',
			'common.buildings' => 'Buildings',
			'common.dues' => 'Dues',
			'common.settings' => 'Settings',
			'common.user' => 'User',
			'common.welcome' => 'Welcome',
			'common.welcomeBack' => 'Welcome Back',
			'common.managedBuildings' => 'Managed Buildings',
			'common.issues' => 'Requests',
			'common.issuesTab' => 'Requests tab',
			'common.apartment' => 'Apartment',
			'common.addBuilding' => 'Add Building',
			'common.inviteCode' => 'Invite Code',
			'common.myBuildings' => 'My Buildings',
			'common.apartments' => 'Apartments',
			'common.collection' => 'Collection',
			'common.monthlyDues' => 'Monthly Dues',
			'common.duesTab' => 'Dues Tab',
			'common.totalApartments' => 'Total Apartments',
			'common.occupiedApartments' => 'Occupied Apartments',
			'common.duesCollection' => 'Dues Collection',
			'common.totalDues' => 'Total Dues',
			'common.recentTransactions' => 'Recent Transactions',
			'common.recentMovements' => 'Recent Activity',
			'common.seeAll' => 'See all',
			'common.payDue' => 'Pay due',
			'common.noCurrentDebt' => 'You have no current balance due ✓',
			'common.announcements' => 'Announcements',
			'common.paid' => 'Paid',
			'common.pending' => 'Pending',
			'common.overdue' => 'Overdue',
			'common.balance' => 'Balance',
			'common.amountDue' => 'Amount Due',
			'common.lastPayment' => 'Last Payment',
			'common.makePayment' => 'Make Payment',
			'common.bills' => 'Bills',
			'common.support' => 'Support',
			'common.quickActions' => 'Quick Actions',
			'common.myApplications' => 'My applications',
			'common.myAnnouncements' => 'Announcements',
			'common.debtAndPay' => 'Debt & pay',
			'common.duesStatus' => 'Dues status',
			'common.accountSummary' => 'Account summary',
			'common.accountSummarySubtitle' => 'Period summary and details',
			'common.myReceiptsSubtitle' => 'Your payment receipts',
			'common.myPaymentRequestSubtitle' => 'Create a payment request',
			'common.mySettings' => 'My settings',
			'common.myReceipts' => 'My receipts',
			'common.myPaymentRequest' => 'Payment request',
			'common.duesHistory' => 'History',
			'common.addRequest' => 'Create request',
			'common.payDebt' => 'Pay debt',
			'common.tabAll' => 'All',
			'common.tabFaults' => 'Faults',
			'common.tabRequests' => 'Requests',
			'common.apartmentNo' => 'Apartment no.',
			'common.fullName' => 'Full name',
			'common.debtAmount' => 'Debt',
			'common.lastDueDate' => 'Due date',
			'common.residentName' => 'Resident Name',
			'common.addBuildingNew' => 'Add New Building',
			'common.basicInfo' => 'Basic Info',
			'common.buildingName' => 'Building Name',
			'common.buildingNameHint' => 'Ex: Güneş Apartmanı',
			'common.location' => 'Location',
			'common.streetAddress' => 'Street Address',
			'common.streetAddressHint' => 'Ex: Bağdat Cad. No: 123',
			'common.details' => 'Details',
			'common.floorCount' => 'Floor Count',
			'common.floorCountHint' => '1–200',
			'common.apartmentsPerFloor' => 'Units per Floor',
			'common.apartmentsPerFloorHint' => '1–50',
			'common.floorRangeError' => 'Floor count must be between 1 and 200',
			'common.apartmentsPerFloorRangeError' => 'Apartments per floor must be between 1 and 50',
			'common.buildingAddFailed' => 'Could not add building. Try again.',
			'common.monthlyDuesLabel' => 'Monthly Dues (₺)',
			'common.monthlyDuesHint' => 'Ex: 1000',
			'common.createBuilding' => 'Create Building',
			'common.cancelBtn' => 'Cancel',
			'common.cityRequired' => 'City *',
			'common.selectCity' => 'Select City',
			'common.districtRequired' => 'District *',
			'common.selectDistrict' => 'Select District',
			'common.selectCityFirst' => 'Select city first',
			'common.selectCityTitle' => 'Select City',
			'common.selectDistrictTitle' => 'Select District',
			'common.neighborhoodRequired' => 'Neighborhood *',
			'common.selectNeighborhood' => 'Select neighborhood',
			'common.selectNeighborhoodTitle' => 'Select Neighborhood',
			'common.selectDistrictFirst' => 'Select district first',
			'common.wizardNext' => 'Next',
			'common.wizardBack' => 'Back',
			'common.wizardMore' => 'More',
			'common.wizardEnterNumber' => 'Enter number',
			'common.wizardBackToGrid' => 'Back to list',
			'common.wizardNumberRangeError' => 'Number must be between {min} and {max}',
			'common.wizardLocationLoadFailed' => 'Could not load city and district list. Try again.',
			'common.wizardNeighborhoodLoadFailed' => 'Could not load neighborhoods. Check your connection and try again.',
			'common.wizardStepBuildingName' => 'Name',
			'common.wizardStepSiteName' => 'Site',
			'common.wizardStepBlockInfo' => 'Block',
			'common.wizardStepLocation' => 'City',
			'common.wizardStepNeighborhoodAddress' => 'Area',
			'common.wizardStepFloors' => 'Floors',
			'common.wizardStepApartments' => 'Units',
			'common.wizardStepDues' => 'Dues',
			'common.wizardStepRecipient' => 'Recipient',
			'common.wizardStepSiteOverrides' => 'Settings',
			'common.wizardPickFloorCount' => 'Select number of floors',
			'common.wizardPickApartmentCount' => 'Select units per floor',
			'common.search' => 'Search...',
			'common.noResults' => 'No results found',
			'common.fieldRequired' => 'cannot be empty',
			'common.fillRequiredFields' => 'Please fill required fields',
			'common.selectCityAndDistrict' => 'You must select city and district',
			'common.floorApartmentMustBePositive' => 'Floor count and apartment count must be greater than 0',
			'common.buildingAddedSuccess' => 'Building added successfully',
			'common.createInviteCode' => 'Create Invite Code',
			'common.whichBuildingForCode' => 'Which building to generate code for?',
			'common.whichSiteForCode' => 'Which site should the code be for?',
			'common.inviteStandaloneBuildings' => 'Standalone buildings',
			'common.whichApartmentForCode' => 'Which apartment to generate code for?',
			'common.noApartmentsInBuilding' => 'No apartments added to this building yet',
			'common.activeCodeBadge' => 'Active Code',
			'common.occupiedBadge' => 'Occupied',
			'common.emptyBadge' => 'Empty',
			'common.activeCodePrefix' => 'Active code',
			'common.residentPrefix' => 'Resident',
			'common.emptyApartment' => 'Empty apartment',
			'common.pendingInviteStatus' => 'Invite pending',
			'common.viewInvite' => 'View invite',
			'common.codeRevoked' => 'Code revoked',
			'common.codeCopied' => 'Code copied',
			'common.clipboardCopied' => 'Message copied to clipboard',
			'common.expiresAtPrefix' => 'Expires at',
			'common.remainingPrefix' => 'Remaining',
			'common.buildingDetail' => 'Building Detail',
			'common.residents' => 'Residents',
			'common.apartmentsBadge' => 'Apartments',
			'common.emptyApartmentText' => 'Empty Apartment',
			'common.emptyApartmentAwaitingResident' => 'No resident has been assigned to this apartment yet',
			'common.inviteResident' => 'Invite',
			'common.vacantBadge' => 'Vacant',
			'common.phoneNotShared' => 'Phone not shared',
			'common.residentDetailsLink' => 'View Details',
			'common.duesPaidStatus' => 'Dues Paid',
			'common.duesPendingStatus' => 'Dues Pending',
			'common.duesOverdueStatus' => 'Dues Overdue',
			'common.noResidentInApartment' => 'No resident assigned',
			'common.residentDetailsSheetTitle' => 'Resident information',
			'common.apartmentDetailsSheetTitle' => 'Apartment information',
			'common.noResidentAssigned' => 'No resident assigned',
			'common.noApartmentsYet' => 'No apartments added yet',
			'common.paidStatus' => 'Paid',
			'common.pendingStatus' => 'Pending',
			'common.overdueStatus' => 'Overdue',
			'common.waivedStatus' => 'Waived',
			'common.all' => 'All',
			'common.status' => 'Status',
			'common.month' => 'Month',
			'common.dayLabel' => 'Day',
			'common.pickDate' => 'Select date',
			'common.monthJanuary' => 'January',
			'common.monthFebruary' => 'February',
			'common.monthMarch' => 'March',
			'common.monthApril' => 'April',
			'common.monthMay' => 'May',
			'common.monthJune' => 'June',
			'common.monthJuly' => 'July',
			'common.monthAugust' => 'August',
			'common.monthSeptember' => 'September',
			'common.monthOctober' => 'October',
			'common.monthNovember' => 'November',
			'common.monthDecember' => 'December',
			'common.allMonths' => 'All months',
			'common.year' => 'Year',
			'common.allYears' => 'All years',
			'common.note' => 'Note',
			'common.myDuesHistory' => 'My Dues History',
			'common.currentPeriodDue' => 'Current due',
			'common.myPastDues' => 'My past dues',
			'common.buildingDues' => 'Building Dues',
			'common.noDuesYet' => 'No dues records yet',
			'common.residentNoDuesYet' => 'No dues have been assigned to you yet',
			'common.duesUpdated' => 'Dues status updated',
			'common.amount' => 'Amount',
			'common.updateDueAmount' => 'Update Due Amount',
			'common.dueSettings' => 'Due Settings',
			'common.dueLatePaymentBadge' => '{days} days late',
			'common.viewPaymentHistory' => 'View Payment History',
			'common.paymentHistoryTitle' => 'Payment History',
			'common.dueAmountUpdated' => 'Due amount updated',
			'common.dueAmountUpdateFailed' => 'Could not update due amount',
			'common.dueDay' => 'Due Day (1-28)',
			'common.selectDueDay' => 'Select day',
			'common.affectCurrentDues' => 'Apply to pending dues',
			'common.affectCurrentDuesHint' => 'Open dues (pending and overdue) get updated amounts and due dates. If the new due date has not passed yet, overdue status is cleared.',
			'common.dueUpdateNeedAmountOrDay' => 'Enter an amount or select a due day to update.',
			'common.dueUpdateNeedStoredAmount' => 'This building has no saved amount yet. Enter an amount before updating the due day only.',
			'common.dueAmountInvalidPositive' => 'Enter a valid amount.',
			'common.dueDayOutOfRange' => 'Due day must be between 1 and 28.',
			'common.update' => 'Update',
			'common.filter' => 'Filter',
			'common.apply' => 'Apply',
			'common.overdueDays' => 'days overdue',
			'common.dueMetaOverdueDelay' => '{days} days late',
			'common.dueStatusOverdueWithDays' => '{days} days late',
			'common.duePaidSummaryLate' => '{date} - {days} days late',
			'common.dueMetaPendingDueDate' => 'due by {day} {month}',
			'common.payShort' => 'Pay',
			'common.dekontShort' => 'Receipt',
			'common.monthChipLabel' => 'MONTH',
			'common.yearChipLabel' => 'YEAR',
			'common.dueDateLabel' => 'Due date',
			'common.perMonth' => '/ month',
			'common.floorLabel' => 'FLOOR',
			'common.apartmentLabel' => 'APT',
			'common.turkishLanguage' => 'Türkçe',
			'common.englishLanguage' => 'English',
			'common.turkishLanguageSubtitle' => 'Turkish',
			'common.englishLanguageSubtitle' => 'İngilizce',
			'common.stepSite' => 'Site',
			'common.stepBuilding' => 'Building',
			'common.stepApartment' => 'Apartment',
			'common.stepCode' => 'Code',
			'common.editBuilding' => 'Edit Building',
			'common.deleteBuilding' => 'Delete Building',
			'common.buildingUpdated' => 'Building updated',
			'common.buildingDeleted' => 'Building deleted',
			'common.buildingUpdateFailed' => 'Could not update building',
			'common.buildingDeleteFailed' => 'Could not delete building',
			'common.buildingDeleteFailedFK' => 'Cannot delete this building: apartments, residents, or dues still exist.',
			'common.deleteBuildingHeader' => 'This action cannot be undone.',
			'common.deleteBuildingTypeHint' => 'To confirm, type the building name below exactly:',
			'common.deleteBuildingTypeFieldLabel' => 'Building name',
			'common.buildingNameMismatch' => 'What you typed does not match the building name.',
			'common.deleteSite' => 'Delete Site',
			'common.siteDeleted' => 'Site deleted',
			'common.siteDeleteFailed' => 'Could not delete site',
			'common.deleteSiteHeader' => 'This action cannot be undone. Blocks under the site are also affected.',
			'common.deleteSiteTypeHint' => 'To confirm, type the site name below exactly:',
			'common.deleteSiteTypeFieldLabel' => 'Site name',
			'common.siteNameMismatch' => 'What you typed does not match the site name.',
			'common.editApartment' => 'Edit Apartment',
			'common.deleteApartment' => 'Delete Apartment',
			'common.addApartment' => 'Add Apartment',
			'common.apartmentUpdated' => 'Apartment updated',
			'common.apartmentCreated' => 'Apartment added',
			'common.apartmentDeleted' => 'Apartment deleted',
			'common.apartmentUpdateFailed' => 'Could not update apartment',
			'common.apartmentDeleteFailed' => 'Could not delete apartment',
			'common.apartmentDeleteFailedFK' => 'Cannot delete this apartment: resident or dues records still exist.',
			'common.deleteApartmentConfirm' => 'Are you sure you want to delete this apartment?',
			'common.apartmentNumberLabel' => 'Apt No (e.g. 5)',
			'common.floorLabel2' => 'Floor (optional)',
			'common.floorOptional' => 'Floor (-5 to 200)',
			'common.buildingNameField' => 'Building name',
			'common.buildingAddressField' => 'Address',
			'common.buildingCityField' => 'City',
			'common.monthlyDuesPerApartment' => 'Monthly dues / apt',
			'common.remove' => 'Remove',
			'common.removeResident' => 'Remove Resident',
			'common.removeResidentConfirm' => 'Are you sure you want to remove this resident from the apartment?',
			'common.removeResidentNote' => 'The resident\'s account will not be deleted; only their link to this apartment is removed. Past dues records are kept. The resident can join another apartment later using an invite code.',
			'common.residentRemoved' => 'Resident removed from apartment',
			'common.residentRemoveFailed' => 'Could not remove resident',
			'common.residentRemoveForbidden' => 'You are not allowed to perform this action. Only the building manager can remove residents.',
			'common.residentRemoveNotFound' => 'No resident to remove from this apartment.',
			'common.multiSelectResidents' => 'Select multiple',
			'common.multiSelectTapHint' => 'Tap the card to select or clear',
			'common.selectTriggerShort' => 'Select',
			'common.selectedCountLabel' => 'selected',
			'common.selectionRemoveHint' => 'Pick the residents you want to remove',
			'common.selectionDeleteIbanHint' => 'Pick the IBANs you want to delete',
			'common.removeSelectedResidents' => 'Remove selected',
			'common.removeSelectedResidentsTitle' => 'Remove selected residents',
			'common.removeSelectedResidentsMessage' => 'Residents in the apartments listed below will be unlinked from their apartments. Accounts are not deleted—only the connection to this building is removed. Past dues records are kept.',
			'common.removeSelectedResidentsAffectedListTitle' => 'Apartments affected',
			'common.removeSelectedResidentsListUnavailable' => 'The apartment list could not be loaded. The count is shown below. If you confirm, removals will still proceed.',
			'common.pickResidentsFirst' => 'Select at least one occupied apartment from the list first',
			'common.noResidentsToRemoveInBuilding' => 'There are no residents to remove in this building.',
			'common.removeSelectedProgress' => 'Working…',
			'common.removeSelectedSuccess' => 'Selected residents were removed from their apartments',
			'common.removeSelectedFailed' => 'Could not finish removing the selected residents',
			'common.currentPassword' => 'Current Password',
			'common.newPassword' => 'New Password',
			'common.newPasswordConfirm' => 'New Password (Repeat)',
			'common.currentPasswordRequired' => 'Enter your current password',
			'common.passwordsMustDiffer' => 'New password cannot be the same as the old one',
			'common.changePasswordTitle' => 'Change Password',
			'common.changePasswordSubtitle' => 'Update your password regularly to keep your account secure.',
			'common.changePasswordSuccess' => 'Your password was changed successfully.',
			'common.changePasswordFailed' => 'Could not change password. Try again.',
			'common.changePasswordWrongCurrent' => 'Current password is incorrect.',
			'common.languageSheetDescription' => 'You can change the application language here.',
			'common.friendlyError.networkTitle' => 'No internet connection',
			'common.friendlyError.networkMessage' => 'Please make sure your phone is connected to the internet and try again.',
			'common.friendlyError.unauthorizedTitle' => 'Session ended',
			'common.friendlyError.unauthorizedMessage' => 'Please close the app and sign in again.',
			'common.friendlyError.serverTitle' => 'Cannot reach the server',
			'common.friendlyError.serverMessage' => 'Please try again in a moment.',
			'common.friendlyError.genericTitle' => 'This page could not be opened',
			'common.friendlyError.genericMessage' => 'Please close and reopen the app.',
			'common.friendlyError.debugOnlyLabel' => 'Visible to developers only (debug):',
			'common.newPasswordHint' => 'Must include uppercase, lowercase, and a number',
			'common.passwordStrengthUnspecified' => 'Not specified',
			'common.passwordStrengthWeak' => 'Weak',
			'common.passwordStrengthMedium' => 'Medium',
			'common.passwordStrengthStrong' => 'Strong',
			'common.passwordStrengthLabel' => 'New password strength: {level}',
			'common.deleteAccount' => 'Close My Account',
			'common.deleteAccountTitle' => 'Do you want to close your account?',
			'common.deleteAccountWarning' => 'This action cannot be undone. Your personal data will be removed, but for legal reasons some records (such as dues history) are kept anonymously.',
			'common.deleteAccountTypeHint' => 'To confirm, type "CLOSE MY ACCOUNT" below:',
			'common.deleteAccountTypePhrase' => 'CLOSE MY ACCOUNT',
			'common.deleteAccountTypeMismatch' => 'What you typed does not match.',
			'common.deleteAccountConfirmButton' => 'Close My Account',
			'common.deleteAccountSuccess' => 'Your account was closed successfully.',
			'common.deleteAccountFailed' => 'Could not close account. Try again.',
			'common.deleteAccountFailedManager' => 'You first need to delete the buildings you manage or transfer them to another manager.',
			'common.dangerZone' => 'Danger Zone',
			'common.forgotPassword' => 'Forgot Password',
			'common.forgotPasswordTitle' => 'Forgot Password',
			'common.forgotPasswordSubtitle' => 'Enter your registered email or phone and we\'ll send you a reset code.',
			'common.forgotPasswordSuccess' => 'Code sent successfully.',
			'common.forgotPasswordSuccessEmail' => 'Code sent successfully to your email.',
			'common.forgotPasswordSuccessSms' => 'Code sent successfully by SMS.',
			'common.forgotPasswordSmsFallback' => 'Didn\'t get the code? Send via SMS',
			'common.forgotPasswordSmsFallbackSuccess' => 'Code sent successfully by SMS.',
			'common.sendResetCode' => 'Send Code',
			'common.iHaveACode' => 'I already have a code',
			'common.resetPasswordTitle' => 'Set New Password',
			'common.resetPasswordSubtitle' => 'Enter the 6-character code you received and a new password.',
			'common.resetPasswordSubtitleEmail' => 'Enter the 6-character code from your email and a new password.',
			'common.resetPasswordSubtitleSms' => 'Enter the 6-character code from your SMS and a new password.',
			'common.resetCode' => 'Reset Code',
			'common.resetCodeHint' => 'ABC123',
			'common.resetCodeRequired' => 'Reset code required',
			'common.resetCodeInvalid' => 'Code must be 6 characters',
			'common.resetPasswordSuccess' => 'Your password was reset successfully.',
			'common.resetPasswordFailed' => 'Could not reset password. The code may be invalid or expired.',
			'common.resetPasswordSubmit' => 'Reset Password',
			'common.backToLogin' => 'Back to login',
			'common.select' => 'Select',
			'common.kNew' => 'New',
			'common.errorKeys.authLoginFailed' => 'There was a problem signing in. Try again.',
			'common.errorKeys.authRegisterFailed' => 'There was a problem creating your account. Try again.',
			'common.errorKeys.authJoinFailed' => 'There was a problem joining the apartment. Try again.',
			'common.errorKeys.authLogoutAllDevicesFailed' => 'Could not sign out other devices. Try again.',
			'common.errorKeys.authForgotPasswordRequestFailed' => 'Could not send the request. Try again.',
			'common.errorKeys.authResetPasswordFailed' => 'Could not reset your password. Try again.',
			'common.errorKeys.dashboardSummaryFetchFailed' => 'Could not load the summary. Try again.',
			'common.errorKeys.dashboardCollectionFetchFailed' => 'Could not load the collection summary. Try again.',
			'common.errorKeys.buildingFetchFailed' => 'Could not load buildings. Try again.',
			'common.errorKeys.collectionPresetsFetchFailed' => 'Could not load collection suggestions. Try again.',
			'common.errorKeys.buildingCreateFailed' => 'Could not add the building. Try again.',
			'common.errorKeys.buildingUpdateFailed' => 'Could not update the building. Try again.',
			'common.errorKeys.buildingCollectionUpdateFailed' => 'Could not update collection details. Try again.',
			'common.errorKeys.collectionPresetNotFound' => 'No IBAN record was found to update or delete.',
			'common.errorKeys.collectionPresetSaveFailed' => 'Could not save the IBAN. Try again.',
			'common.errorKeys.collectionPresetDeleteFailed' => 'Could not delete the IBAN. Try again.',
			'common.errorKeys.buildingDeleteFailed' => 'Could not delete the building. Try again.',
			'common.errorKeys.inviteCodeCreateFailed' => 'Could not create the invite code. Try again.',
			'common.errorKeys.apartmentsFetchFailed' => 'Could not load apartments. Try again.',
			'common.errorKeys.apartmentCreateFailed' => 'Could not add the apartment. Try again.',
			'common.errorKeys.apartmentUpdateFailed' => 'Could not update the apartment. Try again.',
			'common.errorKeys.apartmentDeleteFailed' => 'Could not delete the apartment. Try again.',
			'common.errorKeys.residentRemoveFailed' => 'Could not remove the resident. Try again.',
			'common.errorKeys.buildingDuesFetchFailed' => 'Could not load the dues list. Try again.',
			'common.errorKeys.dueTransactionsFetchFailed' => 'Could not load dues transaction history. Try again.',
			'common.errorKeys.myDuesFetchFailed' => 'Could not load your dues. Try again.',
			'common.errorKeys.dueStatusUpdateFailed' => 'Could not update the due status. Try again.',
			'common.errorKeys.dueAmountUpdateFailed' => 'Could not update the due amount. Try again.',
			'common.errorKeys.dueReminderFailed' => 'Could not send the reminder. Try again.',
			'common.errorKeys.myTicketsFetchFailed' => 'Could not load requests. Try again.',
			'common.errorKeys.buildingTicketsFetchFailed' => 'Could not load building requests. Try again.',
			'common.errorKeys.ticketDetailFetchFailed' => 'Could not load request details. Try again.',
			'common.errorKeys.ticketCreateFailed' => 'Could not create the request. Try again.',
			'common.errorKeys.ticketNoteAddFailed' => 'Could not add the note. Try again.',
			'common.errorKeys.ticketStatusUpdateFailed' => 'Could not update the request status. Try again.',
			'common.errorKeys.expensesFetchFailed' => 'Could not load expenses. Try again.',
			'common.errorKeys.expenseSummaryFetchFailed' => 'Could not load the expense summary. Try again.',
			'common.errorKeys.expenseCreateFailed' => 'Could not save the expense. Try again.',
			'common.errorKeys.expenseUpdateFailed' => 'Could not update the expense. Try again.',
			'common.errorKeys.expenseDeleteFailed' => 'Could not delete the expense. Try again.',
			'common.errorKeys.expenseReceiptsUploadFailed' => 'Could not upload receipts. Try again.',
			'common.errorKeys.profileFetchFailed' => 'Could not load profile information. Try again.',
			'common.errorKeys.profileUpdateFailed' => 'Could not update the profile. Try again.',
			'common.errorKeys.languageUpdateFailed' => 'Could not save the language preference. Try again.',
			'common.errorKeys.passwordChangeFailed' => 'Could not change the password. Try again.',
			'common.errorKeys.accountDeleteFailed' => 'Could not close the account. Try again.',
			'common.errorKeys.profilePictureUploadFailed' => 'Could not upload the profile photo. Try again.',
			'common.errorKeys.profilePictureDeleteFailed' => 'Could not remove the profile photo. Try again.',
			'common.errorKeys.notificationCountFetchFailed' => 'Could not load the notification count. Try again.',
			'common.errorKeys.notificationsFetchFailed' => 'Could not load notifications. Try again.',
			'common.errorKeys.announcementCountFetchFailed' => 'Could not load the announcement count. Try again.',
			'common.errorKeys.notificationMarkReadFailed' => 'Could not mark the notification as read. Try again.',
			'common.errorKeys.notificationsMarkAllReadFailed' => 'Could not mark notifications as read. Try again.',
			'common.errorKeys.announcementSendFailed' => 'Could not send the announcement. Try again.',
			'common.errorKeys.sitesFetchFailed' => 'Could not load sites. Try again.',
			'common.errorKeys.siteDetailFetchFailed' => 'Could not load site details. Try again.',
			'common.errorKeys.siteBuildingsFetchFailed' => 'Could not load blocks. Try again.',
			'common.errorKeys.siteCreateFailed' => 'Could not add the site. Try again.',
			'common.errorKeys.siteUpdateFailed' => 'Could not update the site. Try again.',
			'common.errorKeys.siteCollectionUpdateFailed' => 'Could not update site collection details. Try again.',
			'common.errorKeys.siteDeleteFailed' => 'Could not delete the site. Try again.',
			'common.errorKeys.siteBuildingCreateFailed' => 'Could not add the block. Try again.',
			_ => null,
		} ?? switch (path) {
			'common.errorKeys.siteExpensesFetchFailed' => 'Could not load site expenses. Try again.',
			'common.errorKeys.siteExpenseSummaryFetchFailed' => 'Could not load the site expense summary. Try again.',
			'common.errorKeys.siteExpenseCreateFailed' => 'Could not add the site expense. Try again.',
			'common.errorKeys.siteExpenseUpdateFailed' => 'Could not update the site expense. Try again.',
			'common.errorKeys.siteExpenseDeleteFailed' => 'Could not delete the site expense. Try again.',
			'common.errorKeys.subscriptionFetchFailed' => 'Could not load subscription information. Try again.',
			'common.errorKeys.firebasePhoneInvalid' => 'Enter a valid phone number.',
			'common.errorKeys.firebasePhoneTooMany' => 'Too many attempts. Try again later.',
			'common.errorKeys.firebasePhoneTimeout' => 'Verification timed out. Request a new code.',
			'common.errorKeys.firebasePhoneSessionExpired' => 'Verification session expired. Request a new code.',
			'common.errorKeys.firebasePhoneCodeInvalid' => 'Incorrect code. Try again.',
			'common.errorKeys.firebasePhoneFailed' => 'Phone verification failed. Try again.',
			'common.errorKeys.firebasePhoneAppVerify' => 'Verification could not finish. Update the app and try again.',
			'common.errorKeys.firebasePhoneNotEnabled' => 'Phone sign-in is unavailable right now.',
			'common.errorKeys.firebasePhoneCarrierBlocked' => 'SMS cannot be sent to this number. Try another number or try again later.',
			'common.errorKeys.invalidExpenseResponse' => 'Could not read expense information. Try again.',
			'common.errorKeys.invalidSiteExpenseResponse' => 'Could not read site expense information. Try again.',
			'common.errorKeys.unsupportedFileType' => 'This file type is not supported.',
			'common.errorKeys.dekontUploadFailed' => 'Could not upload the receipt. Try again.',
			'common.errorKeys.serverResponseUnreadable' => 'Could not read the information. Try again.',
			'common.errorKeys.dekontResponseMissing' => 'Could not read the information. Try again.',
			'common.errorKeys.dekontResponseParseFailed' => 'Could not read the information. Try again.',
			'common.errorKeys.reportFileEmpty' => 'The report file was empty. Try again.',
			'common.errorKeys.downloadStarted' => 'Download started...',
			'common.errorKeys.downloadSavedToGallery' => 'Image saved successfully.',
			'common.errorKeys.downloadSavedToDownloads' => 'Receipt saved successfully to Downloads.',
			'common.errorKeys.downloadFallbackShare' => 'Share screen opened.',
			'common.errorKeys.downloadError' => 'An error occurred while downloading the file.',
			'common.errorKeys.galleryPermissionDenied' => 'Gallery access permission was denied.',
			'validation.emailRequired' => 'Email address cannot be empty',
			'validation.emailInvalid' => 'Please enter a valid email address',
			'validation.emailTooLong' => 'Email address is too long',
			'validation.phoneRequired' => 'Phone number cannot be empty',
			'validation.phoneInvalid' => 'Phone number must be 10 digits',
			'validation.passwordRequired' => 'Password cannot be empty',
			'validation.passwordTooShort' => 'Password must be at least 6 characters',
			'validation.passwordTooLong' => 'Password is too long',
			'validation.passwordAlphanumericRequired' => 'Password must be at least 6 characters and contain only letters and numbers',
			'validation.passwordUppercaseRequired' => 'Password must contain at least 1 uppercase letter',
			'validation.passwordLowercaseRequired' => 'Password must contain at least 1 lowercase letter',
			'validation.passwordNumberRequired' => 'Password must contain at least 1 number',
			'validation.passwordSpecialCharRequired' => 'Password must contain at least 1 special character',
			'validation.field_required' => 'This field is required',
			'validation.field_too_short' => 'Value is too short',
			'validation.field_too_long' => 'Value is too long',
			'validation.field_invalid' => 'Please enter a valid value',
			'features.buildings.managerPanel' => 'Manager',
			'features.buildings.buildingDetail' => 'Building Detail',
			'features.buildings.addBuilding' => 'Add Building',
			'features.buildings.newBuilding' => 'Add New Building',
			'features.buildings.inviteCode' => 'Invite Code',
			'features.buildings.createInviteCode' => 'Create Invite Code',
			'features.buildings.cancelCode' => 'Cancel Code',
			'features.buildings.apartmentOccupied' => 'Apartment Occupied',
			'features.buildings.copy' => 'Copy',
			'features.buildings.copyDone' => 'Copied',
			'features.buildings.share' => 'Share',
			'features.buildings.anotherApartment' => 'Another Apartment',
			'features.buildings.codeRevoked' => 'Code revoked',
			'features.buildings.occupiedDialog' => 'If you generate a new code, the old user will be removed. Are you sure?',
			'features.buildings.revokeDialog' => 'The current code will become invalid. Are you sure?',
			'features.buildings.produceAnyway' => 'Produce Anyway',
			'features.buildings.newCodePrefix' => 'If you generate a new code, ',
			'features.buildings.oldUserRemoved' => 'the old user will be removed',
			'features.buildings.currentCodePrefix' => 'The current code ',
			'features.buildings.codeInvalid' => 'will become invalid',
			'features.buildings.codeReady' => 'Invite Code Ready',
			'features.buildings.code' => 'CODE',
			'features.buildings.validFor7Days' => 'Valid for 7 days',
			'features.buildings.expiresAt' => 'Expires at:',
			'features.buildings.remaining' => 'Remaining:',
			'features.buildings.activeCodeNote' => 'While this code is active, you cannot generate a new code for the same apartment. You must revoke the current code first.',
			'features.buildings.backToMainMenu' => 'Back to Main Menu',
			'features.buildings.tekrarDene' => 'Try Again',
			'features.buildings.collection.sectionTitle' => 'Recipient details',
			'features.buildings.collection.sectionHint' => 'IBAN for resident bank transfers. Optional; you can add it later.',
			'features.buildings.collection.modeSaved' => 'Saved IBAN',
			'features.buildings.collection.modeNew' => 'New IBAN',
			'features.buildings.collection.savedListTitle' => 'Previously used',
			'features.buildings.collection.savedListSectionLabel' => 'Saved IBANs',
			'features.buildings.collection.pickSavedIban' => 'Choose saved IBAN',
			'features.buildings.collection.changeSavedIban' => 'Tap to choose another IBAN',
			'features.buildings.collection.searchSavedIban' => 'Search IBAN or recipient name',
			'features.buildings.collection.detailAccountHolder' => 'Recipient name',
			'features.buildings.collection.detailReference' => 'Payment reference',
			'features.buildings.collection.detailReferenceAuto' => 'Apartment number is added to the transfer reference automatically',
			'features.buildings.collection.detailReferenceDaireOnly' => 'Transfer reference: Apartment number',
			'features.buildings.collection.detailReferenceDaireAidat' => 'Transfer reference: Apt. no + dues',
			'features.buildings.collection.detailReferenceAidat' => 'Transfer reference: Dues (apt. no added automatically)',
			'features.buildings.collection.detailReferenceHavale' => 'Transfer reference: Apartment number on transfer',
			'features.buildings.collection.detailUsedInBuildings' => 'Used in {count} buildings',
			'features.buildings.collection.detailUsedInSites' => 'Used in {count} sites',
			'features.buildings.collection.detailUsedInBuildingsAndSites' => 'Used in {buildingCount} buildings, {siteCount} sites',
			'features.buildings.collection.ibanLabel' => 'IBAN',
			'features.buildings.collection.ibanHint' => 'TR33 0006 1005 1978 6457 8413 26',
			'features.buildings.collection.ibanInvalid' => 'Enter a valid Turkish IBAN (TR + 24 digits)',
			'features.buildings.collection.ibanRequiredIfOtherFilled' => 'You entered account title or reference; enter a valid IBAN',
			'features.buildings.collection.ibanNameLabel' => 'IBAN name',
			'features.buildings.collection.ibanNameHint' => 'e.g. My Ziraat account, Kuveyt Turk IBAN',
			'features.buildings.collection.ibanNameLaterHint' => 'You can name your IBAN later from Settings > My saved IBANs.',
			'features.buildings.collection.accountTitleLabel' => 'Recipient name',
			'features.buildings.collection.accountTitleHint' => 'e.g. Ahmet Yilmaz or Building Management',
			'features.buildings.collection.referenceTemplateLabel' => 'Payment reference',
			'features.buildings.collection.referenceTemplateHint' => 'e.g. Dues payment',
			'features.buildings.collection.referenceTemplateHelper' => 'This reference is shown the same way to all your residents',
			'features.buildings.collection.presetsEmpty' => 'No saved collection details yet',
			'features.buildings.collection.presetsLoadFailed' => 'Could not load suggestions',
			'features.buildings.collection.presetBuildingCount' => '{count} buildings',
			'features.buildings.collection.menuEdit' => 'Collection / IBAN',
			'features.buildings.collection.editSheetTitle' => 'Collection details',
			'features.buildings.collection.saveSuccess' => 'Collection details saved',
			'features.buildings.collection.savedIbansTitle' => 'My saved IBANs',
			'features.buildings.collection.savedIbansEmpty' => 'No saved IBAN yet. You can add collection details when creating a building.',
			'features.buildings.collection.savedIbansNoBuildingMatch' => 'No building or site linked to this set',
			'features.buildings.collection.savedIbansBuildingNames' => 'Buildings: {names}',
			'features.buildings.collection.savedIbansSiteNames' => 'Sites: {names}',
			'features.buildings.collection.savedIbansUpdateSuccess' => 'Collection updated for {count} place(s)',
			'features.buildings.collection.savedIbansUpdateHint' => 'Places to update: {names}',
			'features.buildings.collection.editSavedIbanTitle' => 'Edit IBAN',
			'features.buildings.collection.savedIbansOrphanHint' => 'This set is not linked to a building or site yet. Changes are stored in your saved list only.',
			'features.buildings.collection.savedIbansAddTitle' => 'Add IBAN',
			'features.buildings.collection.savedIbansAddHint' => 'You can reuse these details when adding a building or editing collection settings.',
			'features.buildings.collection.savedIbansAddSuccess' => 'IBAN saved',
			'features.buildings.collection.savedIbansSelectMode' => 'Select multiple',
			'features.buildings.collection.savedIbansSelectedLabel' => 'selected',
			'features.buildings.collection.savedIbansDeleteSelected' => 'Delete selected',
			'features.buildings.collection.savedIbansPickFirst' => 'Select the IBANs you want to delete first',
			'features.buildings.collection.savedIbansDeleteTitle' => 'Delete this IBAN?',
			'features.buildings.collection.savedIbansDeleteMessage' => 'This saved IBAN will be removed from your list.',
			'features.buildings.collection.savedIbansDeleteBulkTitle' => 'Delete selected IBANs?',
			'features.buildings.collection.savedIbansDeleteBulkMessage' => '{count} saved IBAN(s) will be deleted.',
			'features.buildings.collection.savedIbansDeleteBuildingWarning' => 'Collection details will also be cleared on {count} place(s).',
			'features.buildings.collection.savedIbansDeleteMultiUsageWarning' => 'This IBAN is used here: {names}. Deleting it will clear collection details for those places. This cannot be undone.',
			'features.buildings.collection.savedIbansDeleteSuccess' => 'IBAN deleted',
			'features.buildings.collection.savedIbansDeleteBulkSuccess' => '{count} IBAN(s) deleted',
			'features.buildings.collection.ibanNotConfigured' => 'Collection IBAN not configured',
			'features.buildings.collection.ibanAlreadyExists' => 'This IBAN is already registered in the system. Please check and try a different IBAN.',
			'features.buildings.list.buildingCount' => 'Building',
			'features.buildings.list.unitCount' => 'Unit',
			'features.buildings.list.overdueShort' => 'Overdue',
			'features.buildings.list.collectionShort' => 'Collected',
			'features.buildings.list.sort' => 'Sort',
			'features.buildings.list.sortByOverdue' => 'By Overdue',
			'features.buildings.list.sortByCollectionRate' => 'By Collection Rate',
			'features.buildings.list.sortByName' => 'By Name',
			'features.buildings.list.paidUnitsProgress' => '{paid} / {total} units paid',
			'features.buildings.list.perUnitDues' => '{amount} / unit',
			'features.buildings.list.unitsOverdue' => '{count} units overdue',
			'features.buildings.list.unitsWaiting' => '{count} units waiting',
			'features.buildings.list.allPaymentsComplete' => 'All payments complete',
			'features.buildings.list.monthlyDuesShort' => 'Monthly Dues',
			'features.sites.addSiteTitle' => 'Add New Site',
			'features.sites.createSite' => 'Create Site',
			'features.sites.siteName' => 'Site name',
			'features.sites.siteNameHint' => 'e.g. Sunny Residence',
			'features.sites.siteCreated' => 'Site created successfully',
			'features.sites.siteCreateFailed' => 'Could not add site',
			'features.sites.mySites' => 'My Sites',
			'features.sites.searchSites' => 'Search by site name or address',
			'features.sites.tabSites' => 'Sites',
			'features.sites.tabBuildings' => 'Buildings',
			'features.sites.siteCount' => '{count} site',
			'features.sites.buildingCount' => '{count} building',
			'features.sites.emptySites' => 'No sites added yet',
			'features.sites.newSite' => 'New Site',
			'features.sites.newBuilding' => 'New Building',
			'features.sites.siteDetailTitle' => 'Site Details',
			'features.sites.addBlock' => 'Add Block',
			'features.sites.addBlockTitle' => 'Add Block to Site',
			'features.sites.createBlock' => 'Create Block',
			'features.sites.blockCreated' => 'Block added successfully',
			'features.sites.blockSection' => 'Block details',
			'features.sites.blockLabel' => 'Block label',
			'features.sites.blockLabelHint' => 'e.g. Block A',
			'features.sites.blockNameOptional' => 'Building name (optional)',
			'features.sites.blockNameHint' => 'Uses block label if left empty',
			'features.sites.addressExtra' => 'Extra address',
			'features.sites.addressExtraHint' => 'e.g. Rear entrance, Gate 2',
			'features.sites.overrideDue' => 'Override site default due amount',
			'features.sites.overrideDueHint' => 'When off, site due applies',
			'features.sites.overrideCollection' => 'Override site default recipient details',
			'features.sites.overrideCollectionHint' => 'When off, site recipient details apply',
			'features.sites.blocksTitle' => 'Blocks',
			'features.sites.noBlocks' => 'No blocks added yet',
			'features.sites.blockApartments' => '{count} units',
			'features.sites.blockCount' => 'Blocks',
			'features.sites.apartmentCount' => 'Units',
			'features.sites.collectedAmount' => 'Collected',
			'features.sites.expectedAmount' => 'Expected',
			'features.sites.collectionRate' => 'Collection',
			'features.sites.collectedExpected' => '{collected} / {expected}',
			'features.sites.commonExpenses' => 'Common Expenses',
			'features.sites.report' => 'Report',
			'features.sites.reportSheetTitle' => 'Site report',
			'features.sites.monthlyReport' => 'Monthly report (PDF)',
			'features.sites.annualReport' => 'Annual report (PDF)',
			'features.sites.siteExpensesTitle' => 'Site Common Expenses',
			'features.sites.addExpenseTitle' => 'Add Common Expense',
			'features.sites.editExpenseTitle' => 'Edit Expense',
			'features.sites.addExpense' => 'Add Expense',
			'features.sites.expenseCreated' => 'Site expense added',
			'features.sites.expenseUpdated' => 'Site expense updated',
			'features.sites.confirmExpenseTitle' => 'Confirmation required',
			'features.sites.deleteExpenseTitle' => 'Delete expense?',
			'features.sites.deleteExpenseConfirm' => 'This site expense will be permanently deleted.',
			'features.sites.deleteExpenseSuccess' => 'Site expense deleted',
			'features.sites.noExpenses' => 'No expenses',
			'features.sites.noExpensesHint' => 'No common expenses for this month.',
			'features.sites.totalExpenses' => 'Total: {amount}',
			'features.sites.perUnitShare' => 'Per unit: {amount}',
			'features.auth.register' => 'Register',
			'features.auth.login' => 'Login',
			'features.auth.join' => 'Join',
			'features.auth.passwordRequired' => 'Password required',
			'features.auth.errorOccurred' => 'An error occurred',
			'features.auth.registrationSuccess' => 'Account created successfully.',
			'features.auth.loginSuccess' => 'Welcome!',
			'features.auth.loginSuccessNamed' => 'Welcome, {name}!',
			'features.auth.loginSuccessWelcomeBack' => 'Welcome back!',
			'features.auth.loginSuccessWelcomeBackNamed' => 'Welcome back, {name}!',
			'features.auth.appTitle' => 'AidatPanel',
			'features.auth.appSubtitle' => 'Apartment Management System',
			'features.auth.splashConnectionError' => 'Could not connect to server',
			'features.auth.splashConnectionHint' => 'Check your connection and try again.',
			'features.auth.skipToLogin' => 'Go to login',
			'features.auth.phone' => 'Phone',
			'features.auth.email' => 'Email',
			'features.auth.phoneHint' => '5XX XXX XX XX',
			'features.auth.emailHint' => 'example@email.com',
			'features.auth.password' => 'Password',
			'features.auth.passwordHint' => '••••••••',
			'features.auth.emailLogin' => 'Login with Email',
			'features.auth.phoneLogin' => 'Login with Phone',
			'features.auth.or' => 'or',
			'features.auth.noAccount' => 'Don\'t have an account? Register',
			'features.auth.joinWithCode' => 'Join with Invite Code',
			'features.auth.signUp' => 'Sign up',
			'features.auth.signUpTitle' => 'Sign Up',
			'features.auth.signUpSubtitle' => 'How would you like to join?',
			'features.auth.beManager' => 'Become a manager',
			'features.auth.beManagerHint' => 'Create a building and open a manager account',
			'features.auth.joinWithInvite' => 'Join with invite code',
			'features.auth.joinWithInviteHint' => 'Join as a resident with your manager\'s code',
			'features.auth.copyright' => '© Vefa Yazılım',
			'features.auth.createAccount' => 'Create New Account',
			'features.auth.name' => 'Full Name',
			'features.auth.nameHint' => 'Ex: Furkan Kaya',
			'features.auth.phoneOptional' => 'Phone (Optional)',
			'features.auth.phoneHintOptional' => '5XX XXX XXXX',
			'features.auth.minLength' => 'At least 6 characters',
			'features.auth.hasUpperCase' => 'At least 1 uppercase letter',
			'features.auth.hasLowerCase' => 'At least 1 lowercase letter',
			'features.auth.hasNumber' => 'At least 1 number',
			'features.auth.hasSpecialChar' => 'At least 1 special character',
			'features.auth.confirmPassword' => 'Confirm Password',
			'features.auth.passwordsDoNotMatch' => 'Passwords do not match',
			'features.auth.emailAndPasswordRequired' => 'Email and password cannot be empty',
			'features.auth.hasAccount' => 'Already have an account? Login',
			'features.auth.joinApartment' => 'Join Apartment',
			'features.auth.inviteCode' => 'Invite Code',
			'features.auth.inviteCodeHint' => 'AP3-B12-A9F0',
			'features.auth.invalidInviteCodeFormat' => 'Invalid invite code format (Ex: AP3-B12-A9F0)',
			'features.auth.invalidPhoneFormat' => 'Enter a valid phone number (5XX XXX XX XX)',
			'features.auth.inviteCodeAndPasswordRequired' => 'Invite code, name and password cannot be empty',
			'features.auth.invalidPhoneNumber' => 'Enter a valid phone number',
			'features.auth.areYouManager' => 'Are you a manager? Register',
			'features.auth.onboarding.stepProgress' => 'Step {current} / {total}',
			'features.auth.onboarding.continueButton' => 'Continue',
			'features.auth.onboarding.goToPanel' => 'Go to panel',
			'features.auth.onboarding.secureNote' => 'Your information is securely protected.',
			'features.auth.onboarding.step1Title' => 'Who will you use the app as?',
			'features.auth.onboarding.step1Subtitle' => 'Select your role to continue.',
			'features.auth.onboarding.step1ManagerOption' => 'I am an apartment manager',
			'features.auth.onboarding.step1ResidentOption' => 'I am an apartment resident',
			'features.auth.onboarding.step1ManagerHint' => 'Select this if you manage an apartment or site.',
			'features.auth.onboarding.step1ResidentHint' => 'I am a resident signing in to my unit.',
			'features.auth.onboarding.step1ReturningLogin' => 'I have signed in before',
			'features.auth.onboarding.step1ReturningLoginManager' => 'I signed in before as manager',
			'features.auth.onboarding.step1ReturningLoginResident' => 'I signed in before as resident',
			'features.auth.onboarding.step1ReturningLoginHint' => '{name} · {contact}',
			'features.auth.onboarding.step1LegacyEmailLogin' => 'Sign in with email and password',
			'features.auth.onboarding.backButton' => 'Back',
			'features.auth.onboarding.managerExperienceTitle' => 'Welcome to AidatPanel',
			'features.auth.onboarding.managerExperienceSubtitle' => 'Have you registered before?',
			'features.auth.onboarding.managerReturningOption' => 'I have registered before',
			'features.auth.onboarding.managerFirstTimeOption' => 'I am using the app for the first time',
			'features.auth.onboarding.managerNameEyebrow' => 'Creating your account',
			'features.auth.onboarding.managerNameTitle' => 'Let\'s get to know you — what\'s your name?',
			'features.auth.onboarding.managerNameSubtitle' => 'How should we address you?',
			'features.auth.onboarding.managerIdentifierTitle' => 'Enter your email or phone',
			'features.auth.onboarding.managerIdentifierSubtitle' => 'This will be used for sign-in.',
			'features.auth.onboarding.managerIdentifierLabel' => 'Email or phone',
			'features.auth.onboarding.managerIdentifierHint' => 'example@mail.com or 05321234567',
			'features.auth.onboarding.managerIdentifierPhoneNote' => 'For phone, enter 11 digits starting with 0.',
			'features.auth.onboarding.identifierRequired' => 'Enter your email or phone',
			'features.auth.onboarding.phoneInvalidElevenDigits' => 'Enter an 11-digit phone number starting with 0',
			'features.auth.onboarding.managerLoginPasswordTitle' => 'Enter your password',
			'features.auth.onboarding.managerLoginWelcomeTitle' => 'Welcome back!',
			'features.auth.onboarding.managerLoginWelcomeNamedTitle' => 'Welcome back, {name}!',
			'features.auth.onboarding.managerLoginWelcomeSubtitle' => 'Enter your password to continue',
			'features.auth.onboarding.managerRegisterPasswordTitle' => 'Set your password',
			'features.auth.onboarding.managerRegisterPasswordSubtitle' => 'At least 6 characters; letters and numbers only.',
			'features.auth.onboarding.managerCreateAccountButton' => 'Create Account',
			'features.auth.onboarding.managerLoginButton' => 'Sign In',
			'features.auth.onboarding.residentExperienceTitle' => 'Welcome to AidatPanel',
			'features.auth.onboarding.residentExperienceSubtitle' => 'How would you like to continue?',
			'features.auth.onboarding.residentReturningOption' => 'I have signed in before',
			'features.auth.onboarding.residentInviteOption' => 'I have an invite code',
			'features.auth.onboarding.residentPhoneTitle' => 'Your phone number',
			'features.auth.onboarding.residentPhoneSubtitle' => 'We will send you a one-time sign-in password.',
			'features.auth.onboarding.residentPhoneNote' => 'Country code +90 is fixed. Enter your number as (5XX) XXX XX XX.',
			'features.auth.onboarding.residentWelcomeTitle' => 'What is your name?',
			'features.auth.onboarding.residentWelcomeSubtitle' => 'Your phone is verified. How should we address you?',
			'features.auth.onboarding.residentCompleteJoinButton' => 'Go to Dashboard',
			'features.auth.onboarding.step2Title' => 'Enter Your Contact Information',
			'features.auth.onboarding.step2Subtitle' => 'Enter your phone number or email address to continue.',
			'features.auth.onboarding.step2SubtitlePhone' => 'We will send you a verification code.',
			'features.auth.onboarding.step2SubtitleEmail' => 'We will send a verification code to your email.',
			'features.auth.onboarding.step3OtpTitle' => 'Verification Code',
			'features.auth.onboarding.step3OtpSubtitlePhone' => 'Enter the 6-digit code sent to {phone}.',
			'features.auth.onboarding.step3OtpSubtitleEmail' => 'Enter the 6-digit code sent to {email}.',
			'features.auth.onboarding.step3OtpSubtitle' => 'Enter the 6-digit code below.',
			'features.auth.onboarding.step3OtpSentTo' => 'Code sent to {phone}.',
			'features.auth.onboarding.step3ResendOtp' => 'Resend code ({time})',
			'features.auth.onboarding.step3ResendOtpReady' => 'Resend code',
			'features.auth.onboarding.step3PasswordTitle' => 'Enter your password',
			'features.auth.onboarding.step3RegisterPasswordTitle' => 'Create your password',
			'features.auth.onboarding.step3SecureVerify' => 'We protect your account with secure verification.',
			'features.auth.onboarding.step3DevOtpHint' => 'If using a test number, enter the one-time password from Firebase Console.',
			'features.auth.onboarding.residentOtpTitle' => 'Your one-time password',
			'features.auth.onboarding.residentOtpSubtitlePhone' => 'Enter the 6-digit one-time password sent to {phone}.',
			'features.auth.onboarding.step4InviteTitle' => 'Enter Your Invite Code',
			'features.auth.onboarding.step4InviteSubtitle' => 'Enter the code from your manager.',
			'features.auth.onboarding.step4InviteHint' => 'You can get your invite code from management or your manager.',
			'features.auth.onboarding.step4ManagerInviteTitle' => 'Enter Your Invite Code',
			'features.auth.onboarding.step4ManagerInviteSubtitle' => 'Enter your invite code to link your manager account to the site or building.',
			'features.auth.onboarding.step4ManagerInviteInfo' => 'You can get your invite code from management or your manager.',
			'features.auth.onboarding.step4ManagerPrimaryLink' => 'No, I am the manager',
			'features.auth.onboarding.step4ManagerPrimaryHint' => 'Choose this if you will manage the building yourself.',
			'features.auth.onboarding.step4InviteValidated' => 'Valid invite: {label}',
			'features.auth.onboarding.step5Title' => 'What You Can Do as a Manager',
			'features.auth.onboarding.step5ManagerSubtitle' => 'Manage your site easily with AidatPanel and serve your residents better.',
			'features.auth.onboarding.step5ResidentTitle' => 'What You Can Do as a Resident',
			'features.auth.onboarding.step5ResidentSubtitle' => 'Track your dues and payments here.',
			'features.auth.onboarding.step5ManagerAnnounceTitle' => 'Manage announcements',
			'features.auth.onboarding.step5ManagerAnnounceBody' => 'Send announcements to all residents quickly.',
			'features.auth.onboarding.step5ManagerDuesTitle' => 'Dues tracking',
			'features.auth.onboarding.step5ManagerDuesBody' => 'Track collections and view payments.',
			'features.auth.onboarding.step5ManagerResidentsTitle' => 'Resident management',
			'features.auth.onboarding.step5ManagerResidentsBody' => 'Manage resident information and simplify communication.',
			'features.auth.onboarding.step5ManagerReportsTitle' => 'Reporting',
			'features.auth.onboarding.step5ManagerReportsBody' => 'Monitor site finances with detailed reports.',
			'features.auth.onboarding.step5ResidentDuesTitle' => 'View your dues',
			'features.auth.onboarding.step5ResidentDuesBody' => 'Track your current balance and payment history.',
			'features.auth.onboarding.step5ResidentDekontTitle' => 'Upload receipts',
			'features.auth.onboarding.step5ResidentDekontBody' => 'Send your payment receipt as a photo or PDF.',
			'features.auth.onboarding.step5ResidentTicketsTitle' => 'Create requests',
			'features.auth.onboarding.step5ResidentTicketsBody' => 'Easily notify management about matters you want to report.',
			'features.auth.onboarding.step5ResidentNotifyTitle' => 'Get notifications',
			'features.auth.onboarding.step5ResidentNotifyBody' => 'Stay informed about announcements and due reminders.',
			'features.auth.onboarding.step6ManagerTitle' => 'Setup complete',
			'features.auth.onboarding.step6ManagerSubtitle' => 'Welcome to the manager panel! You can now start managing your site and serving your residents better.',
			'features.auth.onboarding.step6ResidentTitle' => 'Sign-in complete',
			'features.auth.onboarding.step6ResidentSubtitle' => 'Track your dues and payments from here.',
			'features.auth.onboarding.otpInvalid' => 'Wrong one-time password. Try again.',
			'features.auth.onboarding.otpExpired' => 'One-time password expired. Request a new one.',
			'features.auth.onboarding.phoneInvalid' => 'Enter a valid phone number (5XX XXX XX XX).',
			'features.auth.onboarding.inviteInvalid' => 'Invite code is invalid or expired.',
			'features.auth.onboarding.otpSendFailed' => 'Could not send the one-time password. Try again.',
			'features.auth.onboarding.phoneOtpDisabledHint' => 'Phone sign-in coming soon. You can use email for now.',
			'features.auth.onboarding.residentLoginTitle' => 'Resident Sign In',
			'features.auth.onboarding.residentLoginSubtitle' => 'Enter your details to continue.',
			'features.auth.onboarding.residentLoginWelcomeTitle' => 'Welcome back!',
			'features.auth.onboarding.residentLoginWelcomeNamedTitle' => 'Welcome back, {name}!',
			'features.auth.onboarding.residentLoginWelcomeSubtitle' => 'Enter your one-time password to continue',
			'features.auth.onboarding.residentSendCodeButton' => 'Send Password',
			'features.auth.onboarding.residentPhoneVerifyNote' => 'A one-time password will be sent to your phone number.',
			'features.auth.onboarding.residentOtpSubtitle' => 'Enter the 6-digit one-time password sent to your phone.',
			'features.auth.onboarding.residentResendPrompt' => 'Didn\'t get the password?',
			'features.auth.onboarding.residentResendLink' => 'Resend password',
			'features.auth.onboarding.residentResendOtp' => 'Resend password ({time})',
			'features.auth.onboarding.residentInviteSubtitle' => 'Please enter the invitation code you received from your manager to continue.',
			'features.auth.onboarding.residentJoinButton' => 'Join Apartment',
			'features.auth.onboarding.residentInviteCodeLabel' => 'Invitation Code',
			'features.auth.onboarding.residentInviteCodeHint' => 'e.g. APF-45532',
			'features.auth.onboarding.residentNameRequired' => 'Please enter your full name.',
			'features.apartments.residentPanel' => 'Resident',
			'features.tickets.myTickets' => 'My requests',
			'features.tickets.newTicket' => 'New request',
			'features.tickets.createTitle' => 'Create request',
			'features.tickets.reportFaultTitle' => 'New request',
			'features.tickets.myApplicationsTitle' => 'My requests',
			'features.tickets.fieldTitle' => 'Subject',
			'features.tickets.fieldTitleHint' => 'Enter a short summary.',
			'features.tickets.fieldDetail' => 'Details',
			'features.tickets.fieldDetailHint' => 'Briefly describe the issue.',
			'features.tickets.fieldDescription' => 'Description',
			'features.tickets.fieldDescriptionHint' => 'Write a detailed explanation…',
			'features.tickets.attachmentHint' => 'Add photo, video or document… PNG, JPG — max 5 MB.',
			'features.tickets.attachmentComingSoon' => 'File attachments coming soon.',
			'features.tickets.attachmentPickFailed' => 'Could not select the image. Try again.',
			'features.tickets.fieldCategory' => 'Category',
			'features.tickets.categoryComplaint' => 'Complaint',
			'features.tickets.categoryRequest' => 'Request',
			'features.tickets.categoryMalfunction' => 'Malfunction',
			'features.tickets.categoryOther' => 'Other',
			'features.tickets.submit' => 'Submit',
			'features.tickets.createSuccess' => 'Your request has been submitted',
			'features.tickets.createFailed' => 'Could not save your request. Try again.',
			'features.tickets.createServiceUnavailable' => 'The request service is not available right now. Try again later.',
			'features.tickets.emptyTitle' => 'No requests yet',
			'features.tickets.emptySubtitle' => 'You can create your request here',
			'features.tickets.residentEmptyTitle' => 'You have no requests yet',
			'features.tickets.residentEmptySubtitle' => 'Create a request here to reach your building manager.',
			'features.tickets.managerNoBuildingsTitle' => 'You have no buildings yet',
			'features.tickets.managerNoBuildingsSubtitle' => 'Add a building first to see requests.',
			'features.tickets.managerSelectBuildingTitle' => 'Select a building',
			'features.tickets.managerSelectBuildingSubtitle' => 'Choose a building to view its requests.',
			'features.tickets.managerNoMatchingTicketsTitle' => 'No requests match these criteria',
			'features.tickets.managerNoMatchingTicketsSubtitle' => 'Try changing filters or selecting another building.',
			'features.tickets.titleTooShort' => 'Title must be at least 3 characters',
			'features.tickets.descriptionTooShort' => 'Description must be at least 10 characters',
			'features.tickets.statusOpen' => 'Open',
			'features.tickets.statusInProgress' => 'Approved',
			'features.tickets.statusResolved' => 'Done',
			'features.tickets.statusClosed' => 'Rejected',
			'features.tickets.statusTrackerTitle' => 'REQUEST STATUS',
			'features.tickets.statusStepWaiting' => 'Awaiting review',
			'features.tickets.statusStepInProgress' => 'Approved',
			'features.tickets.statusStepResolved' => 'Done',
			'features.tickets.statusStepClosed' => 'Rejected',
			'features.tickets.statusHeadlineOpen' => 'Your request is waiting',
			'features.tickets.statusHeadlineInProgress' => 'Your request was approved',
			'features.tickets.statusHeadlineResolved' => 'Your request is done',
			'features.tickets.statusHeadlineClosed' => 'Your request was rejected',
			'features.tickets.detailTitle' => 'Request details',
			'features.tickets.managerTitle' => 'Building requests',
			'features.tickets.statusLabel' => 'Status',
			'features.tickets.updatesTitle' => 'Updates',
			'features.tickets.changeStatus' => 'Change status',
			'features.tickets.managerNote' => 'Manager note',
			'features.tickets.addNote' => 'Add note',
			'features.tickets.statusUpdated' => 'Status updated',
			'features.tickets.noteAdded' => 'Note added',
			'features.tickets.undo' => 'Undo',
			'features.tickets.actionApprove' => 'Approve',
			'features.tickets.actionReject' => 'Reject',
			'features.tickets.actionMarkDone' => 'Mark as done',
			'features.tickets.loadError' => 'Could not load requests',
			'features.tickets.noteDisabledClosed' => 'Cannot add notes to a rejected or completed request',
			'features.tickets.statusClosedHint' => 'This request was rejected; status cannot be changed.',
			'features.tickets.apartmentRequired' => 'Apartment not linked. Sign in again.',
			'features.tickets.managerUpdateLabel' => 'Manager update',
			'features.tickets.residentUpdateLabel' => 'Your update',
			'features.tickets.managerUpdateForResident' => 'Update from management',
			'features.tickets.quickReplyTemplatesTitle' => 'Quick reply templates',
			'features.tickets.confirmChanges' => 'Confirm',
			'features.tickets.residentInfoTitle' => 'Resident details',
			'features.tickets.defaultResidentName' => 'Resident',
			'features.tickets.apartmentNumberTag' => 'Apt {number}',
			'features.tickets.apartmentInfoMissing' => 'No apartment info',
			'features.tickets.managerNoteOptional' => 'Manager note (optional)',
			'features.tickets.templateTeamDispatched' => 'Team dispatched',
			'features.tickets.templateTeamDispatchedText' => 'Issue inspected on site; technical team dispatched.',
			'features.tickets.templateWaitingPart' => 'Waiting for parts',
			'features.tickets.templateWaitingPartText' => 'Required materials ordered; waiting for delivery.',
			'features.tickets.templateAppointmentSet' => 'Appointment set',
			'features.tickets.templateAppointmentSetText' => 'Spoke with resident; appointment scheduled.',
			'features.tickets.templateResolvedCheck' => 'Resolved / verified',
			'features.tickets.templateResolvedCheckText' => 'Issue fixed; verification completed.',
			'features.dekont.makePaymentTitle' => 'Make Payment',
			'features.dekont.payDebtTitle' => 'Pay debt',
			'features.dekont.paymentMethodTitle' => 'Payment method',
			'features.dekont.paymentMethodCard' => 'Credit / debit card',
			'features.dekont.paymentMethodEft' => 'Bank transfer',
			'features.dekont.paymentMethodDekont' => 'Upload receipt',
			'features.dekont.paymentCardComingSoon' => 'Card payments coming soon.',
			'features.dekont.uploadReceiptHint' => 'Upload receipt (jpg, png, webp, PDF — max 5 MB).',
			'features.dekont.myDekontsTitle' => 'My Receipts',
			'features.dekont.managerTitle' => 'Receipt Review',
			'features.dekont.reviewAction' => 'Review receipt',
			'features.dekont.detailTitle' => 'Receipt Detail',
			'features.dekont.paymentInfoTitle' => 'Transfer details',
			'features.dekont.collectionNotConfigured' => 'Your manager has not set up collection IBAN yet. You can still upload a receipt.',
			'features.dekont.ibanLabel' => 'IBAN',
			'features.dekont.accountTitleLabel' => 'Recipient name',
			'features.dekont.referenceLabel' => 'Transfer reference',
			'features.dekont.copy' => 'Copy',
			'features.dekont.copied' => 'Copied to clipboard',
			'features.dekont.selectDue' => 'Select dues',
			'features.dekont.selectDueHint' => 'Select the dues you paid (you can select more than one)',
			'features.dekont.selectedTotal' => 'Selected total: {amount}',
			'features.dekont.recipientSection' => 'Recipient details',
			'features.dekont.noPendingDues' => 'No pending dues',
			'features.dekont.uploadSectionTitle' => 'Upload receipt',
			'features.dekont.uploadHint' => 'PDF document or photo (JPEG, PNG) (Max 10 MB)',
			'features.dekont.pickFile' => 'Choose file',
			'features.dekont.upload' => 'Upload receipt',
			'features.dekont.uploadSuccess' => 'Receipt uploaded',
			'features.dekont.uploadRecoveredExisting' => 'This receipt was already on file; your existing record was opened.',
			'features.dekont.uploadFailed' => 'Upload failed',
			'features.dekont.errorUploadDuplicate' => 'You have already uploaded this receipt. Check My Receipts.',
			'features.dekont.errorUploadRateLimit' => 'You uploaded too many receipts in a short time. Please wait.',
			'features.dekont.errorUploadServer' => 'Receipt could not be saved on the server. Try again later.',
			'features.dekont.errorUploadFileRequired' => 'Please select a file.',
			'features.dekont.errorPaymentInfo' => 'Payment details could not be loaded. Try again.',
			'features.dekont.errorListLoad' => 'Receipt list could not be loaded. Try again.',
			'features.dekont.errorDetailLoad' => 'Receipt details could not be loaded. Try again.',
			'features.dekont.errorFileDownload' => 'Receipt file could not be opened. Try again.',
			'features.dekont.errorReviewPaymentDone' => 'Payment for this receipt has already been processed.',
			'features.dekont.errorReviewRejected' => 'A rejected receipt cannot be approved again.',
			'features.dekont.errorReviewNeedDue' => 'Select a due to approve.',
			_ => null,
		} ?? switch (path) {
			'features.dekont.errorReviewNeedAmount' => 'Receipt amount could not be read. Enter the amount to approve.',
			'features.dekont.reviewAmountLabel' => 'Amount to approve (₺)',
			'features.dekont.reviewAmountRequiredHint' => 'No amount was read from this receipt. Enter the amount manually — do not approve without an amount or the remaining balance will not be applied correctly.',
			'features.dekont.reviewApplyAmount' => 'Amount to apply: {amount}',
			'features.dekont.reviewRemainingAmount' => 'Remaining after approval: {amount}',
			'features.dekont.errorReviewStatus' => 'This receipt cannot be approved or rejected right now. Try again later.',
			'features.dekont.errorNoFileSelected' => 'Please select a receipt file first.',
			'features.dekont.errorNoDueSelected' => 'Please select at least one due.',
			'features.dekont.fileTooLarge' => 'File must be 10 MB or smaller',
			'features.dekont.fileEmpty' => 'The selected file is empty',
			'features.dekont.fileNotFound' => 'File not found',
			'features.dekont.invalidExtension' => 'Only PDF, JPEG, or PNG files are allowed',
			'features.dekont.processing' => 'Processing receipt…',
			'features.dekont.viewDekonts' => 'My receipts',
			'features.dekont.breakdownDetails' => 'Details',
			'features.dekont.breakdownBaseDue' => 'Monthly due',
			'features.dekont.breakdownTotal' => 'Total',
			'features.dekont.emptyTitle' => 'No receipts yet',
			'features.dekont.emptySubtitleResident' => 'You don\'t have any receipts yet. You can use the upload button on the top right to add a new receipt.',
			'features.dekont.emptySubtitleManager' => 'There are no receipts uploaded by users.',
			'features.dekont.filterAll' => 'All',
			'features.dekont.filterPending' => 'Under review',
			'features.dekont.filterApproved' => 'Approved',
			'features.dekont.filterRejected' => 'Rejected',
			'features.dekont.resident.statusProcessing' => 'Processing',
			'features.dekont.resident.statusAwaitingApproval' => 'Awaiting approval',
			'features.dekont.resident.statusApproved' => 'Approved',
			'features.dekont.resident.statusPartiallyApproved' => 'Partially approved',
			'features.dekont.resident.statusRejected' => 'Rejected',
			'features.dekont.resident.statusCouldNotMatch' => 'Manual review needed',
			'features.dekont.resident.statusDetailProcessing' => 'Your receipt is being reviewed. The amount will appear shortly.',
			'features.dekont.resident.statusDetailAwaitingApproval' => 'Waiting for the manager\'s approval.',
			'features.dekont.resident.statusDetailAwaitingIbanOk' => 'Recipient details matched. Waiting for the manager\'s approval.',
			'features.dekont.resident.statusDetailAwaitingIbanIssue' => 'Recipient details unclear. Waiting for the manager\'s approval.',
			'features.dekont.resident.statusDetailApproved' => 'Your payment was approved.',
			'features.dekont.resident.statusDetailPartiallyApproved' => 'Your payment was partially approved.',
			'features.dekont.resident.statusDetailRejected' => 'Your receipt was rejected.',
			'features.dekont.resident.filterAll' => 'All your receipts',
			'features.dekont.resident.filterPending' => 'Awaiting approval',
			'features.dekont.resident.filterApproved' => 'Approved',
			'features.dekont.resident.filterRejected' => 'Rejected',
			'features.dekont.resident.dueOverdueHint' => 'This due is overdue',
			'features.dekont.manager.statusProcessing' => 'Processing',
			'features.dekont.manager.statusAwaitingApproval' => 'Awaiting approval',
			'features.dekont.manager.statusApproved' => 'Approved',
			'features.dekont.manager.statusPartiallyApproved' => 'Partially approved',
			'features.dekont.manager.statusRejected' => 'Rejected',
			'features.dekont.manager.statusDetailProcessing' => 'Receipt is being processed. Details will appear shortly.',
			'features.dekont.manager.statusDetailAwaitingApproval' => 'Your approval is needed.',
			'features.dekont.manager.statusDetailAwaitingIbanOk' => 'Recipient details matched. Your approval is needed.',
			'features.dekont.manager.statusDetailAwaitingIbanIssue' => 'Recipient details unclear. Check and decide.',
			'features.dekont.manager.statusDetailApproved' => 'Payment approved.',
			'features.dekont.manager.statusDetailPartiallyApproved' => 'Payment partially approved.',
			'features.dekont.manager.statusDetailRejected' => 'Receipt rejected.',
			'features.dekont.statusReceived' => 'Received',
			'features.dekont.statusExtracting' => 'Reading',
			'features.dekont.statusExtractFailed' => 'Read failed',
			'features.dekont.statusParsed' => 'Parsed',
			'features.dekont.statusParseLowConfidence' => 'Low confidence',
			'features.dekont.statusMatching' => 'Matching',
			'features.dekont.statusMatched' => 'Matched',
			'features.dekont.statusMatchAmbiguous' => 'Ambiguous match',
			'features.dekont.statusUnmatched' => 'Unmatched',
			'features.dekont.statusPaymentApplied' => 'Payment applied',
			'features.dekont.statusPaymentPartial' => 'Partial payment',
			'features.dekont.statusRejected' => 'Rejected',
			'features.dekont.statusRecipientMismatch' => 'Recipient mismatch',
			'features.dekont.statusNeedsManagerReview' => 'Manager review',
			'features.dekont.reupload' => 'Upload again',
			'features.dekont.rejectionReason' => 'Rejection reason',
			'features.dekont.parsedAmount' => 'Parsed amount',
			'features.dekont.paymentDetailsSection' => 'Payment details',
			'features.dekont.fileSection' => 'File',
			'features.dekont.filePreview' => 'File preview',
			'features.dekont.pdfPreviewHint' => 'Pinch to zoom and scroll to view pages.',
			'features.dekont.pdfPreviewUnavailable' => 'PDF could not be opened on this device. Use «Share file» below to open it in another app.',
			'features.dekont.shareFile' => 'Share file',
			'features.dekont.approve' => 'Approve',
			'features.dekont.reject' => 'Reject',
			'features.dekont.reviewNote' => 'Note (optional)',
			'features.dekont.reviewSuccess' => 'Review saved',
			'features.dekont.reviewFailed' => 'Review failed',
			'features.dekont.selectDueForApprove' => 'Select due to approve',
			'features.dekont.uploadedBy' => 'Uploaded by',
			'features.dekont.apartment' => 'Apartment',
			'features.dekont.amount' => 'Amount',
			'features.dekont.loadError' => 'Could not load receipts',
			'features.dekont.systemInfoTitle' => 'System information',
			'features.dekont.systemInfoSubtitle' => 'Below is what we read from your receipt. Payment is not approved automatically; your manager will verify the bank account and approve.',
			'features.dekont.systemReadLabel' => 'Read from receipt',
			'features.dekont.systemInfoProcessing' => 'Your receipt is being processed. Amount, date and bank details will appear here shortly.',
			'features.dekont.systemInfoNoData' => 'Read data',
			'features.dekont.systemInfoNoDataHint' => 'Amount or date could not be read yet. It will still be sent for manager approval.',
			'features.dekont.transactionDateLabel' => 'Transaction date',
			'features.dekont.bankLabel' => 'Bank',
			'features.dekont.receiverIbanLabel' => 'Recipient IBAN',
			'features.dekont.receiverNameLabel' => 'Recipient name',
			'features.dekont.referenceNumberLabel' => 'Reference no.',
			'features.dekont.ibanUnreadableNotice' => 'The recipient IBAN could not be read from your dues payment receipt. It will be submitted for manager approval as is.',
			'features.dekont.ibanMismatchNotice' => 'The recipient IBAN on the receipt does not match your building\'s collection account. Your manager will verify the account and decide.',
			'features.dekont.ibanVerifiedNotice' => 'The recipient IBAN matches your building\'s collection account. Payment still requires manager approval.',
			'features.dekont.residentPendingReviewNotice' => 'Your receipt has been submitted for manager approval. Payment is not approved automatically; your manager will verify the account.',
			'features.dekont.managerApprovalHint' => 'Check the amount in your account, then approve. The amount is applied to the resident\'s selected dues oldest-first; a shortfall leaves remaining balance open.',
			'features.dekont.residentSelectedDues' => 'Dues selected by resident',
			'features.dekont.residentSelectedDuesHint' => 'The resident marked these periods when uploading. On approval the amount is applied to these dues.',
			'features.dekont.managerPaymentSummary' => '{resident} sent {amount} in dues on {date} via {bank}. Please check your account and approve.',
			'features.dekont.residentWithApartment' => '{name} (Apt. {apartment})',
			'features.dekont.apartmentOnly' => 'Apt. {apartment}',
			'features.dekont.residentUnknown' => 'Resident',
			'features.dekont.amountUnknown' => 'the stated amount',
			'features.dekont.receiptPhotoTitle' => 'Receipt image',
			'features.dekont.receiptPhotoHint' => 'Review the system information above first. Open the receipt file whenever you need to.',
			'features.dekont.viewDekont' => 'View receipt',
			'features.dekont.bankKuveytTurk' => 'Kuveyt Türk',
			'features.dekont.bankZiraat' => 'Ziraat Bankası',
			'features.dekont.bankIsbank' => 'İş Bankası',
			'features.dekont.bankGaranti' => 'Garanti BBVA',
			'features.dekont.bankHalkbank' => 'Halkbank',
			'features.dekont.bankVakifbank' => 'VakıfBank',
			'features.dekont.bankYapiKredi' => 'Yapı Kredi',
			'features.dekont.bankAkbank' => 'Akbank',
			'features.dekont.bankQnb' => 'QNB Finansbank',
			'features.dekont.bankGeneric' => 'Bank (generic)',
			'features.dekont.bankUnknown' => 'Bank could not be read',
			'features.expenses.title' => 'Expenses',
			'features.expenses.createTitle' => 'Add expense',
			'features.expenses.fieldTitle' => 'Title',
			'features.expenses.fieldAmount' => 'Amount',
			'features.expenses.fieldCategory' => 'Category',
			'features.expenses.fieldNote' => 'Note (optional)',
			'features.expenses.submit' => 'Save',
			'features.expenses.required' => 'Required field',
			'features.expenses.amountInvalid' => 'Enter a valid amount',
			'features.expenses.amountFromReceiptsHint' => 'Amount is read automatically from the receipt or bank statement.',
			'features.expenses.receiptRequired' => 'Add at least one receipt or bank statement (PDF/photo)',
			'features.expenses.amountOcrPending' => 'Reading receipt/statement amounts. They will appear in the list shortly.',
			'features.expenses.amountPending' => 'Reading amount…',
			'features.expenses.total' => 'Total',
			'features.expenses.createSuccess' => 'Expense saved',
			'features.expenses.categoryCleaning' => 'Cleaning',
			'features.expenses.categoryElevator' => 'Elevator',
			'features.expenses.categoryElectricity' => 'Electricity',
			'features.expenses.categoryWater' => 'Water',
			'features.expenses.categoryInsurance' => 'Insurance',
			'features.expenses.categoryRepair' => 'Repair',
			'features.expenses.categoryGarden' => 'Garden',
			'features.expenses.categoryOther' => 'Other',
			'features.expenses.fieldDate' => 'Expense date',
			'features.expenses.fieldDateHint' => 'Date on the receipt or invoice',
			'features.expenses.fieldMonth' => 'Month',
			'features.expenses.fieldYear' => 'Year',
			'features.expenses.editTitle' => 'Edit expense',
			'features.expenses.editAction' => 'Edit',
			'features.expenses.deleteTitle' => 'Delete expense',
			'features.expenses.deleteAction' => 'Delete',
			'features.expenses.deleteConfirm' => 'Are you sure you want to delete this expense?',
			'features.expenses.deleteSuccess' => 'Expense deleted',
			'features.expenses.updateSuccess' => 'Expense updated',
			'features.expenses.loadError' => 'Could not load expenses',
			'features.expenses.emptyTitle' => 'No expenses this period',
			'features.expenses.emptySubtitle' => 'Add a new expense from the top-right button',
			'features.expenses.residentTitle' => 'Building Expenses',
			'features.expenses.residentEmptySubtitle' => 'Your manager has not added expenses for this period yet',
			'features.expenses.quickActionLabel' => 'Building Expenses',
			'features.expenses.receiptUrlLabel' => 'Receipt link (HTTPS)',
			'features.expenses.receiptUrlHint' => 'Optional — public URL to the receipt file',
			'features.expenses.receiptUrlInvalid' => 'URL must start with https://',
			'features.expenses.receiptTitle' => 'Receipt / bank statement',
			'features.expenses.receiptHint' => 'Bank statement (PDF) or receipt photo (JPEG, PNG). Amount is read automatically (Max 10 MB)',
			'features.expenses.receiptAdd' => 'Add file',
			'features.expenses.receiptChange' => 'Change file',
			'features.expenses.receiptRemove' => 'Remove file',
			'features.expenses.receiptPendingBackend' => 'Receipt will upload later.',
			'features.expenses.receiptUploadFailed' => 'File upload failed. The expense was saved.',
			'features.expenses.receiptPickFailed' => 'Could not pick a file',
			'features.expenses.receiptStoredOnServer' => 'File stored on server',
			'features.expenses.detailTitle' => 'Expense Detail',
			'features.expenses.fieldCreatedAt' => 'Created at',
			'features.expenses.viewReceipt' => 'View file',
			'features.expenses.receiptMissing' => 'No receipt or statement uploaded',
			'features.expenses.targetMonthLabel' => 'Month applied to dues',
			'features.expenses.targetThisMonth' => 'This month',
			'features.expenses.targetNextMonth' => 'Next month',
			'features.expenses.targetSpecificMonth' => 'Pick month',
			'features.expenses.targetPeriodSummary' => 'Applies to {month} {year} dues',
			'features.expenses.pastMonthWarning' => 'Adding an expense to a past month will update due amounts.',
			'features.expenses.splitMonthsEnable' => 'Split across months',
			'features.expenses.splitMonthsHint' => 'Total is divided equally across selected months',
			'features.expenses.splitMonthsCount' => 'Number of months',
			'features.expenses.splitMonthsUnit' => 'months',
			'features.expenses.carryForwardDialogTitle' => 'Already paid dues',
			'features.expenses.carryForwardAuto' => 'Add difference to next month',
			'features.expenses.carryForwardManual' => 'I\'ll handle it manually',
			'features.notifications.markAllRead' => 'Mark all read',
			'features.notifications.markAllReadLong' => 'Mark all as read',
			'features.notifications.viewRelated' => 'Open related item',
			'features.notifications.unreadBadge' => 'New',
			'features.notifications.emptyTitle' => 'No notifications',
			'features.notifications.emptySubtitle' => 'New notifications will appear here',
			'features.notifications.emptyUnreadTitle' => 'No unread notifications',
			'features.notifications.emptyUnreadSubtitle' => 'You\'re all caught up',
			'features.notifications.loadError' => 'Could not load notifications',
			'features.notifications.filterAll' => 'All',
			'features.notifications.filterUnread' => 'Unread',
			'features.notifications.filterRead' => 'Read',
			'features.notifications.emptyReadTitle' => 'No read notifications',
			'features.notifications.emptyReadSubtitle' => 'Notifications you have read will appear here',
			'features.notifications.sectionToday' => 'Today',
			'features.notifications.sectionYesterday' => 'Yesterday',
			'features.notifications.sectionThisWeek' => 'This week',
			'features.notifications.sectionEarlier' => 'Earlier',
			'features.notifications.timeNow' => 'Just now',
			'features.notifications.timeMinuteShort' => 'min ago',
			'features.notifications.timeHourShort' => 'h ago',
			'features.notifications.detailLoadError' => 'Could not load details',
			'features.notifications.fieldStatus' => 'Status',
			'features.notifications.fieldCategory' => 'Category',
			'features.notifications.fieldApartment' => 'Apartment',
			'features.notifications.fieldAmount' => 'Amount',
			'features.notifications.fieldUploadedBy' => 'Uploaded by',
			'features.notifications.fieldDescription' => 'Description',
			'features.notifications.fieldManagerNote' => 'Manager note',
			'features.notifications.fieldRejectionReason' => 'Rejection reason',
			'features.notifications.fieldLatestUpdate' => 'Latest update',
			'features.notifications.fieldCreatedAt' => 'Created',
			'features.notifications.fieldPeriod' => 'Period',
			'features.notifications.actionViewTicket' => 'View request',
			'features.notifications.actionViewDekont' => 'Review receipt',
			'features.notifications.actionViewDue' => 'View due',
			'features.notifications.typeDueReminder' => 'Due reminder',
			'features.notifications.typeDuePaid' => 'Due paid',
			'features.notifications.typeTicketCreated' => 'New request',
			'features.notifications.typeTicketUpdate' => 'Request updated',
			'features.notifications.typeAnnouncement' => 'Announcement',
			'features.notifications.typeDekontReceived' => 'New receipt',
			'features.notifications.typeDekontNeedsReview' => 'Receipt review',
			'features.notifications.typeDekontMatched' => 'Receipt matched',
			'features.notifications.typeDekontPaymentApplied' => 'Receipt approved',
			'features.notifications.typeExpenseAdded' => 'New expense',
			'features.notifications.typeSystem' => 'System',
			'features.notifications.typeAidatPanelTeam' => 'AidatPanel Team',
			'features.notifications.typeOther' => 'Notification',
			'features.notifications.resident.typeDueReminder' => 'You have a due reminder',
			'features.notifications.resident.typeDuePaid' => 'Your due was paid',
			'features.notifications.resident.typeTicketCreated' => 'Your request was created',
			'features.notifications.resident.typeTicketUpdate' => 'Your request was updated',
			'features.notifications.resident.typeAnnouncement' => 'You received an announcement',
			'features.notifications.resident.typeDekontReceived' => 'Your receipt was received',
			'features.notifications.resident.typeDekontNeedsReview' => 'Your receipt is under review',
			'features.notifications.resident.typeDekontMatched' => 'Your receipt was matched',
			'features.notifications.resident.typeDekontPaymentApplied' => 'Your receipt was approved',
			'features.notifications.resident.typeExpenseAdded' => 'A new expense was added',
			'features.notifications.resident.typeSystem' => 'System notification',
			'features.notifications.resident.typeOther' => 'Your notification',
			'features.notifications.resident.allApartmentsTag' => 'Announcement for you',
			'features.notifications.resident.announcementFeedLabel' => 'Announcement from management',
			'features.notifications.resident.announcementsEmptyTitle' => 'No announcements yet',
			'features.notifications.resident.announcementsEmptySubtitle' => 'Announcements from management will appear here.',
			'features.notifications.allApartmentsTag' => 'All apartments',
			'features.notifications.sendTitle' => 'Announcement to residents',
			'features.notifications.fieldTitle' => 'Title',
			'features.notifications.fieldBody' => 'Message',
			'features.notifications.sendButton' => 'Send',
			'features.notifications.sendSuccess' => 'Announcement sent',
			'features.notifications.sendSuccessAll' => 'Announcement sent to all buildings',
			'features.notifications.sendPartialFailed' => 'Announcement sent to {ok}/{total} buildings',
			'features.notifications.sendFailed' => 'Could not send announcement',
			'features.notifications.fieldRequired' => 'Required field',
			'features.notifications.permissionPrompt.residentTitle' => 'Enable notifications',
			'features.notifications.permissionPrompt.residentBody' => 'We recommend allowing notifications so you can get due reminders, announcements, and receipt updates right away.',
			'features.notifications.permissionPrompt.managerTitle' => 'Enable notifications',
			'features.notifications.permissionPrompt.managerBody' => 'We recommend allowing notifications so you can get receipt reviews, resident requests, and due activity right away.',
			'features.notifications.permissionPrompt.allow' => 'Allow',
			'features.notifications.permissionPrompt.notNow' => 'Not now',
			'features.notifications.titleTooLong' => 'Title must be at most 120 characters',
			'features.notifications.bodyTooLong' => 'Message must be at most 2000 characters',
			'features.notifications.noBuilding' => 'Add a building first',
			'features.profile.title' => 'Profile Details',
			'features.profile.fullName' => 'Full name',
			'features.profile.email' => 'Email',
			'features.profile.phone' => 'Phone',
			'features.profile.role' => 'Role',
			'features.profile.languagePref' => 'Language preference',
			'features.profile.notProvided' => 'Not provided',
			'features.profile.editHint' => 'Profile editing will be available soon.',
			'features.profile.sectionPersonal' => 'Personal Information',
			'features.profile.sectionAccount' => 'Account Information',
			'features.profile.editPhotoHint' => 'Tap to change photo',
			'features.profile.editTitle' => 'Edit Profile',
			'features.profile.phoneOptionalHint' => 'Optional',
			'features.profile.phoneRequired' => 'Phone number is required',
			'features.profile.phoneOtpTitle' => 'Phone verification',
			'features.profile.phoneOtpMessage' => 'Enter the 6-digit code sent to {phone}.',
			'features.profile.phoneOtpConfirm' => 'Verify and save',
			'features.profile.phoneOtpSendFailed' => 'Could not send the verification code. Try again.',
			'features.profile.profileUpdated' => 'Your profile has been updated.',
			'features.profile.profileUpdateFailed' => 'Could not update profile. Try again.',
			'features.profile.profileLoadFailed' => 'Could not load profile.',
			'features.profile.readOnlySection' => 'Cannot be edited here',
			'features.profile.contactRequired' => 'At least one contact channel (Email or Phone) must be registered.',
			'features.profile.securityVerificationTitle' => 'Security Verification',
			'features.profile.securityVerificationMessage' => 'You must enter your current password to change your email or phone number.',
			'features.profile.securityVerificationMessageManager' => 'You must enter your current password to change your email or phone number.',
			'features.profile.editSheetHint' => 'Only name and phone can be updated. Other details are shown on the profile screen above.',
			'features.profile.photoSaved' => 'Profile photo saved for this account.',
			'features.profile.photoRemoved' => 'Profile photo removed.',
			'features.profile.removePhoto' => 'Remove profile photo',
			'features.profile.avatarChooseSource' => 'Choose photo',
			'features.profile.avatarCamera' => 'Camera',
			'features.profile.avatarGallery' => 'Gallery',
			'features.profile.avatarSave' => 'Save',
			'features.profile.avatarRemove' => 'Remove Photo',
			'features.profile.avatarPhotoLoadError' => 'Could not load the photo.',
			'features.profile.avatarPhotoProcessError' => 'Could not process the photo.',
			'features.profile.avatarCameraError' => 'Could not open the camera.',
			'features.profile.avatarGalleryError' => 'Could not open the gallery.',
			'features.profile.avatarDecodeError' => 'Could not decode the image.',
			'features.profile.avatarSaveError' => 'Could not save the photo.',
			'features.profile.avatarUnsupportedFormat' => 'Unsupported file type. Please select a JPG, PNG, or GIF.',
			'features.profile.accountCreatedAt' => 'Account created: {date}',
			'features.subscription.title' => 'Subscription',
			'features.subscription.statusActive' => 'Active',
			'features.subscription.statusExpired' => 'Expired',
			'features.subscription.statusCancelled' => 'Cancelled',
			'features.subscription.statusTrial' => 'Trial',
			'features.subscription.statusUnknown' => 'Unknown',
			'features.subscription.planMonthly' => 'Monthly plan',
			'features.subscription.planAnnual' => 'Annual plan',
			'features.subscription.planUnknown' => 'Plan',
			'features.subscription.renewsOn' => 'Renews: {date}',
			'features.subscription.noSubscription' => 'No subscription on file yet.',
			'features.subscription.backendPending' => 'Purchases coming soon.',
			'features.subscription.purchaseComingSoon' => 'Purchase coming soon',
			'features.subscription.purchaseMonthly' => 'Subscribe monthly',
			'features.subscription.purchaseAnnual' => 'Subscribe annually',
			'features.subscription.purchaseSuccess' => 'Purchase completed successfully.',
			'features.subscription.purchaseCancelled' => 'Purchase was cancelled.',
			'features.subscription.purchasesUnavailable' => 'Purchases are not enabled in this build yet.',
			'features.subscription.loadFailed' => 'Could not load subscription.',
			'features.subscription.purchaseProductNotFound' => 'Subscription product not found. Try again later.',
			'features.subscription.purchaseStoreError' => 'Payment is unavailable right now. Try again.',
			'features.subscription.purchaseFailed' => 'Purchase could not be completed. Try again.',
			'features.subscription.sectionSelectPlan' => 'Choose a plan and subscribe',
			'features.subscription.cycleMonthly' => 'Renews every month',
			'features.subscription.cycleAnnual' => 'Renews every year',
			'features.subscription.featureUnlimitedUnits' => 'Unlimited units',
			'features.subscription.buildingUsageSummary' => 'Managed buildings: {used}',
			'features.subscription.buildingUsageWithLimit' => 'Managed buildings: {used} / {limit}',
			'features.subscription.featureDuesTracking' => 'Dues and collections in one place',
			'features.subscription.featureAdvancedReports' => 'Instant PDF reports',
			'features.subscription.featurePrioritySupport' => 'Priority support line',
			'features.subscription.trialActive' => 'Trial period active',
			'features.subscription.subscriptionActive' => 'Subscription active',
			'features.subscription.subscriptionCancelled' => 'Subscription cancelled',
			'features.subscription.subscriptionExpired' => 'Subscription expired',
			'features.subscription.noActiveSubscription' => 'No active subscription',
			'features.subscription.daysLeft' => '{count} days left',
			'features.subscription.planLabel' => 'PLAN',
			'features.subscription.statusLabel' => 'STATUS',
			'features.subscription.renewalLabel' => 'RENEWAL',
			'features.subscription.planAnnualShort' => 'Annual',
			'features.subscription.planMonthlyShort' => 'Monthly',
			'features.subscription.priceExclVatMonth' => 'Excl. VAT / month',
			'features.subscription.priceExclVatYear' => 'Excl. VAT / year',
			'features.subscription.savingBadge' => 'Save {amount}',
			'features.subscription.bestValueBadge' => 'Best value',
			'features.subscription.purchaseMonthlyCta' => 'Subscribe monthly',
			'features.subscription.purchaseAnnualCta' => 'Subscribe annually',
			'features.subscription.kdvNote' => 'Prices exclude VAT · Cancel anytime',
			'features.subscription.guestUser' => 'User',
			'features.subscription.priceUnavailable' => '—',
			'features.subscription.loadingPlans' => 'Loading plans…',
			'features.subscription.purchasesDisabledHint' => 'Purchases are not enabled in this build yet.',
			'features.subscription.plan1To5' => '1-5 Buildings Plan',
			'features.subscription.plan5To20' => '5-20 Buildings Plan',
			'features.subscription.plan20To50' => '20-50 Buildings Plan',
			'features.subscription.plan50Plus' => '50+ Buildings (Custom)',
			'features.subscription.planBusiness' => 'Business',
			'features.subscription.comingSoon' => 'Coming Soon',
			'features.subscription.contactUs' => 'Contact Us',
			'features.subscription.contactUsDesc' => 'Contact us for custom pricing.',
			'features.subscription.sectionPlans' => 'Plans',
			'features.subscription.feature1To5' => 'Manage 1-5 Buildings',
			'features.subscription.feature5To20' => 'Manage 5-20 Buildings',
			'features.subscription.feature20To50' => 'Manage 20-50 Buildings',
			'features.subscription.feature50Plus' => 'Unlimited Building Management',
			'features.subscription.featureBasicUpTo20' => 'Full control for up to 20 buildings',
			'features.subscription.featureBusinessUnlimited' => 'Unlimited buildings · unlimited sites',
			'features.subscription.featureCustomSupport' => 'Dedicated Account Manager',
			'features.subscription.buildingUsageUnlimited' => 'Managed buildings: {used} · ∞',
			'features.subscription.buildingUsageUnlimitedShort' => '{used} / ∞',
			'features.subscription.buildingUsageNeedSubscription' => 'Managed buildings: {used} · Subscription required',
			'features.subscription.noSubCannotAddBuilding' => 'Without a subscription you can view existing data; subscribe to Basic or Business to add buildings.',
			'features.subscription.upgradeToBusinessHint' => 'Basic plan quota is full. Upgrade to Business for more buildings.',
			'features.subscription.purchaseBusinessMonthlyCta' => 'Subscribe to Business monthly',
			'features.subscription.purchaseBusinessAnnualCta' => 'Subscribe to Business annually',
			'features.subscription.toggleMonthly' => 'Monthly',
			'features.subscription.toggleAnnual' => 'Annual',
			'features.subscription.currentPlanBadge' => 'Your Current Plan',
			'features.subscription.buildingProgress' => 'Building Usage',
			'features.subscription.planBasic' => 'Basic',
			'features.subscription.featureBasicBuildings' => 'Up to 20 buildings',
			'features.subscription.featureBasicReports' => 'Basic Reports',
			'features.subscription.statusUnlimited' => 'Lifetime',
			'features.subscription.compareIntro' => 'Basic or Business — pick by your total building count.',
			'features.subscription.planBasicSubtitle' => 'For small and mid-size portfolios',
			'features.subscription.planBusinessSubtitle' => 'For growing portfolios',
			'features.subscription.featureSitesIncluded' => 'Sites and blocks included',
			'features.subscription.featureDekontOcr' => 'Upload receipts — we read them',
			'features.subscription.featurePdfReports' => 'PDF reports in one tap',
			'features.subscription.priceFallbackBasicMonthly' => '₺199.99',
			'features.subscription.priceFallbackBasicAnnual' => '₺1,999.99',
			'features.subscription.priceFallbackBusinessMonthly' => '₺399.99',
			'features.subscription.priceFallbackBusinessAnnual' => '₺3,999.99',
			'features.subscription.recommendedBadge' => 'Recommended',
			'features.subscription.ctaCurrentPlan' => 'Your current plan',
			'features.subscription.ctaSubscribe' => 'Subscribe',
			'features.subscription.ctaUpgrade' => 'Upgrade to Business',
			'features.subscription.ctaAlreadyBusiness' => 'You are already on Business',
			'features.subscription.giftBannerTitle' => 'Complimentary subscription active',
			'features.subscription.giftBannerBody' => 'Free access until {date}. If you purchase, your complimentary period is kept.',
			'features.subscription.sourceGift' => 'Gift',
			'features.subscription.sourceStore' => 'Store',
			'features.subscription.validUntilLabel' => 'Valid until',
			'features.subscription.annualSaveHint' => 'Better value with annual billing',
			'features.subscription.quotaNearHint' => 'You are nearing your building quota. Continue unlimited with Business.',
			'features.reports.menuDownload' => 'Download report',
			'features.reports.sheetTitle' => 'PDF report',
			'features.reports.reportTypeLabel' => 'Report type',
			'features.reports.typeMonthly' => 'Monthly summary',
			'features.reports.typeAnnual' => 'Annual summary',
			'features.reports.periodHintMonthly' => 'Report for {month} {year}',
			'features.reports.periodHintAnnual' => 'Annual report for {year}',
			'features.reports.fieldMonth' => 'Month',
			'features.reports.fieldYear' => 'Year',
			'features.reports.selectMonthTitle' => 'Select month',
			'features.reports.selectYearTitle' => 'Select year',
			'features.reports.download' => 'Show report',
			'features.reports.downloading' => 'Preparing report…',
			'features.reports.previewTitle' => 'Report preview',
			'features.reports.pdfPreviewHint' => 'Pinch to zoom and scroll to view pages.',
			'features.reports.pdfPreviewUnavailable' => 'PDF could not be opened on this device. Use «Share report» below to open it in another app.',
			'features.reports.shareReport' => 'Share report',
			'features.reports.shareFailed' => 'Could not share the report. Try again.',
			'features.reports.failed' => 'Could not generate the report. Try again.',
			'features.dashboard.allBuildings' => 'All Buildings',
			'features.dashboard.properties' => 'Buildings',
			'features.dashboard.selectBuilding' => 'Select building',
			'features.dashboard.searchBuildings' => 'Search by name or address',
			'features.dashboard.buildingPickerTapHint' => 'Tap to search and select a building',
			'features.dashboard.allBuildingsSummary' => '{count} buildings',
			'features.dashboard.buildingUnitsSummary' => '{apartments} units',
			'features.dashboard.collectionRate' => 'Collection Rate',
			'features.dashboard.overduePayments' => 'Overdue Payments',
			'features.dashboard.openTicketRequests' => 'Open Requests',
			'features.dashboard.monthTotalExpense' => 'This Month\'s Expenses',
			'features.dashboard.pendingDekonts' => 'Pending Receipts',
			'features.dashboard.duesCollectionStatus' => 'Dues Collection Status',
			'features.dashboard.financeTrendTitle' => 'Last 6 Months',
			'features.dashboard.incomeExpenseComparison' => 'Income / Expense Comparison',
			'features.dashboard.last6Months' => 'Last 6 Months',
			'features.dashboard.collectedDues' => 'Collected Dues',
			'features.dashboard.totalExpense' => 'Total Expenses',
			'features.dashboard.ticketStatusTitle' => 'Request Status',
			'features.dashboard.ticketOpen' => 'Open',
			'features.dashboard.ticketInProgress' => 'Approved',
			'features.dashboard.ticketResolved' => 'Done',
			'features.dashboard.overdueApartments' => 'Apartments with Overdue Payments',
			'features.dashboard.apartmentCountBadge' => '{count} apartments',
			'features.dashboard.legendPaid' => 'Paid',
			'features.dashboard.legendOverdue' => 'Overdue',
			'features.dashboard.legendPending' => 'Pending',
			'features.dashboard.legendUnit' => '{count} due(s)',
			'features.dashboard.remind' => 'Remind',
			'features.dashboard.remindAll' => 'Remind all',
			'features.dashboard.remindSent' => 'Reminder sent',
			'features.dashboard.remindAllSent' => 'Reminders sent to {count} residents.',
			'features.dashboard.remindCooldown' => 'A reminder was already sent for this due within the last 24 hours.',
			'features.dashboard.remindNoRecipient' => 'No resident found to send a reminder for this apartment.',
			'features.dashboard.apartmentTitle' => 'Apt. {number}',
			'features.dashboard.apartmentShortLabel' => 'A{number}',
			'features.dashboard.apartmentWithFloor' => 'Apt. {number} · Floor {floor}',
			'features.dashboard.noOverdueApartments' => 'No overdue payments',
			'features.dashboard.noChartData' => 'Not enough data yet',
			'features.dashboard.noBuildingsEmptyMessage' => 'You don\'t have a site or building yet. Add your first one to start managing.',
			'features.dashboard.noBuildingsEmptyCta' => 'Add Building',
			'features.dashboard.noBuildingsEmptyCtaSite' => 'Add Site',
			'features.dashboard.noResidentsInviteMessage' => 'No residents have been assigned to the apartments in this building yet. Invite residents to get started.',
			'features.dashboard.noResidentsInviteCta' => 'Invite New Resident',
			'features.dashboard.pendingInvitesCount' => '{count} pending invite(s)',
			'features.dashboard.noBlocksInviteMessage' => 'This site has no buildings yet. Add the first block to get started.',
			'features.dashboard.noBlocksInviteCta' => 'Add Building to Site',
			'features.dashboard.seeMoreOverdue' => 'See more (+{count})',
			'features.dashboard.payNow' => 'Pay Now',
			'features.dashboard.overduePaymentsBadge' => '{count} overdue payment(s)',
			'features.dashboard.residentOverduePaymentsBadge' => '{count} of your dues are overdue',
			'features.dashboard.featuredDuePeriod' => '{month} {year} dues',
			'features.dashboard.residentFeaturedDuePeriod' => 'Your {month} {year} dues',
			'features.dashboard.residentDebtAndPaySubtitle' => 'View and pay your dues here.',
			'features.dashboard.duesStatusAction' => 'Dues Status',
			'features.dashboard.overdueDuesBadge' => '{count} overdue dues',
			'features.dashboard.dataWarningBanner' => '{count} sections failed to load. Pull down to retry.',
			'features.dashboard.sitesSection' => 'Sites',
			'features.dashboard.independentBuildingsSection' => 'Independent Buildings',
			'features.dashboard.sitePickerSummary' => '{name} · {count} buildings',
			'features.dashboard.siteScopeSummary' => '{count} buildings',
			'features.dashboard.activityHistory.title' => 'Recent Activity',
			'features.dashboard.activityHistory.rangeToday' => 'Today',
			'features.dashboard.activityHistory.rangeThisWeek' => 'This Week',
			'features.dashboard.activityHistory.rangeThisMonth' => 'This Month',
			'features.dashboard.activityHistory.rangeThreeMonths' => '3 Months',
			'features.dashboard.activityHistory.rangeSixMonths' => '6 Months',
			_ => null,
		} ?? switch (path) {
			'features.dashboard.activityHistory.emptyTitle' => 'No activity in this period',
			'features.dashboard.activityHistory.emptySubtitle' => 'No payments or announcements in the range you selected.',
			'features.dues.detailTitle' => 'Due Details',
			'features.dues.collectPayment' => 'Collect Payment',
			'features.dues.collectPaymentConfirmTitle' => 'Record cash payment?',
			'features.dues.collectPaymentConfirmBody' => '{apartment} — remaining {amount} for {period} will be marked as paid.',
			'features.dues.reviewDekont' => 'Review Receipt',
			'features.dues.paymentDetail' => 'Payment Details',
			'features.dues.amountLabel' => 'Amount',
			'features.dues.periodLabel' => 'Period',
			'features.dues.resident.paidStatus' => 'Paid',
			'features.dues.resident.overdueStatus' => 'Your due is overdue',
			'features.dues.resident.pendingStatus' => 'Payment pending',
			'features.dues.resident.waivedStatus' => 'You are waived this period',
			'features.dues.resident.overdueDetail' => 'Your due is {days} days overdue',
			'features.dues.resident.pendingDetail' => 'Due by {day} {month}',
			'features.dues.resident.paidLateSummary' => 'You paid on {date} · {days} days late',
			'features.dues.resident.paidOnTimeSummary' => 'You paid on {date}',
			'features.dues.resident.duesUpToDate' => 'Your dues are up to date',
			'features.dues.resident.debtBannerOverdue' => '{count} overdue due · {amount}',
			'features.dues.resident.debtBannerPending' => '{count} due pending · {amount}',
			'features.dues.resident.paymentRecordsLabel' => 'Payment records',
			'features.dues.resident.ledgerPaidSubtitle' => 'Paid on {date}',
			'features.dues.resident.ledgerOverdueSubtitle' => '{days} days overdue',
			'features.dues.resident.ledgerPendingSubtitle' => 'Due by: {date}',
			'features.dues.resident.badgePaid' => 'Paid',
			'features.dues.resident.badgePending' => 'Pending',
			'features.dues.resident.badgeOverdue' => 'Overdue',
			'features.dues.resident.badgeWaived' => 'Waived',
			'features.dues.transactions.title' => 'Dues Status Summary',
			'features.dues.transactions.residentTitle' => 'Your Transaction History',
			'features.dues.transactions.emptyTitle' => 'No transactions yet',
			'features.dues.transactions.emptySubtitle' => 'Receipt approvals and manual payments appear here.',
			'features.dues.transactions.residentEmptyTitle' => 'No transactions yet',
			'features.dues.transactions.residentEmptySubtitle' => 'Your payments and receipts will appear here.',
			'features.dues.transactions.sourceReceipt' => 'Receipt',
			'features.dues.transactions.sourceManual' => 'Manual',
			'features.dues.transactions.statusApproved' => 'Approved',
			'features.dues.transactions.statusPending' => 'Pending',
			'features.dues.transactions.statusRejected' => 'Rejected',
			'features.dues.transactions.unknownApartment' => 'No apartment info',
			'features.dues.transactions.residentPaidByManual' => 'You paid your due in person',
			'features.dues.transactions.residentPaidByReceipt' => 'You paid your due with a receipt',
			'features.dues.transactions.residentDekontPending' => 'Your receipt is awaiting approval',
			'features.dues.transactions.residentDekontRejected' => 'Your receipt was rejected',
			'features.faz2.sectionTitle' => 'Phase 2',
			'features.faz2.tickets' => 'Requests',
			'features.faz2.expenses' => 'Expenses',
			'features.faz2.announcement' => 'Announce',
			'features.welcome.skip' => 'Skip',
			'features.welcome.next' => 'Next',
			'features.welcome.start' => 'Get started',
			'features.welcome.skipSemantics' => 'Skip introduction',
			'features.welcome.nextSemantics' => 'Next page',
			'features.welcome.startSemantics' => 'Finish introduction and continue',
			'features.welcome.pageSemantics' => 'Introduction page {current} of {total}',
			'features.welcome.dotsSemantics' => 'Page {current} of {total}',
			'features.welcome.page1Title' => 'Welcome to AidatPanel',
			'features.welcome.page1Body' => 'Manage your building or complex from your phone. Setup takes just a few minutes.',
			'features.welcome.page2Title' => 'One account, full control',
			'features.welcome.page2Body' => 'Whether you manage a single building or a multi-block complex — all from the same account and screen.',
			'features.welcome.page3Title' => 'Upload a receipt, we handle the rest',
			'features.welcome.page3Body' => 'Residents upload receipts; the system reads amount and date. You just review and approve.',
			'features.welcome.page4Title' => 'Everyone stays in the loop',
			'features.welcome.page4Body' => 'Payments, announcements, and request updates reach everyone with instant notifications.',
			'features.welcome.page5Title' => 'Clear and organized',
			'features.welcome.page5Body' => 'Expenses stay on record and requests live in one place. Everyone knows where things stand.',
			'legal.companyName' => 'Vefa Yazılım',
			'legal.contactEmail' => 'store@vefayazilim.com',
			'legal.contactBlock' => 'Data controller: Vefa Yazılım\nEmail: store@vefayazilim.com',
			'legal.updatedLabel' => 'Last updated',
			'legal.updatedDate' => 'June 2026',
			'legal.privacyIntro' => 'This policy explains how Vefa Yazılım processes your personal data when you use the AidatPanel mobile app. By continuing to use the app, you acknowledge that you have read this policy.',
			'legal.privacyS1Title' => '1. Data controller',
			'legal.privacyS1Body' => 'Your personal data is processed by Vefa Yazılım as the data controller for AidatPanel, in compliance with applicable data protection laws, including Turkish KVKK where applicable. For privacy and KVKK requests: store@vefayazilim.com',
			'legal.privacyS2Title' => '2. Data we collect',
			'legal.privacyS2Body' => 'We may process account details (name, email, phone, language), building and apartment association, dues and payment records, support tickets, announcements and notification preferences, receipt images you upload, device push token (FCM), and secure session tokens.',
			'legal.privacyS3Title' => '3. Purposes',
			'legal.privacyS3Body' => 'Data is used for dues and expense management, payment and receipt workflows, in-building communication, authentication, service security, legal obligations, and sending notifications you enable.',
			'legal.privacyS4Title' => '4. Retention and security',
			'legal.privacyS4Body' => 'Data is stored on secure servers; communication uses HTTPS. Session data is kept in secure device storage. Data is retained for the service relationship and as required by law.',
			'legal.privacyS5Title' => '5. Sharing',
			'legal.privacyS5Body' => 'We do not sell your data. It may be shared only with infrastructure providers necessary to run the service (hosting, push notifications, etc.) and authorities when legally required.',
			'legal.privacyS6Title' => '6. Your rights',
			'legal.privacyS6Body' => 'You may request access, correction, deletion, or restriction of processing. Account closure (soft delete) is available in Settings; records that must be kept by law may be stored in anonymized form. Submit requests to store@vefayazilim.com.',
			'legal.kvkkIntro' => 'This notice is provided under Turkish Personal Data Protection Law No. 6698 (KVKK) for processing by Vefa Yazılım.',
			'legal.kvkkS1Title' => 'Data controller and contact',
			'legal.kvkkS1Body' => 'The data controller for AidatPanel is Vefa Yazılım. You may submit KVKK requests to store@vefayazilim.com or using your registered email in the app.',
			'legal.kvkkS2Title' => 'Data categories',
			'legal.kvkkS2Body' => 'Categories may include identity and contact, customer transaction (dues, payments, expenses), visual records (receipts), security (logs, tokens), and communication (notification consent).',
			'legal.kvkkS3Title' => 'Purposes and legal bases',
			'legal.kvkkS3Body' => 'Processing is based on contract performance, legal obligation, legitimate interest, and your explicit consent where required (e.g. notifications).',
			'legal.kvkkS4Title' => 'Transfers',
			'legal.kvkkS4Body' => 'Data may be transferred to hosting and technical providers within Türkiye as needed to provide the service, with appropriate safeguards.',
			'legal.kvkkS5Title' => 'Collection method',
			'legal.kvkkS5Body' => 'Data is collected electronically via app forms, automated logs, files you upload, and the notification infrastructure.',
			'legal.kvkkS6Title' => 'Data subject rights',
			'legal.kvkkS6Body' => 'You may exercise your rights under Article 11 of KVKK by contacting Vefa Yazılım at store@vefayazilim.com; requests are answered within statutory time limits.',
			'legal.helpIntro' => 'Help center coming soon',
			'legal.helpBody' => 'FAQs, step-by-step guides, and support channels will be added here soon. For app support: store@vefayazilim.com (Vefa Yazılım). For urgent building matters, contact your building manager or site administration.',
			'db_context.user_entry' => 'Record: {value}',
			'db_context.building_name' => 'Building: {value}',
			'db_context.apartment_label' => 'Apartment: {value}',
			'db_context.code_value' => 'Code: {value}',
			'db_context.expiry_date' => 'Expires at: {value}',
			_ => null,
		};
	}
}
