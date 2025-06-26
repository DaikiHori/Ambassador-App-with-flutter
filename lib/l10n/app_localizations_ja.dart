// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'イベント管理アプリ';

  @override
  String get eventListPageTitle => 'イベント一覧';

  @override
  String get createEventMessage => 'イベントを作成してください';

  @override
  String get addNewEventTooltip => '新しいイベントを追加';

  @override
  String get addEventPageTitle => '新しいイベントを追加';

  @override
  String get editEventPageTitle => 'イベントを編集';

  @override
  String get eventNameLabel => 'イベント名';

  @override
  String get eventNameRequired => 'イベント名は必須です';

  @override
  String get eventDateLabel => '開催日';

  @override
  String get eventDateRequired => '開催日は必須です';

  @override
  String get eventCodesLabel => 'コード';

  @override
  String get eventCodesHint => 'コードを改行またはカンマで区切って入力してください (例: CODE1, CODE2\\nCODE3)';

  @override
  String get eventCodesRequired => '少なくとも1つのコードを入力してください。';

  @override
  String get saveButtonText => '保存';

  @override
  String eventSavedSuccess(String eventName) {
    return '$eventName とコードを保存しました！';
  }

  @override
  String eventUpdatedSuccess(String eventName) {
    return '$eventName を更新しました！';
  }

  @override
  String eventSaveFailed(String error) {
    return 'イベントの保存に失敗しました: $error';
  }

  @override
  String get eventTotalCountLabel => '総コード数';

  @override
  String get eventUsableCountLabel => '利用可能数';

  @override
  String get menuTitle => 'メニュー';

  @override
  String get eventUrlLabel => 'イベントURL (任意)';

  @override
  String get eventUrlHint => '例: https://example.com/event';

  @override
  String get deleteButtonText => '削除';

  @override
  String get deleteConfirmTitle => '削除の確認';

  @override
  String deleteEventMessage(String eventName) {
    return 'イベント「$eventName」を削除してもよろしいですか？関連する全てのコードも削除されます。';
  }

  @override
  String eventDeletedSuccess(String eventName) {
    return 'イベント「$eventName」と関連コードを削除しました。';
  }

  @override
  String eventDeleteFailed(Object error) {
    return 'イベントの削除に失敗しました: $error';
  }

  @override
  String get cancelButtonText => 'cancel';

  @override
  String get editButtonText => '編集';

  @override
  String get codeListButtonText => 'コード一覧';

  @override
  String get codeButtonText => 'コード';

  @override
  String codeListPageTitle(String eventName) {
    return '$eventName のコード一覧';
  }

  @override
  String get noCodesMessage => 'このイベントにはコードがありません。';

  @override
  String get codeNumberLabel => 'No.';

  @override
  String get codeLabel => 'コード';

  @override
  String get codeUsableLabel => '利用可能';

  @override
  String get codeUsedLabel => '使用済み';

  @override
  String get codeUserNameLabel => '使用ユーザー名 (任意)';

  @override
  String get codeUserNameHint => '使用された場合はユーザー名を入力';

  @override
  String codeSavedSuccess(String code) {
    return 'コード「$code」を保存しました。';
  }

  @override
  String codeSaveFailed(String error) {
    return 'コードの保存に失敗しました: $error';
  }

  @override
  String get copyCodeButtonText => 'コードをコピー';

  @override
  String get copiedCodeMessage => 'コードをクリップボードにコピーしました！';

  @override
  String codeUsagePageTitle(String eventName) {
    return '$eventName のコード利用';
  }

  @override
  String get noUsableCodesAvailable => 'このイベントには利用可能なコードがありません。';

  @override
  String qrCodeGenerationError(String error) {
    return 'QRコードの生成に失敗しました: $error';
  }

  @override
  String get markAsUsedButtonText => '使用済みにする';

  @override
  String get codeStatusUsed => 'ステータス: 使用済み';

  @override
  String get codeStatusAvailable => 'ステータス: 利用可能';

  @override
  String codeMarkedAsUsedSuccess(String code) {
    return 'コード「$code」を使用済みにしました。';
  }

  @override
  String codeMarkedAsUsedFailed(Object error) {
    return 'コードを使用済みにできませんでした: $error';
  }

  @override
  String get userListMenuText => 'ユーザー管理';

  @override
  String get addUserPageTitle => 'ユーザー追加';

  @override
  String get userListPageTitle => 'ユーザー一覧';

  @override
  String get userNameLabel => 'ユーザー名';

  @override
  String get userNameHint => 'ユーザー名を改行またはカンマで区切って入力してください。重複する名前はスキップされます。';

  @override
  String get userNameRequired => '少なくとも1つのユーザー名を入力してください。';

  @override
  String usersSavedSuccess(int count) {
    return '$count人のユーザーを保存しました！';
  }

  @override
  String usersSavedWithSkip(int count, String skippedNames) {
    return '$count人のユーザーを保存しました。スキップされた重複: $skippedNames';
  }

  @override
  String usersSkippedAll(String skippedNames) {
    return '入力されたユーザー名が全て重複していたためスキップされました: $skippedNames';
  }

  @override
  String get noUsersToSave => '保存するユーザーがいません。';

  @override
  String userSaveFailed(String error) {
    return 'ユーザーの保存に失敗しました: $error';
  }

  @override
  String get noUsersMessage => 'ユーザーが登録されていません。ユーザーを追加してください。';

  @override
  String get addUsersButtonTooltip => '新しいユーザーを追加';

  @override
  String deleteUserMessage(String userName) {
    return 'ユーザー「$userName」を削除してもよろしいですか？';
  }

  @override
  String userDeletedSuccess(String userName) {
    return 'ユーザー「$userName」を削除しました。';
  }

  @override
  String userDeleteFailed(Object error) {
    return 'ユーザーの削除に失敗しました: $error';
  }

  @override
  String loadCodeError(Object error) {
    return 'コードの読み込みに失敗しました: $error';
  }

  @override
  String loadEventFailed(Object error) {
    return 'Failed to load event and code counts: $error';
  }
}
