// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Ambassador App';

  @override
  String get eventListPageTitle => 'イベント一覧';

  @override
  String get createEventMessage => 'イベントを作成してください';

  @override
  String get addNewEventTooltip => '新しいイベントを追加';
}
