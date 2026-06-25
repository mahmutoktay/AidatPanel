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

	/// en: 'Other devices have been signed out.'
	String get logoutAllDevicesSuccess => 'Other devices have been signed out.';

	/// en: 'Could not complete this action. Please try again.'
	String get logoutAllDevicesFailed => 'Could not complete this action. Please try again.';

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

	/// en: 'Something went wrong. Please try again.'
	String get unexpectedError => 'Something went wrong. Please try again.';

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

	/// en: 'Managed Buildings'
	String get managedBuildings => 'Managed Buildings';

	/// en: 'Issues'
	String get issues => 'Issues';

	/// en: 'Issues Tab'
	String get issuesTab => 'Issues Tab';

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

	/// en: 'Quick actions'
	String get quickActions => 'Quick actions';

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

	/// en: 'Could not add building. Please try again.'
	String get buildingAddFailed => 'Could not add building. Please try again.';

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

	/// en: 'Dues status updated'
	String get duesUpdated => 'Dues status updated';

	/// en: 'Amount'
	String get amount => 'Amount';

	/// en: 'Update Due Amount'
	String get updateDueAmount => 'Update Due Amount';

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

	/// en: '{days} days overdue'
	String get dueMetaOverdueDelay => '{days} days overdue';

	/// en: 'paid in {month} {year}'
	String get dueMetaPaidInMonth => 'paid in {month} {year}';

	/// en: 'paid on {day} {month}'
	String get dueMetaPaidOnDay => 'paid on {day} {month}';

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

	/// en: 'Cannot delete this building: apartments, residents, or dues records still exist. Clean up apartments/dues first.'
	String get buildingDeleteFailedFK => 'Cannot delete this building: apartments, residents, or dues records still exist. Clean up apartments/dues first.';

	/// en: 'This action cannot be undone.'
	String get deleteBuildingHeader => 'This action cannot be undone.';

	/// en: 'To confirm, type the building name below exactly:'
	String get deleteBuildingTypeHint => 'To confirm, type the building name below exactly:';

	/// en: 'Building name'
	String get deleteBuildingTypeFieldLabel => 'Building name';

	/// en: 'What you typed does not match the building name.'
	String get buildingNameMismatch => 'What you typed does not match the building name.';

	/// en: 'Edit Apartment'
	String get editApartment => 'Edit Apartment';

	/// en: 'Delete Apartment'
	String get deleteApartment => 'Delete Apartment';

	/// en: 'Apartment updated'
	String get apartmentUpdated => 'Apartment updated';

	/// en: 'Apartment deleted'
	String get apartmentDeleted => 'Apartment deleted';

	/// en: 'Could not update apartment'
	String get apartmentUpdateFailed => 'Could not update apartment';

	/// en: 'Could not delete apartment'
	String get apartmentDeleteFailed => 'Could not delete apartment';

	/// en: 'Cannot delete this apartment: resident or dues records exist. Wait for the resident to close their account and clean up dues.'
	String get apartmentDeleteFailedFK => 'Cannot delete this apartment: resident or dues records exist. Wait for the resident to close their account and clean up dues.';

	/// en: 'Are you sure you want to delete this apartment?'
	String get deleteApartmentConfirm => 'Are you sure you want to delete this apartment?';

	/// en: 'Apt No (e.g. 5A)'
	String get apartmentNumberLabel => 'Apt No (e.g. 5A)';

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

	/// en: 'Your password has been changed. Please sign in again with your new password.'
	String get changePasswordSuccess => 'Your password has been changed. Please sign in again with your new password.';

	/// en: 'Could not change password. Please try again.'
	String get changePasswordFailed => 'Could not change password. Please try again.';

	/// en: 'Current password is incorrect.'
	String get changePasswordWrongCurrent => 'Current password is incorrect.';

	/// en: 'You can change the application language here.'
	String get languageSheetDescription => 'You can change the application language here.';

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

	/// en: 'Your account has been closed. Thank you for using AidatPanel.'
	String get deleteAccountSuccess => 'Your account has been closed. Thank you for using AidatPanel.';

	/// en: 'Could not close account. Please try again.'
	String get deleteAccountFailed => 'Could not close account. Please try again.';

	/// en: 'You first need to delete the buildings you manage or transfer them to another manager.'
	String get deleteAccountFailedManager => 'You first need to delete the buildings you manage or transfer them to another manager.';

	/// en: 'Danger Zone'
	String get dangerZone => 'Danger Zone';

	/// en: 'Forgot Password'
	String get forgotPassword => 'Forgot Password';

	/// en: 'Forgot Password'
	String get forgotPasswordTitle => 'Forgot Password';

	/// en: 'Enter your registered email and we'll send you a reset code.'
	String get forgotPasswordSubtitle => 'Enter your registered email and we\'ll send you a reset code.';

	/// en: 'If this email is registered, a reset code has been sent. Please check your inbox.'
	String get forgotPasswordSuccess => 'If this email is registered, a reset code has been sent. Please check your inbox.';

	/// en: 'Send Code'
	String get sendResetCode => 'Send Code';

	/// en: 'I already have a code'
	String get iHaveACode => 'I already have a code';

	/// en: 'Set New Password'
	String get resetPasswordTitle => 'Set New Password';

	/// en: 'Enter the 6-character code from your email and a new password.'
	String get resetPasswordSubtitle => 'Enter the 6-character code from your email and a new password.';

	/// en: 'Reset Code'
	String get resetCode => 'Reset Code';

	/// en: 'ABC123'
	String get resetCodeHint => 'ABC123';

	/// en: 'Reset code required'
	String get resetCodeRequired => 'Reset code required';

	/// en: 'Code must be 6 characters'
	String get resetCodeInvalid => 'Code must be 6 characters';

	/// en: 'Your password has been reset. You can sign in with your new password.'
	String get resetPasswordSuccess => 'Your password has been reset. You can sign in with your new password.';

	/// en: 'Could not reset password. The code may be invalid or expired.'
	String get resetPasswordFailed => 'Could not reset password. The code may be invalid or expired.';

	/// en: 'Reset Password'
	String get resetPasswordSubmit => 'Reset Password';

	/// en: 'Back to login'
	String get backToLogin => 'Back to login';
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
	late final Translations$features$faz2$en faz2 = Translations$features$faz2$en._(_root);
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

	/// en: 'Could not reach the server. Please try again later.'
	String get serverError => 'Could not reach the server. Please try again later.';

	/// en: 'Please check the information you entered.'
	String get validationError => 'Please check the information you entered.';

	/// en: 'The requested record was not found.'
	String get notFound => 'The requested record was not found.';

	/// en: 'Your session has ended. Please sign in again.'
	String get unauthorized => 'Your session has ended. Please sign in again.';

	/// en: 'Too many attempts. Please wait a moment and try again.'
	String get rateLimit => 'Too many attempts. Please wait a moment and try again.';

	/// en: 'You do not have permission for this action.'
	String get forbidden => 'You do not have permission for this action.';

	/// en: 'Something went wrong. Please try again.'
	String get genericError => 'Something went wrong. Please try again.';

	/// en: 'Email, phone, or password is incorrect. Please check and try again.'
	String get invalidCredentials => 'Email, phone, or password is incorrect. Please check and try again.';

	/// en: 'This email is already registered. Try signing in.'
	String get duplicateEmail => 'This email is already registered. Try signing in.';

	/// en: 'This phone number is already registered.'
	String get duplicatePhone => 'This phone number is already registered.';

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

	/// en: 'This action is not available right now. Please try again later.'
	String get serviceUnavailable => 'This action is not available right now. Please try again later.';

	/// en: 'File could not be uploaded. Please try again.'
	String get fileUploadError => 'File could not be uploaded. Please try again.';

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

	/// en: 'Sites'
	String get tabSites => 'Sites';

	/// en: 'Buildings'
	String get tabBuildings => 'Buildings';

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

	/// en: 'Override site default IBAN'
	String get overrideCollection => 'Override site default IBAN';

	/// en: 'When off, site IBAN applies'
	String get overrideCollectionHint => 'When off, site IBAN applies';

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

	/// en: 'Account created. You can now log in.'
	String get registrationSuccess => 'Account created. You can now log in.';

	/// en: 'Signed in successfully. Welcome.'
	String get loginSuccess => 'Signed in successfully. Welcome.';

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

	/// en: 'Report issue / request'
	String get createTitle => 'Report issue / request';

	/// en: 'Title'
	String get fieldTitle => 'Title';

	/// en: 'e.g. Elevator malfunction'
	String get fieldTitleHint => 'e.g. Elevator malfunction';

	/// en: 'Description'
	String get fieldDescription => 'Description';

	/// en: 'Briefly describe the issue'
	String get fieldDescriptionHint => 'Briefly describe the issue';

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

	/// en: 'Could not save your request. Please try again.'
	String get createFailed => 'Could not save your request. Please try again.';

	/// en: 'The request service is not available right now. Please try again later.'
	String get createServiceUnavailable => 'The request service is not available right now. Please try again later.';

	/// en: 'No requests yet'
	String get emptyTitle => 'No requests yet';

	/// en: 'Report an issue or request from here'
	String get emptySubtitle => 'Report an issue or request from here';

	/// en: 'Title must be at least 3 characters'
	String get titleTooShort => 'Title must be at least 3 characters';

	/// en: 'Description must be at least 10 characters'
	String get descriptionTooShort => 'Description must be at least 10 characters';

	/// en: 'Open'
	String get statusOpen => 'Open';

	/// en: 'In progress'
	String get statusInProgress => 'In progress';

	/// en: 'Resolved'
	String get statusResolved => 'Resolved';

	/// en: 'Closed'
	String get statusClosed => 'Closed';

	/// en: 'REQUEST STATUS'
	String get statusTrackerTitle => 'REQUEST STATUS';

	/// en: 'Waiting'
	String get statusStepWaiting => 'Waiting';

	/// en: 'In progress'
	String get statusStepInProgress => 'In progress';

	/// en: 'Resolved'
	String get statusStepResolved => 'Resolved';

	/// en: 'Closed'
	String get statusStepClosed => 'Closed';

	/// en: 'Your request is waiting'
	String get statusHeadlineOpen => 'Your request is waiting';

	/// en: 'Your request is in progress'
	String get statusHeadlineInProgress => 'Your request is in progress';

	/// en: 'Your request is resolved'
	String get statusHeadlineResolved => 'Your request is resolved';

	/// en: 'Your request is closed'
	String get statusHeadlineClosed => 'Your request is closed';

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

	/// en: 'Could not load requests'
	String get loadError => 'Could not load requests';

	/// en: 'Cannot add notes to a closed request'
	String get noteDisabledClosed => 'Cannot add notes to a closed request';

	/// en: 'This request is closed; status cannot be changed.'
	String get statusClosedHint => 'This request is closed; status cannot be changed.';

	/// en: 'Apartment not linked. Please sign in again.'
	String get apartmentRequired => 'Apartment not linked. Please sign in again.';

	/// en: 'Manager update'
	String get managerUpdateLabel => 'Manager update';

	/// en: 'Resident update'
	String get residentUpdateLabel => 'Resident update';

	/// en: 'Quick reply templates'
	String get quickReplyTemplatesTitle => 'Quick reply templates';

	/// en: 'Confirm'
	String get confirmChanges => 'Confirm';

	/// en: 'Requester details'
	String get residentInfoTitle => 'Requester details';

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

	/// en: 'Account title'
	String get accountTitleLabel => 'Account title';

	/// en: 'Transfer reference'
	String get referenceLabel => 'Transfer reference';

	/// en: 'Copy'
	String get copy => 'Copy';

	/// en: 'Copied to clipboard'
	String get copied => 'Copied to clipboard';

	/// en: 'Select due'
	String get selectDue => 'Select due';

	/// en: 'Select the due you paid'
	String get selectDueHint => 'Select the due you paid';

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

	/// en: 'Receipt could not be saved on the server. Please try again later.'
	String get errorUploadServer => 'Receipt could not be saved on the server. Please try again later.';

	/// en: 'Please select a file.'
	String get errorUploadFileRequired => 'Please select a file.';

	/// en: 'Payment details could not be loaded. Please try again.'
	String get errorPaymentInfo => 'Payment details could not be loaded. Please try again.';

	/// en: 'Receipt list could not be loaded. Please try again.'
	String get errorListLoad => 'Receipt list could not be loaded. Please try again.';

	/// en: 'Receipt details could not be loaded. Please try again.'
	String get errorDetailLoad => 'Receipt details could not be loaded. Please try again.';

	/// en: 'Receipt file could not be opened. Please try again.'
	String get errorFileDownload => 'Receipt file could not be opened. Please try again.';

	/// en: 'Payment for this receipt has already been processed.'
	String get errorReviewPaymentDone => 'Payment for this receipt has already been processed.';

	/// en: 'A rejected receipt cannot be approved again.'
	String get errorReviewRejected => 'A rejected receipt cannot be approved again.';

	/// en: 'Select a due to approve.'
	String get errorReviewNeedDue => 'Select a due to approve.';

	/// en: 'This receipt cannot be approved or rejected right now. Try again later.'
	String get errorReviewStatus => 'This receipt cannot be approved or rejected right now. Try again later.';

	/// en: 'Please select a receipt file first.'
	String get errorNoFileSelected => 'Please select a receipt file first.';

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

	/// en: 'Base due'
	String get breakdownBaseDue => 'Base due';

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

	/// en: 'Check the amount received in your account, then approve or reject.'
	String get managerApprovalHint => 'Check the amount received in your account, then approve or reject.';

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

	/// en: 'Amount is read automatically from receipts.'
	String get amountFromReceiptsHint => 'Amount is read automatically from receipts.';

	/// en: 'Add at least one receipt photo'
	String get receiptRequired => 'Add at least one receipt photo';

	/// en: 'Reading receipt amounts. They will appear in the list shortly.'
	String get amountOcrPending => 'Reading receipt amounts. They will appear in the list shortly.';

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

	/// en: 'Receipt link (HTTPS)'
	String get receiptUrlLabel => 'Receipt link (HTTPS)';

	/// en: 'Optional — public URL to the receipt file'
	String get receiptUrlHint => 'Optional — public URL to the receipt file';

	/// en: 'URL must start with https://'
	String get receiptUrlInvalid => 'URL must start with https://';

	/// en: 'Receipt photo'
	String get receiptTitle => 'Receipt photo';

	/// en: 'PDF or photo (JPEG, PNG). Amount is read from receipts automatically (Max 10 MB)'
	String get receiptHint => 'PDF or photo (JPEG, PNG). Amount is read from receipts automatically (Max 10 MB)';

	/// en: 'Add photo'
	String get receiptAdd => 'Add photo';

	/// en: 'Change photo'
	String get receiptChange => 'Change photo';

	/// en: 'Remove photo'
	String get receiptRemove => 'Remove photo';

	/// en: 'Expense saved. Receipt will upload when the API is live.'
	String get receiptPendingBackend => 'Expense saved. Receipt will upload when the API is live.';

	/// en: 'Receipt upload failed. The expense was saved.'
	String get receiptUploadFailed => 'Receipt upload failed. The expense was saved.';

	/// en: 'Could not pick a photo'
	String get receiptPickFailed => 'Could not pick a photo';

	/// en: 'Expense Detail'
	String get detailTitle => 'Expense Detail';

	/// en: 'Created at'
	String get fieldCreatedAt => 'Created at';

	/// en: 'View receipt'
	String get viewReceipt => 'View receipt';

	/// en: 'No receipt uploaded'
	String get receiptMissing => 'No receipt uploaded';

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

	/// en: 'Notification'
	String get typeOther => 'Notification';

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

	/// en: 'Could not send announcement'
	String get sendFailed => 'Could not send announcement';

	/// en: 'Required field'
	String get fieldRequired => 'Required field';

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

	/// en: 'Your profile has been updated.'
	String get profileUpdated => 'Your profile has been updated.';

	/// en: 'Could not update profile. Please try again.'
	String get profileUpdateFailed => 'Could not update profile. Please try again.';

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

	/// en: 'Only name and phone can be updated. Other details are shown on the profile screen above.'
	String get editSheetHint => 'Only name and phone can be updated. Other details are shown on the profile screen above.';

	/// en: 'Profile photo saved for this account.'
	String get photoSaved => 'Profile photo saved for this account.';

	/// en: 'Profile photo removed.'
	String get photoRemoved => 'Profile photo removed.';

	/// en: 'Remove profile photo'
	String get removePhoto => 'Remove profile photo';

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

	/// en: 'Subscription is not connected to the server yet. Purchases coming soon.'
	String get backendPending => 'Subscription is not connected to the server yet. Purchases coming soon.';

	/// en: 'Purchase coming soon'
	String get purchaseComingSoon => 'Purchase coming soon';

	/// en: 'Subscribe monthly'
	String get purchaseMonthly => 'Subscribe monthly';

	/// en: 'Subscribe annually'
	String get purchaseAnnual => 'Subscribe annually';

	/// en: 'Purchase completed. Your subscription will update within a few minutes.'
	String get purchaseSuccess => 'Purchase completed. Your subscription will update within a few minutes.';

	/// en: 'Purchase was cancelled.'
	String get purchaseCancelled => 'Purchase was cancelled.';

	/// en: 'Purchases are not enabled in this build yet.'
	String get purchasesUnavailable => 'Purchases are not enabled in this build yet.';

	/// en: 'Could not load subscription.'
	String get loadFailed => 'Could not load subscription.';

	/// en: 'Subscription product not found. Install from the Play Store test link and wait a few hours.'
	String get purchaseProductNotFound => 'Subscription product not found. Install from the Play Store test link and wait a few hours.';

	/// en: 'Google Play billing is unavailable. Check your license tester account.'
	String get purchaseStoreError => 'Google Play billing is unavailable. Check your license tester account.';

	/// en: 'Purchase could not be completed. Please try again.'
	String get purchaseFailed => 'Purchase could not be completed. Please try again.';

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

	/// en: 'Dues tracking'
	String get featureDuesTracking => 'Dues tracking';

	/// en: 'Advanced reports'
	String get featureAdvancedReports => 'Advanced reports';

	/// en: 'Priority support'
	String get featurePrioritySupport => 'Priority support';

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

	/// en: 'Could not share the report. Please try again.'
	String get shareFailed => 'Could not share the report. Please try again.';

	/// en: 'Could not generate the report. Please try again.'
	String get failed => 'Could not generate the report. Please try again.';
}

// Path: features.dashboard
class Translations$features$dashboard$en {
	Translations$features$dashboard$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'All Buildings'
	String get allBuildings => 'All Buildings';

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

	/// en: 'Open Maintenance Requests'
	String get openTicketRequests => 'Open Maintenance Requests';

	/// en: 'This Month's Expenses'
	String get monthTotalExpense => 'This Month\'s Expenses';

	/// en: 'Pending Receipts'
	String get pendingDekonts => 'Pending Receipts';

	/// en: 'Dues Collection Status'
	String get duesCollectionStatus => 'Dues Collection Status';

	/// en: 'Income / Expense Comparison'
	String get incomeExpenseComparison => 'Income / Expense Comparison';

	/// en: 'Last 6 Months'
	String get last6Months => 'Last 6 Months';

	/// en: 'Collected Dues'
	String get collectedDues => 'Collected Dues';

	/// en: 'Total Expenses'
	String get totalExpense => 'Total Expenses';

	/// en: 'Maintenance Request Status'
	String get ticketStatusTitle => 'Maintenance Request Status';

	/// en: 'Open'
	String get ticketOpen => 'Open';

	/// en: 'In Progress'
	String get ticketInProgress => 'In Progress';

	/// en: 'Resolved'
	String get ticketResolved => 'Resolved';

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

	/// en: 'Apt. {number} · Floor {floor}'
	String get apartmentWithFloor => 'Apt. {number} · Floor {floor}';

	/// en: 'No overdue payments'
	String get noOverdueApartments => 'No overdue payments';

	/// en: 'Not enough data yet'
	String get noChartData => 'Not enough data yet';

	/// en: 'See more (+{count})'
	String get seeMoreOverdue => 'See more (+{count})';

	/// en: 'Pay Now'
	String get payNow => 'Pay Now';

	/// en: '{count} overdue payment(s)'
	String get overduePaymentsBadge => '{count} overdue payment(s)';

	/// en: '{month} {year} dues'
	String get featuredDuePeriod => '{month} {year} dues';
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

// Path: features.buildings.collection
class Translations$features$buildings$collection$en {
	Translations$features$buildings$collection$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Collection details'
	String get sectionTitle => 'Collection details';

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

	/// en: 'Search IBAN or account name'
	String get searchSavedIban => 'Search IBAN or account name';

	/// en: 'Account holder'
	String get detailAccountHolder => 'Account holder';

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

	/// en: 'IBAN'
	String get ibanLabel => 'IBAN';

	/// en: 'TR33 0006 1005 1978 6457 8413 26'
	String get ibanHint => 'TR33 0006 1005 1978 6457 8413 26';

	/// en: 'Enter a valid Turkish IBAN (TR + 24 digits)'
	String get ibanInvalid => 'Enter a valid Turkish IBAN (TR + 24 digits)';

	/// en: 'You entered account title or reference; enter a valid IBAN'
	String get ibanRequiredIfOtherFilled => 'You entered account title or reference; enter a valid IBAN';

	/// en: 'Account holder name'
	String get accountTitleLabel => 'Account holder name';

	/// en: 'e.g. Building Management'
	String get accountTitleHint => 'e.g. Building Management';

	/// en: 'Payment reference template'
	String get referenceTemplateLabel => 'Payment reference template';

	/// en: 'e.g. Apt {{number}}'
	String get referenceTemplateHint => 'e.g. Apt {{number}}';

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

	/// en: 'No building linked to this set'
	String get savedIbansNoBuildingMatch => 'No building linked to this set';

	/// en: 'Buildings: {names}'
	String get savedIbansBuildingNames => 'Buildings: {names}';

	/// en: 'Collection updated for {count} building(s)'
	String get savedIbansUpdateSuccess => 'Collection updated for {count} building(s)';

	/// en: 'Will update: {names}'
	String get savedIbansUpdateHint => 'Will update: {names}';

	/// en: 'Edit IBAN'
	String get editSavedIbanTitle => 'Edit IBAN';

	/// en: 'This set is not linked to a building yet. Changes are stored in your saved list only.'
	String get savedIbansOrphanHint => 'This set is not linked to a building yet. Changes are stored in your saved list only.';

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

	/// en: 'Collection details will also be cleared on {count} building(s).'
	String get savedIbansDeleteBuildingWarning => 'Collection details will also be cleared on {count} building(s).';

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
			'common.logoutAllDevicesSuccess' => 'Other devices have been signed out.',
			'common.logoutAllDevicesFailed' => 'Could not complete this action. Please try again.',
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
			'common.unexpectedError' => 'Something went wrong. Please try again.',
			'common.api.networkError' => 'Check your internet connection and try again.',
			'common.api.serverError' => 'Could not reach the server. Please try again later.',
			'common.api.validationError' => 'Please check the information you entered.',
			'common.api.notFound' => 'The requested record was not found.',
			'common.api.unauthorized' => 'Your session has ended. Please sign in again.',
			'common.api.rateLimit' => 'Too many attempts. Please wait a moment and try again.',
			'common.api.forbidden' => 'You do not have permission for this action.',
			'common.api.genericError' => 'Something went wrong. Please try again.',
			'common.api.invalidCredentials' => 'Email, phone, or password is incorrect. Please check and try again.',
			'common.api.duplicateEmail' => 'This email is already registered. Try signing in.',
			'common.api.duplicatePhone' => 'This phone number is already registered.',
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
			'common.api.serviceUnavailable' => 'This action is not available right now. Please try again later.',
			'common.api.fileUploadError' => 'File could not be uploaded. Please try again.',
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
			'common.managedBuildings' => 'Managed Buildings',
			'common.issues' => 'Issues',
			'common.issuesTab' => 'Issues Tab',
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
			'common.paid' => 'Paid',
			'common.pending' => 'Pending',
			'common.overdue' => 'Overdue',
			'common.balance' => 'Balance',
			'common.amountDue' => 'Amount Due',
			'common.lastPayment' => 'Last Payment',
			'common.makePayment' => 'Make Payment',
			'common.bills' => 'Bills',
			'common.support' => 'Support',
			'common.quickActions' => 'Quick actions',
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
			'common.buildingAddFailed' => 'Could not add building. Please try again.',
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
			'common.codeRevoked' => 'Code revoked',
			'common.codeCopied' => 'Code copied',
			'common.clipboardCopied' => 'Message copied to clipboard',
			'common.expiresAtPrefix' => 'Expires at',
			'common.remainingPrefix' => 'Remaining',
			'common.buildingDetail' => 'Building Detail',
			'common.residents' => 'Residents',
			'common.apartmentsBadge' => 'Apartments',
			'common.emptyApartmentText' => 'Empty Apartment',
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
			'common.duesUpdated' => 'Dues status updated',
			'common.amount' => 'Amount',
			'common.updateDueAmount' => 'Update Due Amount',
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
			'common.dueMetaOverdueDelay' => '{days} days overdue',
			'common.dueMetaPaidInMonth' => 'paid in {month} {year}',
			'common.dueMetaPaidOnDay' => 'paid on {day} {month}',
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
			'common.buildingDeleteFailedFK' => 'Cannot delete this building: apartments, residents, or dues records still exist. Clean up apartments/dues first.',
			'common.deleteBuildingHeader' => 'This action cannot be undone.',
			'common.deleteBuildingTypeHint' => 'To confirm, type the building name below exactly:',
			'common.deleteBuildingTypeFieldLabel' => 'Building name',
			'common.buildingNameMismatch' => 'What you typed does not match the building name.',
			'common.editApartment' => 'Edit Apartment',
			'common.deleteApartment' => 'Delete Apartment',
			'common.apartmentUpdated' => 'Apartment updated',
			'common.apartmentDeleted' => 'Apartment deleted',
			'common.apartmentUpdateFailed' => 'Could not update apartment',
			'common.apartmentDeleteFailed' => 'Could not delete apartment',
			'common.apartmentDeleteFailedFK' => 'Cannot delete this apartment: resident or dues records exist. Wait for the resident to close their account and clean up dues.',
			'common.deleteApartmentConfirm' => 'Are you sure you want to delete this apartment?',
			'common.apartmentNumberLabel' => 'Apt No (e.g. 5A)',
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
			'common.changePasswordSuccess' => 'Your password has been changed. Please sign in again with your new password.',
			'common.changePasswordFailed' => 'Could not change password. Please try again.',
			'common.changePasswordWrongCurrent' => 'Current password is incorrect.',
			'common.languageSheetDescription' => 'You can change the application language here.',
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
			'common.deleteAccountSuccess' => 'Your account has been closed. Thank you for using AidatPanel.',
			'common.deleteAccountFailed' => 'Could not close account. Please try again.',
			'common.deleteAccountFailedManager' => 'You first need to delete the buildings you manage or transfer them to another manager.',
			'common.dangerZone' => 'Danger Zone',
			'common.forgotPassword' => 'Forgot Password',
			'common.forgotPasswordTitle' => 'Forgot Password',
			'common.forgotPasswordSubtitle' => 'Enter your registered email and we\'ll send you a reset code.',
			'common.forgotPasswordSuccess' => 'If this email is registered, a reset code has been sent. Please check your inbox.',
			'common.sendResetCode' => 'Send Code',
			'common.iHaveACode' => 'I already have a code',
			'common.resetPasswordTitle' => 'Set New Password',
			'common.resetPasswordSubtitle' => 'Enter the 6-character code from your email and a new password.',
			'common.resetCode' => 'Reset Code',
			'common.resetCodeHint' => 'ABC123',
			'common.resetCodeRequired' => 'Reset code required',
			'common.resetCodeInvalid' => 'Code must be 6 characters',
			'common.resetPasswordSuccess' => 'Your password has been reset. You can sign in with your new password.',
			'common.resetPasswordFailed' => 'Could not reset password. The code may be invalid or expired.',
			'common.resetPasswordSubmit' => 'Reset Password',
			'common.backToLogin' => 'Back to login',
			'validation.emailRequired' => 'Email address cannot be empty',
			'validation.emailInvalid' => 'Please enter a valid email address',
			'validation.emailTooLong' => 'Email address is too long',
			'validation.phoneRequired' => 'Phone number cannot be empty',
			'validation.phoneInvalid' => 'Phone number must be 10 digits',
			'validation.passwordRequired' => 'Password cannot be empty',
			'validation.passwordTooShort' => 'Password must be at least 6 characters',
			'validation.passwordTooLong' => 'Password is too long',
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
			'features.buildings.collection.sectionTitle' => 'Collection details',
			'features.buildings.collection.sectionHint' => 'IBAN for resident bank transfers. Optional; you can add it later.',
			'features.buildings.collection.modeSaved' => 'Saved IBAN',
			'features.buildings.collection.modeNew' => 'New IBAN',
			'features.buildings.collection.savedListTitle' => 'Previously used',
			'features.buildings.collection.savedListSectionLabel' => 'Saved IBANs',
			'features.buildings.collection.pickSavedIban' => 'Choose saved IBAN',
			'features.buildings.collection.changeSavedIban' => 'Tap to choose another IBAN',
			'features.buildings.collection.searchSavedIban' => 'Search IBAN or account name',
			'features.buildings.collection.detailAccountHolder' => 'Account holder',
			'features.buildings.collection.detailReference' => 'Payment reference',
			'features.buildings.collection.detailReferenceAuto' => 'Apartment number is added to the transfer reference automatically',
			'features.buildings.collection.detailReferenceDaireOnly' => 'Transfer reference: Apartment number',
			'features.buildings.collection.detailReferenceDaireAidat' => 'Transfer reference: Apt. no + dues',
			'features.buildings.collection.detailReferenceAidat' => 'Transfer reference: Dues (apt. no added automatically)',
			'features.buildings.collection.detailReferenceHavale' => 'Transfer reference: Apartment number on transfer',
			'features.buildings.collection.detailUsedInBuildings' => 'Used in {count} buildings',
			'features.buildings.collection.ibanLabel' => 'IBAN',
			'features.buildings.collection.ibanHint' => 'TR33 0006 1005 1978 6457 8413 26',
			'features.buildings.collection.ibanInvalid' => 'Enter a valid Turkish IBAN (TR + 24 digits)',
			'features.buildings.collection.ibanRequiredIfOtherFilled' => 'You entered account title or reference; enter a valid IBAN',
			'features.buildings.collection.accountTitleLabel' => 'Account holder name',
			'features.buildings.collection.accountTitleHint' => 'e.g. Building Management',
			'features.buildings.collection.referenceTemplateLabel' => 'Payment reference template',
			'features.buildings.collection.referenceTemplateHint' => 'e.g. Apt {{number}}',
			'features.buildings.collection.presetsEmpty' => 'No saved collection details yet',
			'features.buildings.collection.presetsLoadFailed' => 'Could not load suggestions',
			'features.buildings.collection.presetBuildingCount' => '{count} buildings',
			'features.buildings.collection.menuEdit' => 'Collection / IBAN',
			'features.buildings.collection.editSheetTitle' => 'Collection details',
			'features.buildings.collection.saveSuccess' => 'Collection details saved',
			'features.buildings.collection.savedIbansTitle' => 'My saved IBANs',
			'features.buildings.collection.savedIbansEmpty' => 'No saved IBAN yet. You can add collection details when creating a building.',
			'features.buildings.collection.savedIbansNoBuildingMatch' => 'No building linked to this set',
			'features.buildings.collection.savedIbansBuildingNames' => 'Buildings: {names}',
			'features.buildings.collection.savedIbansUpdateSuccess' => 'Collection updated for {count} building(s)',
			'features.buildings.collection.savedIbansUpdateHint' => 'Will update: {names}',
			'features.buildings.collection.editSavedIbanTitle' => 'Edit IBAN',
			'features.buildings.collection.savedIbansOrphanHint' => 'This set is not linked to a building yet. Changes are stored in your saved list only.',
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
			'features.buildings.collection.savedIbansDeleteBuildingWarning' => 'Collection details will also be cleared on {count} building(s).',
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
			'features.sites.tabSites' => 'Sites',
			'features.sites.tabBuildings' => 'Buildings',
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
			'features.sites.overrideCollection' => 'Override site default IBAN',
			'features.sites.overrideCollectionHint' => 'When off, site IBAN applies',
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
			_ => null,
		} ?? switch (path) {
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
			'features.auth.registrationSuccess' => 'Account created. You can now log in.',
			'features.auth.loginSuccess' => 'Signed in successfully. Welcome.',
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
			'features.apartments.residentPanel' => 'Resident',
			'features.tickets.myTickets' => 'My requests',
			'features.tickets.newTicket' => 'New request',
			'features.tickets.createTitle' => 'Report issue / request',
			'features.tickets.fieldTitle' => 'Title',
			'features.tickets.fieldTitleHint' => 'e.g. Elevator malfunction',
			'features.tickets.fieldDescription' => 'Description',
			'features.tickets.fieldDescriptionHint' => 'Briefly describe the issue',
			'features.tickets.fieldCategory' => 'Category',
			'features.tickets.categoryComplaint' => 'Complaint',
			'features.tickets.categoryRequest' => 'Request',
			'features.tickets.categoryMalfunction' => 'Malfunction',
			'features.tickets.categoryOther' => 'Other',
			'features.tickets.submit' => 'Submit',
			'features.tickets.createSuccess' => 'Your request has been submitted',
			'features.tickets.createFailed' => 'Could not save your request. Please try again.',
			'features.tickets.createServiceUnavailable' => 'The request service is not available right now. Please try again later.',
			'features.tickets.emptyTitle' => 'No requests yet',
			'features.tickets.emptySubtitle' => 'Report an issue or request from here',
			'features.tickets.titleTooShort' => 'Title must be at least 3 characters',
			'features.tickets.descriptionTooShort' => 'Description must be at least 10 characters',
			'features.tickets.statusOpen' => 'Open',
			'features.tickets.statusInProgress' => 'In progress',
			'features.tickets.statusResolved' => 'Resolved',
			'features.tickets.statusClosed' => 'Closed',
			'features.tickets.statusTrackerTitle' => 'REQUEST STATUS',
			'features.tickets.statusStepWaiting' => 'Waiting',
			'features.tickets.statusStepInProgress' => 'In progress',
			'features.tickets.statusStepResolved' => 'Resolved',
			'features.tickets.statusStepClosed' => 'Closed',
			'features.tickets.statusHeadlineOpen' => 'Your request is waiting',
			'features.tickets.statusHeadlineInProgress' => 'Your request is in progress',
			'features.tickets.statusHeadlineResolved' => 'Your request is resolved',
			'features.tickets.statusHeadlineClosed' => 'Your request is closed',
			'features.tickets.detailTitle' => 'Request details',
			'features.tickets.managerTitle' => 'Building requests',
			'features.tickets.statusLabel' => 'Status',
			'features.tickets.updatesTitle' => 'Updates',
			'features.tickets.changeStatus' => 'Change status',
			'features.tickets.managerNote' => 'Manager note',
			'features.tickets.addNote' => 'Add note',
			'features.tickets.statusUpdated' => 'Status updated',
			'features.tickets.noteAdded' => 'Note added',
			'features.tickets.loadError' => 'Could not load requests',
			'features.tickets.noteDisabledClosed' => 'Cannot add notes to a closed request',
			'features.tickets.statusClosedHint' => 'This request is closed; status cannot be changed.',
			'features.tickets.apartmentRequired' => 'Apartment not linked. Please sign in again.',
			'features.tickets.managerUpdateLabel' => 'Manager update',
			'features.tickets.residentUpdateLabel' => 'Resident update',
			'features.tickets.quickReplyTemplatesTitle' => 'Quick reply templates',
			'features.tickets.confirmChanges' => 'Confirm',
			'features.tickets.residentInfoTitle' => 'Requester details',
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
			'features.dekont.myDekontsTitle' => 'My Receipts',
			'features.dekont.managerTitle' => 'Receipt Review',
			'features.dekont.reviewAction' => 'Review receipt',
			'features.dekont.detailTitle' => 'Receipt Detail',
			'features.dekont.paymentInfoTitle' => 'Transfer details',
			'features.dekont.collectionNotConfigured' => 'Your manager has not set up collection IBAN yet. You can still upload a receipt.',
			'features.dekont.ibanLabel' => 'IBAN',
			'features.dekont.accountTitleLabel' => 'Account title',
			'features.dekont.referenceLabel' => 'Transfer reference',
			'features.dekont.copy' => 'Copy',
			'features.dekont.copied' => 'Copied to clipboard',
			'features.dekont.selectDue' => 'Select due',
			'features.dekont.selectDueHint' => 'Select the due you paid',
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
			'features.dekont.errorUploadServer' => 'Receipt could not be saved on the server. Please try again later.',
			'features.dekont.errorUploadFileRequired' => 'Please select a file.',
			'features.dekont.errorPaymentInfo' => 'Payment details could not be loaded. Please try again.',
			'features.dekont.errorListLoad' => 'Receipt list could not be loaded. Please try again.',
			'features.dekont.errorDetailLoad' => 'Receipt details could not be loaded. Please try again.',
			'features.dekont.errorFileDownload' => 'Receipt file could not be opened. Please try again.',
			'features.dekont.errorReviewPaymentDone' => 'Payment for this receipt has already been processed.',
			'features.dekont.errorReviewRejected' => 'A rejected receipt cannot be approved again.',
			'features.dekont.errorReviewNeedDue' => 'Select a due to approve.',
			'features.dekont.errorReviewStatus' => 'This receipt cannot be approved or rejected right now. Try again later.',
			'features.dekont.errorNoFileSelected' => 'Please select a receipt file first.',
			'features.dekont.fileTooLarge' => 'File must be 10 MB or smaller',
			'features.dekont.fileEmpty' => 'The selected file is empty',
			'features.dekont.fileNotFound' => 'File not found',
			'features.dekont.invalidExtension' => 'Only PDF, JPEG, or PNG files are allowed',
			'features.dekont.processing' => 'Processing receipt…',
			'features.dekont.viewDekonts' => 'My receipts',
			'features.dekont.breakdownDetails' => 'Details',
			'features.dekont.breakdownBaseDue' => 'Base due',
			'features.dekont.breakdownTotal' => 'Total',
			'features.dekont.emptyTitle' => 'No receipts yet',
			'features.dekont.emptySubtitleResident' => 'You don\'t have any receipts yet. You can use the upload button on the top right to add a new receipt.',
			'features.dekont.emptySubtitleManager' => 'There are no receipts uploaded by users.',
			'features.dekont.filterAll' => 'All',
			'features.dekont.filterPending' => 'Under review',
			'features.dekont.filterApproved' => 'Approved',
			'features.dekont.filterRejected' => 'Rejected',
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
			'features.dekont.managerApprovalHint' => 'Check the amount received in your account, then approve or reject.',
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
			'features.expenses.amountFromReceiptsHint' => 'Amount is read automatically from receipts.',
			'features.expenses.receiptRequired' => 'Add at least one receipt photo',
			'features.expenses.amountOcrPending' => 'Reading receipt amounts. They will appear in the list shortly.',
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
			'features.expenses.receiptUrlLabel' => 'Receipt link (HTTPS)',
			'features.expenses.receiptUrlHint' => 'Optional — public URL to the receipt file',
			'features.expenses.receiptUrlInvalid' => 'URL must start with https://',
			'features.expenses.receiptTitle' => 'Receipt photo',
			'features.expenses.receiptHint' => 'PDF or photo (JPEG, PNG). Amount is read from receipts automatically (Max 10 MB)',
			'features.expenses.receiptAdd' => 'Add photo',
			'features.expenses.receiptChange' => 'Change photo',
			'features.expenses.receiptRemove' => 'Remove photo',
			'features.expenses.receiptPendingBackend' => 'Expense saved. Receipt will upload when the API is live.',
			'features.expenses.receiptUploadFailed' => 'Receipt upload failed. The expense was saved.',
			'features.expenses.receiptPickFailed' => 'Could not pick a photo',
			'features.expenses.detailTitle' => 'Expense Detail',
			'features.expenses.fieldCreatedAt' => 'Created at',
			'features.expenses.viewReceipt' => 'View receipt',
			'features.expenses.receiptMissing' => 'No receipt uploaded',
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
			'features.notifications.typeOther' => 'Notification',
			'features.notifications.allApartmentsTag' => 'All apartments',
			'features.notifications.sendTitle' => 'Announcement to residents',
			'features.notifications.fieldTitle' => 'Title',
			'features.notifications.fieldBody' => 'Message',
			'features.notifications.sendButton' => 'Send',
			'features.notifications.sendSuccess' => 'Announcement sent',
			'features.notifications.sendFailed' => 'Could not send announcement',
			'features.notifications.fieldRequired' => 'Required field',
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
			'features.profile.profileUpdated' => 'Your profile has been updated.',
			'features.profile.profileUpdateFailed' => 'Could not update profile. Please try again.',
			'features.profile.profileLoadFailed' => 'Could not load profile.',
			'features.profile.readOnlySection' => 'Cannot be edited here',
			'features.profile.contactRequired' => 'At least one contact channel (Email or Phone) must be registered.',
			'features.profile.securityVerificationTitle' => 'Security Verification',
			'features.profile.securityVerificationMessage' => 'You must enter your current password to change your email or phone number.',
			'features.profile.editSheetHint' => 'Only name and phone can be updated. Other details are shown on the profile screen above.',
			'features.profile.photoSaved' => 'Profile photo saved for this account.',
			'features.profile.photoRemoved' => 'Profile photo removed.',
			'features.profile.removePhoto' => 'Remove profile photo',
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
			'features.subscription.backendPending' => 'Subscription is not connected to the server yet. Purchases coming soon.',
			'features.subscription.purchaseComingSoon' => 'Purchase coming soon',
			'features.subscription.purchaseMonthly' => 'Subscribe monthly',
			'features.subscription.purchaseAnnual' => 'Subscribe annually',
			'features.subscription.purchaseSuccess' => 'Purchase completed. Your subscription will update within a few minutes.',
			'features.subscription.purchaseCancelled' => 'Purchase was cancelled.',
			'features.subscription.purchasesUnavailable' => 'Purchases are not enabled in this build yet.',
			'features.subscription.loadFailed' => 'Could not load subscription.',
			'features.subscription.purchaseProductNotFound' => 'Subscription product not found. Install from the Play Store test link and wait a few hours.',
			'features.subscription.purchaseStoreError' => 'Google Play billing is unavailable. Check your license tester account.',
			'features.subscription.purchaseFailed' => 'Purchase could not be completed. Please try again.',
			'features.subscription.sectionSelectPlan' => 'Choose a plan and subscribe',
			'features.subscription.cycleMonthly' => 'Renews every month',
			'features.subscription.cycleAnnual' => 'Renews every year',
			'features.subscription.featureUnlimitedUnits' => 'Unlimited units',
			'features.subscription.buildingUsageSummary' => 'Managed buildings: {used}',
			'features.subscription.buildingUsageWithLimit' => 'Managed buildings: {used} / {limit}',
			'features.subscription.featureDuesTracking' => 'Dues tracking',
			'features.subscription.featureAdvancedReports' => 'Advanced reports',
			'features.subscription.featurePrioritySupport' => 'Priority support',
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
			'features.reports.shareFailed' => 'Could not share the report. Please try again.',
			'features.reports.failed' => 'Could not generate the report. Please try again.',
			'features.dashboard.allBuildings' => 'All Buildings',
			'features.dashboard.selectBuilding' => 'Select building',
			'features.dashboard.searchBuildings' => 'Search by name or address',
			'features.dashboard.buildingPickerTapHint' => 'Tap to search and select a building',
			'features.dashboard.allBuildingsSummary' => '{count} buildings',
			'features.dashboard.buildingUnitsSummary' => '{apartments} units',
			'features.dashboard.collectionRate' => 'Collection Rate',
			'features.dashboard.overduePayments' => 'Overdue Payments',
			'features.dashboard.openTicketRequests' => 'Open Maintenance Requests',
			'features.dashboard.monthTotalExpense' => 'This Month\'s Expenses',
			'features.dashboard.pendingDekonts' => 'Pending Receipts',
			'features.dashboard.duesCollectionStatus' => 'Dues Collection Status',
			'features.dashboard.incomeExpenseComparison' => 'Income / Expense Comparison',
			'features.dashboard.last6Months' => 'Last 6 Months',
			'features.dashboard.collectedDues' => 'Collected Dues',
			'features.dashboard.totalExpense' => 'Total Expenses',
			'features.dashboard.ticketStatusTitle' => 'Maintenance Request Status',
			'features.dashboard.ticketOpen' => 'Open',
			'features.dashboard.ticketInProgress' => 'In Progress',
			'features.dashboard.ticketResolved' => 'Resolved',
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
			'features.dashboard.apartmentWithFloor' => 'Apt. {number} · Floor {floor}',
			'features.dashboard.noOverdueApartments' => 'No overdue payments',
			'features.dashboard.noChartData' => 'Not enough data yet',
			'features.dashboard.seeMoreOverdue' => 'See more (+{count})',
			_ => null,
		} ?? switch (path) {
			'features.dashboard.payNow' => 'Pay Now',
			'features.dashboard.overduePaymentsBadge' => '{count} overdue payment(s)',
			'features.dashboard.featuredDuePeriod' => '{month} {year} dues',
			'features.faz2.sectionTitle' => 'Phase 2',
			'features.faz2.tickets' => 'Requests',
			'features.faz2.expenses' => 'Expenses',
			'features.faz2.announcement' => 'Announce',
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
