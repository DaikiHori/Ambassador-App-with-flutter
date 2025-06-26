import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Event Management App'**
  String get appTitle;

  /// No description provided for @eventListPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Event List'**
  String get eventListPageTitle;

  /// No description provided for @createEventMessage.
  ///
  /// In en, this message translates to:
  /// **'Please create an event.'**
  String get createEventMessage;

  /// No description provided for @addNewEventTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add New Event'**
  String get addNewEventTooltip;

  /// No description provided for @addEventPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New Event'**
  String get addEventPageTitle;

  /// No description provided for @editEventPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Event'**
  String get editEventPageTitle;

  /// No description provided for @eventNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Event Name'**
  String get eventNameLabel;

  /// No description provided for @eventNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Event Name cannot be empty'**
  String get eventNameRequired;

  /// No description provided for @eventDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get eventDateLabel;

  /// No description provided for @eventDateRequired.
  ///
  /// In en, this message translates to:
  /// **'Date cannot be empty'**
  String get eventDateRequired;

  /// No description provided for @eventCodesLabel.
  ///
  /// In en, this message translates to:
  /// **'Codes'**
  String get eventCodesLabel;

  /// No description provided for @eventCodesHint.
  ///
  /// In en, this message translates to:
  /// **'Enter codes, separated by newlines or commas. (e.g., CODE1, CODE2\\nCODE3)'**
  String get eventCodesHint;

  /// No description provided for @eventCodesRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter at least one code.'**
  String get eventCodesRequired;

  /// No description provided for @saveButtonText.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButtonText;

  /// No description provided for @eventSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Event \"{eventName}\" and codes saved successfully!'**
  String eventSavedSuccess(String eventName);

  /// No description provided for @eventUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Event \"{eventName}\" updated successfully!'**
  String eventUpdatedSuccess(String eventName);

  /// No description provided for @eventSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save event: {error}'**
  String eventSaveFailed(String error);

  /// No description provided for @eventTotalCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Codes'**
  String get eventTotalCountLabel;

  /// No description provided for @eventUsableCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Usable Codes'**
  String get eventUsableCountLabel;

  /// No description provided for @menuTitle.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menuTitle;

  /// No description provided for @eventUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Event URL (Optional)'**
  String get eventUrlLabel;

  /// No description provided for @eventUrlHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., https://example.com/event'**
  String get eventUrlHint;

  /// No description provided for @deleteButtonText.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButtonText;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteEventMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete event \"{eventName}\"? All associated codes will also be deleted.'**
  String deleteEventMessage(String eventName);

  /// No description provided for @eventDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Event \"{eventName}\" and its codes deleted successfully.'**
  String eventDeletedSuccess(String eventName);

  /// No description provided for @eventDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete event: {error}'**
  String eventDeleteFailed(Object error);

  /// No description provided for @cancelButtonText.
  ///
  /// In en, this message translates to:
  /// **'cancel'**
  String get cancelButtonText;

  /// No description provided for @editButtonText.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editButtonText;

  /// No description provided for @codeListButtonText.
  ///
  /// In en, this message translates to:
  /// **'Code List'**
  String get codeListButtonText;

  /// No description provided for @codeButtonText.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get codeButtonText;

  /// No description provided for @codeListPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Codes for {eventName}'**
  String codeListPageTitle(String eventName);

  /// No description provided for @noCodesMessage.
  ///
  /// In en, this message translates to:
  /// **'No codes found for this event.'**
  String get noCodesMessage;

  /// No description provided for @codeNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'No.'**
  String get codeNumberLabel;

  /// No description provided for @codeLabel.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get codeLabel;

  /// No description provided for @codeUsableLabel.
  ///
  /// In en, this message translates to:
  /// **'Usable'**
  String get codeUsableLabel;

  /// No description provided for @codeUsedLabel.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get codeUsedLabel;

  /// No description provided for @codeUserNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Used by (Optional)'**
  String get codeUserNameLabel;

  /// No description provided for @codeSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Code \"{code}\" saved.'**
  String codeSavedSuccess(String code);

  /// No description provided for @codeSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save code: {error}'**
  String codeSaveFailed(String error);

  /// No description provided for @copyCodeButtonText.
  ///
  /// In en, this message translates to:
  /// **'Copy Code'**
  String get copyCodeButtonText;

  /// No description provided for @copiedCodeMessage.
  ///
  /// In en, this message translates to:
  /// **'Code copied to clipboard!'**
  String get copiedCodeMessage;

  /// No description provided for @codeUsagePageTitle.
  ///
  /// In en, this message translates to:
  /// **'Use Code for {eventName}'**
  String codeUsagePageTitle(String eventName);

  /// No description provided for @noUsableCodesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No usable codes available for this event.'**
  String get noUsableCodesAvailable;

  /// No description provided for @qrCodeGenerationError.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate QR Code: {error}'**
  String qrCodeGenerationError(String error);

  /// No description provided for @markAsUsedButtonText.
  ///
  /// In en, this message translates to:
  /// **'Mark as Used'**
  String get markAsUsedButtonText;

  /// No description provided for @codeStatusUsed.
  ///
  /// In en, this message translates to:
  /// **'Status: USED'**
  String get codeStatusUsed;

  /// No description provided for @codeStatusAvailable.
  ///
  /// In en, this message translates to:
  /// **'Status: AVAILABLE'**
  String get codeStatusAvailable;

  /// No description provided for @codeMarkedAsUsedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Code \"{code}\" marked as used.'**
  String codeMarkedAsUsedSuccess(String code);

  /// No description provided for @codeMarkedAsUsedFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to mark code as used: {error}'**
  String codeMarkedAsUsedFailed(Object error);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ja': return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
