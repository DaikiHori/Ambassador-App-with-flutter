// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Ambassador App';

  @override
  String get eventListPageTitle => 'Event List';

  @override
  String get createEventMessage => 'Please create an event.';

  @override
  String get addNewEventTooltip => 'Add New Event';
}
