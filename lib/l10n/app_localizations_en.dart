// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Event Management App';

  @override
  String get eventListPageTitle => 'Event List';

  @override
  String get createEventMessage => 'Please create an event.';

  @override
  String get addNewEventTooltip => 'Add New Event';

  @override
  String get addEventPageTitle => 'Add New Event';

  @override
  String get editEventPageTitle => 'Edit Event';

  @override
  String get eventNameLabel => 'Event Name';

  @override
  String get eventNameRequired => 'Event Name cannot be empty';

  @override
  String get eventDateLabel => 'Date';

  @override
  String get eventDateRequired => 'Date cannot be empty';

  @override
  String get eventCodesLabel => 'Codes';

  @override
  String get eventCodesHint => 'Enter codes, separated by newlines or commas. (e.g., CODE1, CODE2\\nCODE3)';

  @override
  String get eventCodesRequired => 'Please enter at least one code.';

  @override
  String get saveButtonText => 'Save';

  @override
  String eventSavedSuccess(String eventName) {
    return 'Event \"$eventName\" and codes saved successfully!';
  }

  @override
  String eventUpdatedSuccess(String eventName) {
    return 'Event \"$eventName\" updated successfully!';
  }

  @override
  String eventSaveFailed(String error) {
    return 'Failed to save event: $error';
  }

  @override
  String get eventTotalCountLabel => 'Total Codes';

  @override
  String get eventUsableCountLabel => 'Usable Codes';

  @override
  String get menuTitle => 'Menu';

  @override
  String get eventUrlLabel => 'Event URL (Optional)';

  @override
  String get eventUrlHint => 'e.g., https://example.com/event';

  @override
  String get deleteButtonText => 'Delete';

  @override
  String get deleteConfirmTitle => 'Confirm Deletion';

  @override
  String deleteEventMessage(String eventName) {
    return 'Are you sure you want to delete event \"$eventName\"? All associated codes will also be deleted.';
  }

  @override
  String eventDeletedSuccess(String eventName) {
    return 'Event \"$eventName\" and its codes deleted successfully.';
  }

  @override
  String eventDeleteFailed(Object error) {
    return 'Failed to delete event: $error';
  }

  @override
  String get cancelButtonText => 'cancel';

  @override
  String get editButtonText => 'Edit';

  @override
  String get codeListButtonText => 'List';

  @override
  String get codeButtonText => 'Code';

  @override
  String codeListPageTitle(String eventName) {
    return 'Codes for $eventName';
  }

  @override
  String get noCodesMessage => 'No codes found for this event.';

  @override
  String get codeNumberLabel => 'No.';

  @override
  String get codeLabel => 'Code';

  @override
  String get codeUsableLabel => 'Usable';

  @override
  String get codeUsedLabel => 'Used';

  @override
  String get codeUserNameLabel => 'Used by (Optional)';

  @override
  String get codeUserNameHint => 'Enter name if used by someone';

  @override
  String codeSavedSuccess(String code) {
    return 'Code \"$code\" saved.';
  }

  @override
  String codeSaveFailed(String error) {
    return 'Failed to save code: $error';
  }

  @override
  String get copyCodeButtonText => 'Copy Code';

  @override
  String get copiedCodeMessage => 'Code copied to clipboard!';

  @override
  String codeUsagePageTitle(String eventName) {
    return 'Use Code for $eventName';
  }

  @override
  String get noUsableCodesAvailable => 'No usable codes available for this event.';

  @override
  String qrCodeGenerationError(String error) {
    return 'Failed to generate QR Code: $error';
  }

  @override
  String get markAsUsedButtonText => 'Mark as Used';

  @override
  String get codeStatusUsed => 'Status: USED';

  @override
  String get codeStatusAvailable => 'Status: AVAILABLE';

  @override
  String codeMarkedAsUsedSuccess(String code) {
    return 'Code \"$code\" marked as used.';
  }

  @override
  String codeMarkedAsUsedFailed(Object error) {
    return 'Failed to mark code as used: $error';
  }

  @override
  String get userListMenuText => 'Manage Users';

  @override
  String get addUserPageTitle => 'Add Users';

  @override
  String get userListPageTitle => 'User List';

  @override
  String get userNameLabel => 'User Names';

  @override
  String get userNameHint => 'Enter user names, separated by newlines or commas. Duplicate names will be skipped.';

  @override
  String get userNameRequired => 'Please enter at least one user name.';

  @override
  String usersSavedSuccess(int count) {
    return '$count user(s) saved successfully!';
  }

  @override
  String usersSavedWithSkip(int count, String skippedNames) {
    return '$count user(s) saved. Skipped duplicates: $skippedNames';
  }

  @override
  String usersSkippedAll(String skippedNames) {
    return 'All entered user names were duplicates: $skippedNames';
  }

  @override
  String get noUsersToSave => 'No users to save.';

  @override
  String userSaveFailed(String error) {
    return 'Failed to save users: $error';
  }

  @override
  String get noUsersMessage => 'No users registered. Please add users.';

  @override
  String get addUsersButtonTooltip => 'Add New Users';

  @override
  String deleteUserMessage(String userName) {
    return 'Are you sure you want to delete user \"$userName\"?';
  }

  @override
  String userDeletedSuccess(String userName) {
    return 'User \"$userName\" deleted successfully.';
  }

  @override
  String userDeleteFailed(Object error) {
    return 'Failed to delete user: $error';
  }

  @override
  String loadCodeError(Object error) {
    return 'Failed to load code: $error';
  }

  @override
  String loadEventFailed(Object error) {
    return 'Failed to load event and code counts: $error';
  }

  @override
  String get exportDataMenuText => 'Export Data (CSV)';

  @override
  String get importDataMenuText => 'Import Data (CSV)';

  @override
  String get exportSelectLocationTitle => 'Select Export Location';

  @override
  String exportSuccessMessage(String path) {
    return 'Data exported successfully to: $path';
  }

  @override
  String get exportCancelledMessage => 'Data export cancelled.';

  @override
  String exportFailedMessage(String error) {
    return 'Failed to export data: $error';
  }

  @override
  String get importSelectFileTitle => 'Select CSV File to Import';

  @override
  String importSuccessMessage(String path) {
    return 'Data imported successfully from: $path';
  }

  @override
  String get importCancelledMessage => 'Data import cancelled.';

  @override
  String importFailedMessage(String error) {
    return 'Failed to import data: $error';
  }

  @override
  String importSummaryMessage(String path, int importedEvents, int importedUsers, int importedCodes, int skippedRows) {
    return 'Imported from $path.\nEvents: $importedEvents, Users: $importedUsers, Codes: $importedCodes, Skipped: $skippedRows';
  }

  @override
  String get importConfirmTitle => 'Confirm Import';

  @override
  String get importConfirmMessage => 'This will delete all existing data and import new data. Are you sure you want to proceed?';

  @override
  String get importConfirmButtonText => 'Import (Delete Existing)';

  @override
  String get csvImportFailedEmptyOrUnreadable => 'CSV file is empty or could not be read. Please check encoding.';
}
